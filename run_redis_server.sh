#! /bin/bash


port=7000
cpuset="40-79,120-159"


for ((i=0; i<48; i++));do
    echo "start redis-server prot $port cpuset $cpuset"
    taskset -ac $cpuset redis-server /etc/redis.conf --maxmemory 5G --daemonize yes --port $port --protected-mode no --save ""
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