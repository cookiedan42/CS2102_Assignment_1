#!/usr/bin/env bash
# psql < ./debug.in
BASE="
create database assign1;
\c assign1
\i ./myTests/init.sql
\i answers.sql
"

TARGET=1;

if [ $# -ne 1 ] ; then
    TARGET=1
elif [ $1 -gt 10 ]; then
    TARGET=1
elif [ $1 -lt 1 ]; then
    TARGET=1
else
    TARGET=$1
fi

BASE="$BASE""\i ./myTests/test""$TARGET"".sql\n"
BASE="$BASE""\i ./myTests/checkAns.sql\n"

BASE="$BASE""select * from zzSummary;\n "

printf "$BASE" | psql
