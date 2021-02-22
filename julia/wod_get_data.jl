using PhysOcean
using Dates
ENV["JULIA_DEBUG"] = "all"

include("common.jl")


# Name of the variable

varname = varnames[1]
for varname = varnames
    basedir = joinpath(woddir,varname)
    mkpath(basedir)

    @info "get $varname"
    WorldOceanDatabase.download(lonr,latr,timerange,varname,email,basedir)
end

timerange = [Date(2000,1,1),Date(2000,12,31)]

lonrange = lonr
latrange = latr
