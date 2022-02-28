# load detailed version of test cases

BASE="
create database assign1;
\c assign1
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

BASE="$BASE""\i ./debug/debug""$TARGET"".sql\n"
printf "$BASE" | psql