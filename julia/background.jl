#!/usr/bin/env julia

using Distributed
using Dates
using Printf
using Random
using Profile
using NCDatasets
using PhysOcean
@everywhere import DIVAnd
using StatsBase
using FileIO
using PyPlot
using Glob

ENV["JULIA_DEBUG"] = "DIVAnd"

include("common.jl")

timerange = [DateTime(1900,1,1),DateTime(2017,12,31)]

mkpath(datadir)

epsilon2 = 0.1
#epsilon2 = 0.01
epsilon2 = 1.

sz = (length(lonr),length(latr),length(depthr))

# correlation length in meters (in x, y, and z directions)
#lenx = fill(200_000.,sz)
#leny = fill(200_000.,sz)

#lenx = fill(500_000.,sz)
#leny = fill(500_000.,sz)
lenx = fill(800_000.,sz)
leny = fill(800_000.,sz)
lenz = [min(max(25.,1 + depthr[k]/150),300.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]


moddim = [0,0,0]
memtofit = 300




#TS = DIVAnd.TimeSelectorRunningAverage(
#    [mean(timerange - timerange[1]) + timerange[1]],
#    90)


#TS = DIVAnd.TimeSelectorYearListMonthList([1900:2017],[[12,1,2],[3,4,5],[6,7,8],[9,10,11]])

# TS = DIVAnd.TimeSelectorYearListMonthList(
#                                           [1900:2017],
#                                           [[m] for m in 1:12])


TS = DIVAnd.TimeSelectorYearListMonthList(
    [1900:2017],
    [1:12])

varname = varlist[2]
@show varname
filename = joinpath(resdir,"$(varname)_background_test.nc")

#rm(filename)

bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);


function plotres(timeindex,sel,fit,erri)
    tmp = copy(fit)
    #tmp[erri .> .5] .= NaN;
    figure(figsize = (12,8))
    aspect_ratio = 1/cosd(mean(latr))

    for k = 1:size(fit,3)
        clf()
        subplot(1,2,1)
        title("$(timeindex)")

        Δz = depthr[min(k+1,length(depthr))] - depthr[max(k-1,1)]
        @show Δz

        # select the data near depthr[k]
        sel_depth = sel .& (abs.(obsdepth .- depthr[k]) .<= Δz)

        #vmin = minimum(value[sel_depth])
        #vmax = maximum(value[sel_depth])

        tmpk = tmp[:,:,k]
        vmin,vmax = extrema(tmpk[isfinite.(tmpk)])

        # plot the data
        scatter(obslon[sel_depth],obslat[sel_depth],10,obsvalue[sel_depth];
                vmin = vmin, vmax = vmax)
        xlim(minimum(lonr),maximum(lonr))
        ylim(minimum(latr),maximum(latr))
        colorbar(orientation="horizontal")
        contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
        gca().set_aspect(aspect_ratio)

        # plot the analysis
        subplot(1,2,2)
        pcolor(lonr,latr,permutedims(tmp[:,:,k],[2,1]);
               vmin = vmin, vmax = vmax)
        colorbar(orientation="horizontal")
        contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
        gca().set_aspect(aspect_ratio)
        savefig(joinpath(figdir,"analysis-$(varname)-$(timeindex)-$(depthr[k]).png"))
    end
end



function plotres_timeindex(timeindex,sel,fit,erri)
    @show timeindex
end


filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)

obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(
    Float64,filenames_obs,varname)


#bad = (-11 .<= obslon .<= 0.7) .& (34 .<= obslat .<= 47) .& (obsvalue .<= 100);
#minvalue = 0.01
#sel = (obsvalue .> minvalue)
#=

obslon = obslon[sel]
obslat = obslat[sel]
obsdepth = obsdepth[sel]
obstime = obstime[sel]
obsvalue = obsvalue[sel]
obsids = obsids[sel]
=#

DIVAnd.checkobs((obslon,obslat,obsdepth,obstime),obsvalue,obsids)


#----------------
if isfile(filename)
    rm(filename)
end

#=
ioff()
clf()
hist(obsvalue)
savefig(joinpath(figdir,"$varname.png"))

anam_maxval = percentile(obsvalue,90)
transform = DIVAnd.Anam.loglin(anam_maxval)
clf()
hist(transform[1].(obsvalue))
savefig(joinpath(figdir,"$(varname)_anam.png"))
=#

#=
#@save "dbinfo.jld" dbinfo
qcvalues = dbinfo[:qcvalues]


maxpercentile = 99.
maxpercentile = 95.

maxqcvalue = percentile(qcvalues[isfinite.(qcvalues)],maxpercentile)

obsvaluemin,obsvaluemax = percentile(obsvalue[isfinite.(obsvalue)],[0.01, 99.9])

@show maxqcvalue

#sel = (qcvalues .<= maxqcvalue) .& (obsvaluemin .<= obsvalue .<= obsvaluemax)
sel = (qcvalues .<= maxqcvalue) .& (obsvaluemin .<= obsvalue) .& (obsvalue .<= obsvaluemax)

@show sum(sel)
=#

#filename = replace(@__FILE__,r".jl$" => "_$(randstring()).nc")

sel = trues(size(obsvalue))


dbinfo = @time @profile DIVAnd.diva3d(
    (lonr,latr,depthr,TS),
    (obslon[sel],obslat[sel],obsdepth[sel],obstime[sel]),
    obsvalue[sel],
#              (ones(sz),ones(sz),ones(sz)),
    (lenx,leny,lenz),
    epsilon2,
    filename,varname,
    bathname = bathname,
#              plotres = plotres_timeindex,
    plotres = plotres,
    timeorigin = timeorigin,
#              fitcorrlen = true,
#    transform = transform,
    memtofit = memtofit,
    QCMETHOD = 3,
    minfield = minimum(obsvalue),
    solver = :direct,
    #surfextend = true,
    coeff_derivative2 = [0.,0.,1e-8],
)

#=

used = dbinfo[:used]
sel_used = copy(sel)
sel_used[.!used] = false;
=#

#=
open("prof_all_flat_count2_$VERSION.out","w") do f
    Profile.print(f; format = :flat, sortedby = :count)
end

open("prof_all_flat2_$VERSION.out","w") do f
    Profile.print(f; format = :flat)
end

open("prof_all2_$VERSION.out","w") do f
    Profile.print(f)
end
=#
