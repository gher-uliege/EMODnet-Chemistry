using NCDatasets

datadir1 = "/production/apache/data/emodnet-domains/All_European_Seas-water_body"
datadir2 = "/production/apache/data/emodnet-domains/By_sea_regions-water_body"
datadir3 = "/production/apache/data/emodnet-domains/Coastal_areas-water_body"

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

datafilelist1 = get_netcdf_list(datadir1);
datafilelist2 = get_netcdf_list(datadir2);
datafilelist3 = get_netcdf_list(datadir3);

datafilelist = vcat(datafilelist1, datafilelist2, datafilelist3)


urlfile = "/home/uniliege01/product_list.csv"

open(urlfile, "w") do df
    write(df, "File name,   DOI\n")

    for datafile in datafilelist
        NCDataset(datafile, "r") do ds
            thedoi = ds.attrib["doi"]
            write(df, "$(datafile), $(thedoi)\n")
        end
    end
end
