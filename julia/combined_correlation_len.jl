#!/usr/bin/env julia

#ENV["DISPLAY"] = ""
using Distributed
using Dates
using Printf
using Random
using NCDatasets
@everywhere using DIVAnd
using StatsBase
using FileIO
using PyPlot
using Glob
using JLD2
using DataStructures

include("common.jl")


clversion = "varlen1"

sz = (length(lonr),length(latr),length(depthr))
sz = (length(lonr),length(latr))
@show sz

default_minlenz = 25.

domains = [
    # Arctic 1
    #(len = 1, lonr = (-44.25,70), latr = (56.5,83)),
    (len = 1, minlenz = 25, lonr = (-Inf,70), latr = (56.5,83)),
    (len = 2, minlenz = 25, lonr = (-Inf,70), latr = (56.5,83)),
    # Baltic 0.7
    (len = 0.7, minlenz = 25, lonr = (9.4,30.9), latr = (53,60)),
    (len = 0.7, minlenz = 25, lonr = (14,30.9), latr = (60,65.9)),
    # NS 0.7
    (len = 0.7, minlenz = 25, lonr = (-5.4,13), latr = (47.9,62)),
    # # Med 2
    (len = 2, minlenz = 25, lonr = (-0.8,36.375), latr = (30,46.375)),
    (len = 2, minlenz = 25, lonr = (-7,36.375), latr = (30,43)),
    # # BS 1.5
    (len = 1.5, minlenz = 15, lonr = (26.5,41.95), latr = (40,47.95)),
]

# Atlantic 3
default_len = 3.


len = fill(default_len,sz)
minlenz = fill(default_minlenz,sz)


for i = 1:length(domains)
    inside = (domains[i].lonr[1] .<= lonr .<= domains[i].lonr[2]) .&
       (domains[i].latr[1] .<= latr' .<= domains[i].latr[2])
    len[inside] .= domains[i].len
    minlenz[inside] .= domains[i].minlenz
end



hx,hy,h = DIVAnd.load_bath(bathname,bathisglobal,lonr,latr)

mask,pmn = DIVAnd.domain(bathname,bathisglobal,lonr,latr)
#len[.!mask] .= NaN

slen = (100e3,100e3)
slen = (800e3,800e3)

lenf = DIVAnd.diffusion(mask,pmn,slen,len)
minlenzf = DIVAnd.diffusion(mask,pmn,slen,minlenz)

sigmoid(x) = (tanh(x)+1)/2

@show sigmoid.([-2,-1,0,1,2])

redlen = -0.9 * sigmoid.((-h .+ 100)/20) .+ 1

nearcoast = 1.0 * (1. .- mask)
nearcoastf = copy(nearcoast)

slen = (100e3,100e3)
nearcoastf = @time DIVAnd.diffusion(
    trues(sz),pmn,slen,nearcoast;
    boundary_condition! = x -> x[.!mask] .= 1
)


lenf2 = (1 .- nearcoastf) .* lenf + nearcoastf .* lenf/5

#@code_warntype DIVAnd.diffusion(mask,pmn,slen,len)
lenf2[.!mask] .= NaN
minlenzf[.!mask] .= NaN

lenfilled = DIVAnd.ufill(lenf2,isfinite.(lenf2));
minlenzfilled = DIVAnd.ufill(minlenzf,isfinite.(minlenzf));

#ioff()
ion()
clf()
title("Correlation length")
#pcolormesh(lonr,latr,lenf'-len')
#pcolormesh(lonr,latr,lenf')
#pcolormesh(lonr,latr,redlen')
#pcolormesh(lonr,latr,nearcoastf')
pcolormesh(lonr,latr,lenf2')
#pcolormesh(lonr,latr,lenfilled')
aspect_ratio = 1/cosd(mean(latr))
gca().set_aspect(aspect_ratio)
colorbar()
figdir = joinpath(datadir,"Figures")
mkpath(figdir)
savefig(joinpath(figdir,"correlation_len_$(clversion)_$(deltalon).png"))
clf()
title("minimum vert. correlation length")
pcolormesh(lonr,latr,minlenzf')
colorbar()
savefig(joinpath(figdir,"minlenz_$(clversion)_$(deltalon).png"))


filename_corrlen = joinpath(datadir,"correlation_len_$(clversion)_$(deltalon).nc")
NCDataset(filename_corrlen,"c") do ds
    defVar(ds,"correlation_length",lenfilled,("lon","lat"))
    defVar(ds,"minlenz",minlenzfilled,("lon","lat"))
end
