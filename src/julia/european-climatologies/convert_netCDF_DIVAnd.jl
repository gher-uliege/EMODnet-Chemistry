"""Small script to convert the ODV netCDF to different DIVAnd netCDF, one per variable.

Note: some files have different names for the variables, namely 'DIN' instead of the full name,
in this case the script issues an error and the conversion for that variable is done "by hand".

File naming:
the file names are build from the region (variable `regionname`) and the name of the variable (without the white spaces).
Region name could be deduced from the input file name but that is maybe not trivial (and I did not try).
"""

using NCDatasets
using DIVAnd

# Set list of parameters (long names)
varlist = ["Water body phosphate",
           "Water body dissolved oxygen concentration",
           "Water body silicate",
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen (DIN)",
           "Water body ammonium"
           ]

# Set input and output directories
inputdir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/ODVnetCDF/"
outputdir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/netCDF"
!isdir(outputdir) ? mkdir(outputdir) : @debug("Already created")

datafilesdict = Dict(
"data_from_BALTIC_eutrophication_profiles_20240508.nc" => "BalticSea",
"data_from_BALTIC_eutrophication_timeseries_2024.nc" => "BalticSeaTS",
"data_from_EEA_Eutrophication_BlackSea_profiles_2024_V1.nc" => "BlackSea",
"data_from_Eutrophication_Arctic_profiles_2024_all.nc" => "ArcticSea",
"data_from_Eutrophication_Atlantic_profiles_2024.nc" => "Atlantic",
"data_from_Eutrophication_Atlantic_timeseries_2024.nc" => "AtlanticTS",
"data_from_Eutrophication_Caribbean_profiles_2024.nc" => "Caribbean",
"data_from_Eutrophication_Caribbean_time_series_2024.nc" => "CaribbeanTS",
"data_from_Eutrophication_MED_profiles_6.2024.nc" => "Mediterranean",
"data_from_North_Sea_eutrhophication_profiles_20240529.nc" => "NorthSea",
"data_from_North_Sea_eutrhophication_timeseries_20240529.nc" => "NorthSeaTS"
)


# Loop on the files
for datafile in keys(datafilesdict)
   @info("---------------------------")
   @info("Working on file $(datafile)")
   @info("---------------------------")
   inputfile = joinpath(inputdir, datafile)

   # Set region name (in agreeent with the input file!)
   regionname = datafilesdict[datafile]
   @info("Region name: $(regionname)")

   if isfile(inputfile)
      @info("Start loop on variables")

      for varname in varlist
         @info("Working on variable $(varname)")

         vnameclean = replace(varname, " (DIN)"=> "", " "=>"_")
         outputfile = joinpath(outputdir, "$(regionname)_$(vnameclean).nc")

         if !isfile(outputfile)

            try
               @info("Reading original netCDF file")
                  @time obsval, obslon, obslat, obsdepth, obstime, obsid =
                     NCODV.load(Float64, inputfile, varname, qv_flags = ["good_value", "probably_good_value"]);

               @info("Writing new netCDF file")
               DIVAnd.saveobs(outputfile, vnameclean, obsval, (obslon, obslat, obsdepth, obstime), obsid)
            catch e
               @warn("Problem to read variable $(varname) in the netCDF file")

            end

            @info("Written new file $(outputfile)")
         else
            @info("File $(outputfile) already created")
         end

      end
   else
      @warn("Input file does not exist")
   end
end