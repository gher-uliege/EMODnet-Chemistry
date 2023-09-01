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
    check_url(fileurl)

Check if the URL create by `prepare_url` is correct
(the `curl -Is` command should exit with "200 OK" message)
"""
function check_url(fileurl::String)
  testcommand=`curl -Is $(fileurl)`
  run(testcommand)
end

# Set the directory and the name of the file which will store the lists

#databasedir = "/production/apache/data/emodnet-projects/Phase-3"
databasedir = "/production/apache/data/emodnet-projects/v2023"
outputfile = "./listurl_v2023.csv"

datafilelist = get_netcdf_list(databasedir)
idlist = get_id.(datafilelist)
urllist = prepare_url.(datafilelist)
write_url_file(outputfile, urllist, idlist)
@info("Info written in file $(outputfile)")
                                                  
