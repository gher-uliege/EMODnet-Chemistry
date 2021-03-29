using NCDatasets

datafile = "/home/ctroupin/Water body phosphate_Winter.4Danl.nc"
varname = "Water body phosphate"

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

    # Loop on depth (reversed; starting at the bottom)
    for (idepth, dd) in enumerate(reverse(depth))

        # Look for non-missing values at the considered depth
        nonmissing = (.!ismissing.(field3D[:,:,end - idepth + 1]))
        @info("Found $(sum(nonmissing)) non missing values for depth $(dd)")

        # Add the actual depth when the field value exists
        @info("Size of deepest depth: $(size(deepest_depth))")
        # Write the variabe
        ncvardeepestdepth[nonmissing] .= dd
    end

    @info("Written new variable deepest depth")

end
