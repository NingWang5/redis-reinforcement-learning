from qlearning import *
from env import *
import os


env = ENV()
alg = RL()

log = open("./log", "w")
log.write("episode, reward, energy\n")
log.flush()
try:
    alg.load()
except:
    print("There is no checkpoint")

for i_episode in range(1000):
    s = env.reset()
    ep_r, ep_e = 0, 0
    while True:

        a = alg.choose_action(s)
        # take action
        s_, r, done, info = env.step(a)
        print([round(i, 2) for i in s_], round(r, 2), Action[a])
        # os.system('rdmsr -p 48 0xb1')

        if done:
            break

        alg.store_transition(s, a, r, s_)
        ep_r += r
        ep_e += env.energy
        # if alg.memory_counter > MEMORY_CAPACITY:
        #     alg.learn()

        s = s_

    log.write("{}, {}, {}\n".format(i_episode, ep_r, ep_e))
    log.flush()
    alg.save()

log.close()
env.shutdown()
