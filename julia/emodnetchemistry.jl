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
