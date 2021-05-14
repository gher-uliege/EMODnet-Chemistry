using NCDatasets
using Glob

datadir = "/media/ctroupin/My Passport/data/EMODnet/Eutrophication/Products/BalticSea/"
filelist = Glob.glob("*/*.nc", datadir)

# Get variable name
function get_varname(datafile::String)
    NCDatasets.Dataset(datafile) do ds
        varname = keys(nc)[6]
        return varname::String
    end
end


function write_json(jsonfile::String, varname::String)
    jsontpl = """
    {
        \"default time\": \"2000\",
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
                    \"$(varname)_deepest L1\",
                    \"$(varname)_deepest L2\",
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
    @info(vname)

    jsonfile = datafile * ".json"
    @info("Writing JSON file $(basename(jsonfile))");

    write_json(jsonfile, vname);
end
