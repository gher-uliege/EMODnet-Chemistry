using NCDatasets
using Glob

datadir = "/data/EMODnet/Eutrophication/BlackSeaResults/1/"
datafilelist = readdir(datadir);
nfiles = length(datafilelist)

ntimesteps = 3
ntimes = nfiles * ntimesteps

# Allocate time vector
timeall = Vector{Dates.DateTime}(undef, 0)

# Load coordinates from 1st file
function get_coordinates(datafile::String)
	NCDatasets.Dataset(joinpath(datadir, datafile), "r") do ds
		lon = ds["lon"][:]
		lat = ds["lat"][:]
		depth = ds["depth"][:]
		return lon, lat, depth
	end
end

function sort_fields_time(datafile::String)
    Dataset(datafile::String, "a") do ds

        @info("Read time and sort index")
        times = ds["time"][:];
        sorting_index = sortperm(times);

        # Loop on the variables
        for varname in keys(ds)

            # Check if time is a dimension
            if "time" ∈ dimnames(ds[varname])
                @info("Variable '$(varname)' contains 'time' dimension")
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


@info("Reading coordinates from 1st file")
lon, lat, depth = get_coordinates(joinpath(datadir, datafilelist[1]));
nlon = length(lon)
nlat = length(lat)
ndepth = length(depth)

@info("Array size: time: $(ntimes), depth: $(ndepth), lat: $(nlat), lon: $(nlon)")

# Allocate time vector and other array
timeall = Vector{Dates.DateTime}(undef, 0)
field = Array{Float64, 4}(undef, nlon, nlat, ndepth, ntimes)

for (iii, datafile) in enumerate(datafilelist)
	@info(datafile)
	ds = NCDatasets.Dataset(joinpath(datadir, datafile), "r")
		time = ds["time"][:]
		append!(timeall, time)
		fff = coalesce.(ds["Water body phosphate"][:], NaN)
		tmin = 1 + (iii - 1) * 3
		tmax = iii * 3
		@info(tmin, tmax);
		field[:,:,:,tmin:tmax] = fff;
	close(ds)

	@info(length(timeall));
end

sortingindex = sortperm(timeall)
