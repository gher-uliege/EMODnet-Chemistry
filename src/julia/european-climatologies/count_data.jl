"""
Count the number of observations in the files
"""

using NCDatasets
using DIVAnd
using Glob

# Set list of parameters (long names)
varlist = ["Water body phosphate",
           "Water body dissolved oxygen concentration",
           "Water body silicate",
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen",
           "Water body ammonium"
           ]

# Set input and output directories

# inputdir = "/home/ctroupin/data/EMODnet/Eutrophication/"
inputdir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/ODVnetCDF"
outputdir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/netCDF/"

datafilelist = glob("*.nc", inputdir)

for datafile in datafilelist
    NCDataset(datafile) do ds
        lonvar = varbyattrib(ds, standard_name="longitude")[1]
        nobs = length(lonvar[:])
        @info("$(basename(datafile)) -- $(nobs)")
    end
end

println(" ")
println(" ")
datafilelist2 = glob("*.nc", outputdir)

for datafile in datafilelist2
    NCDataset(datafile) do ds
        lonvar = varbyattrib(ds, standard_name="longitude")[1]
        nobs = length(lonvar[:])
        @info("$(basename(datafile)) -- $(nobs)")
    end
end

