# PlacozoanPredatorPrey

#import BayesianPlacozoan

NO_PLOT = true
# simulation parameters
nFrames = 600      # number of animation frames
mat_radius = 400
approach_Δ = 25.0         # predator closest approach distance
dt = 1.00

# construct observer
priormean = 300.
priorsd = 25.0
posteriorSD = 100.0
n_likelihood_particles = 5000
#n_prior_particles = 500
n_posterior_particles = 2500
# observer = Observer(mat_radius,
#             n_likelihood_particles, n_prior_particles, n_posterior_particles,
#             approach_Δ)

angleCriteria = [π/2, π/4, π/8]
distanceCriteria = [1000., 500., 300.]

for k in 1:1


    # construct prey
    prey_radius = 200
    prey_margin = 50
    Nreceptors = 24
    prey_fieldrange = 0   # no field
    prey = Placozoan(prey_radius, prey_margin, prey_fieldrange,
                      Nreceptors, sizeof_receptor, mat_radius,
                      n_likelihood_particles, n_posterior_particles,
                      priormean, priorsd, nFrames, length(angleCriteria))

    # construct predator
    # nb has dummy observer
    predator_radius = 225
    predator_margin = 0
    predator_speed = 0.6
    predator_fieldrange = mat_radius
    predator = Placozoan(predator_radius, predator_margin, predator_fieldrange,
                         RGBA(.25, 0.1, 0.1, 1.0),
                         RGBA(.45, 0.1, 0.1, 0.25),
                         RGB(.95, 0.1, 0.1) )
    predator.speed[] = predator_speed
    θ = π*rand()[] # Random initial heading (from above)
    predator.x[] = (mat_radius + predator_radius)*cos(θ)
    predator.y[] = (mat_radius + predator_radius)*sin(θ)


    # compute field and potential as a fcn of distance from edge of predator
    placozoanFieldstrength!(predator)

    # compute Bayesian receptive fields for each of prey's receptors
    precomputeBayesianRF(prey, predator)

    likelihood(prey)  # initialize likelihood given initial receptor states
    sample_likelihood(prey) # sample from normalized likelihood
    initialize_posterior_Gaussian(prey)

    # time observable
    # used to force scene update (nothing depends explicitly on time)
    t = Node(0.0)

    if NO_PLOT == false

        # construct scene
        WorldSize = 2*mat_radius+1

        scene = Scene(resolution = (WorldSize, WorldSize),
                      limits = FRect(-mat_radius, -mat_radius ,WorldSize, WorldSize ),
                      show_axis=false, backgroundcolor = colour_background)

        # mat is a dark green disc
        mat_plt = poly!(scene,
               decompose(Point2f0, Circle(Point2f0(0.,0.), mat_radius)),
               color = colour_mat, strokewidth = 0, strokecolor = :black)

        # display nominal time on background
        clock_plt =text!(scene,"t = 0.0s",textsize = 24, color = :white,
             position = (- 0.925*mat_radius , -0.95*mat_radius))[end]

        # predator drawn using lift(..., node)
        # (predatorLocation does not depend explicitly on t, but this causes
        #  the plot to be updated when the node t changes)
        predator_plt = poly!(scene,
              lift(s->decompose(Point2f0, Circle(Point2f0(predator.x[], predator.y[]),
              predator.radius)), t),
              color = predator.color, strokecolor = predator.edgecolor,
              strokewidth = .5)

        # plot likelihood particles (samples from likelihood)
        Lparticle_plt = scatter!(
                  prey.observer.Lparticle[:,1], prey.observer.Lparticle[:,2],
                  color =:yellow, markersize = size_likelihood,
                  strokewidth = 0.1)[end]

        # plot projection of likelihood particles into prey margin
        # nb this is a dummy plot
        # the correct particle locations are inserted before first plot
        observation_plt = scatter!(scene,
            zeros(prey.observer.nLparticles),zeros(prey.observer.nLparticles),
              color = :yellow, strokewidth = 0, markersize=size_observation)[end]

        Bparticle_plt = scatter!(
                  prey.observer.Bparticle[:,1], prey.observer.Bparticle[:,2],
                  color = colour_posterior,
                  markersize = size_posterior, strokewidth = 0.1)[end]

        # plot projection of posterior particles into prey margin
        # nb this is a dummy plot
        # the correct particle locations are inserted before first plot
        belief_plt = scatter!(scene,
                    zeros(prey.observer.nBparticles), zeros(prey.observer.nBparticles),
                    color = colour_posterior, strokewidth = 0, markersize=size_belief)[end]

        # Prey
        prey_plt = poly!(scene,
               decompose(Point2f0, Circle(Point2f0(0.,0.), prey.radius)),
               color = prey.color, strokewidth = 1, strokecolor = RGB(.5, .75, .85))
        preyGut_plt = poly!(scene,
              decompose(Point2f0, Circle(Point2f0(0.,0.), prey.gutradius)),
              color = prey.gutcolor, strokewidth = 0.0)


        receptor_plt = scatter!(scene, prey.receptor.x, prey.receptor.y ,
                    markersize = prey.receptor.size,
                    color = [prey.receptor.openColor for i in 1:prey.receptor.N],
                    strokecolor = :black, strokewidth = 0.25)[end]

        record(scene, "PlacozoanPerception.mp4", framerate = 24, 1:nFrames) do i

            # predator random walk to within Δ of prey
            stalk(predator, prey, approach_Δ)

            # prey receptors respond to predator electric field
            updateReceptors(prey, predator)
            # set color of each receptor, indicating open or closed state
            receptorColor = [prey.receptor.closedColor  for j in 1:prey.receptor.N]
            receptorColor[findall(x->x==1, prey.receptor.state)] .=
                 prey.receptor.openColor
            receptor_plt.color[] = receptorColor

            # prey sensory observations (particles released by active sensors)
            likelihood(prey)      # likelihood given receptor states
            sample_likelihood(prey)     # random sample from likelihood
            bayesUpdate(prey)
            particleEvaluation(predator, prey, i, angleCriteria, distanceCriteria)

            (observation, belief) = reflect(prey) # reflect samples into margin

            Lparticle_plt[1] = prey.observer.Lparticle[:,1]   # update likelihood particle plot
            Lparticle_plt[2] = prey.observer.Lparticle[:,2]

            observation_plt[1] = observation[:,1]     # update observation particle plot
            observation_plt[2] = observation[:,2]

            Bparticle_plt[1] = prey.observer.Bparticle[:,1]  # update posterior particle plot
            Bparticle_plt[2] = prey.observer.Bparticle[:,2]

            belief_plt[1] = belief[:,1]     # update observation particle plot
            belief_plt[2] = belief[:,2]

            # level curves of likelihood
            #LhdPlot.levels[] = maximum(LikelihoodArray)*[0.1, .5 , .9]

            # clock display
            clock_plt[1] = "t = " * string(floor(t[])) * "s"

            # Node update causes redraw
            t[] = dt*(i+1)
        end

    #println(prey.observer.Bparticle[1,2])
    #println(prey.observer.Bparticle[1,1])
     else  # NO_PLOT == true
         for i in 1:nFrames
             stalk(predator, prey, approach_Δ)
             updateReceptors(prey, predator)
             likelihood(prey)      # likelihood given receptor states
             sample_likelihood(prey)     # random sample from likelihood
             bayesUpdate(prey)
             particleEvaluation(predator, prey, i, angleCriteria, distanceCriteria)
             # for k in 1:prey.observer.nBparticles
             #     total_evals[i,1,k] = prey.evaluations[k,1]
             #     total_evals[i,2,k] = prey.evaluations[k,2]
             # end
         end
     end

     CSV.write(string("angles", ".csv"), DataFrame(prey.evaluations.angles), header = false)
     println(prey.evaluations.angles[600, :])
    # evaluationCSV(prey.evaluations.angles, "angles")
    # evaluationCSV(prey.evaluations.distances, "distances")
    #println(total_evals[250,2,250])

end
