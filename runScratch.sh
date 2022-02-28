# load the state of the test case
BASE="
create database assign1;
\c assign1
\i init.sql
\i ./load-db/load-db2.sql
\i answers.sql

SELECT * FROM v10;
"

printf "$BASE" | psql
