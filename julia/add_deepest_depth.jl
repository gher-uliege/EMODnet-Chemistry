using NCDatasets

datafile = "./sample_file.nc"
varname = "Water body phosphate"
varname = "Salinity"

"""
    add_deepest_depth(datafile, varname)

Add a new variable 'deepest_depth' to the netCDF file `datafile`
containing the variable `varname`.

## Examples
```julia-repl
julia> add_deepest_depth("sample_file.nc", "Salinty")
```
"""
function add_deepest_depth(datafile::String, varname::String)
    NCDatasets.Dataset(datafile, "a") do nc

        # Load the depth variable
        depth = nc["depth"][:]
        @info("Working on $(length(depth)) depth layers")

        # Load the 4D variable (we can load the first time instance,
        # as depth is not supposed to change with time)
        field3D = nc[varname][:,:,:,1]
        @info(size(field3D))

        # Get missing value from field
        valex = nc[varname].attrib["missing_value"]

        newvarname = varname * "_deepest_depth"
        @info("Creating new variable $(newvarname)")
        ncvardeepestdepth = defVar(nc, newvarname, Float32, ("lon", "lat"))
        ncvardeepestdepth.attrib["long_name"] = "Deepest depth for $(varname)"
        ncvardeepestdepth.attrib["_FillValue"] = Float32(valex)
        ncvardeepestdepth.attrib["missing_value"] = Float32(valex)
        ncvardeepestdepth.attrib["units"] = "meters"
        ncvardeepestdepth.attrib["positive"] = "down"

        # Loop on depth: start from surface and go to the bottom
        # (I also add "abs" in case depth are negative, but not probable)
        depthindex = sortperm(abs.(depth))
        for idepth in depthindex
            @info("Depth index: $(idepth)")
            # Look for non-missing values at the considered depth
            nonmissing = (.!ismissing.(field3D[:,:,idepth]))
            @info("Found $(sum(nonmissing)) non missing values for depth $(depth[idepth])")

            # Write the variable
            ncvardeepestdepth[nonmissing] .= depth[idepth]
        end

        @info("Written new variable deepest depth")

    end
end

datafile = "sample_file.nc"
isfile(datafile) ? @debug("File already downloaded") : download("https://dox.ulg.ac.be/index.php/s/OIz97X8SCqQGbxO", datafile)

add_deepest_depth(datafile, varname)

# Tests
using Test
nc = NCDatasets.Dataset(datafile)
field_deepest_depth = nc["Salinity_deepest_depth"][:]
close(nc)
@test sum(ismissing.(field_deepest_depth)) == 33
@test field_deepest_depth[3,4] == 0.f0
@test field_deepest_depth[12, 1] == 1000.0f0
@test size(field_deepest_depth) == (18, 5)
