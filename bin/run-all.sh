#!/bin/sh
eval $(dirname $0)/run-gawk.sh '"$@"'
eval $(dirname $0)/run-mawk.sh '"$@"'
eval $(dirname $0)/run-nawk.sh '"$@"'
eval $(dirname $0)/run-bawk.sh '"$@"'
