ENV["DISPLAY"] = ""

using Distributed
@everywhere ENV["MPLBACKEND"]="agg"
@everywhere using PyPlot
using DIVAnd
using NCDatasets
using Glob
@everywhere using Statistics
@everywhere using PyCall



@everywhere ioff()
include("common.jl")
include("DIVAnd_plotting.jl")

@show nworkers()

domains = [
    # Arctic
    (label =  1, lonr = (-Inf,70), latr = (56.5,83)),
    # Baltic
    (label =  2, lonr = (9.4,30.9), latr = (53,60)),
    (label =  2, lonr = (14,30.9), latr = (60,65.9)),
    # North Sea
    (label =  3, lonr = (-5.4,13), latr = (47.9,62)),
    # Mediterranean Sea
    (label =  4, lonr = (-0.8,36.375), latr = (30,46.375)),
    (label =  4, lonr = (-7,36.375), latr = (30,43)),
    # Black Sea
    (label =  5, lonr = (26.5,41.95), latr = (40,47.95)),
]





default_label = 6
domainnames = ["Arctic","Baltic","North Sea","Mediterranean Sea","Black Sea","Atlantic"]


#fnames = sort(glob("*-res-0.25-epsilon2-1.0-varlen1-maxit-100-$(analysistype)/Results/*_$(analysistype).nc",joinpath(datadir,"Case")))
#fnames = sort(glob("*-varlen1-maxit-1000-$(analysistype)/Results/*_$(analysistype).nc",joinpath(datadir,"Case")))

fnames = ARGS;
if fnames == []
    #fnames = ["/data/Case/Water_body_ammonium-res-1-epsilon2-1.0-varlen1-lb6-maxit-1000-background/Results/Water_body_ammonium_background.nc"]
end

@show fnames

ioff()

#figdir = "/tmp/test"
#mkpath(figdir)

@time for fname in fnames
    figdir = joinpath(dirname(fname),"..","Figures")
    @show figdir

    ds = NCDataset(fname)
    varname = ds.attrib["parameter_keyword"]

    if ds.dim["time"] == 1
        TS = TSbackground
    else
        TS = TSmonthly
    end
    close(ds)

    filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)

    plot_section(
        fname,
        filenames_obs, TS,
        bathname;
        #suffix = "_L2",
        figdir = figdir)

    plot_section(
        fname,
        filenames_obs, TS,
        bathname;
        #suffix = "_L1",
        suffix = "_L2",
        figdir = figdir)

    plot_profile(domains,domainnames,fname,filenames_obs,TS; figdir = figdir)
end
