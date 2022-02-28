
/* cs2102 assignment 1 */

drop view if exists v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 cascade;

/*
    Find all distinct student-course pairs (sid, cid) where 
    sid has not enrolled in cid 
    but sid has tutored cid.
*/
create or replace  view v1 (sid,cid) as 
    select distinct sid, cid from Tutors 
    except 
    select distinct sid, cid from Transcripts
;


/*
    Find all distinct students (identified by sid) 
    who have tutored at least two different courses (identified by cid) 
    in the same session (identified by (year, semester)).
*/
create or replace view v2 (sid) as 
    select distinct sid from Tutors 
    group by year,semester,sid
    having count(cid) > 1
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
    */

create or replace view v3 (cid, year, semester) as 
    WITH Enrollment AS (
        select cid,year,semester,count(sid) as sid_count 
        from Transcripts 
        group by cid,year,semester
    ),MAX_Enrollment AS (
        SELECT cid, max(sid_count) as max_sid
        from Enrollment 
        group by cid
    )
    select distinct Enrollment.cid, year, semester from Enrollment inner join MAX_Enrollment 
        on Enrollment.sid_count = MAX_Enrollment.max_sid
        and Enrollment.cid = MAX_Enrollment.cid
;


/*
Find all distinct course offerings O that satisfy 
at least one of the following conditions:
    O was offered by the 'cs' department, or    --> courses.did = cs
    O was taught by exactly one professor, or   --> teaches group by pid count = 1
    O was offered in the second semester (i.e., semester = 2). semester = 2 anywhere
*/
/*
current version checks that one prof teaching since start
ask if its this or one prof at any time in history
*/
create or replace view v4 (cid, year, semester) as 
    with d as (
        select distinct cid, pid  
        from Teaches group by cid,pid
    ), e as (
        select cid,count(*) as counter 
        from d group by cid 
    )
    select distinct cid, year, semester from Offerings NATURAL JOIN Courses NATURAL JOIN e
    where semester=2 or did='cs' or counter =1
;

/*
Find all the distinct courses (identified by cid) that satisfy both of the following conditions:
    cid is available from the 'cs' department, and
    the student 'alice' has not enrolled in cid.
*/
/*
asking for test cs5 but does not exist?
*/

create or replace view v5 (cid) as 
    select distinct cid from Transcripts NATURAL JOIN Courses 
    where did='cs'
    and cid NOT IN(
        select cid from Transcripts
        where sid = 'alice'
    )
    ;

/*
Assume that each course offering has a cost that is computed by the 
sum of the cost paid to each professor teaching 
that course offering and the cost paid to each student tutoring that course offering. 
Each professor and tutor is paid $100 and $50, respectively, 
for each hour of teaching/tutoring a course offering. 

Find the cost for each course offering.
*/
create or replace view v6 (cid, year, semester, cost) as

    with costs as (
        select sid as id, cid,year, semester, hours*50 as pay from Tutors
        UNION
        select pid as id, cid,year, semester, hours*100 as pay from teaches
    )
    select cid,year,semester,sum(pay) from costs 
    group by cid,year,semester
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

a as( select did,count(*) as aa from Students group by did),
b as( select did,count(*) as bb from Courses group by did),
c as( select did,count(*) as cc  from Transcripts Natural join Courses group by did)

*/
create or replace view v7 (did, faculty, num_admitted, num_offering, total_enrollment) as 

    with 
    a as( 
        select did,count(*) as aa from Students  
        where year=2021 group by did),
    b as( 
        select did,count(*) as bb from Offerings natural join Courses 
        where year=2021 group by did),
    c as( 
        select did,count(*) as cc from Transcripts Natural join Courses 
        where year = 2021 group by did)

    select Departments.did,faculty,
        COALESCE(aa,0) as num_admitted, 
        COALESCE(bb,0) as num_offering,
        COALESCE(cc,0) as num_offering
    from Departments 
    full outer join a on Departments.did = a.did
    full outer join b on Departments.did = b.did
    full outer join c on Departments.did = c.did
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

with a as (
    select did,cid,sid,year,semester from Courses natural join Offerings natural join Transcripts
)
select sid, year, semester from a group by sid, year, semester 
except
select sid,year,semester from a where did <> 'cs'
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

/*
with top_scores as(
    select cid, year,semester,max(marks) as max_mark  from Transcripts group by cid,year,semester
), non_tops as (
    select sid,year,semester from Transcripts natural join top_scores
    where marks <> max_mark
)
select distinct sid,year,semester from Transcripts
except 
select * from non_tops
;
*/

create or replace view v9 (sid, year, semester) as 


with top_scores as(
    select cid, year,semester,max(marks) as max_mark  from Transcripts 
    group by cid,year,semester
), workload as (
    select sid, year, semester, count(*) as wl from Transcripts 
    group by sid, year,semester
)
, top_scored as (
    select sid, year, semester, count(*) as wl from Transcripts natural join top_scores
    where marks = max_mark group by sid,year,semester
)
select sid, year, semester from workload natural join top_scored
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
-- select 'sid1', 'sid2', 'sid3', 'sid4'; /* replace this with your answer */
with eligible as (
    select Tutors.sid
    from Tutors left join Students on Tutors.sid = Students.sid
    where Students.year >=2019
    -- and semester = 1 and Tutors.year=2022 
    group by Tutors.sid having sum(hours) >= 10
), mods_taken as (
    select sid, 
    (select count(*)>0 from Transcripts as t2 where cid = 'cs1' and t1.sid = t2.sid) as cs1,
    (select count(*)>0 from Transcripts as t2 where cid = 'cs2' and t1.sid = t2.sid) as cs2,
    (select count(*)>0 from Transcripts as t2 where cid = 'cs3' and t1.sid = t2.sid) as cs3,
    (select count(*)>0 from Transcripts as t2 where cid = 'cs4' and t1.sid = t2.sid) as cs4
 from Transcripts as t1 group by sid
), mods2 as (
    select eligible.sid,
    case when (cs1 and cs2) then 1 else 0 end as cond1,
    case when (cs3 or cs4) then 1 else 0 end as cond2
from eligible left join mods_taken on eligible.sid = mods_taken.sid
)
select m1.sid, m2.sid, m3.sid, m4.sid
from mods2 as m1 cross join mods2 as m2 cross join mods2 as m3 cross join mods2 as m4
where m1.sid < m2.sid and m2.sid < m3.sid and m3.sid < m4.sid
and m1.cond1 + m2.cond1 + m3.cond1 + m4.cond1 >=2
and m1.cond2 + m2.cond2 + m3.cond2 + m4.cond2 >=2
;

