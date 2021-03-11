#!/usr/bin/env julia

ENV["DISPLAY"] = ""
using Distributed
using Dates
using Printf
using Random
using Profile
using NCDatasets
using PhysOcean
@everywhere using DIVAnd
using StatsBase
using FileIO
#using PyPlot
using Glob
using JLD2
using DataStructures

# uses lonr,latr,varname,figdir,bx,by,b,obslon,obslat...
# from global scope

#=
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
=#


function plotres_timeindex(timeindex,sel,fit,erri)
    @show timeindex
end

ENV["JULIA_DEBUG"] = "DIVAnd"

include("common.jl")
clversion = "varlen1"


sz = (length(lonr),length(latr),length(depthr))
@show sz
mkpath(datadir)

#analysistype = "background"
#analysistype = "monthly"
analysistype = get(ENV,"ANALYSIS_TYPE","background")

@show analysistype

lenz = [min(max(25.,1 + depthr[k]/10),500.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]

#varname_index = parse(Int,get(ENV,"VARNAME_INDEX","2"))
varname_index = parse(Int,get(ENV,"VARNAME_INDEX","3"))

@show varname_index
varname = varlist[varname_index]
varname_ = replace(varname," " => "_")

#maxit = 100
maxit = 1000
#maxit = 10000
reltol = 1e-6;
reltol = 1e-9;
#maxit = 5000
#len_background = 1000_000
epsilon2_background = 1.


filename_corrlen = joinpath(datadir,"correlation_len_$(clversion)_$(deltalon).nc")

lenx_2D = NCDataset(filename_corrlen,"r") do ds
    ds["correlation_length"][:,:] * 111e3
end

lb = 6
lenx = repeat(lenx_2D,inner=(1,1,sz[3]))
#lenx_background = lenx*3
lenx_background = lenx*lb

if analysistype == "background"
    epsilon2 = epsilon2_background

    # correlation length in meters (in x, y, and z directions)
    # lenx = fill(800_000.,sz)
    # leny = fill(800_000.,sz)

    # lenx = fill(len_background,sz)
    # leny = fill(len_background,sz)

    lenx = lenx_background
    leny = lenx_background

    background = nothing
    TS = TSbackground
else
    # monthly
    TS = TSmonthly

    leny = copy(lenx)
    epsilon2 = 1.

    filenamebackground = joinpath(datadir,"Case/$(varname_)-res-$(deltalon)-epsilon2-$(epsilon2_background)-$(clversion)-lb$(lb)-maxit-$(maxit)-reltol-$(reltol)-background/Results/$(varname_)_background.nc")
    background = DIVAnd.backgroundfile(filenamebackground,varname,TSbackground)

    #debug
    # TS = DIVAnd.TimeSelectorYearListMonthList(
    #     [1970:2020],
    #     [m:m for m in 4:4])
    # maxit = 200
    # maxit = 500
    # maxit = 100
end


#--

@show varname

casedir = joinpath(datadir,"Case/$(varname_)-res-$(deltalon)-epsilon2-$(epsilon2)-$(clversion)-lb$(lb)-maxit-$(maxit)-reltol-$(reltol)-$(analysistype)")
mkpath(casedir)

@info "casedir: $casedir"

gitdiff(casedir)

# Figures
figdir = joinpath(casedir,"Figures")
mkpath(figdir)

# Results
resdir = joinpath(casedir,"Results")
mkpath(resdir)

filename = joinpath(resdir,"$(varname_)_$(analysistype).nc")

#rm(filename)

bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);

filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)

obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(
    Float64,filenames_obs,varname)



obslon = mod.(obslon .+ 180,360) .- 180

#=
sel = 1:10
obslon = obslon[sel]
obslat = obslat[sel]
obsdepth = obsdepth[sel]
obstime = obstime[sel]
=#


filename_rdiag = joinpath(obsdir,"weights","$(varname)_rdiag.nc")

if isfile(filename_rdiag)
    rdiag = NCDataset(filename_rdiag,"r") do ds
        ds[varname * "_rdiag"][:]
    end
else
    @info "creating '$filename_rdiag'"
    #rdiag = 1.0 ./ DIVAnd.weight_RtimesOne((obslon,obslat,obsdepth,Dates.datetime2julian.(obstime)),(0.1,0.1,10.,60.))
    rdiag = 1.0 ./ DIVAnd.weight_RtimesOne((obslon,obslat,obsdepth),(0.1,0.1,10.))

    NCDataset(filename_rdiag,"c") do ds
        defVar(ds,varname * "_rdiag", rdiag, ("observations",))
    end
end




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
else
    out = repeat((32 .<= lonr) .& (latr' .<= 30.2),inner=(1,1,length(depthr)))
    mask[out] .= false
end

mean_value = mean(obsvalue[sel])
@show mean_value
    size(mask)

    P35 = Vocab.SDNCollection("P35")
    c = Vocab.findbylabel(P35,[varname])[1]
    parameter_keyword_urn = Vocab.notation(c)

metadata = OrderedDict(
    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-chemistry, ...)
    "project" => "EMODNET-chemistry",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "institution_urn" => "SDN:EDMO::1579", # GHER
    # Name and emails from authors
    #"Author_e-mail" => ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

    # Source of the observation
    "source" => "Observations from EMODnet-Chemistry",

    # SeaDataNet Vocabulary P35 URN
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p35
    # example: SDN:P35::WATERTEMP
    "parameter_keyword_urn" => parameter_keyword_urn,

    # List of SeaDataNet Parameter Discovery Vocabulary P02 URNs
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p02
    # example: ["SDN:P02::TEMP"]
    "search_keywords_urn" => varinfo[varname]["search_keywords_urn"],

    # List of SeaDataNet Vocabulary C19 area URNs
    # SeaVoX salt and fresh water body gazetteer (C19)
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=C19
    # example: ["SDN:C19::3_1"]
    "area_keywords_urn" => area_keywords_urn,
    "bathymetry_source" => "The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003",
    # # NetCDF CF standard name
    # # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
    # # example "standard_name" = "sea_water_temperature",
    "netcdf_standard_name" => varinfo[varname]["netcdf_standard_name"],
    "netcdf_long_name" => varname,
    "netcdf_units" => varinfo[varname]["netcdf_units"],
    "product_version" => "1.0",
    # # Abstract for the product
    # "abstract" => "...",

    # # This option provides a place to acknowledge various types of support for the
    # # project that produced the data
    # "acknowledgement" => "...",

    # "documentation" => "https://doi.org/doi_of_doc",

    # # Digital Object Identifier of the data product
    # "doi" => "...",
);




ncglobalattrib, ncvarattrib = SDNMetadata(metadata, filename, varname, lonr, latr)


dbinfo = @time DIVAnd.diva3d(
    (lonr,latr,depthr,TS),
    (obslon[sel],obslat[sel],obsdepth[sel],obstime[sel]),
    obsvalue[sel],
#              (ones(sz),ones(sz),ones(sz)),
    (lenx,leny,lenz),
    epsilon2 .* rdiag,
    filename,varname,
    mask = mask,
    bathname = bathname,
#              plotres = plotres_timeindex,
#    plotres = plotres,
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
    tol = reltol,
    divamethod = DIVAndrun,
    background = background,
    ncvarattrib = ncvarattrib,
    ncglobalattrib = ncglobalattrib,
)

used = dbinfo[:used]
obsresiduals = dbinfo[:residuals]

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
    obsvalue,
    (obslon,obslat,obsdepth,obstime),obsids,
    used=used);

NCDataset(filename_residual,"a") do ds
    defVar(ds,varname * "_residual", obsresiduals[used], ("observations",))
end

JLD2.@save replace(filename,".nc" => "_dbinfo.jld2") dbinfo
end
