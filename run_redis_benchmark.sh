#!/bin/bash

ulimit -n 1000000

LOGFILE="/home/redis-ning/result/result.txt"

UP=${1:-00}
UF=${2:-0E}
CFMAX=${3:-3.8GHZ}
UFMAX=${4:-19}
name=$5

# echo $LOGFILE
SERVER_IP=10.67.124.196
# CLIENT_IP=10.67.124.182

#create redis-server
bash run_redis_server.sh

START_TIME=`date +%s`
START_TIME1=`date +%D-%H:%M:%S`


bash run_test.sh $name

while true
do
    if [ `ssh 10.67.124.182 -T "ps aux | grep redis-benchmark | wc -l"` == 2 ]; then
        break
    fi
done

END_TIME=`date +%s`
END_TIME1=`date +%D-%H:%M:%S`
TIME=`expr $END_TIME - $START_TIME`
echo "TIME: $TIME"

#kill redis-benchmark
ssh 10.67.124.182 -T ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9

#kill redis-server
ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9

# if [ 16 != `cat /home/redis/result/OPM/result-* | wc -l` ]; then
#     exit 0
# fi

# Performance=`cat /home/redis/result/$name/result-* | awk -F ',|"' '{sum +=$5} END {print sum/NR}'`

# CPU1Energy=`promtool query range --start=$START_TIME --end=$END_TIME --step=1s http://$SERVER_IP:9090 'collectd_pwrmetric_power_watt_gauge{pwrmetric_power_watt="pkg01"}' | grep -v pwrmetric | awk '{sum += $1} END {print sum}'`
# AvgCPU1Power=`echo "scale=2; $CPU1Energy/$TIME" | bc`
# Perf_per_watt=`echo "scale=2; $Performance/$AvgCPU1Power*100" | bc`

# echo "CPU1Energy: $CPU1Energy  AvgCPU1Power: $AvgCPU1Power"
# echo -e "START_TIME \tEND_TIME \tTIME" >> $LOGFILE
# echo -e "$START_TIME \t$END_TIME \t$TIME" >> $LOGFILE
# echo -e "START_TIME \tEND_TIME" >> $LOGFILE
# echo -e "$START_TIME1 \t$END_TIME1" >> $LOGFILE
# echo -e "Testname\tUP \tUF \tCF_MAX \tUF_MAX   \tCPU1Energy \tAvgCPU1Power \tPerformance \tPerf_per_watt" >> $LOGFILE
# echo -e "$name \t$UP \t$UF \t$CFMAX \t$UFMAX  \t$CPU1Energy \t$AvgCPU1Power \t$Performance \t$Perf_per_watt" >> $LOGFILE
# echo -e "========================================================================" >> $LOGFILE

# echo "Test Done"

# echo -e "Testname\tUP\tUF\tCF_MAX\tUF_MAX\tCPU1Energy\tAvgCPU1Power\tPerformance\tPerf_per_watt\tTIME" >> $LOGFILE
# echo -e "$name\t$UP\t$UF\t$CFMAX\t$UFMAX\t$CPU1Energy\t$AvgCPU1Power\t$Performance\t$Perf_per_watt\t$TIME" >> $LOGFILE

# echo "Test Done"
