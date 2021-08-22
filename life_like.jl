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
    
    grid2 = grid #pad_to_2d(grid, size(grid) .* 2)
    #grid2 = pad_circular(grid)
    
    if size(grid2) != size(kernel)
        padded_kernel = pad_to_2d(kernel, size(grid2))
    else
        padded_kernel = kernel
    end
    
    abs.(FFTW.ifftshift(FFTW.ifft(FFTW.fft(FFTW.fftshift(uni.grid)) .* FFTW.fft(temp) ) ))

    convolved = round.(FFTW.ifftshift(abs.(FFTW.ifft(
                    FFTW.fft(FFTW.fftshift(grid2)) .* 
                    FFTW.fft(FFTW.fftshift(padded_kernel)) ))) )

    #new_convolved = pad_to_2d(convolved[2:size(grid)[1], 2:size(grid)[2]], size(grid)) #zeros(size(convolved))
    
    new_convolved = convolved[2:size(convolved)[1]-1, 2:size(convolved)[1]-1]
   
    return convolved #convolved[1:size(grid)[1], 1:size(grid)[2]]
end

function ca_update(grid, rules)

    # Moore neighborhood kernel
    kernel = ones(Int32, 3,3)
    kernel[2, 2] = 0
    
    moore_grid = ft_convolve(pad_circular(grid), kernel)

    moore_grid = moore_grid[2:33, 2:33]
    new_grid = zeros(size(moore_grid))
    
    for birth in rules[1]
        new_grid[(round.(moore_grid .- birth) .== 0.0) .& (grid .!= 1)] .= 1
    end

    for survive in rules[2]
        new_grid[(round.(moore_grid .- survive) .== 0.0) .& (grid .== 1)] .= 1
    end

    return new_grid 
end


function ca_step(universe::Universe)
    
    universe.grid = ca_update(universe.grid, [universe.born, universe.live]) 

end



