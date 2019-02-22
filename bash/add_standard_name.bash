#!/bin/bash
#===============================================================================
#
# FILE: add_standard_name.bash
#
# USAGE: add_standard_name.bash
#
# DESCRIPTION: add the standard name to the variables in the netCDF files
# Possible issues with the white spaces in the variable names,
# hence double checking before production
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, Uliege),
#
# VERSION: 1.1
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s globstar

# dictionary storing the standard names
# (checked before if we were using bash version 4
# echo $BASH_VERSION)

declare -A stdnames

stdnames=( ["Water_body_ammonium"]="mole_concentration_of_ammonium_in_sea_water"
["Water_body_chlorophyll-a"]="mass_concentration_of_chlorophyll_a_in_sea_water"
["Water_body_phosphate"]="mass_concentration_of_phosphate_in_sea_water"
["Water_body_dissolved_oxygen_concentration"]="mass_concentration_of_oxygen_in_sea_water"
["Water_body_silicate"]="mass_concentration_of_silicate_in_sea_water"
["Water_body_dissolved_inorganic_nitrogen_(DIN)"]="mass_concentration_of_inorganic_nitrogen_in_sea_water"
["Water_body_dissolved_oxygen_saturation"]="fractional_saturation_of_oxygen_in_sea_water"
)

#declare -r domaindir="/production/apache/data/emodnet-test-charles/North Sea/"
declare -r domaindir="/data/EMODnet/Chemistry/prod/"
echo "Working in ${domaindir}"

# Function to generate a list of variables based on the main variable
function getvarlist {
    echo $1 $1"_err" $1"_L1" ${1}"_L2" $1"_deepest" $1"_deepest_L1" $1"_deepest_L2"
    }

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
  # Identify domain name and variable using file path
  # (not the most robust but ok for now)
  domain=$(echo ${ncfile} | cut -d "/" -f 6)
  echo "  Domain: "${domain}
  variable=$(echo $(basename "${ncfile}") | cut -d "." -f 1)
  echo "  Variable to process:" ${variable}
  # Get standard name from dictionary
  stdname=${stdnames[$variable]}
  echo "  CF Standard name: ${stdname}"
  echo " -----------------------------"

  # Special case for nitrogen (parenthesis in the name)
  # We change the value of the variable name to be the same as in the netCDF (escaping the parenthesis)
  if [[ "${variable}" == "Water_body_dissolved_inorganic_nitrogen"* ]] ; then
    variable=Water_body_dissolved_inorganic_nitrogen_\\\(DIN\\\)
    echo "Changed variable name to $variable"
  fi

  # Loop on the variables of which we have to change the name
  vlist=$(echo $(getvarlist "${variable}"))
  for varnames in ${vlist}; do
    echo "    Working on variable "${varnames}
    #ncatted -O -h -a standard_name,${varnames},o,c,${stdname} "${ncfile}"
  done

done
