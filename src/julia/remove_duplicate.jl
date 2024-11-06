"""Remove the duplicates from the list of residuals,
based on the data files provided by the regional leaders
"""
using DIVAnd


# Files and directories
casenamelist = [
    "Water_body_chlorophyll-a-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_dissolved_inorganic_nitrogen_(DIN)-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_dissolved_oxygen_concentration-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_phosphate-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_silicate-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
]

for casename in casenamelist

    datadir = "/data/EMODnet/Eutrophication/Products/$(casename)/"
    fileglob = glob("*residual*nc", datadir)
    if isempty(fileglob)
        @warn("No residual file found in $(datadir)")
        break
    end

    datafile = fileglob[1]
    figdir = "../figures/domain-split/$(casename)"
    outputdir = joinpath(datadir, "Split_V3/")

    !isdir(outputdir) ? mkpath(outputdir) : @debug("Directory already created")
    !isdir(figdir) ? mkpath(figdir) : @debug("Figure directory already created")

    # Get variable name from file name:
    varname = replace(basename(datafile), "_monthly_residuals.nc" => "")
    varname = replace(varname, "_" => " ")

    @info("Working on variable $(varname)")

    @info("Loading variables from netCDF file $(basename(datafile))")
    obsvalue, obslon, obslat, obsdepth, obstime, obsids = DIVAnd.loadobs(
        Float64, datafile, varname)

    @info("Loading residuals")
    residuals = get_residuals(datafile, varname);

    npoints = length(obsvalue);
    @info("Number of data points: $(npoints)")

    @info("Splitting data into sub-domains")
    domain_split(datafile, outputdir, varname, domainext, obsvalue, obslon, obslat, obsdepth, obstime, obsids, residuals, figdir)

    @info("Splitted files available in $(outputdir)")
    @info(" ")
    @info("Finished processing $(casename)")
end


resobsvalue,resobslon,resobslat,resobsdepth,resobstime,resobsids = loadobs(Float64,"Water_body_chlorophyll-a_monthly_residuals.nc","Water body chlorophyll-a");
obsvalue,obslon,obslat,obsdepth,obstime,obsids = loadobs(Float64,"ArcticSea_Water_body_chlorophyll-a.nc","Water body chlorophyll-a");
Set1 = Set(obsids);
obsmask = [id in Set1 for id = resobsids];
@show length(obsmask)
@show sum(obsmask)
@show length(obsvalue)
