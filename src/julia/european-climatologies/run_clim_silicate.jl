# run as
# julia -p 6 run_clim.jl | tee run_clim_$(date +"%Y%m%dT%H%M%S").log

using Distributed
include("common.jl")  

#=
pmap(varname -> begin;
     @info varname
     ENV["VARNAME"] = varname;
     include("background.jl")
     end,
     varlist);
=#


@info(length(varlist));
varname_index = 5
@info varlist[varname_index]
ENV["VARNAME_INDEX"] = "$varname_index"
@info("Computing background field")
ENV["ANALYSIS_TYPE"] = "background"
include("background.jl")
GC.gc()

@info("Computing monthly field")
ENV["ANALYSIS_TYPE"] = "monthly"
include("background.jl")
GC.gc()

