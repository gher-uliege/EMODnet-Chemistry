using PhysOcean
using Dates
using DIVAnd
#ENV["JULIA_DEBUG"] = "all"
ENV["JULIA_DEBUG"] = ""

include("common.jl")


# Name of the variable

varname = varnames[1]
for varname = varnames
    basedir = joinpath(woddir,varname)

    if !isdir(basedir)
        mkpath(basedir)

        @info "get $varname"
        WorldOceanDatabase.download(lonr,latr,timerange,varname,email,basedir)
    else
        @info "already downloaded $varname"
    end
end
#=
timerange = [Date(2000,1,1),Date(2000,12,31)]

lonrange = lonr
latrange = latr
=#

prefixid = "1977-"

varname = varnames[3]
for varname = varnames

    filename_obs = joinpath(woddir,"$(varname)_obs.nc")

    if !isfile(filename_obs)
        basedir = joinpath(woddir,varname)

        obsvalue,obslon,obslat,obsdepth,obstime,obsid = WorldOceanDatabase.load(Float64,basedir,varname; prefixid = prefixid);

        DIVAnd.saveobs(filename_obs,varname,obsvalue,(obslon,obslat,obsdepth,obstime),obsid);
        @info "creating $filename_obs"
    else
        @info "already created $filename_obs"
    end
end
