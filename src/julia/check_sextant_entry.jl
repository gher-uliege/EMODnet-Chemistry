#!/usr/bin/env julia
using HTTP, EzXML, NCDatasets
include("emodnetchemistry.jl")

# Usage:
# julia --color=yes check_sextant_entry.jl  "/production/apache/data/emodnet-domains/"

rootpath = "/production/apache/data/emodnet-domains/"
rootpath = "/production/apache/data/emodnet-projects/Phase-3"
rootpath = ARGS[1]

pattern  = r".nc"

allfiles = collect(EMODnetChemistry.rlist(rootpath,pattern))

for ncfile = allfiles
    product_id = Dataset(ncfile) do ds
        get(ds.attrib,"product_id",nothing)
    end

    print("checking $ncfile: ")
    
    if EMODnetChemistry.check_uuid(product_id)
        printstyled("present in Sextant",color = :green)
    else
        printstyled("not present in Sextant",color = :red)
        println("check: https://www.emodnet-chemistry.eu/products/catalogue#/metadata/$(product_id)")
    end
    println()
    sleep(3)
end