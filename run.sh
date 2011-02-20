#!/bin/sh
cat $1 | ./Parser | awk --lint -f run.awk
