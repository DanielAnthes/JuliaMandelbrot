using Plots

# CUT OFF CONDITION
MAX_Z = 2
MAX_ITER = 80

# Resolution
WIDTH = 1920
HEIGHT = 1080

# Position
xpos = (-2, 1)
ypos = (-2, 2)

# Grid
c = zeros(ComplexF16, (HEIGHT,WIDTH))
for j = 1:size(c,2)
    for i = 1:size(c,1)
        c[i,j] = xpos[1] + (xpos[2] - xpos[1])/WIDTH * j + ((ypos[1] + (ypos[2]-ypos[1])/HEIGHT * i) * im) # TODO probably not exactly the correct interval (missing endpoint)
    end
end

# z - to be iterated over
z = zeros(ComplexF16, (HEIGHT,WIDTH))

# membership of mandelbrot set and escape duration
# insert -1 for members, number of iterations before meeting escape criterion otherwise
mandelbrot = zeros(Int128, (HEIGHT,WIDTH))


function iterateMandelbrot(z::Array{ComplexF16, 2}, c::Array{ComplexF16, 2}) :: Array{ComplexF16, 2}
    z = z.^2 .+ c
    return z
end

function checkMembership(z::Array{ComplexF16, 2}, mandelbrot::Array{Int128, 2}, iteration::Int) :: Array{Int128, 2}
        escaped = map(a -> sqrt(real(a)^2 + imag(a)^2) > MAX_Z, z)
        notDone = map(a -> a == 0, mandelbrot)
        newEscaped = escaped .& notDone
        mandelbrot[newEscaped] .= iteration
        return mandelbrot
end

function isComplete(mandelbrot::Array{Int128, 2}) :: Bool
    unfinished = map(x -> x == 0, mandelbrot)
    return unfinished == false
end

for i in 1:MAX_ITER
    global z
    global mandelbrot
    z = iterateMandelbrot(z,c)
    mandelbrot = checkMembership(z, mandelbrot, i)
end


#%% Plot

x = real(c[1,:])
y = imag(c[:,1])

p1 = heatmap(x, y, mandelbrot, aspect_ratio=1)
plot(p1, colorbar=false, grid = false, showaxis=false)
