"""
Example of script to merge the observations containing in a list of netCDF files
and write them in a new file.

The 2 main inputs to modify are:
1) `datafilelist`: a list of file paths
2) `datafilemerge`: the path of a netCDF file into which the combined observations
will be written.

Typically, `datafilemerge` would be a file obtained following these
[instructions](https://github.com/gher-ulg/EMODnet-Chemistry/blob/master/doc/merging_netCDF.md),
after the command
```bash
ncks -x -v obslon,obslat,obsdepth,obstime,obsid inputfile.nc outputfile.nc
```

If you get the error
`ERROR: LoadError: NetCDF error: NetCDF: String match to name in use (NetCDF error code: -42)`,
this is probably due the fact that the variables you want to create (obslon, obslat etc)
have not been removed from the file.
"""

using NCDatasets
using PyPlot
using DataStructures
using Dates
include("MergingClim.jl")


# Specify list of 4 input files (one per season)
datadir = "/media/ctroupin/My Passport/data/EMODnet/Eutrophication/Products/BlackSea"
datafilelist = [joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Spring.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Summer.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Winter.4Danl.nc"),
               ]

# Output file name
datafilemerge = joinpath(datadir, "Water_body_dissolved_oxygen_concentration_year.nc")

# Remove the variables
nckscommand = `ncks -O -x -v obslon,obslat,obsdepth,obstime,obsid $(datafilemerge) $(datafilemerge)`

# Read observations from the file list
obslon, obslat, obsdepth, obstime, obsid = MergingClim.read_obs(datafilelist);

# Write the file
MergingClim.write_obs(datafilemerge, obslon, obslat, obsdepth, obstime, obsid)
