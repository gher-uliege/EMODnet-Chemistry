using EzXML
using DelimitedFiles
using Glob

function extract_edmo_originators(fname)
    xml = EzXML.readxml(fname);

    xml_namespace = Dict("gmd" => "http://www.isotc211.org/2005/gmd");

    edmo = Int[]

    for party in findall("//gmd:CI_RoleCode[@codeListValue='originator']/../..",root(xml),xml_namespace)
        @assert nodename(party) == "CI_ResponsibleParty"
        push!(edmo,parse(Int,replace(party["uuid"],"https://edmo.seadatanet.org/report/" => "")))
    end

    @info "In $fname found $(length(edmo)) originators"
    writedlm(replace(fname,".xml" => ".emdo.txt"),edmo)
end

# apply to a single file
#fname = "Water_body_chlorophyll-a.xml"
#extract_edmo_originators(fname)

# call this function to all files matching Water*xml
# in current working directory
extract_edmo_originators.(glob("Water*xml"))
