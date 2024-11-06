"""
Example of script to merge the observations contained in a list of netCDF files
and write them in a new netCDF file.

The 2 main user inputs to modify are:
1. `datafilelist`: a list of file paths containing the original observations
2. `datafilemerge`: the path of the netCDF file (already created) into which the combined observations
will be written.

Typically, `datafilemerge` would be a file obtained following these
[instructions](https://github.com/gher-uliege/EMODnet-Chemistry/blob/master/doc/merging_netCDF.md),
after the command
```bash
ncks -x -v obslon,obslat,obsdepth,obstime,obsid inputfile.nc outputfile.nc
```
(removal of the variables relative to the observations)

If you get the error
`ERROR: LoadError: NetCDF error: NetCDF: String match to name in use (NetCDF error code: -42)`,
this is probably due the fact that the variables you want to create (obslon, obslat etc)
have not been removed from the file.
"""

using NCDatasets
using PyPlot
using Dates
include("MergingClim.jl")


# Specify list of 4 input files (one per season)
datadir = "/data/EMODnet/Eutrophication/Products/BlackSea"  # edit this line 
datafilelist = [joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Spring.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Summer.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Winter.4Danl.nc"),
                ]                                            # edit the file names

# Output file name
datafilemerge = joinpath(datadir, "Water_body_dissolved_oxygen_concentration_year.nc")

# Remove the variables (if necessary)
nckscommand = `ncks -O -x -v obslon,obslat,obsdepth,obstime,obsid "$(datafilemerge)" "$(datafilemerge)"`
run(nckscommand);

# Read observations from the file list
@time obslon, obslat, obsdepth, obstime, obsid = MergingClim.read_obs(datafilelist);

# Ensure unique observations
obslon_u, obslat_u, obsdepth_u, obstime_u, obsid_u = MergingClim.unique_obs(obslon, obslat, obsdepth, obstime, obsid);

# Write the file
MergingClim.write_obs(datafilemerge, obslon_u, obslat_u, obsdepth_u, obstime_u, obsid_u);
