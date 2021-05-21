using NCDatasets
using Glob

"""
    sort_fields_time(datafile)

Sort chronologically the variables that depend on the time variable.

## Example
```julia-repl
sort_fields_time("Water_body_dissolved_oxygen_concentration_year.nc")
```
"""
function sort_fields_time(datafile::String)
    Dataset(datafile::String, "a") do ds

        @debug("Read time and sort index")
        times = ds["time"][:];
        sorting_index = sortperm(times);

        # Loop on the variables
        for varname in keys(ds)

            # Check if time is a dimension
            if "time" ∈ dimnames(ds[varname])
                @debug("Variable '$(varname)' contains 'time' dimension")
                var = ds[varname][:]
                ndims = length(size(var))
                @debug("Number of dimensions: $(ndims)")
                if ndims == 1
                    ds[varname][:] = var[sorting_index]
                elseif ndims == 2
                    ds[varname][:] = var[:,sorting_index]
                elseif ndims == 3
                    ds[varname][:] = var[:,:,sorting_index]
                elseif ndims == 4
                    ds[varname][:] = var[:,:,:,sorting_index]
                else
                    @warn("Number of dimensions larger than 4")
                end
            end
        end
    end
end

datadir = "/media/ctroupin/My Passport/data/EMODnet/Eutrophication/Products/BlackSea/"
datafile = joinpath(datadir, "Water_body_dissolved_oxygen_concentration_year.nc")

if isfile(datafile)
    @info("Working on $(datafile)")
    @time sort_fields_time(datafile);
else
    @error("File $(datafile) does not exist")
end


# If you want to work on a list of files:
datafilelist = Glob.glob("*.nc", datadir)

for datafile in datafilelist

    if isfile(datafile)
        @info("Working on $(datafile)")
        @time sort_fields_time(datafile);
    else
        @error("File $(datafile) does not exist")
    end
end
