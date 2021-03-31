using NCDatasets
using PyPlot
using DIVAnd

# Datafile = Most recent time series file prepared by Julie
datafile = "./Final_for_DIVA_Eutrophication_Acidification_NAT_all_time_series.nc"
isfile(datafile) ? @debug("Already downloade") : download("https://dox.ulg.ac.be/index.php/s/H8FHY0Dl3ODniPG/download", datafile)

varname = "Water body dissolved oxygen concentration"

# 1) Reading with NCODV
obsval, obslon, obslat, obsdepth, obstime, obsid =
                NCODV.load(Float64, datafile, varname);

@show(length(obslon), unique(obslon))
println("It seems not all the data were read")

# 2) Reading with classic NCDatasets
# (fails)

nc = NCDatasets.Dataset(datafile, "r")
try
    time = nc["var1"][:]
catch e
    println("Fail reading time variable:")
    println(e)
end
close(nc)

# 3) Reading only the data values (years)
nc = NCDatasets.Dataset(datafile, "r")
    time_year = nc["var1"].var[:]
close(nc)

sum(time_year .> 1800)
