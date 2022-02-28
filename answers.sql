
/* cs2102 assignment 1 */

drop view if exists v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 cascade;

create or replace  view v1 (sid,cid) as 
select 'sid','cid'  /* replace this with your answer */
;

create or replace view v2 (sid) as 
select 'sid' /* replace this with your answer */
;

create or replace view v3 (cid, year, semester) as 
select 'cid',1980,1 /* replace this with your answer */
;

create or replace view v4 (cid, year, semester) as 
select 'cid',1980,1 /* replace this with your answer */
;

create or replace view v5 (cid) as 
select 'cid' /* replace this with your answer */
;

create or replace view v6 (cid, year, semester, cost) as
select 'cid',1980,1,0 /* replace this with your answer */
;

create or replace view v7 (did, faculty, num_admitted, num_offering, total_enrollment) as 
select 'did','faculty',0,0,0 /* replace this with your answer */
;


create or replace view v8 (sid, year, semester) as
select 'sid',1980,1 /* replace this with your answer */
;

create or replace view v9 (sid, year, semester) as 
select 'sid',1980,1 /* replace this with your answer */
;

create or replace view v10 (sid1, sid2, sid3, sid4) as 
select 'sid1', 'sid2', 'sid3', 'sid4' /* replace this with your answer */
;

