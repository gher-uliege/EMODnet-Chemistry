include("./emodnetchemistry.jl")
using NCDatasets

# Files and directories
datadir = "/production/apache/data/emodnet-domains/By sea regions//Mediterranean Sea/"
datafilelist = get_file_list(datadir)

@info("Processing $(length(datafilelist)) file(s)");

function get_varname(datafile::String)
  varname = replace(basename(datafile), ".4Danl.nc" => "")
  return varname::String
end

for datafile in datafilelist
  @info("Working on file $(basename(datafile))")
  varname = get_varname(datafile)
  @debug("Variable name: $(varname)")
  remove_attribs(datafile, varname)
end
