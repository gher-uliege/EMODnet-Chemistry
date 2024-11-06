#!/usr/bin/env julia
using HTTP, EzXML, NCDatasets

# Usage:
# julia --color=yes check_sextant_entry.jl  "/production/apache/data/emodnet-domains/"

function check_uuid(uuid)
    r = HTTP.get("https://sextant.ifremer.fr/geonetwork/srv/eng/qi", query = Dict("_uuid" => uuid));
    body = String(r.body)
    doc = parsexml(body)
    summary = EzXML.findfirst("/response/summary",doc)
    count = parse(Int,summary["count"])
    if count == 1
        return true
    else
        @show uuid
        return false
    end
end

function rlist(rootpath,pattern)
    Channel() do ch
        for (root, dirs, files) in walkdir(rootpath)
            for file in files
                if occursin(pattern, file) 
                    put!(ch,joinpath(root,file))
                end
            end
        end
    end
end


rootpath = "/production/apache/data/emodnet-domains/"
rootpath = "/production/apache/data/emodnet-projects/Phase-3"
rootpath = ARGS[1]

pattern  = r".nc$"

allfiles = collect(rlist(rootpath,pattern))

for ncfile = allfiles
    product_id = Dataset(ncfile) do ds
        get(ds.attrib,"product_id",nothing)
    end

    print("checking $ncfile: ")
    
    if check_uuid(product_id)
        printstyled("present in Sextant",color = :green)
    else
        printstyled("not present in Sextant",color = :red)
        println("check: https://www.emodnet-chemistry.eu/products/catalogue#/metadata/$(product_id)")
    end
    println()
    sleep(3)
end