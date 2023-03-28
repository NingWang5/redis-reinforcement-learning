# ssh 10.10.20.3 -T redis-cli -h 10.10.20.2 -p 6000 info stats | grep instantaneous_ops_per_sec
ps -ef | grep 'pcm' | grep -v grep | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'python' | grep -v grep | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'sar' | grep -v grep | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'observe' | grep -v grep | awk '{print $2}' | xargs -r kill -9
ssh 10.67.124.182 -T ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9
