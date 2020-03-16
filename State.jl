# State.jl module
# For use in Placozoan
# Contains state variables for Placozoan
# March 2020 NDong

struct State
    # trichoplax state variables
    x0::Array{Float64,2}  # Body origin (centre of cell 1) in World frame
    θ::Array{Float64,1}   # Body orientation in World frame
    vertex::Array{Float64,2}   # cell vertex coords in Body frame
    potential::Array{Float64,1}   # membrane potential per cell
    calcium::Array{Float64,1}     # [calcium] per cell
    edgelength::Array{Float64,1}  # edge rest lengths
    volume::Array{Float64,1}   # volume (area) of each cell
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
