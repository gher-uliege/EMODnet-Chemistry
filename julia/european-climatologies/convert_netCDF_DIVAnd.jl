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
inputdir = "/data/EMODnet/Eutrophication/"
outputdir = "/data/EMODnet/Eutrophication/Split"

inputfile = joinpath(inputdir, "data_from_BALTIC_eutrophication_timeseries_20221005.nc")

# Set region name (in agreeent with the input file!)
regionname = "BalticSea_TS"


!isdir(outputdir) ? mkdir(outputdir) : @debug("Already created")

@info("Working on region $(regionname)")
@info("File from directory: $(dirname(inputfile))")
if isfile(inputfile)
   @info("Start loop on variables")

   for varname in varlist
      @info("Working on variable $(varname)")

      vnamesuffix = replace(varname, " " => "_")
      outputfile = joinpath(outputdir, "$(regionname)_$(vnamesuffix).nc")

      if !isfile(outputfile)

         try
            @info("Reading original netCDF file")
               @time obsval, obslon, obslat, obsdepth, obstime, obsid =
                   NCODV.load(Float64, inputfile, varname);

            @info("Writing new netCDF file")
            @time DIVAnd.saveobs(outputfile, varname, obsval,
               (obslon, obslat, obsdepth, obstime), obsid)
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
