#!/bin/bash
#===============================================================================
#
# FILE: modify_productID.bash
#
# USAGE: modify_productID.bash
#
# DESCRIPTION: processes all the netCDF files
# listed in the directory "domaindir".
#
# REQUIREMENTS: netCDF Operator toolkit (http://nco.sourceforge.net/)
#
# AUTHOR: C. Troupin (GHER, Uliege)),
#
# VERSION: 1.1
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s globstar

# Set the directory containing the netCDF files to be processed
declare -r domaindir="/home/ctroupin/Data/EMODnet/Chemistry/Products2018/Black Sea/"
#declare -r domaindir="/production/apache/data/emodnet-domains/North Sea/"

divacitation="Troupin, C.; Sirjacobs, D.; Rixen, M.; Brasseur, P.; Brankart, J.-M.;\
Barth, A.;Alvera-Azcarate, A.; Capet, A.; Ouberdous, M.; Lenartz, F.; Toussaint, M.-E. & Beckers, J.-M. (2012)\
Generation of analysis and consistent error fields using the Data Interpolating Variational Analysis (Diva).\
Ocean Modelling, 52-53: 90-101. doi:10.1016/j.ocemod.2012.05.002\n\
Beckers, J.-M.; Barth, A.; Troupin, C. & Alvera-Azcarate, A.\
Some approximate and efficient methods to assess error fields in spatial gridding with DIVA\
(Data Interpolating Variational Analysis) (2014).\
Journal of Atmospheric and Oceanic Technology, 31: 515-530.\
doi:10.1175/JTECH-D-13-00130.1"

# Check if directory exists
if [ -d "$domaindir" ]; then
  echo "Working in ${domaindir}"
else
  echo "Directory ${domaindir} doesn't exist, exit"
  exit 1
fi

# Loop on the netCDF files
nfiles=$(ls "${domaindir}"/*6-years*/*.nc | wc -l)
echo "Processing " ${nfiles} "netCDF files"
echo " "

i=0
for ncfile in "${domaindir}"*6-years*/*.nc; do # Whitespace-safe and recursive
((i++))
echo " "
echo "${ncfile}"
echo "Working on file ${i}/${nfiles}"
echo "File: "$(basename "${ncfile}")

# Identify domain name and variable using file path and awk
# (work if we don't change the directory structure and naming too much)
domain=$(echo "$ncfile" | awk -F/ '{print $(NF-2)}')
echo "Domain: ${domain}"
season=$(echo ${ncfile} | awk -F/ '{print $(NF-1)}' | cut -d " " -f 1)
echo "Season: $season"
variable=$(echo ${ncfile} | awk -F/ '{print $(NF)}' | cut -d "." -f 1)
echo "Variable: ${variable}"

# Set the new product ID according to region and variable
# (horribly hard-coded!)

if [ "${domain}" == "Atlantic Sea" ]; then
  if [ "${variable}" == "Water_body_chlorophyll-a" ]; then
    productID="ce474bda-7eba-11e8-84a3-40a8f051e8d0"
  elif [ "${variable}" == "Water_body_dissolved_inorganic_nitrogen_(DIN)" ]; then
    productID="8c928758-84dd-11e8-9571-40a8f051e8d0"
  elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
    productID="210c2726-7a12-11e8-a42c-40a8f051e8d0"
  elif [ "${variable}" == "Water_body_phosphate" ]; then
    productID="a156c24e-7a15-11e8-9a07-40a8f051e8d0"
  elif [ "${variable}" == "Water_body_silicate" ]; then
    productID="6820da10-7aa0-11e8-8311-40a8f051e8d0"
  else
    echo "Error: unknown variable"
    exit 1
  fi
elif [ "${domain}" == "North Sea" ]; then
  if [ "${variable}" == "Water_body_chlorophyll-a" ]; then
    productID="437e11a8-b670-11e8-af14-080027b41aee"
  elif [ "${variable}" == "Water_body_dissolved_inorganic_nitrogen_(DIN)" ]; then
    productID="19eb7546-b671-11e8-bccd-080027b41aee"
  elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
    productID="53ff3c72-b671-11e8-a971-080027b41aee"
  elif [ "${variable}" == "Water_body_dissolved_oxygen_saturation" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_phosphate" ]; then
    productID="f0ff4c10-b671-11e8-baf5-080027b41aee"
  elif [ "${variable}" == "Water_body_silicate" ]; then
    productID="4f41ac50-b672-11e8-baca-080027b41aee"
  else
    echo "Error: unknown variable"
    exit 1
  fi

elif [ "${domain}" == "Black Sea" ]; then
  if [ "${variable}" == "Water body chlorophyll-a" ]; then
    productID="4242ce4f-ba4e-11e8-afd4-6805ca696f0e"
  elif [ "${variable}" == "Water body dissolved inorganic nitrogen (DIN)" ]; then
    productID="b671dcb0-9a1b-11e8-96e7-6805ca696f0e"
  elif [ "${variable}" == "Water body dissolved oxygen concentration" ]; then
    productID="1f1e0e51-b745-11e8-869e-6805ca696f0e"
  elif [ "${variable}" == "Water body phosphate" ]; then
    productID="c5778bd1-b80a-11e8-b013-6805ca696f0e"
  elif [ "${variable}" == "Water body silicate" ]; then
    productID="494676cf-ba43-11e8-a1b8-6805ca696f0e"
  else
    echo "Error: unknown variable"
    exit 1
  fi

elif [ "${domain}" == "Baltic Sea" ]; then
  if [ "${variable}" == "Water_body_ammonium" ]; then
    productID="872da035-f1a5-4288-90bd-82defcb0308b"
  elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
    productID="4e8cdba1-b7e3-49fb-b3c3-312d3de9babe"
  elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
    productID="dc62757e-49da-486c-b9e6-a4e8b0f5659f"
  elif [ "${variable}" == "Water_body_nitrate" ]; then
    productID="b6ec21f4-134b-48ac-b5aa-28550fc3bcaf"
  elif [ "${variable}" == "Water_body_phosphate" ]; then
    productID="cf170882-d53b-4f20-869a-525e2a5b3346"
  elif [ "${variable}" == "Water_body_silicate" ]; then
    productID="31c2227b-a52b-4ce7-b4b1-043a09432ebb"
  elif [ "${variable}" == "Water_body_nitrate_plus_nitrite" ]; then
    productID="c3a6041e-c81d-4646-8bde-8f9fff889944"
  elif [ "${variable}" == "Water_body_total_nitrogen" ]; then
    productID="a03b7c1e-9468-4c22-9823-b36f2433e87c"
  elif [ "${variable}" == "Water_body_total_phosphorus" ]; then
    productID="ea195371-0620-434f-a7a4-094d920c1da3"
  else
    echo "Error: unknown variable"
    exit 1
  fi

elif [ "${domain}" == "Mediterranean Sea" ]; then
  if [ "${variable}" == "Water_body_ammonium" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_nitrate" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_nitrite" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_phosphate" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_silicate" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_pH" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_total_nitrogen" ]; then
    productID=""
  elif [ "${variable}" == "Water_body_total_phosphorus" ]; then
    productID=""
  else
    echo "Error: unknown variable"
    exit 1
  fi
else
  echo "Error: unknown region"
  echo "Stop"
  exit 1
fi

# Check if the files has been processed
# by inspecting the attributes
if ncdump -h "${ncfile}" | grep -q '\:old_product_id\ =\ ' ; then
  echo "File has already been processed"
else
  echo "File has not been processed"

  # Copy the old product ID
  echo "Modifying product ID"
  #ncrename -a global@product_id,old_product_id "${ncfile}"

  # Update the new product ID
  echo "  New product ID: ${productID}"
  echo " "
  #ncatted -a product_id,global,o,c,${productID} "${ncfile}"

  # Editing the attributes
  # -a: name of the attribute
  # o = overwrite (editing mode)
  # c = character (attribute type)
  echo "Modifying global attributes"
  #ncatted -h -a project,global,o,c,"EMODnet Chemistry: http://www.emodnet-chemistry.eu/" "${ncfile}"
  #ncatted -h -a data_access,global,o,c,"OPeNDAP: http://ec.oceanbrowser.net:8081/data/emodnet-domains/" "${ncfile}"
  #ncatted -h -a WEB_visualisation,global,o,c,"http://ec.oceanbrowser.net/emodnet/" "${ncfile}"

  # Adding new attributes
  # -h: don't write the command in "history" global attribute
  echo "  Creating new global attributes"
  #ncatted -h -a DIVA_source,global,o,c,"https://github.com/gher-ulg/DIVA" "${ncfile}"
  #ncatted -h -a DIVA_code_doi,global,o,c,"10.5281/zenodo.592476" "${ncfile}"
  #ncatted -h -a DIVA_references,global,o,c,"${divacitation}" "${ncfile}"


  echo "Finished processing file ${i}/${nfiles}"
fi
done
