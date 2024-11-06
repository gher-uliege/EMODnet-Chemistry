using NCDatasets
using URIs

@info("Starting")

"""
    get_id(ncfile)

Get the `product_id` variable out of the specified netCDF file
"""
function get_id(ncfile::String)::String
  NCDataset(ncfile, "r") do ds
    return ds.attrib["product_id"]
  end
end

"""
    get_netcdf_list(datadir)

Return the list of the netCDF files (i.e. with the suffix ".nc") in the specified directory
"""
function get_netcdf_list(datadir::String)::Vector{Any}
  filelist = []
  for item in walkdir(datadir)
    thefiles = item[3]
    thedir = item[1]
    nfiles = length(thefiles)
    if nfiles > 0
      @debug("has $(nfiles) files in $(thedir)")
      for ff in thefiles
        if split(ff, ".")[end] == "nc"
          fname = joinpath(thedir, ff)
          push!(filelist, fname)
        end
      end
    end
  end
  @info("Found $(length(filelist)) files")
  return filelist
end

"""
    prepare_url(fileurl)

Convert the file path to a URL in OceanBrowser
"""
function prepare_url(fileurl::String)
  urlesc = URIs.escapepath(fileurl)
  mainurl = "https://ec.oceanbrowser.net"
  return replace(urlesc, "/production/apache" => mainurl)

end

"""
    write_url_file(urlfile, urllist, idlist)

Write the URLs and the IDs into the file `urlfile`
"""
function write_url_file(urlfile::String, urllist, idlist)
  open(urlfile, "w") do df
    for (fileurl, id) in zip(urllist, idlist)
      write(df, "$(fileurl), $(id)\n")
    end
  end
  return nothing
end

"""
    write_url_file(urlfile, theme, subtheme, filename, layername, uuid, comments)
    )

Create the table requied by Central Portal

"""
function write_url_file(urlfile::String, theme::Array, subtheme::Array, filename::Array, layername::Array, uuid, comments="")
  open(urlfile, "w") do df
    write(df, "Theme,	Sub-theme, File name,	Layer Name,	Metadata record UUID,	Comments\n")

    nfiles = length(theme)
    for iii=1:nfiles
      write(df, "$(theme[iii]), $(subtheme[iii]), $(filename[iii]), $(layername[iii]), $(uuid[iii]), \n")
    end
  end
  return nothing
end

"""
    check_url(fileurl)

Check if the URL create by `prepare_url` is correct
(the `curl -Is` command should exit with "200 OK" message)
"""
function check_url(fileurl::String)
  testcommand=`curl -Is $(fileurl)`
  run(testcommand)
end

"""
    get_layer_name(datafile)

Get the layer name that will be displated in the Central Portal
(by default: the field masked with the 0.5 relative error)
"""
function get_layer_name(datafile::AbstractString)
  NCDataset(datafile, "r") do ds
    varlist = keys(ds)
    varindex = findfirst(occursin.("_L2", varlist))
    layername = ds[varlist[varindex]].attrib["long_name"]
    return layername::String
  end
end
"""
    get_theme(datafile)

Get the theme and sub-theme according to Central Portal requirements

# Examples

```julia-repl
julia> datafile = "/production/apache/data/emodnet-projects/v2023/Coastal_areas/Northeast_Atlantic_Ocean_-_Loire_River/Water_body_phosphate.nc"
julia> julia> get_theme(datafile)
("Coastal areas", "Northeast Atlantic Ocean - Loire River")
"""
function get_theme(datafile::AbstractString)
  pathsplit = split(datafile, "/")
  theme = replace(pathsplit[end-2], "_"=>" ")
  subtheme = replace(pathsplit[end-1], "_"=> " ")
  return theme::String
end

function get_subtheme(datafile::AbstractString)
  pathsplit = split(datafile, "/")
  subtheme = replace(pathsplit[end-1], "_"=> " ")
  return subtheme::String
end

# Set the directory and the name of the file which will store the lists
# -----------------

#databasedir = "/production/apache/data/emodnet-projects/Phase-3"
#databasedir = "/production/apache/data/emodnet-projects/v2023"
databasedir = "/home/ctroupin/data/EMODnet-Chemistry/emodnet-results-2023"
outputfile = "./listurl_v2023.csv"

datafilelist = get_netcdf_list(databasedir)
idlist = get_id.(datafilelist)
urllist = prepare_url.(datafilelist)
theme = get_theme.(datafilelist)
subtheme = get_subtheme.(datafilelist)
layername = get_layer_name.(datafilelist)

write_url_file(outputfile, theme, subtheme, urllist, layername, idlist)

@info("Info written in file $(outputfile)")
