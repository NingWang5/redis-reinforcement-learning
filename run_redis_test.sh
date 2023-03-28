#! /bin/bash

AIM_SCRIPT=/home/test_activeidle.sh

redis_benchamrk_script=/home/redis-ning/run_redis_benchmark.sh

LOGFILE="/home/redis-ning/result/result.txt"


function set_aim(){
    $AIM_SCRIPT $1 $2
}

function reset_aim(){
    $AIM_SCRIPT 00 0E
}


function set_cfreq(){
    cpupower -c all frequency-set -u $1 > /dev/null 2>&1
}

function reset_cfreq(){
    cpupower -c all frequency-set -u 3.4ghz > /dev/null 2>&1
}

function set_ufreq(){
    wrmsr -a 0x620 0x08$1 2>&1
}

function reset_ufreq(){
    wrmsr -a 0x620 0x0819 2>&1
}

function kill_redis(){
    pkill redis
}

function kill_redis_benchmark(){
    ssh 10.67.124.182 -T 'pkill redis-benchmark'
}

function run_redis_benchmark(){
    bash $redis_benchamrk_script $@
}

function create_redis(){
    bash /home/redis/run_redis_server.sh
}

function run_test(){
    UP=$1
    UF=$2
    CF_MAX=$3
    UF_MAX=$4
    name=$5

    # set_aim $UP $UF

    # set_cfreq $CF_MAX

    # set_ufreq $UF_MAX

    # create_redis

    run_redis_benchmark $UP $UF $CF_MAX $UF_MAX $name

    # reset_aim

    # reset_cfreq

    # reset_ufreq

    # kill_redis

    # kill_redis_benchmark
}

UP_SET=(04 08)
UF_SET=(08 0a 0c 0e 10 12 14 16 18 19)
times=1

# echo "######TEST START########" >> $LOGFILE

while true
do
    # Test OPM
    run_test 06 0E 3.8GHZ 16 OPM #06 0E 3.8GHZ 16 OPM

    sleep 10
done

# while true
# do
#     UP=08
#     UF=08

#     run_test $UP $UF 3.8GHZ 16 IEM-$UP-$UF
#     sleep 10

#     if [ `cat $LOGFILE | grep IEM-$UP-$UF | wc -l` == $times ]; then
#         break
#     fi
# done

# echo "######TEST END########" >> $LOGFILE


