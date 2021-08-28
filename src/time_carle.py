import time
from carle.env import CARLE

import torch
import matplotlib.pyplot as plt
my_cmap = plt.get_cmap("magma")

# Run performance test

obs_dim = 64
act_dim = 64

elapsed = []

for obs_dim in [1024, 256, 128, 64]: 
    replicates = 1

    env = CARLE(height=obs_dim, width=obs_dim,\
             action_height=act_dim, action_width=act_dim)

    env.rules_from_string("B3/S23")

    action = torch.zeros(act_dim, act_dim)
    

    # build a glider
    action[34, 32] = 1
    action[35, 32:34] = 1
    action[36, 31] = 1
    action[36, 33] = 1
    
    obs = env.reset()
    obs = env.step(action)
    
    action *= 0

    t0 = time.time()
    
    temp_elapsed = []
    for steps in [1, 100, 1000, 10000]:
        
        t0 = time.time()

        for hh in range(replicates):

            t1 = time.time()
            for ii in range(steps):
                o,r,d,i = env.step(action)

            t2 = time.time()

        
        temp_elapsed.append(t2-t1)
        
        print(f"   universe dimension = {obs_dim}")
        print(f"time elapsed for {replicates} runs of {steps}" \
              f"steps: {t2-t0:.3f} seconds,"\
              f"{(replicates * steps) / (t2-t0):.2f} avg. steps/sec.")
    elapsed.append(temp_elapsed)

#plot it up

obs_dims = [1024, 256, 128, 64]
steps = [1, 100, 1000, 10000]

plt.figure(figsize=(9,6))
    
plt.bar([1,2,3,4], [steps[-1] / e[-1] for e in elapsed], \
        tick_label = [str(o) for o in obs_dims], \
        facecolor=my_cmap(120), edgecolor=my_cmap(55), linewidth=3)
    

plt.title("Speed of Life in CARLE", fontsize=32)
plt.xlabel("CA dimension", fontsize=26)
plt.ylabel("steps/second", fontsize=26)

plt.savefig("./assets/carle_speed.png")


plt.figure(figsize=(8,8), facecolor="white")
plt.imshow(o.detach().cpu().squeeze(), cmap=my_cmap)
plt.title("Life glider last step", fontsize=32)
plt.savefig("./assets/carle_last_frame.png")
