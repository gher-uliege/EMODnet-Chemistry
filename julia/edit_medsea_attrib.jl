using NCDatasets

datadir = "/production/apache/data/emodnet-domains/By sea regions/Mediterranean Sea"


# oxygen
NCDatasets.Dataset(datafile1, "a") do ds
  ds.attrib["product_id"] = "94f43d88-c880-11e8-bb45-8056f28224bb"
end


