#   Saving attributes
#   ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
# 
#   This notebook show how to get the global and variable attributes and save
#   them into a file that can be read later. This is useful when one is working
#   on a machine which has not internet connection to the Vocab Server.

using DIVAnd
using DataStructures
theyear = 2024

outputdir = "/home/ctroupin/data/EMODnet-Chemistry/Eutrophication2024/Attributes"

# Name of the variables (EMODnet Chemistry)
varlist = ["Water body phosphate",
           "Water body chlorophyll-a",
           "Water body dissolved inorganic nitrogen (DIN)",
           "Water body ammonium",
           "Water body silicate",
	       "Water body dissolved oxygen concentration"
           ]

varinfo2 = Dict(
    "Water body dissolved oxygen concentration" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::DOXY"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_dissolved_molecular_oxygen_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0, 1150.0, 1200.0, 1250.0, 1300.0, 1350.0, 1400.0, 1450.0, 1500.0],
        "doi" => "https://doi.org/10.6092/yepr-1a13", # Water body dissolved oxygen concentration
    ),
    "Water body phosphate" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::PHOS"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "moles_of_phosphate_per_unit_mass_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0],
        "doi" => "https://doi.org/10.6092/njj3-hk55", # Water body phosphate
    ),
    "Water body chlorophyll-a" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::CPWC"],
        "netcdf_units" => "mg/m3",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mass_concentration_of_chlorophyll_in_sea_water",
        "doi" => "https://doi.org/10.6092/av67-qz53", # Water body chlorophyll-a
    ),
    "Water body ammonium" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::AMON"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_ammonium_in_sea_water",
        "doi" => "https://doi.org/10.6092/av67-qz53", # Ammonium
    ),
    "Water body silicate" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::SLCA"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_silicate_in_sea_water",
        "woa_depthr" => [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0],
        "doi" => "https://doi.org/10.6092/cyd3-ew67", # Water body silicate
    ),
    "Water body dissolved inorganic nitrogen (DIN)" => Dict(
        # http://vocab.nerc.ac.uk/collection/P02/current/
        "search_keywords_urn" => ["SDN:P02::TDIN"],
        "netcdf_units" => "umol/l",
        # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
        "netcdf_standard_name" => "mole_concentration_of_dissolved_inorganic_nitrogen_in_sea_water",
        "doi" => "https://doi.org/10.6092/xjj3-7d14", # Water body dissolved inorganic nitrogen (DIN)
    )
)


nvar = length(varlist)

for iii in 1:nvar
    @info("Working on $(varlist[iii])")
    
    P35 = Vocab.SDNCollection("P35")
    c = Vocab.findbylabel(P35,[varlist[iii]])[1]
    parameter_keyword_urn = Vocab.notation(c)

    varname_nospace = replace(varlist[iii], " (DIN)"=>"", " "=>"_", )
    @info(varname_nospace);
    
    metadata = OrderedDict(
        "title" => "European seas - DIVAnd 4D monthly analysis of $(varlist[iii]) 1960/2023 v$(theyear)",
        "project" => "EMODNET-chemistry",
        "institution_urn" => "SDN:EDMO::1579",
        "production" => "University of Liège, GeoHydrodynamics and Environment Research",
        "Author_e-mail" => ["Charles Troupin <ctroupin@uliege.be>", "Alexander Barth <A.Barth@uliege.be>"],
        "source" => "Observations from EMODnet-Chemistry",
        "comment" => "Monthly climatology",
        "parameter_keyword_urn" => parameter_keyword_urn,
        "search_keywords_urn" => varinfo2[varlist[iii]]["search_keywords_urn"],
        "area_keywords_urn" => ["SDN:C19::9", "SDN:C19::1", "SDN:C19::3_3", "SDN:C19::2", "SDN:C19::1_2", "SDN:C19::3_1"],
        "product_version" => "v$(theyear)",
        "product_code" => "All Europeans Seas-$(varlist[iii])-v$(theyear)-ANA",
        "bathymetry_source" => "The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003",
        "netcdf_standard_name" => varinfo2[varlist[iii]]["netcdf_standard_name"],
        "netcdf_long_name" => varlist[iii],
        "netcdf_units" => varinfo2[varlist[iii]]["netcdf_units"],
        "DIVA_references" => "Barth, A., Beckers, J.-M., Troupin, C., Alvera-Azcarate, A., and Vandenbulcke, L. (2014): divand-1.0: n-dimensional variational data analysis for ocean observations, Geosci. Model Dev., 7, 225-241, doi: 10.5194/gmd-7-225-2014",
		"data_access" => "https://emodnet.ec.europa.eu/geoviewer",
		"WEB_visualisation" => "https://emodnet.ec.europa.eu/geoviewer",
        "acknowledgement" => "Aggregated data products are generated by EMODnet Chemistry under the support of DG MARE Call for Tenders EASME/EMFF/2016/006-lot4, EASME/2019/OP/0003-lot4.",
        "documentation" => "https://doi.org/10.13120/fa5c704a-a5ea-4f60-91b5-2bf6a7aded45",
        "doi" => varinfo2[varlist[iii]]["doi"]
    );
    
    fname = "$(varname_nospace)_monthly.nc"
    varname = varlist[iii]
    deltalon = 0.25
    deltalat = 0.25
    lonr = -45.:deltalon:70.
    latr = 24.:deltalat:83.
    
    # Get the attributes from the Vocab server    
    ncglobalattrib, ncvarattrib = SDNMetadata(metadata,fname,varname,lonr,latr);

    # Save the information in a text file
    # The keys and values are separated by "|", but another separator can be used.
    
    open(joinpath(outputdir, "ncglobalattrib_$(varname_nospace).txt"), "w") do f
        for (i, j) in ncglobalattrib
            write(f, "$i|$j\n")
        end
    end
    
    open(joinpath(outputdir, "ncvarattrib_$(varname_nospace).txt"), "w") do f
        for (i, j) in ncvarattrib
            write(f, "$i|$j\n")
        end
    end
    
end

