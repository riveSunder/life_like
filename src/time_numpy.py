import time 

import numpy as np
import matplotlib.pyplot as plt
my_cmap = plt.get_cmap("viridis")

from life_like import ca_steps, ca_update, ft_convolve, pad_to_2d

def time_ca_steps(universe, num_steps):
    t0 = time.time()
    universe = ca_steps(universe, num_steps)
    t1 = time.time()
    
    return universe, t1-t0

def timing_script():
    seconds = np.zeros((4,))

    cc = 0
    for obs_dim in [1024, 256, 128, 64]:
        uni = {"born": [3],\
               "live": [2,3],\
               "grid": np.zeros((obs_dim, obs_dim))\
              }
               

        # build a glider
        uni["grid"][34, 32] = 1
        uni["grid"][35, 32:34] = 1
        uni["grid"][36, 31] = 1
        uni["grid"][36, 33] = 1

        dd = 0
        for steps in [1, 10, 100, 10000]: 

            t0 = time_ca_steps(uni, steps)[1]
            
            print(f"{obs_dim} obs_dim")
            print(f"{steps} steps in {t0} seconds, {steps/t0} steps/second")


            dd += 1

            seconds[ cc ] = t0

        cc += 1


    return seconds, uni["grid"]

seconds, grid = timing_script()

# plot it up

x = [1, 2, 3, 4]
y = 10000 / seconds


plt.figure(figsize=(8,4), facecolor="white")

plt.bar(x, y, width=0.75, \
        color=[my_cmap(150), my_cmap(150), my_cmap(150), my_cmap(150)], \
        edgecolor=my_cmap(10), linewidth=3,\
       tick_label =["obs_dim = 1024", "obs_dim = 256", "obs_dim = 128", "obs_dim = 64"])


plt.title("Speed of Life in Numpy", fontsize=32)

plt.ylabel("steps per second", fontsize=22)


plt.savefig("./assets/numpy_speed.png")

plt.figure(figsize=(8,8))
plt.imshow(grid, cmap=my_cmap)
plt.title("Life glider last step", fontsize=32)

plt.savefig("./assets/numpy_last_step.png")
