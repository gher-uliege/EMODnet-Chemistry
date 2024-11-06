Dear Reiner,

I would like to propose you a simple development for ODV that could be relevant in the frame of FAIR-EASE.

As we know it is fundamental that users have access to datasets in a few clicks.
However with DIVAnd, reading an ODV spreasheet can be very time consuming. 
Why is that? The observations are organised as profiles, and one has to loop over each profiles and read all the observations. We believe our code (in Julia) is rather optimised for this task. Still, if we want to read all the temperature measurements from the Mediterranean Sea eutrophication dataset, it takes approximately 2100 seconds. 

Solution #1: export the data to netCDF instead of an ODV spreasheet.




tar xvf odv_5.6.7_linux-amd64.tar.gz

EMD_Eutrophication_Med_2022_unrestricted.zip

Export to ODV spreadsheet:
- data_from_Eutrophication_Med_profiles_2022_unrestricted.txt 
- temperature and salinity
- Export performed in two minutes
- File size: 2.5G

191099 stations exported??
  
Export to netCDF: 
- data_from_Eutrophication_Med_profiles_2022_unrestricted.nc
- same configuration as before
- export performed in two minutes
- File size: 147M

Reading the spreadsheet file

@time obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.ODVspreadsheet.load(Float64,["data_from_Eutrophication_Med_profiles_2022_unrestricted_short.txt"],["ITS-90 water temperature"];
           nametype = :localname)

[ Info: Starting loop on the 20800593 profiles
...

2914.798722

Read the netCDF file

@time obsval, obslon, obslat, obsdepth, obstime, obsid = NCODV.load(Float64, "data_from_Eutrophication_Med_profiles_2022_unrestricted.nc", "ITS-90 water temperature");

29.145991 seconds   

Rewrite the netCDF file using the ragged array format

outputfile = "data_from_Eutrophication_Med_profiles_2022_unrestricted_ragged.nc
@time DIVAnd.saveobs(outputfile, "ITS-90 water temperature", obsval, (obslon, obslat, obsdepth, obstime), obsid)



