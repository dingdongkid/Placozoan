# Anatomy.jl module
# For use in Placozoan
# Create placozoan and assign body structures
# March 2020 NDong

struct Anatomy
    # look-up tables that specify anatomical
    #   parent-child and neighbour relationships of trichoplax components
    # e.g. which vertices belong to which cell, etc.
    ncells::Int64              # number of cells
    layercount::Array{Int64,1}  # number of cells in each layer
    stomach::Int64            # number of stomach cells (1:stomach)
    triangle::Array{Int64,2}   # skeleton Delaunay triangles
    skintriangle::Array{Int64,2} # triangles for skin vertices
    cellvertexindex::Array{Int64, 2}      # 6 vertices for each cell
    edge::Array{Int64}         # [i,:] index links between cells
    skinvertexindex::Array{Int64}         # index to cell vertices on exterior surface
    gutboundaryvertexindex::Array{Int64,1}
    n_edges2vertex::Array{Int64,1}   # number of edges at ith vertex
    edge2vertex::Array{Int64,2}     # index of edges at ith vertex
    n_neighbourvertex::Array{Int64,1}   # number of neighbours for each vertex
    neighbourvertex::Array{Int64,2}  # neighbours of each vertex
    n_neighbourcell::Array{Int64,1}  # number of neighbours for each cell
    neighbourcell::Array{Int64,2}  # neighbours of each cell
    n_vertexcells::Array{Int64,1}  # number of cells containing each vertex
    vertexcells::Array{Int64,2} # index of cells containing each vertex
    skin_neighbour::Array{Int64,2}  # 2 skin neighbours for each skin vertex
    #cilia_direction::Array{Float64, 2}  # position of cilia force between two vertices
end
