#! /bin/bash


port=6000
# cpuset1=48
# cpuset2=50
cpuset=0-191



for ((i=0; i<192; i++));do

    echo "start redis-server prot $port cpuset $cpuset"
    taskset -ac $cpuset redis-server /etc/redis.conf --daemonize yes --port $port --maxmemory 2000m --maxmemory-policy allkeys-lru --protected-mode no --save ""

    port=`expr $port + 1`
done

# port=6002
# cpuset="60-67"
# echo "start redis-server prot $port cpuset $cpuset"
# taskset -ac $cpuset redis-server /etc/redis.conf --daemonize yes --port $port --protected-mode no --save ""

# port=6003
# cpuset="70-77"
# echo "start redis-server prot $port cpuset $cpuset"
# taskset -ac $cpuset redis-server /etc/redis.conf --daemonize yes --port $port --protected-mode no --save ""

# port=6004
# cpuset="80-87"
# echo "start redis-server prot $port cpuset $cpuset"
# taskset -ac $cpuset redis-server /etc/redis.conf --daemonize yes --port $port --protected-mode no --save ""
