# load the state of the test case
psql
create database assign1;
\c assign1
\i ./load-db/load-db1.sql
select * from students;

