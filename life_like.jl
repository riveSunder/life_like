using FFTW
using ImageView
using Gtk
using PyPlot
pygui(false)

# universe constructor

mutable struct Universe 
    born::Array{Int32}
    live::Array{Int32}
    grid::Array{Int32, 2}
end

# default constructor for CA universe

Universe() = Universe([3], [2,3], zeros(64,64)) 

function fftshift(grid)
    # shift the grid to give you that sweet circular convolution you crave
    
    dim_x, dim_y = size(grid)
    
    
    mid_x = round(dim_x/2)
    mid_y = round(dim_y/2)
    r_x = mid_x - ceil(dim_x/2)
    r_y = mid_x - ceil(dim_y/2)
    
    new_grid = zeros(dim_x, dim_y)
    
    new_grid[1:mid_x+r_x, 1:mid_y+r_y] = grid[mid_x+1:dim_x, mid_y+1:dim_y]
    
    new_grid[1:mid_x+r_x, mid_y+1:dim_y] = grid[mid_x+1:dim_x, 1:dim_y+r_y]
    
    new_grid[mid_x+1:dim_x, mid_y+1:dim_y] = grid[1:mid_x+r_x, 1:mid_y+r_y]
    
    new_grid[mid_x+1:dim_x, 1:dim_y+r_y] = grid[1:mid_x+r_x, mid_y+1:dim_y]
    
    return new_grid
    
    
end

function pad_to_2d(kernel, dims)

    padded = zeros(dims)
    mid_x = Int64(round(dims[1] / 2))
    mid_y = Int64(round(dims[2] / 2))
    mid_k_x = Int64(round(size(kernel)[1] / 2))
    mid_k_y = Int64(round(size(kernel)[2] / 2))
    
    start_x = mid_x - mid_k_x
    start_y = mid_y - mid_k_y
    
    padded[2+mid_x-mid_k_x:mid_x-mid_k_x + size(kernel)[1]+1,
            2+mid_y-mid_k_y:mid_y-mid_k_y + size(kernel)[2]+1] = kernel
    
    #padded[1:size(kernel)[1], 1:size(kernel)[2]] = copy(kernel)

    return padded
end

function pad_circular(grid)
   
    dim_x, dim_y = size(grid)
    
    padded_grid = zeros(dim_x+2, dim_y+2)
    
    padded_grid[2:dim_x+1, 2:dim_y+1] = copy(grid)
    
    padded_grid[1, 2:dim_y+1] = grid[dim_x, :]
    padded_grid[dim_x+2, 2:dim_y+1] = grid[1, :]
    
    padded_grid[2:dim_x+1, 1] = grid[:, dim_y]
    padded_grid[2:dim_x+1, dim_y+2] = grid[:, 1]
    
    return padded_grid
    
end

function ft_convolve(grid, kernel)
    
    grid2 = grid 
    
    if size(grid2) != size(kernel)
        padded_kernel = pad_to_2d(kernel, size(grid2))
    else
        padded_kernel = kernel
    end
    
    abs.(FFTW.ifftshift(FFTW.ifft(FFTW.fft(FFTW.fftshift(grid)) .* FFTW.fft(padded_kernel) ) ))

    convolved = round.(FFTW.ifftshift(abs.(FFTW.ifft(
                    FFTW.fft(FFTW.fftshift(grid2)) .* 
                    FFTW.fft(FFTW.fftshift(padded_kernel)) ))) )

    
    return convolved 
end

function ca_update(grid, rules)

    # Moore neighborhood kernel
    kernel = ones(Int32, 3,3)
    kernel[2, 2] = 0
    
    moore_grid = ft_convolve(grid, kernel)
    
    new_grid = zeros(size(moore_grid))
   
    #my_fn(a,b) = a + b
    #born = reduce(my_fn, [elem .== moore_grid for elem in rules[1]])
    #live = reduce(my_fn, [elem .== moore_grid for elem in rules[2]])

    #new_grid = grid .* born + (1 .- grid) * live
 
    for birth in rules[1]
        #new_grid[(round.(moore_grid .- birth) .== 0.0) .& (grid .!= 1)] .= 1
        new_grid[((moore_grid .== birth) .& (grid .!= 1))] .= 1
    end

    for survive in rules[2]
        #new_grid[(round.(moore_grid .- survive) .== 0.0) .& (grid .== 1)] .= 1
        new_grid[((moore_grid .== survive) .& (grid .== 1))] .= 1
    end

    return new_grid 
end


function ca_steps(universe::Universe, steps::Int64)

    for ii = 1:steps
        universe.grid = ca_update(universe.grid, [universe.born, universe.live]) 
    end

end



