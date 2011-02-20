#!/bin/sh
cat $1 | ./Parser | awk -f run.awk
