#!/bin/bash
#===============================================================================
#
# FILE: edit_attributes_2018.bash
#
# USAGE: edit_attributes_2018.bash
#
# DESCRIPTION: processes all the netCDF files
# listed in the directory "domaindir" and edit the
# variable and global attributes of the products.
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

stdnames=( ["Water_body_chlorophyll-a"]="mass_concentration_of_chlorophyll_a_in_sea_water"
["Water_body_phosphate"]="mass_concentration_of_phosphate_in_sea_water"
["Water_body_dissolved_oxygen_concentration"]="mass_concentration_of_oxygen_in_sea_water"
["Water_body_silicate"]="mass_concentration_of_silicate_in_sea_water"
["Water_body_dissolved_inorganic_nitrogen_(DIN)"]="mass_concentration_of_inorganic_nitrogen_in_sea_water"
)

declare -r domaindir="/production/apache/data/emodnet-test-charles/"
echo "Working in ${domaindir}"

# Function to generate a list of variables based on the main variable
function getvarlist {
    echo $1 $1"_err" $1"_L1" ${1}"_L2" $1"_deepest" $1"_deepest_L1" $1"_deepest_L2"
    }

divacitation="Troupin, C.; Sirjacobs, D.; Rixen, M.; Brasseur, P.; Brankart, J.-M.;\
Barth, A.;Alvera-Azcarate, A.; Capet, A.; Ouberdous, M.; Lenartz, F.; Toussaint, M.-E. & Beckers, J.-M. (2012)\
Generation of analysis and consistent error fields using the Data Interpolating Variational Analysis (Diva).\
Ocean Modelling, 52-53: 90-101. doi:10.1016/j.ocemod.2012.05.002\n\
Beckers, J.-M.; Barth, A.; Troupin, C. & Alvera-Azcarate, A.\
Some approximate and efficient methods to assess error fields in spatial gridding with DIVA\
(Data Interpolating Variational Analysis) (2014).\
Journal of Atmospheric and Oceanic Technology, 31: 515-530.\
doi:10.1175/JTECH-D-13-00130.1"


# Loop on the netCDF files
nfiles=$(ls "${domaindir}"/**/*.nc | wc -l)
echo "Processing " ${nfiles} "netCDF files"

i=0
for ncfile in "${domaindir}"**/*.nc; do # Whitespace-safe and recursive
  ((i++))
  echo " "
  echo "  Working on file ${i}/${nfiles}"
  echo "  File: ${ncfile}"
  # Identify domain name and variable using file path
  # (not the most robust but ok for now)
  domain=$(echo ${ncfile} | cut -d "/" -f 6)
  echo "  Domain: "${domain}
  variable=$(echo $(basename "${ncfile}") | cut -d "." -f 1)
  echo "  Variable:" ${variable}
  echo " "

  # Get standard name from dictionary
  stdname=${stdnames[$variable]}
  echo "  CF Standard name: ${stdname}"

  if ncdump -h "${ncfile}" | grep -q 'DIVA_references' ; then
    echo "File has already been processed"
  else
    echo "File has not been processed"
  

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
      ncatted -O -h -a standard_name,${varnames},o,c,${stdname} "${ncfile}"
    done


    # Editing the attributes
    # -a: name of the attribute
    # o = overwrite (editing mode)
    # c = character (attribute type)
    echo "  Modifying global attributes"
    ncatted -h -a project,global,o,c,"EMODnet Chemistry: http://www.emodnet-chemistry.eu/" "${ncfile}"
    ncatted -h -a data_access,global,o,c,"OPeNDAP: http://ec.oceanbrowser.net:8081/data/emodnet-domains/" "${ncfile}"
    ncatted -h -a WEB_visualisation,global,o,c,"http://ec.oceanbrowser.net/emodnet/" "${ncfile}"

    # Adding new attributes
    # -h: don't write the command in "history" global attribute
    echo "  Creating new global attributes"
    ncatted -h -a DIVA_source,global,o,c,"https://github.com/gher-ulg/DIVA" "${ncfile}"
    ncatted -h -a DIVA_code_doi,global,o,c,"10.5281/zenodo.592476" "${ncfile}"
    ncatted -h -a DIVA_references,global,o,c,"${divacitation}" "${ncfile}"

    echo "  Finished processing file ${i}/${nfiles}"
  fi

done
