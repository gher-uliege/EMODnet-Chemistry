"""Create netCDF and CSV files containing the residuals for each of the
regions. Plots are also created to check that the splitting was correct.
"""

using NCDatasets
using DIVAnd
using DataStructures
using DataFrames
using CSV
using Glob

# Set as true to generate plots
testplot = true
if testplot
    using PyPlot
end

# List of variables (not used anymore)
"""
varlist = ["Water body phosphate",
           "Water body dissolved oxygen concentration",
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen (DIN)",
           "Water body ammonium",
           "Water body silicate",
           ]
"""


# Files and directories
casenamelist = [
    "Water_body_chlorophyll-a-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_dissolved_inorganic_nitrogen_(DIN)-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_dissolved_oxygen_concentration-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_phosphate-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
    "Water_body_silicate-res-0.25-epsilon2-10-varlen1-lb6-maxit-5000-reltol-1.0e-9-bathcl-go-monthly",
]

"""
domainext = OrderedDict(
    "Baltic" => [[9.4, 30.9, 53., 60.], [14. , 30.9, 60., 65.9]],
    "Black Sea" => [[26.5, 41.95, 40., 47.95]],
    "Mediterranean Sea" => [[-0.8, 36.375, 30., 46.375], [-7, 36.375, 30. ,43.]],
    "North Sea" => [[-5.4, 13., 47.9, 62.]],
    "Arctic" => [[-180., 70., 56.5, 83.]],
    "Atlantic" => [[-180., 180., 0., 90.]]
    )
"""

# Julie's email:
# NE Atlantic extends Northward to 48°N and in the Gibraltar strait until
# 5°55'°
domainext = OrderedDict(
    "Baltic" => [[9.4, 30.9, 53., 60.], [14. , 30.9, 60., 65.9]],
    "Black Sea" => [[26.5, 41.95, 40., 47.95]],
    "Mediterranean Sea" => [[2., 36.375, 30., 46.375], [-5.917, 2., 30., 42.]],
    "North Sea" => [[-5.4, 13., 48., 62.]],
    "Arctic" => [[-180., 70., 56.5, 83.]],
    "Atlantic" => [[-180., 180., 0., 48.]]
)


function get_residuals(datafile::String, vname::String)
    NCDatasets.Dataset(datafile, "r") do ds
        vname_res = vname * "_residual"
        residuals = ds[vname_res][:]
        return residuals::Vector{Float64}
    end
end

function domain_split(datafile::String, outputdir::String, varname, domainext::OrderedDict,
    obsvalue, obslon, obslat, obsdepth, obstime, obsids, residuals, figdir)

    npoints = length(obslon)
    npointscheck = 0

    # Loop on domains
    for (domain, extension) in domainext

        @info("------------------------------")
        @info("Working on domain $(domain)")
        @info(length(obslon))

        goodcoord = []

        # Loop on subdomains:
        # Find data points inside bounding boxes
        for dd in extension
            @debug(dd);
            gg = findall((obslon .<= dd[2]) .& (obslon .>= dd[1]) .& (obslat .<= dd[4]) .& (obslat .>= dd[3]) )
            append!(goodcoord, gg)
            @info(length(gg))
        end

        # Need to apply 'unique' since subdomains have sometimes overlay
        unique!(goodcoord)
        npointsdomain = length(goodcoord)
        npointscheck += npointsdomain
        @info("Found $(npointsdomain) data points for domain $(domain)");

        # Create output file
        fname = split(basename(datafile), ".")[1] * "_" * replace(domain, " " => "_") * ".nc"
        @info("Saving new netCDF file as $(fname)")
        outputfile = joinpath(outputdir, fname)

        isfile(outputfile) ? rm(outputfile) : " "

        DIVAnd.saveobs(
            outputfile,
            varname,
            obsvalue[goodcoord],
            (obslon[goodcoord],obslat[goodcoord],
            obsdepth[goodcoord],
            obstime[goodcoord]),obsids[goodcoord]
            );

        if testplot
            domainstr =replace(domain, " "=>"_")
            PyPlot.plot(obslon[goodcoord],obslat[goodcoord], "ko",
            markersize=1)
            PyPlot.title("$(length(goodcoord)) data points")
            vname = replace(varname, " "=> "_")
            PyPlot.savefig(joinpath(figdir, "domain_split_test_$(domainstr)_$(vname).jpg"))
            PyPlot.close()
        end

        ds = NCDatasets.Dataset(outputfile, "a")
            defVar(ds, varname * "_residuals", residuals[goodcoord], ("observations", ))
        close(ds)

        @info("Saving residuals as CSV file")
        fname2 = split(basename(datafile), ".")[1] * "_" * replace(domain, " " => "_") * ".csv"
        outputfile2 = joinpath(outputdir, fname2)
        df = DataFrame(lon=obslon[goodcoord], lat=obslat[goodcoord],
        depth=obsdepth[goodcoord],
        time=obstime[goodcoord],
        IDs=obsids[goodcoord],
        values=obsvalue[goodcoord],
        residuals=residuals[goodcoord],
        exclude=0)

        CSV.write(outputfile2, df)

        # Keep only the unused data points
        badcoords = trues(length(obslon))
        badcoords[goodcoord] .= false
        bb = findall(badcoords);
        obsvalue = obsvalue[bb]
        obslon = obslon[bb]
        obslat = obslat[bb]
        obsdepth = obsdepth[bb]
        obstime = obstime[bb]
        obsids = obsids[bb]
        residuals = residuals[bb]

        @info("Remaining data points: $(length(obsvalue))")

        if testplot
            @info("Creating plot of the remaining data points")
            PyPlot.plot(obslon, obslat, "ko", markersize=0.5)
            PyPlot.savefig(joinpath(figdir, "remainingdata_$(varname)"), dpi=300, bbox_inches="tight")
            PyPlot.close()
        end

    end
    if npoints == npointscheck
        @info("Check OK")
    else
        @warn("Problem with the number of points")
    end
end


datadirori = "/data/EMODnet/Eutrophication/Split/"
outputdir = "/data/EMODnet/Eutrophication/Residuals/All/"
isdir(outputdir) ? @debug("ok") : mkpath(outputdir)

@info("Loop on $(length(casenamelist)) cases")
for casename in casenamelist

    local datadir = "/data/EMODnet/Eutrophication/Products/$(casename)/"
    fileglob = glob("*residual*nc", datadir)
    if isempty(fileglob)
        @warn("No residual file found in $(datadir)")
        break
    end

    datafile = fileglob[1]
    figdir = "../figures/domain-split/$(casename)/V3"
    # outputdir = joinpath(datadir, "Split_V3/")

    !isdir(outputdir) ? mkpath(outputdir) : @debug("Directory already created")
    !isdir(figdir) ? mkpath(figdir) : @debug("Figure directory already created")

    # Get variable name from file name:
    varname_ = replace(basename(datafile), "_monthly_residuals.nc" => "")
    varname = replace(varname_, "_" => " ")

    @info("Working on variable $(varname)")

    @info("Loading variables from netCDF file $(basename(datafile))")
    obsvalue, obslon, obslat, obsdepth, obstime, obsids = DIVAnd.loadobs(
        Float64, datafile, varname)

    @info("Loading residuals")
    residuals = get_residuals(datafile, varname);

    npoints = length(obsvalue);
    @info("Number of data points: $(npoints)")

    #@info("Splitting data into sub-domains")
    #domain_split(datafile, outputdir, varname, domainext, obsvalue, obslon, obslat, obsdepth, obstime, obsids, residuals, figdir)

    # Loop on regions
    filelistori = glob("*$(varname_)*.nc", datadirori)
    @info(filelistori);

    for datafileori in filelistori
        @info("Reading ID's from original file $(datafileori)")
        _, _, _, _, _, obsids_ori = loadobs(Float64, datafileori, varname);
        @info(length(obsids), length(obsids_ori));

        # Find the ID's of the residual file that were in the original data files
        # (i.e., provided by the users)
        Set1 = Set(obsids_ori);
        obsmask = [id in Set1 for id = obsids];
        @info("Number of points present in the initial datafile: $(sum(obsmask))")

        # Create a CSV file with the corresponding data and residuals
        df = DataFrame(lon=obslon[obsmask], lat=obslat[obsmask],
        depth=obsdepth[obsmask],
        time=obstime[obsmask],
        IDs=obsids[obsmask],
        values=obsvalue[obsmask],
        residuals=residuals[obsmask],
        exclude=0)

        @info("Saving residuals as CSV file")
        fname3 = replace(basename(datafileori), ".nc" => ".csv")
        outputfile3 = joinpath(outputdir, fname3)

        CSV.write(outputfile3, df)
        @info("Written CSV file $(fname3)")

        @info("Compress the output file")
        zipcommand = `zip $(outputfile3).zip $(outputfile3)`
        run(zipcommand)

        if testplot
            figname = replace(fname3, ".csv" => ".jpg")
            @info("Creating plot of the remaining data points")
            PyPlot.plot(obslon[obsmask], obslat[obsmask], "ko", markersize=0.5)
            PyPlot.title("$(sum(obsmask)) data points")
            PyPlot.savefig(joinpath(figdir, figname), dpi=300, bbox_inches="tight")
            PyPlot.close()
        end

    end

    @info("Splitted files available in $(outputdir)")
    @info("Finished processing $(casename)")
    @info(" ")

end
