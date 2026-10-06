#!/bin/bash

# install juliaup
curl -fsSL https://install.julialang.org | sh

declare -a julia_versions=("1.5" "1.6" "1.7" "1.8" "1.9" "1.10" "1.11" "1.12")
declare -a netcdf_jll_version=("400.701.400" "400.702" "400.702.400" "400.702.402" "400.802.101" "400.802.102" "400.902" "400.902.5" "400.902.208" "400.902.209" "400.902.211" "400.902.211" "401.900.300")
declare testfile="test_netcdf.jl"
declare logfile="test_netcdf.log"

echo "Julia version     NetCDF_jll version  Status" > ${logfile}
## loop through Julia versions
for version in "${julia_versions[@]}"
do
    juliaup add ${version}
    juliaup default ${version}

    # Loop through netCDF jll versions
    for ncversion in "${netcdf_jll_version[@]}"
    do
        echo ${ncversion}
        echo "@eval using Pkg" > ${testfile}
        echo "Pkg.activate(temp=true)" >> ${testfile}
        echo "open(\"${logfile}\", \"a\") do io" >> ${testfile}
        echo "    try" >> ${testfile}
        echo "        Pkg.add(name=\"NetCDF_jll\", version=\"${ncversion}\", io=devnull)" >> ${testfile}
        echo "    catch e"  >> ${testfile}
        echo "        println(\"error when adding the package\")"  >> ${testfile}
        echo "        write(io, \"${version} \t ${ncversion} \t NetCDF_jll cannot be added\n\")" >> ${testfile}
        echo "    end"  >> ${testfile}
        echo "    try" >> ${testfile}
        echo "        @eval using NetCDF_jll" >> ${testfile}
        echo "    catch e" >> ${testfile}
        echo "        println(\"error when installing\")" >> ${testfile}
        echo "        write(io, \"${version} \t ${ncversion} \t NetCDF_jll cannot be imported\n\n\")" >> ${testfile}
        echo "    end" >> ${testfile}
        echo "end" >> ${testfile}
        julia ${testfile}
    done
done
