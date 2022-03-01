
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
    SELECT DISTINCT sid FROM Tutors 
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
        SELECT cid,year,semester,count(sid) AS sid_count 
        FROM Transcripts 
        GROUP BY cid,year,semester
    ),
    MAX_Enrollment AS (
        SELECT cid, max(sid_count) AS max_sid
        FROM Enrollment 
        GROUP BY cid
    )
    SELECT DISTINCT Enrollment.cid, year, semester 
    FROM Enrollment 
        LEFT JOIN MAX_Enrollment 
            USING (cid)
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
    SELECT DISTINCT cid, year, semester 
    FROM Offerings 
        LEFT JOIN Prof_count
            USING(cid,year,semester)
        LEFT JOIN Courses 
            USING (cid)
    WHERE semester = 2
        OR did = 'cs'
        OR counter = 1
;

/*
Find all the distinct courses (identified by cid) that satisfy both of the following conditions:
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
                USING(cid) 
        WHERE year = 2021 
        GROUP BY did
    )
    SELECT did, faculty,
        COALESCE(num_admitted, 0)   as num_admitted, 
        COALESCE(num_offering, 0)   as num_offering,
        COALESCE(num_enrollment, 0) as num_enrollment
    FROM Departments 
        LEFT JOIN Admission_num 
            USING(did)
        LEFT JOIN Offering_num
            USING(did)
        LEFT JOIN Enrollment_num
            USING(did)
;


/*
Find all (sid, year, semester) where 
the student identified by sid has enrolled only in courses offered by the 'cs' department 
    in the session specified by (year, semester). 
That is, sid did not enroll in any course that is offered by a department that is not 'cs' 
    in the session (year, semester).
Exclude (sid, year, semester) where sid did not enroll in any courses at all 
    in the session (year, semester).

// Transcripts group by session,sid check if any non-cs
select cid,sid,year,semester from Courses natural join Offerings natural join Transcripts group by sid,year,semester;
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
        SELECT sid, year, semester, count(*) as mod_count 
        FROM Transcripts 
        GROUP BY sid, year, semester
    ), 
    Topped_mods_count as (
        SELECT sid, year, semester, count(*) as mod_count 
        FROM Transcripts 
            INNER JOIN Top_marks
                USING(cid, year, semester, marks)
        GROUP BY sid, year, semester
    )
    SELECT sid, year, semester 
    FROM Taken_mods_count 
        INNER JOIN Topped_mods_count
            USING (sid, year, semester, mod_count)
;

/*
A professor is looking for a team of four students to help tutor a course in session (2022,2). 
The team of tutors must meet all the following requirements:

    Each of the tutors must be admitted in 2019 or later.
    Each of the tutors must have tutored at least a total of 10 hours in the session (2022,1).

    At least two of the tutors must have enrolled in the courses 'cs1' and 'cs2'.
    At least two of the tutors must have enrolled in the course 'cs3' or 'cs4'.

Find all teams (sid1, sid2, sid3, sid4) that meet the above requirements where sid1, sid2, sid3, and sid4 are student identifiers such that sid1 < sid2 < sid3 < sid4.

*/

create or replace view v10 (sid1, sid2, sid3, sid4) as 

with eligible as (
    select sid
    from Tutors 
        left join Students 
            using(sid)
    where Students.year >=2019
        and Tutors.semester = 1 
        and Tutors.year = 2022 
    group by sid 
    having sum(hours) >= 10
), 
mods_taken as (
    select sid, 
        bool_or(cid='cs1') as cs1, 
        bool_or(cid='cs2') as cs2, 
        bool_or(cid='cs3') as cs3, 
        bool_or(cid='cs4') as cs4
    from Transcripts
    group by sid
), 
mods2 as (
    select sid,
        case when (cs1 and cs2) then 1 else 0 end as cond1,
        case when (cs3 or cs4) then 1 else 0 end as cond2
    from eligible 
        left join mods_taken 
            using(sid)
)
select distinct m1.sid, m2.sid, m3.sid, m4.sid
from mods2 as m1
    cross join mods2 as m2 
    cross join mods2 as m3 
    cross join mods2 as m4
where m1.sid < m2.sid and m2.sid < m3.sid and m3.sid < m4.sid
and m1.cond1 + m2.cond1 + m3.cond1 + m4.cond1 >=2
and m1.cond2 + m2.cond2 + m3.cond2 + m4.cond2 >=2
;

