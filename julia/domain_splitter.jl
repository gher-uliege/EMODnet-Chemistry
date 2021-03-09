using NCDatasets
using DIVAnd
using DataStructures

# Files and directories
datadir = "/data/EMODnet/Eutrophication/Products/Water body phosphate-res-0.25-epsilon2-1.0-lenx-250000.0-maxit-100-monthly/Results"
figdir = "../figures/domain-split"
outputdir = joinpath(datadir, "Split/")
datafile = joinpath(datadir, "Water body phosphate_monthly_residuals.nc")
!isdir(outputdir) ? mkpath(outputdir) : @debug("Directory already created")

# Set as true to generate plots
testplot = true
if testplot
    using PyPlot
end

# List of variables
varlist = ["Water body phosphate",
           "Water body dissolved oxygen concentration",
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen (DIN)",
           "Water body ammonium",
           "Water body silicate",
           ]

varname = varlist[1]
@info("Working on variable $(varname)")

@info("Loading variables from netCDF file $(basename(datafile))")
obsvalue, obslon, obslat, obsdepth, obstime, obsids = DIVAnd.loadobs(
    Float64, datafile, varname)

function get_residuals(datafile::String, vname::String)
    NCDatasets.Dataset(datafile, "r") do ds
        vname_res = vname * "_residual"
        residuals = ds[vname_res][:]
        return residuals::Vector{Float64}
    end
end
residuals = get_residuals(datafile, varname);

npoints = length(obsvalue);
@info("Number of data points: $(npoints)")

domainext = OrderedDict(
    "Baltic" => [[9.4, 30.9, 53., 60.], [14. , 30.9, 60., 65.9]],
    "Black Sea" => [[26.5, 41.95, 40., 47.95]],
    "Mediterranean Sea" => [[-0.8, 36.375, 30., 46.375], [-7,36.375, 30. ,43.]],
    "North Sea" => [[-5.4, 13., 47.9, 62.]],
    "Arctic" => [[-180., 70., 56.5, 83.]],
    "Atlantic" => [[-180., 180., 0., 90.]]
    )

function domain_split(domainext::OrderedDict, obsvalue, obslon, obslat, obsdepth, obstime, obsids, residuals)

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

        end

        @info("Found $(length(goodcoord)) data points for domain $(domain)");

        # Create output file
        fname = split(basename(datafile), ".")[1] * "_" * replace(domain, " " => "_") * ".nc"
        @info("Saving new file as $(fname)")
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
            PyPlot.savefig(joinpath(figdir, "domain_split_test_$(domainstr).jpg"))
            PyPlot.close()
        end

        ds = NCDatasets.Dataset(outputfile, "a")
            defVar(ds, varname * "_residuals", residuals[goodcoord], ("observations", ))
        close(ds)

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

    end
end

@info("Splitting data into sub-domains")
domain_split(domainext, obsvalue, obslon, obslat, obsdepth, obstime, obsids, residuals)
