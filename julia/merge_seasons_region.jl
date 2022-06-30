using NCDatasets
using Dates
using Glob
using DIVAnd
include("MergingClim.jl")

# Merge the 4 seasonal file into a unique, annual file for each variable and each season.
# The record variable (time) has already been created.
#
# 1. Loop on the regions
# 2. Loop on the variables
# 3. List the files corresponding to the variable and the region
# 4. Process the list of files


# User inputs
# ------------

hostname = gethostname()
if hostname == "ogs04"
	@info "Working in production server"
	outputbasedir = "/production/apache/data/emodnet-test-charles/merged"
	databasedir = "/production/apache/data/emodnet-domains/By sea regions"
elseif hostname == "GHER-ULg-Laptop"
	outputdir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
else
	@error("Unknown host")
end

isdir(outputbasedir) ? @debug("Already exists") : mkpath(outputbasedir);

regionlist = readdir(databasedir);
varnamelist = ["chlorophyll-a", "silicate", "oxygen_concentration", "phosphate", "nitrogen"]

# Loop on regions
for region in regionlist[1:1]
	@info("Working on region $(region)")
	regiondir = joinpath(databasedir, region)
	isdir(regiondir) ? @debug("Directory exists") : @warn("Directory does not exist")

	seasonlist = readdir(regiondir)
	seasondir = joinpath(regiondir, seasonlist[1])	

	# Generate a list of files from the first season directory
	# (since the file names are the same for each season)
	datafilelist = basename.(glob("*.nc", seasondir))
	#@show(datafilelist);
	nfiles = length(datafilelist)
	@info("Found $(nfiles) variables");

	# Create new output directory
	outputdir = joinpath(outputbasedir, region)
	isdir(outputdir) ? @debug("Already exists") : mkpath(outputdir);	
        @info("Output directory: $(outputdir)");
 
	# Now for each variable we construct the path of the 4 files (one per season)
	for variable in datafilelist[1:1]
		@info("Working on variable $(variable)");
			
		outputfile = joinpath(outputdir, replace(variable, ".nc"=>"year.nc"))
		@info("Creating new output file $(outputfile)")
		datafilepaths = [joinpath(databasedir, region, season, variable) for season in seasonlist];
		#@show(datafilepaths);
                ncrcatcommand = """ncrcat $(join(datafilepaths, " ")) $(outputfile)""";
                ncrcatcommand = `ncrcat "$(datafilepaths[1])" "$(datafilepaths[2])" "$(datafilepaths[3])" "$(datafilepaths[4])" $(outputfile)`;
		@show(ncrcatcommand);
		# Write the command to a text file
		#open("commands2run.txt", "w") do io
		#	write(io, ncrcatcommand)
		#end
		
	end

end
