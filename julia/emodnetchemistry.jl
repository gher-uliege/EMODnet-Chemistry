using Glob
using NCDatasets

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
        ncvardeepestdepth = nc[newvarname]
        
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
	return field3D
    end
end



"""
    get_file_list(datadir, varname, season)

Return a list of file paths (netCDF) contained in `datadir`.

## Examples

Listing all the netCDF files in the selected directory:
```julia
julia> datafilelist = get_file_list("/production/apache/data/emodnet-domains/By sea regions")
[ Info: No variable selected
[ Info: No season selected
112-element Vector{Any}:
 "/production/apache/data/emodnet-domains/By sea regions/Arctic Ocean/Autumn (September-November) - 6-year running averages/Water_body_dissolved_oxygen_concentration.4Danl.nc"
 ⋮
 "/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/Winter (January-March) - 6-year running averages/Water_body_silicate.4Danl.nc"
```

List all the files containing chlorophyll-a data:
julia> datafilelist = get_file_list("/production/apache/data/emodnet-domains/By sea regions", "chlorophyll-a")
[ Info: Looking for variable chlorophyll-a
[ Info: No season selected
20-element Vector{Any}:
 "/production/apache/data/emodnet-domains/By sea regions/Baltic Sea/Autumn (September-November) - 6-year running averages/Water_body_chlorophyll-a.4Danl.nc"
 ⋮
 "/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/Winter (January-March) - 6-year running averages/Water_body_chlorophyll-a.4Danl.nc"

List all the files containing chlorophyll-a data for summer season:
julia> datafilelist = get_file_list("/production/apache/data/emodnet-domains/By sea regions", "chlorophyll-a", "summer")
[ Info: Looking for variable chlorophyll-a
[ Info: Searching for season summer
5-element Vector{Any}:
"/production/apache/data/emodnet-domains/By sea regions/Baltic Sea/Summer (June-August) - 6-year running averages/Water_body_chlorophyll-a.4Danl.nc"
 ⋮
"/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/Summer (July-September) - 6-year running averages/Water_body_chlorophyll-a.4Danl.nc"


"""
function get_file_list(datadir::String, varname::String="", season::String="")::Array
    filelist = []
    # Varname with spaces instead of underscores
    varname2 = replace(varname, "_" => " ")

    if length(varname) > 0
        @info("Looking for variable $(varname)")
    else
        @info("No variable selected")
    end

    if length(season) > 0
        @info("Searching for season $(season)")
    else
        @info("No season selected")
    end



    for (root, dirs, files) in walkdir(datadir)
        for file in files
            # List only netCDF files
            if endswith(file, ".nc")
                # Check variable name
                if length(varname) > 0
                    # Check for seaon
                    if length(season) > 0
                        if (occursin(varname, file) | occursin(varname2, file)) & occursin(uppercasefirst(season), root)
                            push!(filelist, joinpath(root, file))
                        end
                    else
                        if (occursin(varname, file) | occursin(varname2, file))
                            push!(filelist, joinpath(root, file))
                        end
                    end
                else
                    if length(season) > 0
                        if occursin(uppercasefirst(season), root)
                            push!(filelist, joinpath(root, file))
                        end
                    else
                        push!(filelist, joinpath(root, file))
                    end
                end

            end
        end
    end
    return filelist
end
