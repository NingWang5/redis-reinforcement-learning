#!/bin/bash

ulimit -n 1000000

LOGFILE="/home/redis-reinforcement-learning/result/result.txt"

UP=${1:-00}
UF=${2:-0E}
CFMAX=${3:-3.8GHZ}
UFMAX=${4:-19}
name=$5

echo $LOGFILE
SERVER_IP=10.67.124.61
# CLIENT_IP=10.67.124.182

#create redis-server
bash run_redis_server.sh

START_TIME=`date +%s`
START_TIME1=`date +%D-%H:%M:%S`


bash run_test.sh $name


while true
do
    if [ `ps aux | grep redis | wc -l` -le 2 ];
    then
        break
    fi
done



END_TIME=`date +%s`
END_TIME1=`date +%D-%H:%M:%S`
TIME=`expr $END_TIME - $START_TIME`
echo "TIME: $TIME"

#kill redis-benchmark
ssh 10.67.124.182 -T 'pkill redis-benchmark'

#kill redis-server
pkill redis-server


Performance=`cat /home/redis-reinforcement-learning//result/$name/result-* | awk -F ',|"' '{sum +=$5} END {print sum/NR}'`

CPU1Energy=`promtool query range --start=$START_TIME --end=$END_TIME --step=1s http://$SERVER_IP:9090 'collectd_pwrmetric_power_watt_gauge{pwrmetric_power_watt="pkg01"}' | grep -v pwrmetric | awk '{sum += $1} END {print sum}'`
AvgCPU1Power=`echo "scale=2; $CPU1Energy/$TIME" | bc`
Perf_per_watt=`echo "scale=2; $Performance/$AvgCPU1Power*100" | bc`

echo -e "Testname\tUP\tUF\tCF_MAX\tUF_MAX\tCPU1Energy\tAvgCPU1Power\tPerformance\tPerf_per_watt" >> $LOGFILE
echo -e "$name\t$UP\t$UF\t$CFMAX\t$UFMAX\t$CPU1Energy\t$AvgCPU1Power\t$Performance\t$Perf_per_watt" >> $LOGFILE
