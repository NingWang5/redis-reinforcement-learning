#! /bin/bash


# ssh 10.67.124.182 -T 'redis-benchmark -h 10.10.20.2 -p 6001 -t set -r 10000 -n 100000  -d 5000000 -q  --csv' > test1.csv  &
# ssh 10.67.124.182 -T 'redis-benchmark -h 10.10.20.2 -p 6002 -t set -r 10000 -n 100000  -d 5000000 -q  --csv' > test2.csv  &
# ssh 10.67.124.182 -T 'redis-benchmark -h 10.10.20.2 -p 6003 -t set -r 10000 -n 10uli0000  -d 5000000 -q  --csv' > test3.csv  &
# ssh 10.67.124.182 -T 'redis-benchmark -h 10.10.20.2 -p 6004 -t set -r 10000 -n 100000  -d 5000000 -q  --csv' > test4.csv  &

name=$1
port=6000
ip=10.10.20.3
# mkdir -p /home/redis-ning/result/$name

for((i=0; i<192; i++));do

    # ssh $ip -T redis-benchmark -h 10.10.20.2 -p $port -t set -r 300000 -n 2000000 -d 2048 -c 200 -P 30 -q --csv > /home/redis/result/$name/result-$i.csv &
    ssh $ip -T redis-benchmark -h 10.10.20.2 -p $port -t set -r 600000 -n 2000000 -d 1024 -c 200 -P 30 -q & #--csv > /home/redis/result/$name/result-$i.csv &

    port=`expr $port + 1` 
    sleep 0.1
done