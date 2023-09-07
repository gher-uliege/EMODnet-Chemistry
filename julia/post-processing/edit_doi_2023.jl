using NCDatasets
using Dates
using Glob
using DIVAnd
using Test
using CSV
using DataFrames

doifile = "../../diva_2023_doi.csv"

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

function get_ncfile_list(datadir::String)::Array
    filelist = []
	# Varname with spaces instead of underscores
	for (root, dirs, files) in walkdir(datadir)
        for file in files
            if endswith(file, ".nc")
                push!(filelist, joinpath(root, file))
            end
        end
    end
    @info("Found $(length(filelist)) files")
    return filelist
end

# Read the CSV
data = CSV.read(doifile, DataFrame, header=["productID", "productTitle", "productDOI"]);

# Generate list of netCDF
resultfilelist = get_ncfile_list(databasedir);
resultfilelist

for resfile in resultfilelist
    @debug("Working on file $(resfile)")
    
    NCDataset(resfile, "a") do ds
        productID = ds.attrib["product_id"]
        #@info(productID);
        
        productIndex = findfirst(data.productID .== productID)
        @info(productIndex);
        
        if productIndex == nothing
            @info(resfile);
        else
            @info("Modify the DOI")
            oldDOI = ds.attrib["doi"]
            newDOI = data.productDOI[productIndex]
            @info("$(oldDOI) → $(newDOI)")
        end
    end
end