using NCDatasets
include("emodnetchemistry.jl")

datadir = "/production/apache/data/emodnet-domains/By sea regions/Mediterranean Sea"

# Dictionary that related variable and IDs
var_id_dict = Dict("Water_body_chlorophyll-a" => "17cccf54-d3bc-11e8-b813-8056f28224bb ",
                   "Water_body_dissolved_inorganic_nitrogen_(DIN)" => "3b85a714-cd1c-11e8-8664-8056f28224bb", 
                   "Water_body_dissolved_oxygen_concentration" => "94f43d88-c880-11e8-bb45-8056f28224bb",
                   "Water_body_phosphate" => "158de2d6-ca8a-11e8-b0bc-8056f28224bb",
                   "Water_body_silicate" => "877bff16-cc53-11e8-814a-8056f28224bb")


# Loop on variables
for (var, id) in var_id_dict

  datafilelist = get_file_list(datadir, var)
  
  for datafile in datafilelist
    
    @info(datafile);
    @info(var, id); 
    #NCDatasets.Dataset(datafile, "a") do ds
    #  ds.attrib["product_id"] = var_id_dict["var"]
    #end
  end

end


