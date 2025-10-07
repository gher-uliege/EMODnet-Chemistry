using Glob
using NCDatasets

"""
    get_file_list(datadir, varname, season)

Return a list of file paths (netCDF) contained in `datadir`.

## Examples

Listing all the netCDF files in the selected directory:
```julia-repl
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

"""
	remove_attribs(datafile, varname)

Remove the valid_min and valid_max attributes from the variables.

## Examples

```julia-repl
julia> remove_attribs("Water_body_chlorophyll-a.4Danl.nc", "Water_body_chlorophyll")
"""
function remove_attribs(datafile::String, varname::String)
    NCDatasets.Dataset(datafile, "a") do nc

        # Get list of variables
        varlist = keys(nc)
        for var in varlist
            # Check if the variable is one of the 4D fields
            if occursin(varname, var)
                @info(var)
                if occursin("relerr", var)
                    # Keep attributes for error fields
                    @info("Relative error variable; no need to remove attributes")
                else
                    @info("Normal variable; remove valid_min and valid_max")
                    vv = nc[var]

                    attrib_dict = Dict(vv.attrib)
                    if haskey(attrib_dict, "valid_max")
                        @info("Remove valid_max attrib")
                        delete!(vv.attrib, "valid_max")
                    end
                    if haskey(attrib_dict, "valid_min")
                        @info("Remove valid_min attrib")
                        delete!(vv.attrib, "valid_min")
                    end
                end
            end
        end
    end
end

"""
    count_nans(filename)

Return the number of NaNs in the filename.

```julia-repl
count_nans(filename)
```
"""
function count_nans(filename::String)
        Dataset(filename) do ds
                var0 = varbyattrib(ds, standard_name=var_stdname);
                d = ds["Water_body_ammonium_L1"].var[:];
                nnans = sum(isnan.(d));
                @info("Found $(nnans) NaNs for the variable")
                return nnans
                fv = fillvalue(ds["Water_body_ammonium_L1"])
                # d[isnan.(d)] .= fv;
                # ds["Water_body_ammonium_L1"].var[:] = d;
        end
end
    
"""
    get_dirnames()

Return the paths of the data and output directories

# Examples
```julia-repl
databasedir, outputbasedir = get(dirnames)
```
"""
function get_dirnames()
    hostname = gethostname()
    if hostname == "ogs04"
        @info "Working in production server"
        databasedir = "/production/apache/data/emodnet-domains"
        outputbasedir = nothing
    elseif hostname == "GHER-ULg-Laptop"
        outputbasedir = "/data/EMODnet/Chemistry/merged/"
        databasedir = "/data/EMODnet/Chemistry/prod/"
    elseif hostname == "gherdivand"
        outputbasedir = "/home/ctroupin/data/EMODnet/merged"
        databasedir = "/home/ctroupin/data/EMODnet/By sea regions"
    elseif hostname == "FSC-PHYS-GHER01"
        outputbasedir = "/home/ctroupin/data/EMODnet-Chemistry/merged"
        databasedir = "/home/ctroupin/data/EMODnet-Chemistry/emodnet-results-2023"
    else
        @error("Unknown host")
    end

    return databasedir, outputbasedir
end
