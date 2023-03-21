#! /bin/bash

name=$1
port=6000
ip=10.10.20.3
mkdir -p /home/redis-ning/result/$name

for((i=0; i<16; i++));do
    if [ $i != 15 ];then
        ssh $ip -T redis-benchmark -h 10.67.124.61 -p $port -t set -r 100000 -n 10000  -d 10000000 -q  --csv > /home/redis-ning/result/$name/result-$i.csv  &
        port=`expr $port + 1`
    else
        ssh $ip -T redis-benchmark -h 10.67.124.61 -p $port -t set -r 100000 -n 10000  -d 10000000 -q  --csv > /home/redis-ning/result/$name/result-$i.csv  
   fi 
done