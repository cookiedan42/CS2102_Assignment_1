
/* cs2102 assignment 1 */

drop view if exists v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 cascade;

/*
    Find all distinct student-course pairs (sid, cid) where 
    sid has tutored cid.
    sid has not enrolled in cid 
*/
create or replace  view v1 (sid,cid) as 
    SELECT DISTINCT sid, cid
    FROM Tutors 

    EXCEPT

    SELECT DISTINCT sid, cid 
    FROM Transcripts
;


/*
    Find all distinct students (identified by sid) 
    who have tutored at least two different courses (identified by cid) 
    in the same session (identified by (year, semester)).
*/
create or replace view v2 (sid) as 
    SELECT DISTINCT sid 
    FROM Tutors 
    GROUP BY year, semester, sid
    HAVING count(*) >= 2
;


/*
    For each course cid, 
    find all its sessions (year, semester) 
    which have the largest number of enrolled students for that course 
    among all the offerings for that course. 
    Exclude courses that have no enrollment at all.

    Enrollment is count of students taking each session
    max_enrollment is max value of each CID
    then select from those properly

    all transcripted mods are representedin enrollment and max_enrollment
    natural join takes cid as key so we g
    */

create or replace view v3 (cid, year, semester) as 
    WITH 
    Enrollment AS (
        SELECT cid, year, semester,count(sid) AS sid_count 
        FROM Transcripts 
        GROUP BY cid, year, semester
    ),
    MAX_Enrollment AS (
        SELECT cid, max(sid_count) AS max_sid
        FROM Enrollment 
        GROUP BY cid
    )
    SELECT DISTINCT Enrollment.cid, year, semester 
    FROM Enrollment 
        LEFT JOIN MAX_Enrollment 
            ON Enrollment.cid = MAX_Enrollment.cid
    WHERE Enrollment.sid_count = MAX_Enrollment.max_sid
;


/*
Find all distinct course offerings O that satisfy 
at least one of the following conditions:
    O was offered by the 'cs' department, or    --> courses.did = cs
    O was offered in the second semester (i.e., semester = 2). semester = 2 anywhere
    O was taught by exactly one professor, or   --> teaches group by session count = 1

    Ensures all offerings are presented
*/
create or replace view v4 (cid, year, semester) as 
    with 
    Prof_count as (
        SELECT cid, year, semester, count(*) as counter
        FROM Teaches 
        GROUP BY cid, year, semester
    )
    SELECT DISTINCT Offerings.cid, Offerings.year, Offerings.semester 
    FROM Offerings 
        LEFT JOIN Courses 
            ON Offerings.cid = Courses.cid
        LEFT JOIN Prof_count
            ON  Offerings.cid = Prof_count.cid
            AND Offerings.year = Prof_count.year
            AND Offerings.semester = Prof_count.semester
    WHERE Offerings.semester = 2
        OR Courses.did = 'cs'
        OR Prof_count.counter = 1
;


/*
Find all the distinct courses (identified by cid) 
that satisfy both of the following conditions:
    cid is available from the 'cs' department, and
    the student 'alice' has not enrolled in cid.
*/


create or replace view v5 (cid) as 
    SELECT DISTINCT cid 
    FROM Courses 
    WHERE did='cs'

    EXCEPT

    SElECT cid 
    FROM Transcripts 
    WHERE sid = 'alice'
    ;

/*
Assume that each course offering has a cost that is computed by the 
sum of the cost paid to each professor teaching 
that course offering and the cost paid to each student tutoring that course offering. 
Each professor and tutor is paid $100 and $50, respectively, 
for each hour of teaching/tutoring a course offering. 

Find the sum of tas
find the sum of profs
use union all to ensure no drop repeats
*/
create or replace view v6 (cid, year, semester, cost) as
    with 
    Costs as (
        SELECT cid, year, semester, hours*50  as pay 
        FROM Tutors
        
        UNION ALL
        
        SELECT cid, year, semester, hours*100 as pay 
        FROM Teaches
    )
    SELECT cid, year, semester, SUM(pay) as cost
    FROM Costs 
    GROUP BY cid, year, semester
;


/*
For each department D, find the following information for D:
    the faculty of D,
    the number of students who got admitted to D in the year 2021, and
    the total number of course offerings from D in the year 2021,
    the total number of student enrollments in the course offerings from D in the year 2021.
*/
/*
for each did
    select faculty from departments
    sum of students with this home fac
    sum of all course enrollments
*/
create or replace view v7 (did, faculty, num_admitted, num_offering, total_enrollment) as 

    with 
    Admission_num as( 
        SELECT did, count(*) as num_admitted 
        FROM Students  
        WHERE year = 2021 
        GROUP BY did
    ),
    Offering_num as( 
        SELECT did, count(*) as num_offering 
        FROM Offerings 
            LEFT JOIN Courses
                USING(cid) 
        WHERE year = 2021 
        GROUP BY did
    ),
    Enrollment_num as( 
        SELECT did, count(*) as num_enrollment 
        FROM Transcripts 
            LEFT JOIN Courses
                ON Transcripts.cid = Courses.cid 
        WHERE year = 2021 
        GROUP BY did
    )
    SELECT DISTINCT Departments.did, faculty,
        COALESCE(num_admitted  , 0) as num_admitted, 
        COALESCE(num_offering  , 0) as num_offering,
        COALESCE(num_enrollment, 0) as num_enrollment
    FROM Departments 
        LEFT JOIN Admission_num
            ON Departments.did = Admission_num.did
        LEFT JOIN  Offering_num
            ON Departments.did = Offering_num.did
        LEFT JOIN Enrollment_num
            ON Departments.did = Enrollment_num.did
;


/*
Find all (sid, year, semester) where 
the student identified by sid has enrolled 
only in courses offered by the 'cs' department 
    in the session specified by (year, semester). 

That is, sid did not enroll in any course that 
is offered by a department that is not 'cs' 
    in the session (year, semester).

Exclude (sid, year, semester) where sid did not enroll 
in any courses at all 
    in the session (year, semester).

// if enroll in nothing, won't appear in Transcripts
All enroll - enroll in non-cs
*/

create or replace view v8 (sid, year, semester) as

    SELECT DISTINCT sid, year, semester
    FROM Transcripts

    EXCEPT

    SELECT DISTINCT sid, year, semester 
    FROM Transcripts 
        LEFT JOIN courses
            USING(cid) 
    WHERE did <> 'cs'
;

/*
A student (identified by sid) is said to be a top student in a session (year, semester) 
if for each course (identified by cid) that is enrolled by sid in session (year, semester), 
sid obtained the highest marks among all the students who were enrolled in cid in that session.

Find all distinct (sid, year, semester) 
where sid has enrolled in at least one course in session (year, semester) 
and sid is a top student in session (year, semester).

if a student tops all classes they took in a session, then they are top student
// step 1 get higest score for each
// step 2 for each student compare
*/
create or replace view v9 (sid, year, semester) as 

    with 
    Top_marks as(
        SELECT cid, year, semester, max(marks) as marks
        FROM Transcripts 
        GROUP BY cid, year, semester
    ), 
    Taken_mods_count as (
        SELECT sid, year, semester, count(*) as mod_taken_counter
        FROM Transcripts 
        GROUP BY sid, year, semester
    ), 
    Topped_mods_count as (
        SELECT 
            Transcripts.sid, 
            Transcripts.year, 
            Transcripts.semester, 
            count(*) as mod_topped_counter
        FROM Transcripts 
            INNER JOIN Top_marks
                ON Transcripts.cid = Top_marks.cid
                AND Transcripts.year = Top_marks.year
                AND Transcripts.semester = Top_marks.semester
                AND Transcripts.marks = Top_marks.marks
        GROUP BY
            Transcripts.sid, 
            Transcripts.year, 
            Transcripts.semester
    )
    SELECT DISTINCT
        Taken_mods_count.sid, 
        Taken_mods_count.year, 
        Taken_mods_count.semester 
    FROM Taken_mods_count 
        INNER JOIN Topped_mods_count
            ON Taken_mods_count.sid = Topped_mods_count.sid
            AND Taken_mods_count.year = Topped_mods_count.year
            AND Taken_mods_count.semester = Topped_mods_count.semester
            AND Taken_mods_count.mod_taken_counter = Topped_mods_count.mod_topped_counter
;


/*
A professor is looking for a team of four students to help tutor a course in session (2022,2). 
The team of tutors must meet all the following requirements:

    Each of the tutors must be admitted in 2019 or later.
    Each of the tutors must have tutored at least a total of 10 hours in the session (2022,1).

    At least two of the tutors must have enrolled in the courses 'cs1' and 'cs2'.
    At least two of the tutors must have enrolled in the course 'cs3' or 'cs4'.

Find all teams (sid1, sid2, sid3, sid4) that meet the above requirements where sid1, sid2, sid3, and sid4 are student identifiers such that sid1 < sid2 < sid3 < sid4.

does splitting up the cross join help performance? probable

*/

create or replace view v10 (sid1, sid2, sid3, sid4) as 

with 
Eligible_Hours as (
    select Tutors.sid
    from Tutors 
        left join Students 
            on Tutors.sid = Students.sid
    where Students.year >= 2019
        and Tutors.semester = 1 
        and Tutors.year = 2022 
    group by Tutors.sid 
    having sum(hours) >= 10
), 
Cond_12 as (
    select sid, 1 as cond12
    from Transcripts
    where cid = 'cs1'
        or cid = 'cs2'
    group by sid
    having count(distinct cid) >= 2
),
Cond_34 as (
    select sid, 1 as cond34
    from Transcripts
    where cid = 'cs3'
        or cid = 'cs4'
    group by sid
    having count(distinct cid) >= 1
),

mods_1 as (
    select Eligible_Hours.sid, 
        COALESCE(cond12,0) as cond12, 
        COALESCE(cond34,0) as cond34
    from Eligible_Hours
        left join Cond_12
            ON Eligible_Hours.sid = Cond_12.sid
        left join Cond_34
            ON Eligible_Hours.sid = Cond_34.sid
),
mods_2 as (
    select distinct 
        m1.sid as sid1, m2.sid as sid2,
        m1.cond12 + m2.cond12 as cond12,
        m1.cond34 + m2.cond34 as cond34
    from mods_1 as m1 cross join mods_1 as m2 
    where m1.sid < m2.sid
)
select distinct m12.sid1, m12.sid2, m34.sid1, m34.sid2
from mods_2 as m12 cross join mods_2 as m34

where m12.sid2 < m34.sid1
and m12.cond12 + m34.cond12 >=2
and m12.cond34 + m34.cond34 >=2
;
