ENV["DISPLAY"] = ""

using Distributed
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

varname_index = parse(Int,get(ENV,"VARNAME_INDEX","2"))

fname = "/data/Case/Water body dissolved oxygen concentration-res-0.25-epsilon2-1.0-varlen0-maxit-100-monthly/Results/Water body dissolved oxygen concentration_monthly.nc"

analysistype = get(ENV,"ANALYSIS_TYPE","background")
analysistype = "monthly"
#analysistype = "background"

fnames = sort(glob("*-res-0.25-epsilon2-1.0-varlen0-maxit-100-$(analysistype)/Results/*_$(analysistype).nc",joinpath(datadir,"Case")))

if analysistype == "background"
    TS = TSbackground
else
    TS = TSmonthly
end

ioff()

#figdir = "/tmp/test"
#mkpath(figdir)

@time for fname in fnames[2:2]
    figdir = joinpath(dirname(fname),"..","Figures")

    ds = NCDataset(fname)
    varname = ds.attrib["parameter_keyword"]
    close(ds)

    filenames_obs = glob("*" * replace(varname," " => "_") * "*.nc",obsdir)

    plot_section(
        fname,
        filenames_obs,
        bathname;
        #suffix = "_L2",
        figdir = figdir)

    plot_profile(domains,domainnames,fname,filenames_obs,TS; figdir = figdir)
end



