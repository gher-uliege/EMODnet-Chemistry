using NCDatasets
using Glob

#datadir = "/production/apache/data/emodnet-domains/By sea regions/Baltic Sea/"
#datadir = "/production/apache/data/emodnet-domains/All European Seas/"
#datadir = "/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean"
#datadir = "/production/apache/data/emodnet-domains/By sea regions/Black Sea/"
#datadir = "/production/apache/data/emodnet-domains/By sea regions/Arctic Ocean/"

datadir = "/production/apache/data/emodnet-domains/Coastal areas/Northeast Atlantic Ocean - Loire River"
filelist = Glob.glob("*.nc", datadir)

# Get variable name
function get_varname(datafile::String)
    NCDatasets.Dataset(datafile) do nc
        varname = keys(nc)[1]
        return varname::String
    end
end

#function get_varname(datafile::String)
#    fname = basename(datafile)
#    varname = replace(fname, ".4Danl.nc" => "")
#    return varname
#end


function write_json(jsonfile::String, varname::String)
    jsontpl = """
    {
        \"default_time\": \"2000\",
        \"subfolders\": [
            {
                \"name\": \"Additional fields\",
                \"variables\": [
                    \"$(varname)\",
                    \"$(varname)_L1\",
                    \"$(varname)_err\",
                    \"$(varname)_relerr\",
                    \"databins\",
                    \"outlbins\",
                    \"CLfield\",
                    \"$(varname)_deepest\",
                    \"$(varname)_deepest_L1\",
                    \"$(varname)_deepest_L2\",
                    \"$(varname)_deepest_depth\"
                ]
            }
        ]
    }
    """

    open(jsonfile, "w") do io
        write(io, jsontpl)
    end
end

for datafile in filelist
    @info("Working on file $(basename(datafile))")
    vname = get_varname(datafile)
    @info("Variable name: $(vname)")

    jsonfile = datafile * ".json"
    @info("Writing JSON file $(basename(jsonfile))");

    write_json(jsonfile, vname);
end
