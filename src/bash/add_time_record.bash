#!/bin/bash
#===============================================================================
#
# FILE: add_time_record.bash
#
# USAGE: add_time_record.bash
#
# DESCRIPTION: add a record variable (usually the time), i
# that will be used for the concatenation. T
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, Uliege),
#
# VERSION: 1.1
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s globstar


#declare -r domaindir="/production/apache/data/emodnet-domains/By sea regions"
declare -r domaindir="/production/apache/data/emodnet-domains/By sea regions/Mediterranean Sea/Summer (July-September) - 6-year running averages/"
#declare -r domaindir="/production/apache/data/emodnet-test-charles/Black Sea"
echo "Working in ${domaindir}"

i=0
nfiles=$(find "${domaindir}" -type f -name "*.nc" | wc -l )
echo "Found ${nfiles} netCDF files in the specified directory"
echo " "


# Loop on the files
find "${domaindir}" -type f -name "*.nc" -print0 | while IFS= read -r -d '' ncfile; do
  ((i++))
  echo " "
  echo "  Working on file ${i}/${nfiles}"
  echo "  File: ${ncfile}"
  # check if file is empty

  if [ -s "${ncfile}" ]; then
    echo "  -- File is not empty"

    OLDIFS=${IFS}
    IFS=",";
    variable_esc="$(printf '%q' ${variable})"
    
    IFS=${OLDIFS}

    ncks -O --mk_rec_dmn time "${ncfile}" "${ncfile}"
  else
    echo "  -- File is empty (test file)"
  fi

done

