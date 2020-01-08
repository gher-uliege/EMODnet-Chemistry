using DIVAnd
using PyPlot
using Dates


# get file from
# http://www.emodnet-chemistry.eu/products/catalogue#/metadata/3ed92363-3e1b-499f-ad7a-2192eabac46b

fname = expanduser("~/Downloads/North_Sea_eutrophication_and_ocean_acidification_aggregated_v2018.txt")

# list all parameters in file

parameters = ODVspreadsheet.listparameters(fname)

println.(parameters);

obsvalue,obslon,obslat,obsdepth,obstime,obsids = ODVspreadsheet.load(
    Float64,[fname],["Water body nitrate"],nametype = :localname)


@info "number of observations: $(length(obsvalue))"

sel = (obsdepth .< 10) .& (Dates.month.(obstime) .== 1);
scatter(obslon[sel],obslat[sel],10,obsvalue[sel])
colorbar()
