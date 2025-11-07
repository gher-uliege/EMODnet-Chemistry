#!/bin/bash
#===============================================================================
#
# FILE: nc_compress.sh
#
# USAGE: nc_compress.sh directory_path
#
# DESCRIPTION: Apply netCDF compression to all the netCDF files found 
# in the specified directory
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, ULiege),
#
# VERSION: 1.1
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s nullglob

datadir=${1}

if [ -d "${datadir}" ]; then
    echo "directory exists"
else
    echo "No directory named ${datadir}"
    exit 0
fi

find "${datadir}" -maxdepth 1 -type f -name "*.nc" -print0 | while IFS= read -r -d '' datafile; do
    ((i++))
    echo " "
    echo "working on file $(basename "${datafile}")"

    ncks -7 -O -L 5 --baa=4 --ppc default=3 "${datafile}" "${datafile}" 

done
