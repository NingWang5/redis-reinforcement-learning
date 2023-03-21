# energy
# promtool query range --start=`date +%s` --end=$[`date +%s`+10] --step=1s http://10.67.124.196:9090 'collectd_pwrmetric_power_watt_gauge{pwrmetric_power_watt="pkg01"}' | grep -v pwrmetric | awk '{sum += $1} END {print sum}'

# while true
# do
#     cat /proc/cpuinfo | grep processor | tail -n +49 | head -n 48 > observation/cpu_frequency
# done

# memory throughput
pcm-mem 0.1 -csv=observation/memory_throughput.csv &

# cpu usage
sar -P 48-95 1 | grep -v CPU > observation/cpu_usage &

# memory usage
sar -r 1 > observation/memory_usage &

# network bandwidth ens43f0
sar -n DEV 1 > observation/network_bandwidth &
