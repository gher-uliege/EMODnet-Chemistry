using NCDatasets
using Dates
using Glob
using DIVAnd
using Test
using CSV
using DataFrames
include("./emodnetchemistry.jl")

doifile = "../../diva_2023_doi.csv"

if isfile(doifile)
    # Read the CSV
    data = CSV.read(doifile, DataFrame, header=["productID", "productTitle", "productDOI"]);
else
    @error("The file containing the DOI doesn't exist")
end

databasedir, _ = get_dirnames()

# Generate list of netCDF
resultfilelist = get_file_list(databasedir);
@info("Found $(length(resultfilelist)) netCDF files");

thecitation = "Usage is subject to mandatory citation: \"This resource was generated in the framework \
 of EMODnet Chemistry, under the support of DG MARE Call for Tender EASME/EMFF/2020/3.1.11/European \
 Marine Observation and Data Network (EMODnet) - Lot 5 - Chemistry\""

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
            @info("$(oldDOI) -> $(newDOI)")
            ds.attrib["doi"] = newDOI
        end

        @info("Changing citation")
        ds.attrib["citation"] = thecitation
        # ds.attrib["Conventions"] = "CF-1.10"
    end
end
