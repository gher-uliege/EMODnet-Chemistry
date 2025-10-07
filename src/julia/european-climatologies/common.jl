#!/usr/bin/env julia

# Definition of the common parameters to various scripts:
# domain, grid, depth levels, background field, variable names
# ------------------------------------------------------------

using DIVAnd
using Dates
using DelimitedFiles

do_exclude = false      # Flag to remove bad data from a list of indices stored in file

# Directories
# -----------

email = "ctroupin@uliege.be"
datadir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/"
woddir = joinpath(datadir,"WOD")
obsdir = datadir
excludedir = joinpath(datadir,"EMODnet","blacklist")

# isdir(datadir) ? @debug("Already exists") : mkpath(datadir)

# Grid and resolutions
# --------------------

#deltalon = 0.1
#deltalat = 0.1

deltalon = 0.25
deltalat = 0.25

#deltalon = 0.5
#deltalat = 0.5

#deltalon = 1
#deltalat = 1

# Domain extent
# -------------

lonr = -45.:deltalon:70.
latr = 24.:deltalat:83.

timeorigin = DateTime(1900,1,1,0,0,0)

# List of depths
# --------------
# selected as the union of the different products

depthr = Float64[0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350, 1400, 1450, 1500, 1550, 1600, 1650, 1700, 1750, 1800, 1850, 1900, 1950, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000, 4100, 4200, 4300, 4400, 4500, 4600, 4700, 4800, 4900, 5000, 5100, 5200, 5300, 5400, 5500]

# Period of interest
# ------------------
# Note: changed 2020 to 2023 since new observations have been made available
yearlist = [1960:2023]

# Time periods
# ----------------

# Main background takes all the months together

TSbackground = DIVAnd.TimeSelectorYearListMonthList(
    yearlist,
    [1:12])

TSmonthly = DIVAnd.TimeSelectorYearListMonthList(
    yearlist,
    [m:m for m in 1:12]
)

# time range of the in-situ data
timerange = [Date(1000,1,1),Date(3000,12,31)]

# Variable names
# --------------

# World Ocean Database
varnames = ["Oxygen","Phosphate","Silicate","Nitrate and Nitrate+Nitrite","Chlorophyll"]

# EMODnet Chemistry
# Note: we removed the white spaces and the `(DIN)` to avoid possible issues with ERDDAP extract_bath

varlist = ["Water_body_phosphate",
           "Water_body_chlorophyll-a",
           "Water_body_dissolved_inorganic_nitrogen",
           "Water_body_ammonium",
           "Water_body_silicate",
	       "Water_body_dissolved_oxygen_concentration"
]

# Metadata and vocab
# ------------------

area_keywords = [
        "Arctic Ocean",
        #"Barents Sea","Greenland Sea","Iceland Sea",
        "North Atlantic Ocean",
        #"Norwegian Sea",
	"Black Sea",
        #"Sea of Azov","Sea of Marmara",
        "Baltic Sea",
        "North Sea",
        "Mediterranean Sea"]

#area_collection = Vocab.SDNCollection("C19")
#@show Vocab.notation.(Vocab.findbylabel(area_collection,area_keywords))

area_keywords_urn = [
    "SDN:C19::9",
    "SDN:C19::1",
    "SDN:C19::3_3",
    "SDN:C19::2",
    "SDN:C19::1_2",
    "SDN:C19::3_1",
]

# Attributes for the variables
# ----------------------------

varinfo = Dict(
    "Water_body_dissolved_oxygen_concentration" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::DOXY"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_dissolved_molecular_oxygen_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0, 1150.0, 1200.0, 1250.0, 1300.0, 1350.0, 1400.0, 1450.0, 1500.0],
        "doi" => "https://doi.org/", # Water body dissolved oxygen concentration
    ),
    "Water_body_phosphate" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::PHOS"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "moles_of_phosphate_per_unit_mass_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0],
        "doi" => "https://doi.org/", # Water body phosphate
    ),
    "Water_body_chlorophyll-a" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::CPWC"],
        "netcdf_units" => "mg/m3",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mass_concentration_of_chlorophyll_in_sea_water",
        "doi" => "https://doi.org/", # Water body chlorophyll-a
    ),
    "Water_body_ammonium" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::AMON"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_ammonium_in_sea_water",
        "doi" => "https://doi.org/", # Ammonium
    ),
    "Water_body_silicate" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::SLCA"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_silicate_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0],
        "doi" => "https://doi.org/", # Water body silicate
    ),
    "Water_body_dissolved_inorganic_nitrogen" => Dict(
         # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::TDIN"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_dissolved_inorganic_nitrogen_in_sea_water",
        "doi" => "https://doi.org/10.6092/xjj3-7d14", # Water body dissolved inorganic nitrogen (DIN)
    )
)

bathname = joinpath(datadir, "gebco_30sec_4.nc")
bathisglobal = true

function gitdiff(casedir)
    cd(joinpath(dirname(pathof(DIVAnd)),"..")) do
        write(joinpath(casedir,"DIVAnd.commit"), read(`git rev-parse HEAD`))
        write(joinpath(casedir,"DIVAnd.diff"), read(`git diff`))
    end;

    cd(expanduser("~/src/EMODnet-Chemistry")) do
        write(joinpath(casedir,"EMODnet-Chemistry.commit"), read(`git rev-parse HEAD`))
        write(joinpath(casedir,"EMODnet-Chemistry.diff"), read(`git diff`))
    end;
end

function loadexclude(fname_exclude::AbstractString)
    #data, headers = readdlm(fname_exclude, header = true)
    #headers = vec(headers)
    #@assert headers == ["lon",  "lat",  "depth",  "time",  "IDs"]
    data = readdlm(fname_exclude, header = false)

    obslon = data[:,1]
    obslat = data[:,2]
    obsdepth = data[:,3]
    obstime = DateTime.(data[:,4])
    obsids = data[:,5]

    obslon = mod.(obslon .+ 180,360) .- 180
    return obslon,obslat,obsdepth,obstime,obsids
end


function sampleid(obslon,obslat,obsdepth,obstime,obsids)
    obslon = mod.(obslon .+ 180,360) .- 180

    return (
        round(Int,obslon*10000),
        round(Int,obslat*10000),
        round(Int,obsdepth*10000),
        # round to seconds
        Dates.epochms2datetime(1000 * (Dates.datetime2epochms(obstime) ÷ 1000)),
        obsids,
    )
end

exclude_sampleid(fname_exclude::AbstractString) = sampleid.(loadexclude(fname_exclude)...)
exclude_sampleid(fnames_exclude::AbstractVector) = reduce(vcat,exclude_sampleid.(fnames_exclude),init=Tuple{Int,Int,Int,DateTime,String}[])
#exclude_sampleid(fnames_exclude::AbstractVector) = reduce(vcat,exclude_sampleid.(fnames_exclude))
