#!/usr/bin/env julia

#ENV["DISPLAY"] = ""
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

ENV["JULIA_DEBUG"] = "DIVAnd"
ENV["JULIA_DEBUG"] = ""

include("common.jl")
year0 = yearlist[1][1]
year1 = yearlist[1][end]

cdilist = joinpath(datadir,"export.zip")
if !isfile(cdilist)
    download("https://emodnet-chemistry.maris.nl/download/export.zip",cdilist)
end

i = 1
for i = 1:length(varlist)

    varname = varlist[i]
    varname_ = replace(varname," " => "_")


    filename_src = joinpath(datadir,"Case/$(varname_)-res-0.25-epsilon2-2.0-varlen1-lb5-maxit-5000-reltol-1.0e-9-bathcl-go-exclude-mL-1960-exNS2-monthly/Results/$(varname_)_monthly.nc")

    resdir = dirname(filename_src)
    xmlname = joinpath(resdir,"$(varname_).xml")

    filename = replace(filename_src,"_monthly.nc" => ".nc")

    DIVAnd.derived(filename_src,varname,filename)

    titlestr = "European seas - DIVAnd 4D monthly analysis of $varname $year0/$year1 v2021"
    NCDataset(filename,"a") do ds
        ds.attrib["title"] = titlestr
    end

    #ds = NCDataset(filename)

    files = [filename]

    url_path = "All European Seas"

    absstr = """
$varname - Monthly Climatology for the European Seas for the period $(TSbackground.yearlists[1][1])-$(TSbackground.yearlists[1][end]) on the domain from longitude $(lonr[1]) to $(lonr[end]) degrees East and latitude $(latr[1]) to $(latr[end]) degrees North.
Data Sources: observational data from SeaDataNet/EMODnet Chemistry Data Network.
Description of DIVA analysis: The computation was done with the DIVAnd (Data-Interpolating Variational Analysis in n dimensions), version 2.7.2, using GEBCO 30sec topography for the spatial connectivity of water masses. Horizontal correlation length and vertical correlation length vary spatially depending on the topography and domain.
Depth range: $(join(string.(depthr),", ")) m.
Units: $(varinfo[varname]["netcdf_units"]).
The horizontal resolution of the produced DIVAnd analysis is $(step(lonr)) degrees."""

    print(absstr)

    cd(dirname(filename)) do
        DIVAnd.divadoxml(
            basename.(files),varname,"EMODNET-chemistry",cdilist,xmlname;
            ignore_errors = true,
            additionalvars = Dict(
                "abstract" => absstr,
            ),
            url_path = url_path,
            WMSexclude = ["obsid"],
        )
    end

end

#=
for i = 1:length(varlist)
    varname = varlist[i]
    varname_ = replace(varname," " => "_")
    filename_src = joinpath(datadir,"Case/$(varname_)-res-0.25-epsilon2-2.0-varlen1-lb5-maxit-5000-reltol-1.0e-9-bathcl-go-exclude-mL-1960-exNS-monthly/Results/$(varname_)_monthly.nc")
    filename = replace(filename_src,"_monthly.nc" => ".nc")
    @show dirname(filename)
end
=#
