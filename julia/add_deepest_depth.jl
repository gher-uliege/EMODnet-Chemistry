using NCDatasets

datafile = "/data/EMODnet/Eutrophication/BlackSeaResults/1/Water body phosphate_Winter.4Danl.nc"
varname = "Water body phosphate"

nc = NCDatasets.Dataset(datafile)

    # Load the depth variable
    depth = nc["depth"][:]
    @info("Working on $(length(depth)) depth layers")

    # Load the 4D variable (we can load only the first time instance,
    # as depth don't change with time)
    field3D = nc[varname][:,:,:,1]
    @info(size(field4D))

    # Create the new variable '*_deepest_depth'
    deepest_depth = copy(field3D)

    # Loop on depth
    for (idepth, dd) in enumerate(depth)
        nonmissing = (.!ismissing.(field3D[:,:,idepth]))
        @info("Found $(sum(nonmissing)) non missing values for depth $(dd)")
        deepest_depth[nonmissing] .= idepth
    end
    newvarname = varname * "_deepest_depth"
    @info("Creating new variable $(newvarname)")
    # continue

close(nc)
