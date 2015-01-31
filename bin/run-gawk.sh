#!/bin/sh
eval $(dirname $0)/run.sh '"gawk --lint --posix --optimize"' '"$@"'
