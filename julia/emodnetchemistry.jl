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
            if length(varname) > 0
                
            if endswith(file, ".nc") &
                (occursin(varname, file) | occursin(varname2, file)) &
                occursin(uppercasefirst(season), root)
                push!(filelist, joinpath(root, file))
            end
        end
    end
    return filelist
end

