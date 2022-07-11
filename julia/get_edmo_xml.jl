using Glob
using Pkg
Pkg.add(PackageSpec(name="DIVAnd", rev="Alex"))
using DIVAnd#Alex

datadir = "/production/apache/data/emodnet-domains"
@info("Download CDI list")

cdifile = "export.zip"
if isfile(cdifile)
    @info("Already downloaded")
else
    download(DIVAnd.OriginatorEDMO_URL, cdifile)
    run(`unzip export.zip`) # if unzip is installed
end

cdilist = "export.csv";

varnames = ["silicate", "nitrogen", "oxygen", "phosphate", "chlorophyll", "ammonium"]
ignore_errors = true

for var in varnames
    @info("Working on variable $(var)")
    filepaths = glob("*/*/*$(var)*.nc", datadir)
    @info("Found $(length(filepaths)) files")

    xmlfilename = "out_$(var).xml"
    
    @info("Generating the XML file for originators")
    DIVAnd.divadoxml_originators(cdilist, filepaths, xmlfilename; ignore_errors = ignore_errors)
end

