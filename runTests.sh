#!/usr/bin/env bash
# psql < ./debug.in
BASE="
create database assign1;
\c assign1
\i init.sql
\i answers.sql
"

if [ $# -ne 1 ] ; then
    for ((i = 1 ; i <= 10 ; i++)); do
        BASE="$BASE""select test$i();\n"
    done
elif [ $1 -gt 10 ]; then
    for ((i = 1 ; i <= 10 ; i++)); do
        BASE="$BASE""select test$i();\n"
    done
elif [ $1 -lt 1 ]; then
    for ((i = 1 ; i <= 10 ; i++)); do
        BASE="$BASE""select test$i();\n"
    done
else
    # echo "one arg"
    BASE="$BASE\nselect test$1();\n"
fi

printf "$BASE" | psql
