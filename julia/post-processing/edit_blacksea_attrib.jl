using NCDatasets

datadir = "/production/apache/data/emodnet-domains/Coastal areas/Black Sea - Danube Delta/"

datafile1 = joinpath(datadir, "Water_body_chlorophyll-a.nc")
datafile2 = joinpath(datadir, "Water_body_dissolved_inorganic_nitrogen_(DIN).nc")
datafile3 = joinpath(datadir, "Water_body_dissolved_oxygen_concentration.nc")
datafile4 = joinpath(datadir, "Water_body_phosphate.nc")
datafile5 = joinpath(datadir, "Water_body_silicate.nc")

NCDatasets.Dataset(datafile1, "a") do ds
  ds.attrib["product_id"] = "9b7a0190-bc72-11eb-341f-5f9aa55431bb"
  ds.attrib["title"] = "Black Sea - Danube Delta - DIVAnd 4D seasonal analysis of Water body chlorophyll-a 2001/2018 v2021"
end

NCDatasets.Dataset(datafile2, "a") do ds
  ds.attrib["title"] = "Black Sea - Danube Delta - DIVAnd 4D seasonal analysis of Water body dissolved inorganic nitrogen (DIN) 2001/2018 v2021"
end

NCDatasets.Dataset(datafile3, "a") do ds
  ds.attrib["title"] = "Black Sea - Danube Delta - DIVAnd 4D seasonal analysis of Water body dissolved oxygen concentration 2001/2018 v2021"
end

NCDatasets.Dataset(datafile4, "a") do ds
  ds.attrib["title"] = "Black Sea - Danube Delta - DIVAnd 4D seasonal analysis of Water body phosphate 2001/2018 v2021"
end

NCDatasets.Dataset(datafile5, "a") do ds
  ds.attrib["title"] = "Black Sea - Danube Delta - DIVAnd 4D seasonal analysis of Water body silicate 2001/2018 v2021"
end

