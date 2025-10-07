#!/bin/bash
shopt -s nullglob

#datadir = ${1}
datadir="/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/Results/By_sea_regions-water_body/Baltic_Sea"

if [ -d ${datadir} ]; then
    echo "directory exists"
else
    echo "No directory names ${datadir}"
    exit 0
fi

for datafile in $(ls ${datadir}/*.nc); do
    echo "working on file $(basename ${datafile})"

    if [[ "$(basename ${datafile})" =~ "chlorophyll" ]]; then
        echo "Working on chlorophyll"
        echo "----------------------"
        ncrename -h -O -v ".Water body chlorophyll-a","Water_body_chlorophyll-a" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_L1","Water_body_chlorophyll-a_L1" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_L2","Water_body_chlorophyll-a_L2" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_relerr","Water_body_chlorophyll-a_relerr" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_deepest","Water_body_chlorophyll-a_deepest" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_deepest_L1","Water_body_chlorophyll-a_deepest_L1" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_deepest_L2","Water_body_chlorophyll-a_deepest_L2" ${datafile}
        ncrename -h -O -v ".Water body chlorophyll-a_deepest_depth","Water_body_chlorophyll-a_deepest_depth" ${datafile}

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile} 
    elif [[ "$(basename ${datafile})" =~ "nitrogen" ]]; then
        echo "Working on nitrogen"
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen","Water_body_dissolved_inorganic_nitrogen" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_L1","Water_body_dissolved_inorganic_nitrogen_L1" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_L2","Water_body_dissolved_inorganic_nitrogen_L2" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_relerr","Water_body_dissolved_inorganic_nitrogen_relerr" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_deepest","Water_body_dissolved_inorganic_nitrogen_deepest" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_deepest_L1","Water_body_dissolved_inorganic_nitrogen_deepest_L1" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_deepest_L2","Water_body_dissolved_inorganic_nitrogen_deepest_L2" ${datafile}
        ncrename -h -O -v ".Water body dissolved inorganic nitrogen_deepest_depth","Water_body_dissolved_inorganic_nitrogen_deepest_depth" ${datafile}

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile}
    elif  [[ "$(basename ${datafile})" =~ "oxygen" ]]; then
        echo "Working on oxygen"
        ncrename -h -O -v ".Water body dissolved oxygen concentration","Water_body_dissolved_oxygen_concentration" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_L1","Water_body_dissolved_oxygen_concentration_L1" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_L2","Water_body_dissolved_oxygen_concentration_L2" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_relerr","Water_body_dissolved_oxygen_concentration_relerr" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_deepest","Water_body_dissolved_oxygen_concentration_deepest" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_deepest_L1","Water_body_dissolved_oxygen_concentration_deepest_L1" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_deepest_L2","Water_body_dissolved_oxygen_concentration_deepest_L2" ${datafile}
        ncrename -h -O -v ".Water body dissolved oxygen concentration_deepest_depth","Water_body_dissolved_oxygen_concentration_deepest_depth" ${datafile}

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile}
    elif  [[ "$(basename ${datafile})" =~ "phosphate" ]]; then
        echo "Working on nitrate"
        ncrename -h -O -v ".Water body phosphate","Water_body_phosphate" ${datafile}
        ncrename -h -O -v ".Water body phosphate_L1","Water_body_phosphate_L1" ${datafile}
        ncrename -h -O -v ".Water body phosphate_L2","Water_body_phosphate_L2" ${datafile}
        ncrename -h -O -v ".Water body phosphate_relerr","Water_body_phosphate_relerr" ${datafile}
        ncrename -h -O -v ".Water body phosphate_deepest","Water_body_phosphate_deepest" ${datafile}
        ncrename -h -O -v ".Water body phosphate_deepest_L1","Water_body_phosphate_deepest_L1" ${datafile}
        ncrename -h -O -v ".Water body phosphate_deepest_L2","Water_body_phosphate_deepest_L2" ${datafile}
        ncrename -h -O -v ".Water body phosphate_deepest_depth","Water_body_phosphate_deepest_depth" ${datafile}

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile}

    elif  [[ "$(basename ${datafile})" =~ "silicate" ]]; then
        echo "Working on silicate"
        ncrename -h -O -v ".Water body silicate","Water_body_silicate" ${datafile}
        ncrename -h -O -v ".Water body silicate_L1","Water_body_silicate_L1" ${datafile}
        ncrename -h -O -v ".Water body silicate_L2","Water_body_silicate_L2" ${datafile}
        ncrename -h -O -v ".Water body silicate_relerr","Water_body_silicate_relerr" ${datafile}
        ncrename -h -O -v ".Water body silicate_deepest","Water_body_silicate_deepest" ${datafile}
        ncrename -h -O -v ".Water body silicate_deepest_L1","Water_body_silicate_deepest_L1" ${datafile}
        ncrename -h -O -v ".Water body silicate_deepest_L2","Water_body_silicate_deepest_L2" ${datafile}
        ncrename -h -O -v ".Water body silicate_deepest_depth","Water_body_silicate_deepest_depth" ${datafile}

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile}
    elif  [[ "$(basename ${datafile})" =~ "ammonium" ]]; then
        echo "Working on ammonium"

        ncks -7 -O -L 5 --baa=4 --ppc default=3 ${datafile} ${datafile}
    else
        echo "Unknown variable"
    fi

done