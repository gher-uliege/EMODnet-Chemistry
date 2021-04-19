using NCDatasets
using PyPlot
using DataStructures
using Dates

datafileold = "/data/EMODnet/Eutrophication/BlackSeaResults/Old/Water body phosphate.4Danl.nc"
datafilenew = "/data/EMODnet/Eutrophication/BlackSeaResults/1/Water body phosphate_Autumn.4Danl.nc"
datafilemerge = "/data/EMODnet/Eutrophication/BlackSeaResults/Old/output2.nc"

"""
    read_obs(datafile)

Read the observations from a netCDF file.

## Example
```julia-repl
julia> obslon, obslat, obsdepth, obstime, obsid = read_obs(datafile)
```
"""
function read_obs(datafile::String)

    NCDatasets.Dataset(datafile, "r") do nc

        obslon = nc["obslon"][:]
        obslat = nc["obslat"][:]
        obsdepth = nc["obsdepth"][:]
        obstime = nc["obstime"][:]
        obsid = nc["obsid"][:]

        return obslon, obslat, obsdepth, obstime, obsid

    end
end

"""
    merge_obsids(obsid1, obsid2)

Merge two arrays of observations

## Example
```julia-repl
julia> obsid = merge_obsids(obsid_old, obsid_new)
```
"""
function merge_obsids(obsid1::Matrix{Char}, obsid2::Matrix{Char})
    idlen1, nobs1 = size(obsid1)
    idlen2, nobs2 = size(obsid2)
    @debug(idlen1, idlen2, nobs1, nobs2);

    # Allocate new matrix for obsid
    obsid = Array{Char, 2}(undef, maximum((idlen1, idlen2)), nobs1 + nobs2);
    # Merge obsid's
    obsid[1:idlen1, 1:nobs1] = obsid1;
    obsid[1:idlen2, nobs1+1:nobs1 + nobs2] = obsid2;
    @debug(size(obsid));

    return obsid
end


"""
    write_obs(datafile)

Write the new observations to a netCDF file from which the variables
corresponding to the observations (obslon, obslat etc) have been removed.

## Example
```julia-repl
julia> write_obs("merged.nc", obslon, obslat, obsdepth, obstime, obsid)
```
"""
function write_obs(datafile::String, obslon::Vector{Float64}, obslat::Vector{Float64},
    obsdepth::Vector{Float64}, obstime::Vector{Dates.DateTime},
    obsid::Matrix{Char})

    idlen, nobs = size(obsid)

    # Write in the new file
    NCDatasets.Dataset(datafile, "a") do nc
        nc.dim["idlen"] = idlen
        nc.dim["observations"] = nobs

        ncobsdepth = defVar(nc,"obsdepth", Float64, ("observations",),
            attrib = OrderedDict(
                        "units" => "meters",
                        "positive" => "down",
                        "long_name" => "depth of the observations",
                        "standard_name" => "depth"
                    )
                )

        ncobsid = defVar(nc,"obsid", Char, ("idlen", "observations"),
            attrib = OrderedDict(
                "long_name" => "observation identifier",
                "coordinates" => "obstime obsdepth obslat obslon",
                )
            )

        ncobslat = defVar(nc,"obslat", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "degrees_north",
                "long_name" => "latitude of the observations",
                "standard_name" => "latitude"
                )
            )

        ncobslon = defVar(nc,"obslon", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "degrees_east",
                "long_name" => "longitude of the observations",
                "standard_name" => "longitude"
                )
            )

        ncobstime = defVar(nc,"obstime", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "days since 1900-01-01 00:00:00",
                "long_name" => "time of the observations",
                "standard_name" => "time"
                )
            )

        ncobslon[:] = obslon
        ncobslat[:] = obslat
        ncobsdepth[:] = obsdepth
        ncobstime[:] = obstime
        ncobsid[:] = obsid;

        return
    end;
end;


# Read observations from old and new files
obslon_new, obslat_new, obsdepth_new, obstime_new, obsid_new = read_obs(datafilenew);
obslon, obslat, obsdepth, obstime, obsid_old = read_obs(datafileold);

# Append the coordinate arrays
append!(obslon, obslon_new);
append!(obslat, obslat_new);
append!(obsdepth, obsdepth_new);
append!(obstime, obstime_new);

# Merge the obsid's
obsid = merge_obsids(obsid_old, obsid_new)

# Write the file
write_obs(datafilemerge, obslon, obslat, obsdepth, obstime, obsid)
