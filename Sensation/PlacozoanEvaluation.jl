#PlacozoanEvaluation
#Evaluation methods for Placozoan model

#given two distances, find percentage difference
function checkDistance(d1::Float64, d2::Float64)
  n = abs(d1-d2)
  n2 = n/d1
  return n2
end

#given two angles, find percentage difference
function checkAngle(θ1::Float64, θ2::Float64)
  n = (θ1-θ2)
  if n > π
    n = n - 2π
  end
  if n < -π
    n = n+2π
  end
  return abs(n)/2π
end

#given two distances, find discrete difference
function checkDistance(d1::Float64, d2::Float64, arr::Array{Float64})
  n = abs(d1-d2)

  if n < 1000
    arr[4] += 1
    if n < 500
      arr[5] += 1
      if n < 250
        arr[6] += 1
      end
    end
  end
#  println(arr)
end

#given two angles, find discrete difference
function checkAngle(θ1::Float64, θ2::Float64, arr::Array{Float64})
  diff = 0
  n = (θ1-θ2)
  if n > π
    n = n - 2π
  end
  if n < -π
    n = n+2π
  end
  n = abs(n)

  if n < π/2
    arr[1] += 1
    if n < π/4
      arr[2] += 1
      if n < π/8
        arr[3] += 1
      end
    end
  end
#  println(arr)
end

#evaluation of all particles, based on discrete criteria for angles and distances
function particleEvaluation(predator::Placozoan, prey::Placozoan, t::Int64,
  angleCriteria::Array{Float64}, distanceCriteria::Array{Float64})

  Pd = [predator.x[], predator.y[]]
  Pa = atan(predator.y[], predator.x[])

  for i in 1:prey.observer.nBparticles

    a = atan(prey.observer.Bparticle[i,2], prey.observer.Bparticle[i,1])

    #given two angles, find discrete difference
    # function checkAngle(θ1::Float64, θ2::Float64, arr::Array{Float64})
    A = (Pa-a)
    A += A > π ? -2π : A < -π ? 2π : 0
    A = abs(A)

    for j in 1:length(prey.evaluations.angles[1,:])
      if A < angleCriteria[j]
        prey.evaluations.angles[t,j] +=1
      end
    end

    #calculate
    d = sqrt((Pd[1] - prey.observer.Bparticle[i,1])^2 + (Pd[2] - prey.observer.Bparticle[i,2])^2)# - prey.radius
    for k in 1:length(prey.evaluations.distances[1,:])
      if d < distanceCriteria[k]
        prey.evaluations.distances[t,k] +=1
      end
    end

  end

end

# function evaluationCSV(arr::Array{Float64,2}, name::String)
#   filename = string(name, ".csv")
#   df = convert(DataFrame, arr')
#   df |> CSV.write(filename)
#
# end
#
# function evaluationCSV(arr::Array{Float64,2}, name::String, i::Int64)
#   filename = string(name, i, ".csv")
#   df = convert(DataFrame, arr')
#   df |> CSV.write(filename)
# end
