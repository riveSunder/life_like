import numpy as np
import matplotlib.pyplot as plt

universe = {"born": [], \
        "live": [], \
        "grid": None \
        }
        

def pad_to_2d(kernel, dims):

    mid_x = dims[0] // 2
    mid_y = dims[1] // 2 
    mid_k_x = kernel.shape[0] // 2
    mid_k_y = kernel.shape[1] // 2
    
    start_x = mid_x - mid_k_x
    start_y = mid_y - mid_k_y
    
    padded = np.zeros(dims)
    padded[mid_x-mid_k_x:mid_x-mid_k_x + kernel.shape[0],
            mid_y-mid_k_y:mid_y-mid_k_y + kernel.shape[1]] = kernel
    
    return padded

def ft_convolve(grid, kernel):

    grid2 = grid
    if np.shape(kernel) != np.shape(grid2):
        padded_kernel = pad_to_2d(kernel, grid2.shape)
    else:
        padded_kernel = kernel

    convolved = np.round(np.fft.ifftshift(np.abs(np.fft.ifft2(\
            np.fft.fft2(np.fft.fftshift(grid2)) \
            * np.fft.fft2(np.fft.fftshift(padded_kernel))))))

    return convolved 

def ca_update(grid, rules):

    kernel = np.ones((3,3))
    kernel[1,1] = 0

    moore_grid = ft_convolve(grid, kernel)

    new_grid = np.zeros_like(grid)

    
    for birth in rules[0]:
        new_grid[((moore_grid == birth) * (grid == 0))] = 1

    for survive in rules[1]:
        new_grid[((moore_grid == survive) * (grid == 1))] = 1

    return new_grid

def ca_steps(universe, steps):

    for step in range(steps):

        universe["grid"] = ca_update(universe["grid"], [universe["born"], universe["live"]])


    return universe

if __name__ == "__main__":

    obs_dim = 64
    universe["born"] = [3]
    universe["live"] = [2,3]

    universe["grid"] = np.zeros((obs_dim, obs_dim))
    
    universe["grid"][34, 32] = 1
    universe["grid"][35, 32:34] = 1
    universe["grid"][36, 31] = 1
    universe["grid"][36, 33] = 1

    plt.figure()
    plt.imshow(universe["grid"])


    universe = ca_steps(universe, 1)


    plt.figure()
    plt.imshow(universe["grid"])

    universe = ca_steps(universe, 1)


    plt.figure()
    plt.imshow(universe["grid"])
    universe = ca_steps(universe, 1)


    plt.figure()
    plt.imshow(universe["grid"])
    plt.show()

