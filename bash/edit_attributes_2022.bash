#!/bin/bash
#===============================================================================
#
# FILE: edit_attributes_2022.bash
#
# USAGE: edit_attributes_2022.bash
#
# DESCRIPTION: processes all the netCDF files
# listed in the directory "domaindir" and edit the
# variable and global attributes of the products.
#
# If parameter 'testmode' is set to true, no modification is applied to
# the files
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, Uliege)
#
# VERSION: 1.2
#===================================================================================

# Define some flags for the processing
testmode=true           # print the command that wil be executed but don't run anything
newattributes=false     # add a set of global attributes (DIVAnd version, DOI, etc)
addstandardname=false   # add the standard name
removeunitsrelerr=true  # remove the "1" units for the relative error field

# Modify shell behavior and enable "shell globbing"
shopt -s globstar

# dictionary storing the standard names
# (checked before if we were using bash version 4
# echo $BASH_VERSION)


declare -r domaindir="/production/apache/data/emodnet-domains/"
echo "Working on files from directory${domaindir}"

# Generate list of files
datafilelist=()
tmpfile=$(mktemp)
echo ${tmpfile}
find ${domaindir} -type f -name "*.nc" -print0 > ${tmpfile}
while IFS=  read -r -d $'\0'; do
  datafilelist+=("$REPLY")
done <${tmpfile}
rm -f tmpfile

# Need to list all the variables that will be processed by the script:

# 1. Working on all the variables: 
#    the names are constructed by adding a suffix to the main variable name

#     Function to generate a list of variables based on the main variable
function getvarlist {
    echo ${1}","$1"_err",$1"_L1",${1}"_L2",$1"_deepest",$1"_deepest_L1",$1"_deepest_L2"
    }

# 2. Working on all the "relative error" variables:
#    the names are also obtained from the main variable name
#     
#    Examples:
#    Water\ body\ silicate_relerr → Arctic
#    Water\ body\ silicate_relerr → Baltic
#    Water\ body\ silicate_relerr → Black Sea (no unit)
#    Water\ body\ silicate_relerr → Med Sea (no unit)
#    Water_body_silicate_relerr → Atlantic
#    Water\ body\ silicate_relerr → North Sea
#    
# In this case the variable name is obtained easily as:
# varname$1"_relerr",$1"_L1",${1}"_L2",$1"_deepest",$1"_deepest_L1",$1"_deepest_L2"
}


# Define the paper citation, to be included in the metadata (global attributes)
divacitation="Barth, A., Beckers, J.-M., Troupin, C., Alvera-Azcárate, A.,\
and Vandenbulcke, L. (2014): divand-1.0: n-dimensional variational data analysis\
for ocean observations, Geosci. Model Dev., 7, 225–241,\
doi:10.5194/gmd-7-225-2014"

divadoi="10.5281/zenodo.7016823"
divaversion="2.7.9"
divagithub="https://github.com/gher-uliege/DIVAnd.jl"


# Loop on the files found in the directory "domaindir"
i=0
for ncfile in "${datafilelist[@]}" ; do # Whitespace-safe and recursive

  ((i++))
  echo " "
  echo "  Working on file ${i}/${nfiles}"
  echo "  File: ${ncfile}"


  # Editing the attributes
  # -h: override automatically appending the command to the history global attribute
  # -a: name of the attribute
  # o = overwrite (editing mode)
  # c = character (attribute type)
  echo "  Modifying global attributes"

    if [ "${addstandardname}" = true ]; then
      echo "Adding standard name to variables"
      # Loop on the variables of which we have to change the standard name
      vlist=$(echo $(getvarlist "${variable}"))
      IFS=","
      for varnames in ${vlist[@]}; do
        echo "    Working on variable "${varnames}
        if [ "$testmode" = true]; then
          echo "test mode"
          echo ncatted -O -h -a standard_name,"${varnames}",o,c,${stdname} "${ncfile}"
        else
          ncatted -O -h -a standard_name,"${varnames}",o,c,${stdname} "${ncfile}"
        fi
      done
      unset IFS
    fi

    if [ "${removeunitsrelerr}" = true ]; then
      echo "Removing units to the relative error fields"
      # Loop on the variables of which we have to change the standard name
      IFS=","
      if [ "$testmode" = true]; then
        echo "test mode"
        echo ncatted -O -h -a units,"${varnames}",o,c,"" "${ncfile}"
      else
        ncatted -O -h -a units,"${varnames}",o,c,"" "${ncfile}"
      fi
      unset IFS
    fi


    if [ "$newattributes" = true ]; then
      echo "Addig new attributes"
      if [ "$testmode" = true]; then
        echo "test mode"
        echo ncatted -h -a project,global,o,c,"EMODnet Chemistry: http://www.emodnet-chemistry.eu/" "${ncfile}"
        echo ncatted -h -a data_access,global,o,c,"OPeNDAP: http://ec.oceanbrowser.net:8081/data/emodnet-domains/" "${ncfile}"
        echo ncatted -h -a WEB_visualisation,global,o,c,"http://ec.oceanbrowser.net/emodnet/" "${ncfile}"
        echo ncatted -h -a DIVA_source,global,o,c,"${divagithub}" "${ncfile}"
        echo ncatted -h -a DIVA_code_doi,global,o,c,"${divadoi}" "${ncfile}"
        echo ncatted -h -a DIVA_references,global,o,c,"${divacitation}" "${ncfile}"
      else
        ncatted -h -a project,global,o,c,"EMODnet Chemistry: http://www.emodnet-chemistry.eu/" "${ncfile}"
        ncatted -h -a data_access,global,o,c,"OPeNDAP: http://ec.oceanbrowser.net:8081/data/emodnet-domains/" "${ncfile}"
        ncatted -h -a WEB_visualisation,global,o,c,"http://ec.oceanbrowser.net/emodnet/" "${ncfile}"
        ncatted -h -a DIVA_source,global,o,c,"${divagithub}" "${ncfile}"
        ncatted -h -a DIVA_code_doi,global,o,c,"${divadoi}" "${ncfile}"
        ncatted -h -a DIVA_references,global,o,c,"${divacitation}" "${ncfile}"
      fi
    fi

  if [ "$testmode" = true]; then
    echo "test mode"
  fi
  #ncatted -h -a DIVA_source,global,o,c,"https://github.com/gher-ulg/DIVA" "${ncfile}"
  #ncatted -h -a DIVA_code_doi,global,o,c,"10.5281/zenodo.592476" "${ncfile}"
  #ncatted -h -a DIVA_references,global,o,c,"${divacitation}" "${ncfile}"

  echo "  Finished processing file ${i}/${nfiles}"

done
