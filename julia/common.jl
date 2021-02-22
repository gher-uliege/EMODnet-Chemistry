# common parameters to various scripts

# Grid and resolutions

deltalon = 0.1
deltalat = 0.1

deltalon = 0.5
deltalat = 0.5

lonr = -40.:deltalon:55.
latr = 24.:deltalat:67.


# List of depths: selected as the union of the different products

depthr = Float64[
  0, 10, 20, 30, 50, 75, 100, 125, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000,
  1100, 1200, 1300, 1400, 1500, 1750, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500]


# time range of the in-situ data
timerange = [Date(1000,1,1),Date(3000,12,31)]


# set EMAIL address in ~/.bachrc, for example
# export EMAIL="..."

email = ENV["EMAIL"]

datadir = "/data"
woddir = joinpath(datadir,"WOD")


# Name of the variables
varnames = ["Oxygen","Phosphate","Silicate","Nitrate and Nitrate+Nitrite","pH","Chlorophyll"]
