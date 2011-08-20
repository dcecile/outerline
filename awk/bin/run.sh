#!/bin/sh

# Grab "awk" (plus arguments)
awk=$1
shift

# Grab the target program
prog=$1
shift

# Find the preprocessor
pp=$(dirname $0)
pp="$pp/pp.awk"

# Run the preprocessor
expanded=$($awk -f $pp $prog)

# Run the program
eval echo '"[$awk]"' > /dev/stderr
eval $awk '"$expanded"' '"$@"'
