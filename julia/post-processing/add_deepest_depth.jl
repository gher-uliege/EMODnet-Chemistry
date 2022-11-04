using NCDatasets

datafile = "/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/Autumn (October-December) - 6-year running averages/Water_body_chlorophyll-a.4Danl.nc"
varname = "Water_body_chlorophyll-a"

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


