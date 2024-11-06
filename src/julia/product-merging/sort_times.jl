# This script shows how to sort the fields according to time
# in a netCDF file.
#
# The main function `sort_fields_time` is stored in `MergingClim.jl`

using NCDatasets
using Glob
include("MergingClim.jl")


datadir = "/production/apache/data/emodnet-test-charles/test-merg/Baltic Sea/"
datafile = joinpath(datadir, "Water_body_chlorophyll-a.4Danl_year.nc")

if isfile(datafile)
    @info("Working on $(datafile)")
    @time MergingClim.sort_fields_time(datafile);
else
    @error("File $(datafile) does not exist")
end


# If you want to work on a list of files:
#datafilelist = Glob.glob("*.nc", datadir)

#for datafile in datafilelist

#    if isfile(datafile)
#        @info("Working on $(datafile)")
#        @time MergingClim.sort_fields_time(datafile);
#    else
#        @error("File $(datafile) does not exist")
#    end
#end
