using Pkg
Pkg.activate("./life_like")
include("../src/life_like_2.jl")

my_cmap = PyPlot.get_cmap("magma")

function time_ca_steps(universe::Universe, steps::Int64)
    @timed ca_steps(universe, steps)
    
end   

# run performance test

function timing_script()
    seconds = zeros(4,4)

    bb = 1

    for obs_dim = [1024, 256, 128, 64] #, 1024]
        uni = Universe( [3], [2,3], zeros(Float32, obs_dim, obs_dim) )

        # build a glider
        uni.grid[34, 32] = 1
        uni.grid[35, 32:33] .= 1
        uni.grid[36, 31] = 1
        uni.grid[36, 33] = 1
        
        cc = 1
        for steps = [1, 10, 100, 1000] 


            t0 = time_ca_steps(uni, steps)[2]
            println(obs_dim, " obs_dim")
            println(steps, " steps in ", t0, " seconds, ", steps/t0, " steps/second ")

            seconds[ bb, cc ] = t0

            cc += 1 
        end

        global my_grid = uni.grid
        bb += 1
    end

    return seconds
end

seconds = timing_script()

# plot it up

x = [1, 2, 3, 4]
y = 1000 ./ seconds[:, 4]
print(seconds)

PyPlot.figure(figsize=(6,4), facecolor="white")
PyPlot.bar(x, y, width=0.75, color=my_cmap(155), tick_label=["dim=1024", "dim=256", "dim=128", "dim=64"])
PyPlot.title("nn Speed of Life in Julia", fontsize=32)
PyPlot.ylabel("steps per second", fontsize=22)

PyPlot.tight_layout()
PyPlot.savefig("./assets/julia_speed_nnlib_amd_float32.png")

PyPlot.figure(figsize=(8,8))
PyPlot.imshow(my_grid, cmap=my_cmap)
PyPlot.title("Life glider last step", fontsize=32)
PyPlot.tight_layout()

PyPlot.savefig("./assets/julia_last_frame.png")
