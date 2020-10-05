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

  if n < 100
    arr[4] += 1
    if n < 75
      arr[5] += 1
      if n < 50
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

function particleEvaluation(predator::Placozoan, prey::Placozoan, t::Int64)

  Pd = sqrt(predator.x[]^2 + predator.y[]^2) - predator.radius# - prey.radius
  Pa = atan(predator.y[], predator.x[])

  #for every posterior particle x/y
  #check compare angle to Pa and distance to Pd
  angles = zeros(prey.observer.nBparticles, 2)
  distances = zeros(prey.observer.nBparticles, 2)
  evalArr = zeros(6)

  for i in 1:prey.observer.nBparticles

    angles[i,1] = atan(prey.observer.Bparticle[i,2], prey.observer.Bparticle[i,1])
    #angles[i,2] = checkAngle(angles[i,1], Pa)
    checkAngle(angles[i,1], Pa, evalArr)
    #prey.evaluations[i,1] = angles[i,2]

    distances[i,1] = sqrt(prey.observer.Bparticle[i,1]^2 + prey.observer.Bparticle[i,2]^2)# - prey.radius
    #distances[i,2] = checkDistance(distances[i,1], Pd)
    checkDistance(distances[i,1], Pd, evalArr)
    #prey.evaluations[i,2] = distances[i,2]

  end
  if 0 < size(prey.evaluations.eval, 1) >= t
    for j in 1:6
      prey.evaluations.eval[t,j] = evalArr[j]
    end
  end

  #println(evalArr)

end

function evaluationCSV(arr::Array{Float64,2}, name::String)
  filename = string(name, ".csv")
  df = convert(DataFrame, arr')
  df |> CSV.write(filename)
end

function evaluationCSV(arr::Array{Float64,2}, name::String, i::Int64)
  filename = string(name, i, ".csv")
  df = convert(DataFrame, arr')
  df |> CSV.write(filename)
end
