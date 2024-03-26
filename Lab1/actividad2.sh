#!/bin/bash
date=$(date '+%Y%m_%d_%H_%M')
apt install stress
taskset -c 0 stress -c 1 &
last=$!
taskset -c 1 stress -c 1 &
last_2=$!
echo -e "$date"'\t'"$last"'\t'"$last2" >>"log_2.txt"
mv log_2.txt .log_2.txt
