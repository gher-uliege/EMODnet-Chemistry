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
# VERSION: 1.0
#===================================================================================

# Modify shell behavior and enable "shell globbing"
shopt -s globstar

declare -r domaindir="/production/apache/data/emodnet-domains/"
echo "Working in ${domaindir}"

# Loop on the netCDF files
nfiles=$(ls ${domaindir}/**/*.nc | wc -l)
echo "Processing " ${nfiles} "netCDF files"
echo " "

i=0
for ncfile in ${domaindir}**/*.nc; do # Whitespace-safe and recursive
  ((i++))
  echo " "
  echo "Working on file ${i}/${nfiles}"
  echo "File: "$(basename "${ncfile}")
  # Identify domain name and variable using file path
  # (not the most robust but ok for now)
  domain=$(echo ${ncfile} | cut -d "/" -f 6)
  echo "Domain: "${domain}
  variable=$(echo ${ncfile} | cut -d "/" -f 8 | cut -d "." -f 1)
  echo "Variable:" ${variable}

  # Set the new product ID according to region and variable
  # (horribly hard-coded!)

  if [ "${domain}" == "Atlantic Sea" ]; then
    if [ "${variable}" == "Water_body_ammonium" ]; then
      productID="32aa0167-7214-4351-932e-b938b63077e0"
    elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
      productID="65db24d9-6a85-4897-ab66-39bef973d747"
    elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
      productID="0136ec2d-0b48-4664-86a2-5e05063293ab"
    elif [ "${variable}" == "Water_body_nitrate_plus_nitrite" ]; then
      productID="09124f6c-fce6-4c5d-9b03-7a3b60f2eb77"
    elif [ "${variable}" == "Water_body_phosphate" ]; then
      productID="c438a6f0-76b3-4921-b60b-d8f8fff352c7"
    elif [ "${variable}" == "Water_body_silicate" ]; then
      productID="7dcf1336-3fe7-4b16-aa06-83f0d2c30cc5"
    else
      echo "Error: unknown variable"
      exit 1
    fi
  elif [ "${domain}" == "North Sea" ]; then
    if [ "${variable}" == "Water_body_ammonium" ]; then
      productID="c2faff2e-8958-47fb-8ccb-80b6b3516d88"
    elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
      productID="f9b9cf57-ac4e-474d-b390-cf7fb312d9ad"
    elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
      productID="ed23d9ce-bb9a-4573-b9d6-fdf2bf818102"
    elif [ "${variable}" == "Water_body_nitrate" ]; then
      productID="4f9f3a44-1ae3-4fc1-b59b-99645c00ab9a"
    elif [ "${variable}" == "Water_body_phosphate" ]; then
      productID="5b3e0cf8-7adc-44a1-b174-a89b42906575"
    elif [ "${variable}" == "Water_body_silicate" ]; then
      productID="cda9b48c-f155-4823-8525-7242eccfc6b9"
    elif [ "${variable}" == "Water_body_total_nitrogen" ]; then
      productID="9c877fc1-73ec-488b-87a6-fae14c935f83"
    elif [ "${variable}" == "Water_body_total_phosphorus" ]; then
      productID="df2f22cd-0a16-4d0c-b007-53ad48f5996a"
    else
      echo "Error: unknown variable"
      exit 1
    fi

  elif [ "${domain}" == "Black Sea" ]; then
    if [ "${variable}" == "Water_body_ammonium" ]; then
      productID="82843445-5693-46d9-b382-d818694766a3"
    elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
      productID="25d11e8f-dc14-4004-890c-5dfcd612433a"
    elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
      productID="694210d4-7858-4e4a-bd58-3261a5014e97"
    elif [ "${variable}" == "Water_body_nitrate" ]; then
      productID="2db8fc59-9993-45f9-87bc-6ae555dd5b37"
    elif [ "${variable}" == "Water_body_phosphate" ]; then
      productID="e7d76c4d-5c1f-411e-9962-0cb38eea5b54"
    elif [ "${variable}" == "Water_body_silicate" ]; then
      productID="05313f4a-c353-4e67-a81d-1ab6c4cd1a98"
    elif [ "${variable}" == "Water_body_nitrate_plus_nitrite" ]; then
      productID="a9e5d9a0-d6d8-4ada-ab72-59bccce197e3"
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
      productID="c7e7b665-c7bb-45e6-a09b-d01660ea6aa2"
    elif [ "${variable}" == "Water_body_chlorophyll-a" ]; then
      productID="306468ef-b808-44aa-9054-c879d3885bc1"
    elif [ "${variable}" == "Water_body_dissolved_oxygen_concentration" ]; then
      productID="3a857428-637c-4c4c-8033-2c89f5a0abe9"
    elif [ "${variable}" == "Water_body_nitrate" ]; then
      productID="539e9068-448f-490d-b90b-903d163aad4d"
    elif [ "${variable}" == "Water_body_nitrite" ]; then
      productID="94cd2997-78be-47e6-b570-c51d51041118"
    elif [ "${variable}" == "Water_body_phosphate" ]; then
      productID="3252a2e1-1e38-4ac3-b7c9-491f6bbe97ea"
    elif [ "${variable}" == "Water_body_silicate" ]; then
      productID="98f133a5-3203-44d2-b5fc-4db1656dd3bc"
    elif [ "${variable}" == "Water_body_pH" ]; then
      productID="d6c96e8b-88a6-4d68-9f6d-872c4aff0600"
    elif [ "${variable}" == "Water_body_total_nitrogen" ]; then
      productID="1be7509b-2379-4e1e-bb98-e6c8057fa750"
    elif [ "${variable}" == "Water_body_total_phosphorus" ]; then
      productID="78727f28-e8e0-4f9c-8580-a047b4056d1a"
    else
      echo "Error: unknown variable"
      exit 1
    fi
  else
    echo "Error: unknown region"
    echo "Stop"
    exit 1
  fi

    # Copy the old product ID
    echo "Modifying product ID"
    ncrename -a global@product_id,old_product_id ${ncfile}

    # Update the new product ID
    echo "New product ID: ${productID}"
    ncatted -a product_id,global,o,c,${productID} ${ncfile}

    # Editing the attributes
    # -a: name of the attribute
    # o = overwrite (editing mode)
    # c = character (attribute type)
    echo "Modifying global attributes"
    ncatted -a project,global,o,c,"EMODnet Chemistry: http://www.emodnet-chemistry.eu/" ${ncfile}
    ncatted -a data_access,global,o,c,"OPeNDAP: http://ec.oceanbrowser.net:8081/data/emodnet-domains/" ${ncfile}
    ncatted -a WEB_visualisation,global,o,c,"http://ec.oceanbrowser.net/emodnet/" ${ncfile}

    # Adding new attributes
    # -h: don't write the command in "history" global attribute
    echo "Creating new global attributes"
    ncatted -a DIVA_source,global,o,c,"https://github.com/gher-ulg/DIVA" ${ncfile}
    ncatted -a DIVA_code_doi,global,o,c,"10.5281/zenodo.592476" ${ncfile}
    ncatted -h -a DIVA_references,global,o,c,"Troupin, C.; Sirjacobs, D.; Rixen, M.; Brasseur, P.; Brankart, J.-M.;\
    Barth, A.;Alvera-Azcárate, A.; Capet, A.; Ouberdous, M.; Lenartz, F.; Toussaint, M.-E. & Beckers, J.-M. (2012)\
    Generation of analysis and consistent error fields using the Data Interpolating Variational Analysis (Diva).\
    Ocean Modelling, 52-53: 90-101. doi:10.1016/j.ocemod.2012.05.002\n\
    Beckers, J.-M.; Barth, A.; Troupin, C. & Alvera-Azcárate, A.\
    Some approximate and efficient methods to assess error fields in spatial gridding with DIVA\
    (Data Interpolating Variational Analysis) (2014).\
    Journal of Atmospheric and Oceanic Technology, 31: 515-530.\
    doi:10.1175/JTECH-D-13-00130.1" ${ncfile}

done
