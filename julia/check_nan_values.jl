using NCDatasets
using Dates
using Glob
using DIVAnd
include("MergingClim.jl")

# User inputs
# ------------

varname = "chlorophyll-a"
var_stdname = "mass_concentration_of_chlorophyll_a_in_sea_water"
longname = "chlorophyll-a"
units = "mg/m^3"

#varname = "silicate"
#longname = "Water body silicate"
#var_stdname = "mass_concentration_of_silicate_in_sea_water"
#units = "umol/l"

#varname = "oxygen_concentration"
#longname = "Water body dissolved oxygen concentration"
#var_stdname = "mass_concentration_of_oxygen_in_sea_water"
#units = "umol/l"

#varname = "phosphate"
#longname = "Water body phosphate"
#var_stdname = "mass_concentration_of_phosphate_in_sea_water"
#units = "umol/l"

#varname = "nitrogen"
#longname = "Water_body_dissolved_inorganic_nitrogen"
#var_stdname = "mass_concentration_of_inorganic_nitrogen_in_sea_water"
#units = "umol/l"

product_id = ""

hostname = gethostname()
if hostname == "ogs01"
	@info "Working in production server"
	outputdir = "/production/apache/data/emodnet-test-charles/merged"
	databasedir = "/production/apache/data/emodnet-domains/"
elseif hostname == "GHER-ULg-Laptop"
	outputdir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
else
	@error("Unknown host")
end


"""
```julia
count_nans(filename)
```
Return the number of NaNs in the filename.
"""
function count_nans(filename::String)
	Dataset(filename) do ds
		d = ds["Water_body_ammonium_L1"].var[:];
		nnans = sum(isnan.(d));
		@info("Found $(nnans) NaNs for the variable")
		fv = fillvalue(ds["Water_body_ammonium_L1"])
		# d[isnan.(d)] .= fv;
		# ds["Water_body_ammonium_L1"].var[:] = d;
	end
end
