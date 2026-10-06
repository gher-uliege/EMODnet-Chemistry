mkdir -pv {All_European_Seas-water_body,By_sea_regions-water_body,Coastal_areas-water_body}

cd By_sea_regions-water_body
mkdir -pv {Arctic_Ocean,Baltic_Sea,Black_Sea,Mediterranean_Sea,Northeast_Atlantic_Ocean,North_Sea}

cd ../Coastal_areas-water_body/
mkdir -pv {Baltic_Sea_-_Gulf_of_Riga,Black_Sea-_Danube_Delta,Mediterranean_Sea_-_Po_River,Northeast_Atlantic_Ocean_-_Loire_River}


## Moving



## Renaming

cd By_sea_regions-water_body/Black_Sea/
rename 's/By_sea_regions_Black_Sea_//' *

cd By_sea_regions-water_body/Mediterranean_Sea
mv Water_body_dissolved_inorganic_nitrogen_\(DIN\).4Danl.nc Water_body_dissolved_inorganic_nitrogen.4Danl.nc

cd Coastal_areas-water_body/Black_Sea-_Danube_Delta
rename 's/Coastal_areas_Black_Sea_-_Danube_Delta_//' *

cd Coastal_areas-water_body/Mediterranean_Sea_-_Po_River/
mv Water_body_dissolved_inorganic_nitrogen_\(DIN\).4Danl.nc Water_body_dissolved_inorganic_nitrogen.4Danl.nc

## Change variable names

Use script 
./change_varnames.bash /media/ctroupin/T7Shield/data/EMODnet-Chemistry/Eutrophication2024/Results/Archives2PROCESS/

## Changing DOIs

### Mediterranean_Sea/Water_body_phosphate.4Danl.nc

> Charles, Sissy vient de me confirmer que la "bonne" métadonnée est la "cf00a29d-3a4b-4045-baa4-cbde6259c85c", donc celle qui n'avait pas la mention "to be deleted". J'ai publié la "cf00a29d-3a4b-4045-baa4-cbde6259c85c". Si tout est ok pour toi je supprimerai la "fa8e1c55-829e-4cdc-98ba-7595dd6d5051". -- Amandine

## Baltic_Sea/Water_body_silicate.4Danl.nc

https://doi.org/10.13120/: 63ec087e-be7c-4eba-b74d-7d4baddd01a0 → remove the ":" symbol

```julia
ncatted -h -a doi,global,o,c,"https://doi.org/10.13120/63ec087e-be7c-4eba-b74d-7d4baddd01a0" Water_body_silicate.4Danl.nc
```

## Change long names

Notebook `european-climatologies/change_long_names.ipynb`

