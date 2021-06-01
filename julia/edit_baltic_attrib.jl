using NCDatasets
include("emodnetchemistry.jl")

datadir = "/production/apache/data/emodnet-domains/Coastal areas/Baltic Sea - Gulf of Riga/"
datafilelist = get_file_list(datadir)

for datafile in datafilelist
  @info("Working on $(datafile)")
  NCDatasets.Dataset(datafile, "a") do ds
    oldtitle = ds.attrib["title"]
    newtitle = replace(oldtitle, "2019" => "2018")
    ds.attrib["title"] = newtitle 
  end
end


