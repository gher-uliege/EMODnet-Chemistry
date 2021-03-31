using NCDatasets

datafile = "/home/ctroupin/sample_file.nc"
varname = "Water body phosphate"
varname = "Salinity"

NCDatasets.Dataset(datafile, "a") do nc

    # Load the depth variable
    depth = nc["depth"][:]
    @info("Working on $(length(depth)) depth layers")

    # Load the 4D variable (we can load the first time instance,
    # as depth don't change with time)
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
