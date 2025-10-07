#!/usr/bin/env julia
# Creation of the climatologies
# -----------------------------

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
using Glob
using JLD2
using DataStructures
using Interpolations

#ENV["JULIA_DEBUG"] = "DIVAnd"

# Include the configuration file
# ------------------------------

include("common.jl")

# Information about correlation length
# ------------------------------------

clversion = "varlen1"
sz = (length(lonr),length(latr),length(depthr))
@show sz

# Get the type of analysis from the main script
analysistype = get(ENV,"ANALYSIS_TYPE","background")
@info("Analysis type: $(analysistype)")

# Get the variable name from the main script
varname_index = parse(Int,get(ENV,"VARNAME_INDEX", "1"))
@info("Working on variable number $(varname_index)")
varname = varlist[varname_index]
varname_ = replace(varname," " => "_")
@show varname

#maxit = 100
# maxit = 1000
maxit = 5000
#maxit = 10000

reltol = 1e-6;
reltol = 1e-9;

#len_background = 1000_000
epsilon2_background = 10

suffix = "bathcl"
suffix = "bathcl-go"
suffix = "bathcl-go-exclude"
suffix = "bathcl-go-exclude-rdiag"
suffix = "bathcl-go-exclude-mL"
suffix = "bathcl-go-exclude-mL-1960-exNS2"

# Prepare correlation length field
# --------------------------------

filename_corrlen = joinpath(datadir,"correlation_len_$(clversion)_$(deltalon).nc")

ds = NCDataset(filename_corrlen,"r")
lenx_2D = ds["correlation_length"][:,:] * 111e3
minlenz = ds["minlenz"][:,:]
close(ds)

#lenx_2D[lenx_2D .< 80_000] .= 80_000

#lenz = [min(max(25.,1 + depthr[k]/10),500.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]
lenz = [min(max(minlenz[i,j],depthr[k]/10),500.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]

lb = 6
lb = 5
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
    epsilon2 = 10
    #epsilon2 = 5
    epsilon2 = 1.
    epsilon2 = 2.
    #epsilon2 = 0.5

    filenamebackground = joinpath(datadir,"Case/$(varname_)-res-$(deltalon)-epsilon2-$(epsilon2_background)-$(clversion)-lb$(lb)-maxit-$(maxit)-reltol-$(reltol)-$(suffix)-background/Results/$(varname_)_background.nc")
    background = DIVAnd.backgroundfile(filenamebackground,varname,TSbackground)

    #debug
    # TS = DIVAnd.TimeSelectorYearListMonthList(
    #     [1970:2020],
    #     [m:m for m in 4:4])
    # maxit = 200
    # maxit = 500
    # maxit = 100
end

# reduced correlation in Black Sea
BS = repeat((26.5 .<= lonr .<= 41.95) .& (40 .<= latr' .<= 47.95),inner=(1,1,length(depthr)))

@show mean(lenx[BS])
@show mean(leny[BS])

if analysistype == "background"
    lenx[BS] .= lenx[BS] / 3
end

@show mean(lenx[BS])
@show mean(leny[BS])

hxi,hyi,h = DIVAnd.load_bath(bathname,bathisglobal,lonr,latr)
mask2D,(pm2D,pn2D) = DIVAnd.domain(bathname,bathisglobal,lonr,latr)

h[.!mask2D] .= 0

slen = (50e3,50e3)
hf = DIVAnd.diffusion(mask2D,(pm2D,pn2D),slen,h)

bath_RL = DIVAnd.lengraddepth((pm2D,pn2D),hf,20e3; hmin = 30)
clamp!(bath_RL,0.5,1);
bath_RL[.!mask2D] .= NaN
#bath_RLf = DIVAnd.diffusion(mask2D,(pm2D,pn2D),slen,bath_RL)

#=
clf(); pcolormesh(lonr,latr,bath_RL'); colorbar();
figdir = joinpath(datadir,"Figures")
mkpath(figdir)
savefig(joinpath(figdir,"bath_RL_$(deltalon).png"))
=#

bath_RL = DIVAnd.ufill(bath_RL,mask2D)

# This also updates leny
lenx .= bath_RL .* lenx

#@show mean(lenx[BS])
#@show mean(leny[BS])

#suffix="redvert"
#suffix = "bathcl"

#--

# Load data
# ---------

# Bathymetry
bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);

# Observations (netCDF files)
filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)
obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(Float64,filenames_obs,varname)
# Edit longitude to lie between -180. and 180.
obslon = mod.(obslon .+ 180,360) .- 180

# Create data weights
# -------------------

rdiag_len = 0.1
mkpath(joinpath(obsdir,"weights"))
#filename_rdiag = joinpath(obsdir,"weights","$(varname)_len$(rdiag_len)_rdiag.nc")
filename_rdiag = joinpath(obsdir,"weights","$(varname)_rdiag.nc")

if isfile(filename_rdiag)
    @info "loading '$filename_rdiag'"
    rdiag = NCDataset(filename_rdiag,"r") do ds
        ds[varname * "_rdiag"][:]
    end
else
    @info "creating '$filename_rdiag'"
    #rdiag = 1.0 ./ DIVAnd.weight_RtimesOne((obslon,obslat,obsdepth,Dates.datetime2julian.(obstime)),(0.1,0.1,10.,60.))
    rdiag = 1.0 ./ DIVAnd.weight_RtimesOne((obslon,obslat,obsdepth),(rdiag_len,rdiag_len,10.))

    NCDataset(filename_rdiag,"c") do ds
        defVar(ds,varname * "_rdiag", rdiag, ("observations",))
    end
end

sel = obsvalue .>= 0

# Exclude values flagged as unrepresentative
# ------------------------------------------

# Need to set the flag `do_exclude` to `true` in file `common.jl`  
if do_exclude 
    fnames_exclude = glob("exclude_" * replace(varname," " => "_")  * "*.csv",excludedir)
    exclude_sampleid_set = Set(exclude_sampleid(fnames_exclude))
    @show length(obsvalue)
    obs_sampleid = sampleid.(obslon,obslat,obsdepth,obstime,obsids)
    good = [sid ∉ exclude_sampleid_set for sid in obs_sampleid];

    @info "remove $(sum(.!good)) unrepresentative value(s)"
    @info "remove $(sum(.!sel)) negative value(s)"
end

# Prepare distance to coast
# -------------------------

# Read from data file
dsc = NCDataset(joinpath(datadir,"dist2coast.nc"))
distance2coast = dsc["distance2coast"][:,:]
distance2coast_lon = dsc["lon"][:]
distance2coast_lat = dsc["lat"][:]

distance2coast_lat = distance2coast_lat[end:-1:1]
distance2coast = distance2coast[:,end:-1:1]
close(dsc)

# Interpolate on the grid
itp = interpolate((distance2coast_lon,distance2coast_lat),
            distance2coast,Gridded(Linear()))
obsdistance2coast = itp.(obslon,obslat)
rdiag_coastal = ones(size(obsvalue))
coastal_lim = 10 # km
rdiag_coastal = ones(size(obsdistance2coast));
rdiag_coastal[ obsdistance2coast .<  coastal_lim] .= 30;
rdiag = rdiag .* rdiag_coastal;

@show sum(rdiag_coastal .> 1)
@show sum(rdiag_coastal .<= 1)

#=
clf(); hist(obsdistance2coast,0:5:100)
savefig("/data/Figures/dist2coast_phosphate.png")
=#

# (-18.61436491935485, 46.021723790322554, 29.82312530335926, 72.3762527284168)

# sel = sel .& good

obslon = obslon[sel]
obslat = obslat[sel]
obsdepth = obsdepth[sel]
obstime = obstime[sel]
obsvalue = obsvalue[sel]
obsids = obsids[sel]
rdiag = rdiag[sel]

# variable specific code
if isfile(varname_ * ".jl")
    include(varname_ * ".jl")
end

casedir = joinpath(datadir,"Case/$(varname_)-res-$(deltalon)-epsilon2-$(epsilon2)-$(clversion)-lb$(lb)-maxit-$(maxit)-reltol-$(reltol)-$(suffix)-$(analysistype)")
mkpath(casedir)

@info "casedir: $casedir"

#gitdiff(casedir)

# Figures
figdir = joinpath(casedir,"Figures")
mkpath(figdir)

# Results
resdir = joinpath(casedir,"Results")
mkpath(resdir)

filename = joinpath(resdir,"$(varname_)_$(analysistype).nc")


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


"""
Read the attributes from the text file storing the 
different key-value pairs.
"""
function read_attrib_file(filename::String, colsep::String="|")::OrderedDict
    ncattrib = OrderedDict{String,String}()
    open(filename, "r") do fr
        while !eof(fr)
            line = readline(fr)
            linesplit = split(line,colsep)
            global key
            if length(linesplit) == 2
                key = String(linesplit[1]);
                value = String(linesplit[2])
                ncattrib[key] = value
            elseif length(linesplit) == 1
                ncattrib[key] = ncattrib[key] * linesplit[1]
            else
                @warn("There is a problem with the number of column in the text file")
                @show linesplit
            end
        end
    end
    return ncattrib
end

ncglobalattrib = read_attrib_file(joinpath(datadir, "Attributes/ncglobalattrib_$(varname_).txt"))
ncvarattrib = read_attrib_file(joinpath(datadir, "Attributes/ncvarattrib_$(varname_).txt"))

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
#    maxfield = maximum(obsvalue),

    solver = :direct,
    MEMTOFIT = 500,

    #surfextend = true,
    coeff_derivative2 = [0.,0.,1e-8],
#=
    inversion = :cg_amg_sa,
    maxit = maxit,
    tol = reltol,
    divamethod = DIVAndrun,
=#
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
