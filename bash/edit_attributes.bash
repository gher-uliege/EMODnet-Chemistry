#!/bin/bash
#===============================================================================
#
# FILE: edit_attributes.bash
#
# USAGE: edit_attributes.bash
#
# DESCRIPTION: modify the global attribute 'DIVA_references'
# in all the netCDF files listed in the directory "domaindir".
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, Uliege)),
#
# VERSION: 1.0
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s globstar

declare -r domaindir="/production/apache/data/emodnet-domains/"
echo "Working in ${domaindir}"

if [ -d "${domaindir}" ]; then
  echo "Directory exists"
else
  echo "Directory does not exist. Exit"
  exit 1
fi
# Loop on the netCDF files
nfiles=$(ls "${domaindir}"/**/*.nc | wc -l)
echo "Processing " ${nfiles} "netCDF files"

if [ "${nfiles}" -gt "0" ]; then
  i=0
  for ncfile in "${domaindir}"**/*.nc; do # Whitespace-safe and recursive
    ((i++))
    echo " "
    echo "Working on file ${i}/${nfiles}"
    echo "File: ${ncfile}"

    # Editing the attributes
    # -a: name of the attribute
    # -h: don't write the command in "history" global attribute
    echo "Editing global attributes 'DIVA_references'"
    ncatted -h -a DIVA_references,global,o,c,"Troupin, C.; Sirjacobs, D.; Rixen, M.; Brasseur, P.; Brankart, J.-M.;\
    Barth, A.;Alvera-Azcarate, A.; Capet, A.; Ouberdous, M.; Lenartz, F.; Toussaint, M.-E. & Beckers, J.-M. (2012)\
    Generation of analysis and consistent error fields using the Data Interpolating Variational Analysis (Diva).\
    Ocean Modelling, 52-53: 90-101. doi:10.1016/j.ocemod.2012.05.002\n\
    Beckers, J.-M.; Barth, A.; Troupin, C. & Alvera-Azcarate, A.\
    Some approximate and efficient methods to assess error fields in spatial gridding with DIVA\
    (Data Interpolating Variational Analysis) (2014).\
    Journal of Atmospheric and Oceanic Technology, 31: 515-530.\
    doi:10.1175/JTECH-D-13-00130.1" "${ncfile}"

    echo "Finished processing file ${i}/${nfiles}"
  done
else
  echo "There is no file in the specified directory"
fi
