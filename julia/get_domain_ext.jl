using NCDatasets
using DIVAnd
using DataStructures
using DataFrames
using CSV
using Glob

datadir = "/data/EMODnet/Eutrophication/Split/"
filelist = glob("*dissolved_oxygen_concentration*.nc", datadir)

for datafile in filelist
	@info("Working on $(datafile)")
	NCDatasets.Dataset(datafile, "r") do nc
		lon = nc["obslon"][:]
		lat = nc["obslat"][:]
		lon[lon.>= 180.] = lon[lon.>= 180.] .- 360.
		domain = [extrema(lon)[1:2], extrema(lat)[:]]
		println(domain);
	end
end
