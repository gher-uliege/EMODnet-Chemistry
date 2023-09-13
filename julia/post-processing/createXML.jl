using DIVAnd
using Glob

project = "EMODNET-chemistry"

# User inputs
# ------------

hostname = gethostname()
if hostname == "ogs04"
	@info "Working in production server"
	databasedir = "/production/apache/data/emodnet-domains/By sea regions/Black Sea"
elseif hostname == "GHER-ULg-Laptop"
	outputbasedir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
elseif hostname == "gherdivand"
	outputbasedir = "/home/ctroupin/data/EMODnet/merged"
	databasedir = "/home/ctroupin/data/EMODnet/By sea regions"
elseif hostname == "FSC-PHYS-GHER01"
    outputbasedir = "/home/ctroupin/data/EMODnet-Chemistry/merged"
	databasedir = "/home/ctroupin/data/EMODnet-Chemistry/emodnet-results-2023"
else
	@error("Unknown host")
end

datadir = joinpath(databasedir, "All_European_Seas/")
datafilelist = Glob.glob("*.nc", datadir)
varlist = ["Water body ammonium", 
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen (DIN)",
           "Water body dissolved oxygen concentration",
           "Water body phosphate",
           "Water body silicate"
           ]
cdilist = "./CDI-list-export.zip"

if !isfile(cdilist)
   download("http://emodnet-chemistry.maris2.nl/download/export.zip", cdilist)
end

ignore_errors = true

for (datafile, varname) in zip(datafilelist, varlist)
   @info("Working on file $(basename(datafile))");
   xmlfilename = replace(datafile, ".nc"=>".xml")

   # generate a XML file for Sextant catalog
   divadoxml(datafile,varname,project,cdilist,xmlfilename,
             ignore_errors = ignore_errors)

end