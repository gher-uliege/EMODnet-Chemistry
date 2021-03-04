using NCDatasets
using DIVAnd

datadir = "/data/EMODnet/Eutrophication/Products/Water body phosphate-res-0.25-epsilon2-1.0-lenx-250000.0-maxit-100-monthly/Results"
outputdir = joinpath(datadir, "Split/")
datafile = joinpath(datadir, "Water body phosphate_monthly_residuals.nc")

!isdir(outputdir) ? mkpath(outputdir) : @debug("Directory already created")

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

domainext = Dict(
    "Arctic" => [[-180., 70., 56.5, 83.]],
    "Baltic" => [[9.4, 30.9, 53., 60.], [14. , 30.9, 60., 65.9]],
    "North Sea" => [[-5.4, 13., 47.9, 62.]],
    "Mediterranean Sea" => [[-0.8, 36.375, 30., 46.375], [-7,36.375, 30. ,43.]],
    "Black Sea" => [[26.5, 41.95, 40., 47.95]]
    )

for (domain, extension) in domainext
    @info("Working on domain $(domain)")

    local goodcoords = []
    for dd in extension
        @debug(dd);
        @time gg = findall((obslon .<= dd[2]) .& (obslon .>= dd[1]) .& (obslat .<= dd[4]) .& (obslat .>= dd[3]) )
        append!(goodcoords, gg)
    end
    @info("Found $(length(goodcoords)) data points for domain $(domain)");

    fname = split(basename(datafile), ".")[1] * "_" * replace(domain, " " => "_") * ".nc"
    @info("Saving new file as $(fname)")
    outputfile = joinpath(outputdir, fname)

    if isfile(outputfile)
        rm(outputfile)
    end

    DIVAnd.saveobs(
        outputfile,
        varname,
        obsvalue[goodcoords],
        (obslon[goodcoords],obslat[goodcoords],obsdepth[goodcoords],
        obstime[goodcoords]),obsids[goodcoords]
        );

    ds = NCDatasets.Dataset(outputfile, "a")
        defVar(ds, varname * "_residuals", residuals[goodcoords], ("observations", ))
    close(ds)
end
