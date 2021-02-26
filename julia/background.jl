#!/usr/bin/env julia

ENV["DISPLAY"] = ""
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
using JLD2


# uses lonr,latr,varname,figdir,bx,by,b,obslon,obslat...
# from global scope

function plotres(timeindex,sel,fit,erri)
    tmp = copy(fit)
    #tmp[erri .> .5] .= NaN;
    figure(figsize = (12,8))
    aspect_ratio = 1/cosd(mean(latr))

    for k = 1:size(fit,3)
        clf()
        subplot(1,2,1)
        title("Time index $(timeindex); depth = $(depthr[k])")

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
    PyPlot.close()
end



function plotres_timeindex(timeindex,sel,fit,erri)
    @show timeindex
end

ENV["JULIA_DEBUG"] = "DIVAnd"

include("common.jl")
sz = (length(lonr),length(latr),length(depthr))

mkpath(datadir)

#analysistype = "background"
#analysistype = "monthly"
analysistype = get(ENV,"ANALYSIS_TYPE","background")

TSbackground = DIVAnd.TimeSelectorYearListMonthList(
    [1970:2020],
    [1:12])
lenz = [min(max(25.,1 + depthr[k]/150),500.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]

varname_index = parse(Int,get(ENV,"VARNAME_INDEX","2"))
varname = varlist[varname_index]

#varname = 

if analysistype == "background"
    epsilon2 = 0.1
    epsilon2 = 1.

    # correlation length in meters (in x, y, and z directions)
    lenx = fill(800_000.,sz)
    leny = fill(800_000.,sz)

    lenx = fill(1000_000.,sz)
    leny = fill(1000_000.,sz)

    maxit = 100
    background = nothing
    TS = TSbackground
else
    # monthly
    TS = DIVAnd.TimeSelectorYearListMonthList(
        [1970:2020],
        [m:m for m in 1:12])

    lenx = fill(250_000.,sz)
    leny = fill(250_000.,sz)
    epsilon2 = 1.
    maxit = 10
    filenamebackground = joinpath(datadir,"Case/$(varname)-res-$(deltalon)-epsilon2-1.0-lenx-1.0e6-maxit-100-background/Results/$(varname)_background.nc")
    background = DIVAnd.backgroundfile(filenamebackground,varname,TSbackground)
end


#--

@show varname

casedir = joinpath(datadir,"Case/$varname-res-$(deltalon)-epsilon2-$(epsilon2)-lenx-$(mean(lenx))-maxit-$(maxit)-$(analysistype)")
mkpath(casedir)

@info "casedir: $casedir"

gitdiff(casedir)

# Figures
figdir = joinpath(casedir,"Figures")
mkpath(figdir)

# Results
resdir = joinpath(casedir,"Results")
mkpath(resdir)

filename = joinpath(resdir,"$(varname)_$(analysistype).nc")

#rm(filename)

bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);

filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)

obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(
    Float64,filenames_obs,varname)


obslon = mod.(obslon .+ 180,360) .- 180

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


filename_residual = replace(filename,".nc" => "_residuals.nc")

#----------------
if isfile(filename_residual)
    #rm(filename)
    @info "filename $filename_residual already exists; skipping"
else

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

mask,(pm,pn,po),(xi,yi,zi) = DIVAnd.domain(bathname,bathisglobal,lonr,latr,depthr)

# the 2 largest water bodies (include Black Sea) at 0.1 degree
if deltalon == 0.1
    label = DIVAnd.floodfill(mask);
    mask = 0 .< label .<= 2
end

mean_value = mean(obsvalue[sel])
@show mean_value
size(mask)

dbinfo = @time DIVAnd.diva3d(
    (lonr,latr,depthr,TS),
    (obslon[sel],obslat[sel],obsdepth[sel],obstime[sel]),
    obsvalue[sel],
#              (ones(sz),ones(sz),ones(sz)),
    (lenx,leny,lenz),
    epsilon2,
    filename,varname,
    mask = mask,
    bathname = bathname,
#              plotres = plotres_timeindex,
    plotres = plotres,
    timeorigin = timeorigin,
#              fitcorrlen = true,
#    transform = transform,
#    memtofit = memtofit,
#    QCMETHOD = 3,
    minfield = minimum(obsvalue),
    maxfield = maximum(obsvalue),
    #solver = :direct,
    #surfextend = true,
    coeff_derivative2 = [0.,0.,1e-8],
    inversion = :cg_amg_sa,
    maxit = maxit,
    background = background,
)

used = dbinfo[:used]
residuals = dbinfo[:residuals]

@show sum(used)
@show mean(used)
DIVAnd.saveobs(
    filename,
    (obslon,obslat,obsdepth,obstime),obsids,
    used=used);


if isfile(filename_residual)
    rm(filename_residual)
end

DIVAnd.saveobs(
    filename_residual,
    varname,
    residuals,
    (obslon,obslat,obsdepth,obstime),obsids,
    used=used);


JLD2.@save replace(filename,".nc" => "_dbinfo.jld2") dbinfo
end
