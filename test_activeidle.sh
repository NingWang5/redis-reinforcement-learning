#!/bin/bash
total_sockets=$(lscpu | awk '/Socket\(s\):/{print $NF}')
cores_per_socket=$(lscpu | awk '/Core\(s\) per socket:/{print $NF}')
utilization_point=$1
uncore_freq=$2
for ((socket=0;socket<total_sockets;socket++)) ; do
core=$((socket * cores_per_socket))
# Read old settings
echo "Setting for core $core from socket $socket"
wrmsr -p $core 0xb0 0x80000694
echo "Prev Value $(rdmsr -p $core 0xb1)"
# Write new settings
wrmsr -p $core 0xb1 "0x${utilization_point}${uncore_freq}"
wrmsr -p $core 0xb0 0x81000695
# Read back
wrmsr -p $core 0xb0 0x80000694
echo "New value $(rdmsr -p $core 0xb1)"
done
