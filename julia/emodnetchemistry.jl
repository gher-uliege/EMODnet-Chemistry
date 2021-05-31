using Glob
using NCDatasets

"""
    get_file_list(datadir, varname, season)

Return a list of file paths (netCDF) contained in `datadir`.

"""
function get_file_list(datadir::String, varname::String="", season::String="")::Array
    filelist = []
    # Varname with spaces instead of underscores
    varname2 = replace(varname, "_" => " ")
    for (root, dirs, files) in walkdir(datadir)
        for file in files
            # List only netCDF files
            if endswith(file, ".nc")
                # Check variable name
                if length(varname) > 0
                    @info("Looking for variable $(varname)")
                    # Check for seaon
                    if length(season) > 0
                        @info("Searching for season $(season)")
                        if (occursin(varname, file) | occursin(varname2, file)) & occursin(uppercasefirst(season), root)
                            push!(filelist, joinpath(root, file))
                        end
                    else
                        @info("No season selected")
                        if (occursin(varname, file) | occursin(varname2, file))
                            push!(filelist, joinpath(root, file))
                        end
                    end
                else
                    @info("No variable selected")
                    if length(season) > 0
                        @info("Searching for season $(season)")
                        if occursin(uppercasefirst(season), root)
                            push!(filelist, joinpath(root, file))
                        end
                    else
                        @info("No season selected")
                        push!(filelist, joinpath(root, file))
                    end
                end

            end
        end
    end
    return filelist
end
