#! /bin/bash

name=$1
port=7000
ip=10.67.124.182
mkdir -p /home/redis-reinforcement-learning/result/$name

for((i=0; i<48; i++));do
    ssh $ip -T redis-benchmark -h 10.67.124.61 -p $port -t set -r 100000 -n 10000  -d 10000000 -q  --csv > /home/redis-reinforcement-learning//result/$name/result-$i.csv  &
    port=`expr $port + 1`
    sleep 0.1
done