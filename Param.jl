# Param.jl module
# For use in Placozoan
# Assign parameters for Placozoan construction
# March 2020 NDong


struct Param
    nlayers::Int64
    margin::Int64         # number of layers in gut margin ("brain")
    k2::Array{Float64,1}  # half of cytoskeleton spring constant (k/2)
    ρ::Array{Float64,1}   # cell pressure constant \rho (energy/volume)
    σ::Array{Float64,1}   # surface energy density
    celldiameter::Float64      # nominal cell diameter when constructed
    dt::Array{Float64,1}  # simulation time step length (seconds)
end

# utility for constructing parameter struct
function trichoplaxparameters( nlayers,
                               margin,
                               skeleton_springconstant,
                               cell_pressureconstant,
                               cell_surface_energy_density,
                               cell_diameter,
                               dt )
    Param(  nlayers,
            margin,
            [skeleton_springconstant/2.0],
            [cell_pressureconstant],
            [cell_surface_energy_density],
            cell_diameter,
            [dt]
            )
end
