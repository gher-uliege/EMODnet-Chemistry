# run as
# julia -p 6 background_all.jl | tee background_all.log

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


@show procs()

@sync @distributed for varname_index in 1:length(varlist)
    @info varlist[varname_index]
    ENV["VARNAME_INDEX"] = "$varname_index"
    ENV["ANALYSIS_TYPE"] = "background"
    #ENV["ANALYSIS_TYPE"] = "monthly"
    include("background.jl")
    GC.gc()

    #ENV["ANALYSIS_TYPE"] = "background"
    ENV["ANALYSIS_TYPE"] = "monthly"
    include("background.jl")
    GC.gc()
end

