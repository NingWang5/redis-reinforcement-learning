import numpy as np
import pandas as pd
from env import *


class RL:
    def __init__(self, actions=list(range(len(Action))), learning_rate=0.01, reward_decay=0.99, e_greedy=0.5):
        self.actions = actions  # a list
        self.lr = learning_rate
        self.gamma = reward_decay
        self.epsilon = e_greedy
        self.q_table = pd.DataFrame(columns=self.actions, dtype=np.float64)

    def choose_action(self, observation):
        observation = self.discrete(observation)
        self.check_state_exist(observation)
        print(self.q_table)
        # action selection
        if np.random.uniform() < self.epsilon:
            # choose best action
            state_action = self.q_table.loc[observation, :]
            # some actions may have the same value, randomly choose on in these actions
            action = np.random.choice(state_action[state_action == np.max(state_action)].index)
        else:
            # choose random action
            action = np.random.choice(self.actions)
        return action

    def store_transition(self, s, a, r, s_):
        self.learn(s, a, r, s_)

    def learn(self, s, a, r, s_):
        s = self.discrete(s)
        s_ = self.discrete(s_)
        self.check_state_exist(s_)
        q_predict = self.q_table.loc[s, a]
        if s_ != 'terminal':
            q_target = r + self.gamma * self.q_table.loc[s_, :].max()  # next state is not terminal
        else:
            q_target = r  # next state is terminal
        self.q_table.loc[s, a] += self.lr * (q_target - q_predict)  # update

    def check_state_exist(self, state):
        if state not in self.q_table.index:
            # append new state to q table
            self.q_table = self.q_table.append(
                pd.Series(
                    [0]*len(self.actions),
                    index=self.q_table.columns,
                    name=state,
                )
            )

    def discrete(self, s):
        s_new = []
        for i,j in enumerate(s):
            if i < 3: continue
            if j <= 0.2: j = 0.2
            elif j <= 0.4: j = 0.4
            elif j <= 0.6: j = 0.6
            elif j <= 0.8: j = 0.8
            else: j = 1
            s_new.append(j)
        return str(s_new)

    def save(self):
        self.q_table.to_csv('./q_table.csv')
        pass

    def load(self):
        pass


if __name__ == "__main__":
    algo = RL()

    s = algo.discrete([0.334, 0.586, 0.129, 0.876, 0.784])
    print(s)

