using Pkg
Pkg.activate("../life_like")
include("../src/life_like.jl")

my_cmap = PyPlot.get_cmap("magma")

function time_ca_steps(universe::Universe, steps::Int64)
    @timed ca_steps(universe, steps)
    
end   

# run performance test

function timing_script()
    seconds = zeros(3,4)

    bb = 1
    for num_threads = [1, 2, 4] # [1, 8, 16]
        FFTW.set_num_threads(num_threads)
        cc = 1
        for obs_dim = [1024, 256, 128, 64] #, 1024]
            uni = Universe( [3], [2,3], zeros(obs_dim, obs_dim) )

            # build a glider
            uni.grid[34, 32] = 1
            uni.grid[35, 32:33] .= 1
            uni.grid[36, 31] = 1
            uni.grid[36, 33] = 1

            for steps = [1, 10, 100, 10000] 


                t0 = time_ca_steps(uni, steps)[2]
                println(num_threads, " threads")
                println(obs_dim, " obs_dim")
                println(steps, " steps in ", t0, " seconds, ", steps/t0, " steps/second ")

                seconds[ bb, cc ] = t0
            end

            cc += 1
            global my_grid = uni.grid
        end
        bb += 1
    end

    return seconds
end

seconds = timing_script()

# plot it up

x = [1, 2, 3, 4]
y = 10000 ./ seconds[1,:]

x2 = [1.25, 2.25, 3.25, 4.25]
y2 = 10000 ./ seconds[2,:]

x3 = [1.5, 2.5, 3.5, 4.5]
y3 = 10000 ./ seconds[1, :]


PyPlot.figure(figsize=(12,4), facecolor="white")
PyPlot.bar(x, y, width=0.25, color=my_cmap(5))
PyPlot.bar(x2, y2, width=0.25, color=my_cmap(100),
    tick_label=["1, 2, 4 threads, dim=1024", "1, 2, 4 threads, dim=256",
        "1, 2, 4 threads, dim=128","1, 2, 4 threads, dim=64"])
PyPlot.bar(x3, y3, width=0.25, color=my_cmap(200))


PyPlot.title("Speed of Life in Julia", fontsize=32)
PyPlot.ylabel("steps per second", fontsize=22)

PyPlot.savefig("./assets/julia_speed.png")

PyPlot.figure(figsize=(8,8))
PyPlot.imshow(my_grid, cmap=my_cmap)
PyPlot.title("Life glider last step", fontsize=32)
PyPlot.tight_layout()

PyPlot.savefig("./assets/julia_last_frame.png")
