# TODO: same compression level as source files?
# *deepest level*: DIVAnd.derive?

# ncmerge: could be integrated in DIVAnd to simplify update

function defSimilarVar(ds,ncvar)
    dn = dimnames(ncvar)

    kwargs = Dict();
    T = eltype(ncvar.var)
    ncvar_merged = defVar(
        ds,name(ncvar),T,dn;
        kwargs...,
        attrib = OrderedDict(ncvar.attrib))

    return ncvar_merged
end

function ncmerge(fnames,varname,timeindex,fname_merged)
    if isfile(fname_merged)
        rm(fname_merged)
    end

    ds = NCDataset.(fnames);
    ds_main = ds[end]
    NCDataset(fname_merged,"c",attrib = ds_main.attrib) do ds_merged

        # set dimenions
        for (dimname,dimlen) in ds_main.dim
            ds_merged.dim[dimname] =
                if dimname == "time"
                    Inf
                else
                    dimlen
                end
        end

        # copy over
        for ncvarname in ["lon","lat","depth"]
            @info "Create variable $ncvarname"
            ncdata = defSimilarVar(ds_merged,ds_main[ncvarname])
            ncdata[:] = ds_main[ncvarname][:]
        end

        ncvarnames = ["time",varname,"$(varname)_L1","$(varname)_L2","$(varname)_relerr","climatology_bounds"]

        for ncvarname in ncvarnames
            @info "Create variable $ncvarname"

            ncvar = ds_main[ncvarname]
            ncvar_merged = defSimilarVar(ds_merged,ncvar)
            count = 0

            for i = 1:length(fnames)
                ncvar = ds[i][ncvarname]

                for n in timeindex[i]
                    @info "$ncvarname: get slice $n from file $(fnames[i])"

                    count = count + 1
                    if ndims(ncvar_merged) == 4
                        ncvar_merged[:,:,:,count] = ncvar[:,:,:,n]
                    elseif ndims(ncvar_merged) == 3
                        ncvar_merged[:,:,count] = ncvar[:,:,n]
                    elseif ndims(ncvar_merged) == 2
                        ncvar_merged[:,count] = ncvar[:,n]
                    end
                end
            end
        end

        close.(ds)
    end
end

# -------------


# User input

cd("/data/MergeResults")


fnames = ["Water body phosphate.4Danl.nc", "Water body phosphate_Autumn.4Danl.nc"]
timeindex = [1:40, 1:3];
fname_merged = "test_merged.nc"
varname = "Water body phosphate";


ncmerge(fnames,varname,timeindex,fname_merged)
