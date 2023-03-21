import subprocess
import os
import io
import time
import numpy as np


Action = [['01', '13'],
          ['02', '12'],
          ['03', '11'],
          ['04', '10'],
          ['05', '0f'],
          ['06', '0e'],
          ['07', '0d'],
          ['08', '0c'],
          ['09', '0b'],
          ['10', '0a']]

MAX_ENERGY, MAX_PERF, MAX_THROUGHPUT, MAX_BANDWIDTH = 310, 80, 130000, 100000

class ENV():
    def __init__(self):
        subprocess.Popen('./observe.sh', shell=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.rate = 4
        self.done = False
        self.energy = 0

    def shutdown(self):
        os.system("ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9")
        os.system("ps -ef | grep 'sar' | grep -v grep | awk '{print $2}' | xargs -r kill -9")
        os.system("ps -ef | grep 'pcm' | grep -v grep | awk '{print $2}' | xargs -r kill -9")

    def reset(self):
        time.sleep(2)

        while True:
            subprocess.Popen('./run_redis_test.sh', shell=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(5)
            p = os.popen('ps aux | grep redis')
            content = p.read()
            if len(content.split("\n")) > 10:
                break
            os.system("ps -ef | grep 'redis' | grep -v grep | awk '{print $2}' | xargs -r kill -9")
            time.sleep(1)

        self.done = False
        state = self.observe()
        return state

    def step(self, act):
        p = os.system('/home/test_activeidle.sh {} {} > /dev/null'.format(Action[act][0], Action[act][1]))

        time.sleep(self.rate)

        state = self.observe()
        reward = self.reward()

        return state, reward, self.done, None

    def reward(self):
        energy = self.read_energy() / MAX_ENERGY
        performance = self.read_redis_throughput() / MAX_PERF
        self.energy = energy
        print(round(energy * MAX_ENERGY, 2), round(performance * MAX_PERF, 2))

        reward = performance / energy
        return reward

    def observe(self):
        cpu_usage = self.read_cpu_usage()
        cpu_frequency = self.read_cpu_frequency()  / 3800
        memory_throughput = self.read_memory_throughput() / MAX_THROUGHPUT
        memory_usage = self.read_memory_usage() / 100
        network_io = self.read_network_io() / MAX_BANDWIDTH

        state = [cpu_usage, cpu_frequency, memory_throughput, memory_usage, network_io]
        return state

    def read_cpu_usage(self, num=48):
        size = num * 2 + 1
        p = os.popen('cat ./observation/cpu_usage | tail -n {}'.format(size))
        content = p.read()
        content = content.split('\n')
        content = reversed(content)
        idles = []
        flag = False
        for idx, con in enumerate(content):
            if idx == 0 or con == "": continue
            con = con.split()
            if con[2] == '95':
                flag = True
            if flag:
                idles.append(float(con[-1]))
            if flag and con[2] == '48':
                break
        avg_usage = 1 - np.mean(idles) / 100
        return avg_usage

    def read_cpu_frequency(self, num=48):
        p = os.popen('cat /proc/cpuinfo | grep MHz | tail -n +49 | head -n 48')
        content = p.read()
        content = content.split('\n')
        freqs = []
        for con in content:
            if con == "": continue
            idx = con.find(':')
            freqs.append(float(con[idx+1:]))
        avg_freq = np.mean(freqs)
        return avg_freq
    
    def read_memory_throughput(self, num=5):
        num = self.rate+1
        p = os.popen('cat ./observation/memory_throughput.csv | tail -n {}'.format(num))
        content = p.read()
        content = content.split('\n')
        throughputs = []
        for idx, con in enumerate(content):
            if idx == len(content) - 1 or con == "": continue
            con = con.split(",")
            throughputs.append(float(con[-1]))
        avg_throughput = np.mean(throughputs)
        return avg_throughput

    def read_memory_usage(self, num=5):
        num = self.rate+1
        p = os.popen('cat ./observation/memory_usage | tail -n {}'.format(num))
        content = p.read()
        content = content.split('\n')
        usages = []
        for idx, con in enumerate(content):
            if "memused" in con or "Linux" in con or con == "": continue
            con = con.split()
            usages.append(float(con[5]))
        avg_usage = np.mean(usages)
        return avg_usage

    def read_network_io(self, num=5):
        num = self.rate+1
        p = os.popen('cat ./observation/network_bandwidth | tail -n {}'.format(num * 10))
        content = p.read()
        temp = content.split('\n')
        content = [i for i in temp if "ens43f0" in i]
        bandwidths = []
        for idx, con in enumerate(content):
            try:
                if con == "": continue
                con = con.split()
                bandwidths.append(float(con[6]) + float(con[7]))
            except:
                pass
        avg_bandwidth = np.mean(bandwidths)
        return avg_bandwidth

    def read_energy(self, num=5):
        num = self.rate+1
        command = "promtool query range --start=$[`date +%s`-"+str(num)+"] --end=`date +%s` --step=1s http://10.67.124.196:9090 'collectd_pwrmetric_power_watt_gauge{pwrmetric_power_watt=\"pkg01\"}' | grep -v pwrmetric | awk '{sum += $1} END {print sum}'"
        p = os.popen(command)
        content = p.read()
        avg_energy = float(content) / num
        return avg_energy

    def read_redis_throughput(self, ports=[6000+i for i in range(16)]):
        perfs = []
        for port in ports:
            p = os.popen('redis-cli -h 10.10.20.2 -p {} info stats | grep instantaneous_ops_per_sec'.format(port))
            content = p.read()
            try:
                content = float(content[content.find(":")+1:])
                perfs.append(content)
            except:
                self.done = True
                return 0
        avg_perf = np.mean(perfs)
        return avg_perf


if __name__ == '__main__':   

    MAX_ENERGY, MAX_PERF, MAX_THROUGHPUT, MAX_IO = 0, 0, 0, 0
    
    env = ENV()
    env.reset()
    while True:
        cpu_usage = env.read_cpu_usage()
        cpu_frequency = env.read_cpu_frequency()
        memory_throughput = env.read_memory_throughput()
        memory_usage = env.read_memory_usage()
        network_io = env.read_network_io()
        energy = env.read_energy()
        performance = env.read_redis_throughput()
        print("cpu usgae:", cpu_usage)
        print("cpu frequency:", cpu_frequency)
        print("memory throughput:", memory_throughput)
        print("memory usage:", memory_usage)
        print("network io:", network_io)
        print("energy:", energy)
        print("performance:", performance)

        MAX_ENERGY = max(MAX_ENERGY, energy)
        MAX_PERF = max(MAX_PERF, performance)
        MAX_IO = max(MAX_IO, network_io)
        MAX_THROUGHPUT = max(MAX_THROUGHPUT, memory_throughput)

        print(MAX_ENERGY, MAX_PERF, MAX_THROUGHPUT, MAX_IO)

        time.sleep(2)
    # proc = subprocess.run(['bash', '/home/redis-ning/observe.sh'], stdout=None, shell=True)
