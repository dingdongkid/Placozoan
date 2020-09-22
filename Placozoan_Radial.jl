#Placozoan_radial.jl



bodylayers = 6 # number of body cell layers
margin = 5  # number of layers in gut margin ("brain")
celldiameter = 10.0
skeleton_springconstant = 5.0e-2
cell_pressureconstant = 1.0e0
cell_surface_energy_density = 5.0e1
dt = 0.001

param = trichoplaxparameters(
    bodylayers,
    margin,
    skeleton_springconstant,
    cell_pressureconstant,
    cell_surface_energy_density,
    celldiameter,
    dt,
)

@time trichoplax = Trichoplax(param)
# trichoplax.param.k2[] = 5.0e-2    # cytoskeleton spring constant /2
# trichoplax.param.σ[]  = 5.0e1   # cell surface energy density
# trichoplax.param.ρ[]  = 1.0e0 #1.0e2    # cell turgor pressure energy per unit volume

# Draw
R = bodylayers * celldiameter    # approx radius of Trichoplax (for scene setting)
D = 3 * R  # scene diameter
limits = FRect(-D / 2, -D / 2, D, D)
scene = Scene(
    resolution = (800, 800),
    scale_plot = false,
    show_axis = false,
    limits = limits,
)

# draw trichoplax cells

cells_handle = draw(scene, trichoplax, RGB(0.25, 0.25, 0.25), 1)

display(scene)

println(trichoplax.anatomy.cellvertexindex[1, :])
println(trichoplax.state.vertex[2,:])


function findcentroid(vertices)
    
    centre = colmeans(verticesofcell(vertices, trichoplax))
    scatter!(centre, markersize = 2, color = :red)

    return centre
end

#=
function findCentre(trichoplax)
    centre = colmeans(verticesofcell(i, trichoplax))
end
=#
function findfurthest(vertices)
    n = size(trichoplax.anatomy.cellvertexindex,2)
    v = fill(0, n)
    d = fill(0.0, n)

    @inbounds for i = 1:n
        v[i] = trichoplax.anatomy.cellvertexindex[vertices, i]
    end
    #println(v)

    @inbounds for i = 1:n
        a = v[i]
        x = trichoplax.state.vertex[a, 1]

        y = trichoplax.state.vertex[a, 2]
        d[i] = sqrt(abs2(x) + abs2(y))
    end
    #println(d)
    m = findmax(d)
    trichoplax.anatomy.cilia_direction[vertices] = m[2]
    #println(m)

    scatter!([trichoplax.state.vertex[v[6], 1] trichoplax.state.vertex[v[6], 2]], markersize = 2, color = :blue)
    x = [findcentroid(vertices)[1], trichoplax.state.vertex[v[6], 1]]
    y = [findcentroid(vertices)[2], trichoplax.state.vertex[v[6], 2]]
    lines!(x, y)

end

function f_direction(vertices)
    n = size(trichoplax.anatomy.cellvertexindex,2)
    v = fill(0, n)
    println(v)

end


f_direction(2)
findcentroid(50)
findfurthest(50)


k = 1
while k < 80
    findcentroid(k)
    findfurthest(k)
    global k = k + 1
end


#=
cilia force function {
check cilia_direction (usually vertex 6)
if (cilia active)
    force inversely proportional to stretch
    figure out how to add force vector
        i.e. location = location +[x][y] of cilia move
        probably external to gradient calculations
        possibly before? adds extra stretch possibility
        add to each vertex of the active cell
}

=#
