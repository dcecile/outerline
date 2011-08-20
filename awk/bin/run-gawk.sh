#!/bin/sh
eval $(dirname $0)/run.sh '"gawk --lint=fatal --posix --optimize"' '"$@"'
