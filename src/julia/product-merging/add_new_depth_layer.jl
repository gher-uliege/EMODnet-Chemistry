# Add a new (and empty) depth layer that is missing in a file

include("MergingClim.jl")
using NCDatasets
using Glob
using DataStructures

datadir = "/production/apache/data/emodnet-domains/By sea regions/Black Sea/Autumn (September-November) - 6-year running averages/"
datafile1 = joinpath(datadir, "Water_body_dissolved_oxygen_concentration.4Danl.nc")
outputdir = "/production/apache/data/emodnet-domains/Tests"
outputfile = joinpath(outputdir, "test.nc")

isfile(outputfile) ? rm(outputfile) : @debug("Creating new output file")

# Dimensions
ndepth = 13
nlon = 310
nlat = 160
ntimes = 46
valex = Float32(-99.0)

ds = NCDataset(outputfile,"c", attrib = OrderedDict(
    "Conventions"               => "CF-1.0",
    "project"                   => "SeaDataNetII: http://www.seadatanet.org/",
    "institution"               => "University of Liege, GeoHydrodynamics and Environment Research",
    "production"                => "Diva group. E-mails : a.barth@ulg.ac.be ; swatelet@ulg.ac.be",
    "data_access"               => "GHER OPENDAB: http://gher-diva.phys.ulg.ac.be/data/",
    "WEB_visualisation"         => "http://gher-diva.phys.ulg.ac.be/web-vis/clim.html",
    "Author_e-mail"             => "Luminita Buga <lbuga@web.de>, Gheorghe Sarbu <ghesarbu@gmail.com>",
    "Acknowledgements"          => "No acknowledgement",
    "date"                      => "2021-03-08T00:00:00",
    "title"                     => "DIVA 4D analysis of Water body dissolved oxygen concentration",
    "file_name"                 => "../output/3Danalysis/Water body dissolved oxygen concentration.4Danl.nc",
    "source"                    => "observational data from EMODNet Chemistry Data Network",
    "comment"                   => "Every year of the time dimension corresponds to a 6-year centred average for the Autumn season (September-November)",
    "product_id"                => "1f1e0e51-b745-11e8-869e-6805ca696f0e",
    "search_keywords"           => "Dissolved oxygen parameters in the water column",
    "parameter_keywords"        => "Water body dissolved oxygen concentration",
    "area_keywords"             => "Black Sea, Sea of Azov, Sea of Marmara",
    "product_version"           => "1.0",
    "preview"                   => "http://ec.oceanbrowser.net/emodnet/Python/web/wms?styles=vmax%3A338.5918%2Bvmin%3A258.90442&format=image%2Fpng&height=500&bbox=26.5%2C40.0%2C41.95%2C47.95&decorated=true&transparent=true&layers=Black+Sea%2FAutumn+%28September-November%29+-+6-years+running+averages%2FWater+body+dissolved+oxygen+concentration.4Danl.nc%2AWater+body+dissolved+oxygen+concentration&crs=CRS%3A84&service=WMS&request=GetMap&width=800&version=1.3.0",
    "institution_edmo_code"     => "697",
    "doi"                       => "10.6092/1c3ae65f-ab75-4ce0-9485-e9a4383581c1",
    "history"                   => "Mon Jun 27 14:53:39 2022: ncks -O --mk_rec_dmn time /production/apache/data/emodnet-domains/By sea regions/Black Sea/Autumn (September-November) - 6-year running averages/Water_body_dissolved_oxygen_concentration.4Danl.nc /production/apache/data/emodnet-domains/By sea regions/Black Sea/Autumn (September-November) - 6-year running averages/Water_body_dissolved_oxygen_concentration.4Danl.nc
Wed Jul 28 13:25:23 2021: ncatted -a product_id,global,o,c,1f1e0e51-b745-11e8-869e-6805ca696f0e Water_body_dissolved_oxygen_concentration.4Danl.nc
Wed May 12 14:52:11 2021: ncks -d depth,1,12 Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc Water_body_dissolved_oxygen_concentration_Autumn.4Danl_depth.nc
Mon May 10 22:18:24 2021: ncatted -O -a date,global,o,c,2021-03-08T00:00:00 Autumn (September-November) - 6-years running averages/Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc
Mon May 10 21:52:12 2021: ncatted -O -a date,global,o,c,2021-03-08T00:00:00 Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc
Thu Apr  1 18:56:35 2021: ncks -x -v obslon,obslat,obsdepth,obstime,obsid output1.nc output2.nc
Thu Apr  1 18:56:12 2021: ncrcat unu.nc Water_body_dissolved_oxygen_concentration_Autumn_EMD4.4Danl.nc output1.nc
Thu Apr  1 18:56:03 2021: ncks -d time,0,40 Water_body_dissolved_oxygen_concentration_Autumn_EMD3.4Danl.nc unu.nc
Thu Apr  1 18:55:29 2021: ncks --ovr --mk_rec_dmn time Water_body_dissolved_oxygen_concentration_Autumn_EMD3.4Danl.nc Water_body_dissolved_oxygen_concentration_Autumn_EMD3.4Danl.nc",
    "NCO"                       => "netCDF Operators version 4.9.9 (Homepage = http://nco.sf.net, Code = http://github.com/nco/nco)",
    "nco_openmp_thread_number"  => Int32(1),
))

ds.dim["time"] = Inf # unlimited dimension
ds.dim["depth"] = ndepth
ds.dim["lat"] = nlat
ds.dim["lon"] = nlon
ds.dim["nv"] = 2
ds.dim["observations"] = 311840
ds.dim["idlen"] = 51

# Declare variables

ncCLfield = defVar(ds,"CLfield", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Correlation length field",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(1.6),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncCORRLEN = defVar(ds,"CORRLEN", Float32, ("depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Correlation Length",
    "units"                     => "degrees_north",
))

ncSNR = defVar(ds,"SNR", Float32, ("depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Signal to Noise",
))

ncVARBACK = defVar(ds,"VARBACK", Float32, ("depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Background Field Variance",
    "units"                     => "umol/l^2",
))

ncWater_body_dissolved_oxygen_concentration = defVar(ds,"Water body dissolved oxygen concentration", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Water body dissolved oxygen concentration",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(553.0),
    "_FillValue"                => Float32(-99.0),
    "cell_methods"              => "time: mean (this month data from all years)",
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_L1 = defVar(ds,"Water body dissolved oxygen concentration_L1", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Water body dissolved oxygen concentration masked using relative error threshold 0.3",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(553.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_L2 = defVar(ds,"Water body dissolved oxygen concentration_L2", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Water body dissolved oxygen concentration masked using relative error threshold 0.5",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(553.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_deepest = defVar(ds,"Water body dissolved oxygen concentration_deepest", Float32, ("lon", "lat", "time"), attrib = OrderedDict(
    "long_name"                 => "Deepest values of Water body dissolved oxygen concentration",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(553.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_deepest_L1 = defVar(ds,"Water body dissolved oxygen concentration_deepest_L1", Float32, ("lon", "lat", "time"), attrib = OrderedDict(
    "long_name"                 => "Deepest values of Water body dissolved oxygen concentration masked using relative error threshold 0.3",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(437.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_deepest_L2 = defVar(ds,"Water body dissolved oxygen concentration_deepest_L2", Float32, ("lon", "lat", "time"), attrib = OrderedDict(
    "long_name"                 => "Deepest values of Water body dissolved oxygen concentration masked using relative error threshold 0.5",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(437.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_err = defVar(ds,"Water body dissolved oxygen concentration_err", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Error standard deviation of Water body dissolved oxygen concentration",
    "units"                     => "umol/l",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(90.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncWater_body_dissolved_oxygen_concentration_relerr = defVar(ds,"Water body dissolved oxygen concentration_relerr", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Relative error of Water body dissolved oxygen concentration",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(1.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncclimatology_bounds = defVar(ds,"climatology_bounds", Float32, ("nv", "time"), attrib = OrderedDict(
    "climatology_bounds"        => Float32[243.0, 2160.0, 608.0, 2526.0, 974.0, 2891.0, 1339.0, 3256.0, 1704.0, 3621.0, 2069.0, 3987.0, 2435.0, 4352.0, 2800.0, 4717.0, 3165.0, 5082.0, 3530.0, 5448.0, 3896.0, 5813.0, 4261.0, 6178.0, 4626.0, 6543.0, 4991.0, 6909.0, 5357.0, 7274.0, 5722.0, 7639.0, 6087.0, 8004.0, 6452.0, 8370.0, 6818.0, 8735.0, 7183.0, 9100.0, 7548.0, 9465.0, 7913.0, 9831.0, 8279.0, 10196.0, 8644.0, 10561.0, 9009.0, 10926.0, 9374.0, 11292.0, 9740.0, 11657.0, 10105.0, 12022.0, 10470.0, 12387.0, 10835.0, 12753.0, 11201.0, 13118.0, 11566.0, 13483.0, 11931.0, 13848.0, 12296.0, 14214.0, 12662.0, 14579.0, 13027.0, 14944.0, 13392.0, 15309.0, 13757.0, 15675.0, 14123.0, 16040.0, 14488.0, 16405.0, 14853.0, 16770.0, 15218.0, 17136.0],
))

ncdatabins = defVar(ds,"databins", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Logarithm10 of number of data in bins",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(2.6),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

ncdepth = defVar(ds,"depth", Float32, ("depth",), attrib = OrderedDict(
    "units"                     => "meters",
    "positive"                  => "down",
))

nclat = defVar(ds,"lat", Float32, ("lat",), attrib = OrderedDict(
    "units"                     => "degrees_north",
))

nclon = defVar(ds,"lon", Float32, ("lon",), attrib = OrderedDict(
    "units"                     => "degrees_east",
))

ncobsdepth = defVar(ds,"obsdepth", Float64, ("observations",), attrib = OrderedDict(
    "units"                     => "meters",
    "positive"                  => "down",
    "long_name"                 => "depth of the observations",
    "standard_name"             => "depth",
))

ncobsid = defVar(ds,"obsid", Char, ("idlen", "observations"), attrib = OrderedDict(
    "long_name"                 => "observation identifier",
    "coordinates"               => "obstime obsdepth obslat obslon",
))

ncobslat = defVar(ds,"obslat", Float64, ("observations",), attrib = OrderedDict(
    "units"                     => "degrees_north",
    "long_name"                 => "latitude of the observations",
    "standard_name"             => "latitude",
))

ncobslon = defVar(ds,"obslon", Float64, ("observations",), attrib = OrderedDict(
    "units"                     => "degrees_east",
    "long_name"                 => "longitude of the observations",
    "standard_name"             => "longitude",
))

ncobstime = defVar(ds,"obstime", Float64, ("observations",), attrib = OrderedDict(
    "units"                     => "days since 1900-01-01 00:00:00",
    "long_name"                 => "time of the observations",
    "standard_name"             => "time",
))

ncoutlbins = defVar(ds,"outlbins", Float32, ("lon", "lat", "depth", "time"), attrib = OrderedDict(
    "long_name"                 => "Logarithm10 of number of outliers data in bins",
    "valid_min"                 => Float32(0.0),
    "valid_max"                 => Float32(-99.0),
    "_FillValue"                => Float32(-99.0),
    "missing_value"             => Float32(-99.0),
))

nctime = defVar(ds,"time", Float32, ("time",), attrib = OrderedDict(
    "units"                     => "Days since 1970-01-01",
    "climatology"               => "climatology_bounds",
))


# Read info from the original netCDF file
NCDatasets.Dataset(datafile1, "r") do ds

    # Create an empty 4D array that will be filled using the values from
    # the original fields
    emptyfield4D = Array{Union{Missing, Float32}, 4}(undef, nlon, nlat, ndepth, ntimes);
    emptyfield4D[:,:,1,:] .= valex 
    emptyfield4D[:,:,2:end,:] = ds["CLfield"][:]
    ncCLfield[:] = emptyfield4D

    emptyfield = Array{Union{Missing, Float32}, 2}(undef, ndepth, ntimes);
    emptyfield[1,:] .= valex 
    emptyfield[2:end,:] = ds["CORRLEN"][:]
    ncCORRLEN[:] = emptyfield

    emptyfield[2:end,:] = ds["SNR"][:]
    ncSNR[:] = emptyfield

    emptyfield[2:end,:] = ds["VARBACK"][:]
    ncVARBACK[:] = emptyfield

    emptyfield4D[:,:,2:end,:] = ds["Water body dissolved oxygen concentration"][:]
    ncWater_body_dissolved_oxygen_concentration[:] = emptyfield4D

    emptyfield4D[:,:,2:end,:] = ds["Water body dissolved oxygen concentration_L1"][:]
    ncWater_body_dissolved_oxygen_concentration_L1[:] = emptyfield4D
    
    emptyfield4D[:,:,2:end,:] = ds["Water body dissolved oxygen concentration_L2"][:]
    ncWater_body_dissolved_oxygen_concentration_L2[:] = emptyfield4D
    
    # The 'deepest' fields don't have to be modified
    ncWater_body_dissolved_oxygen_concentration_deepest[:] = ds["Water body dissolved oxygen concentration_deepest"][:]
    
    ncWater_body_dissolved_oxygen_concentration_deepest_L1[:] = ds["Water body dissolved oxygen concentration_deepest_L1"][:]
    
    ncWater_body_dissolved_oxygen_concentration_deepest_L2[:] = ds["Water body dissolved oxygen concentration_deepest_L2"][:]
    
    emptyfield4D[:,:,2:end,:] = ds["Water body dissolved oxygen concentration_err"][:]
    ncWater_body_dissolved_oxygen_concentration_err[:] = emptyfield4D
    
    emptyfield4D[:,:,2:end,:] = ds["Water body dissolved oxygen concentration_relerr"][:]
    ncWater_body_dissolved_oxygen_concentration_relerr[:] = emptyfield4D

    ncclimatology_bounds[:] = ds["climatology_bounds"][:]
    ncdatabins[:] = ds["databins"][:]

    # We add one depth layer...
    ncdepth[:] = Float32.([250, 200, 150, 125, 100, 75, 50, 40, 30, 20, 10, 5, 0])
    nclat[:] = ds["lat"][:]
    nclon[:] = ds["lon"][:]
    ncobsdepth[:] = ds["obsdepth"][:]
    ncobsid[:] = ds["obsid"][:]
    ncobslat[:] = ds["obslat"][:]
    ncobslon[:] = ds["obslon"][:]
    ncobstime[:] = ds["obstime"][:]
    ncoutlbins[:] = ds["outlbins"][:]
    nctime[:] = ds["time"]
end

close(ds)
