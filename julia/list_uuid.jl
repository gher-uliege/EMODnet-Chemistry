# List the uuid from a list of files
#

using NCDatasets
using Glob

hostname = gethostname()
if hostname == "ogs04"
	@info "Working in production server"
	outputbasedir = "/production/apache/data/emodnet-test-charles/merged"
	databasedir = "/production/apache/data/emodnet-domains/By sea regions"
elseif hostname == "GHER-ULg-Laptop"
	outputbasedir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
elseif hostname == "gherdivand"
	outputbasedir = "/home/ctroupin/data/EMODnet/merged"
	databasedir = "/home/ctroupin/data/EMODnet/By sea regions"
else
	@error("Unknown host")
end


regionlist = readdir(databasedir);

# Loop on regions
for region in regionlist[1:1]
	@info("Working on region $(region)")
	
	seasonlist = readdir(regiondir)
	seasondir = joinpath(regiondir, seasonlist[1])

	# Generate a list of files from the first season directory
	# (since the file names are the same for each season)
	datafilelist = basename.(glob("*.nc", seasondir))
	#@show(datafilelist);
	nfiles = length(datafilelist)
	@info("Found $(nfiles) variables");


	# Now for each variable we construct the path of the 4 files (one per season)
	for variable in datafilelist
		@info("Working on variable $(variable)");

		# Generate a list of file path for: 1 region and 1 variable (and hence 4 seasons)
		datafilepaths = [joinpath(databasedir, region, season, variable) for season in seasonlist];

		# Loop on all the 4 files
		for datafile in datafilepaths

		    # Open the netCDF and loop on the time instances
		    # to create new files
       	    NCDatasets.Dataset(datafile, "r") do ds
            	uuid = ds.attrib["product_id"];
                println(uuid);
            end
        end
		
	end
end
