using NCDatasets

include("./emodnetchemistry.jl")
datadir = "/production/apache/data/emodnet-domains"
datafilelist = get_file_list(datadir)

for datafile in datafilelist
    @info("Working on $(datafile)")
    NCDataset(datafile, "r") do ds
        if "abstract" in keys(ds.attrib)
            @debug("ok")
        else
            @info("No abstract")
        end
    end
end
