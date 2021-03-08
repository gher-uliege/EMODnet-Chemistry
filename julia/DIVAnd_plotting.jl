function splitobs(obslon,obslat,domains,default_label = 0)
    obslabel = fill(default_label,size(obslon))

    for i = 1:length(domains)
        inside = (domains[i].lonr[1] .<= obslon .<= domains[i].lonr[2]) .&
        (domains[i].latr[1] .<= obslat .<= domains[i].latr[2])
        obslabel[inside] .= domains[i].label
    end

    return obslabel
end


function plot_profile(
    domains,domainnames,fname,filenames_obs,TS;
    vmin = 1,
    vmax = 1000,
    figdir = joinpath(dirname(fname),"..","Figures"),
)
    @info "File name: $fname"

    ds = NCDataset(fname)
    varname = ds.attrib["parameter_keyword"]

    obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(
        Float64,filenames_obs,varname)

    obslon = mod.(obslon .+ 180,360) .- 180

    obslabel = splitobs(obslon,obslat,domains,default_label)

    lon = ds["lon"][:]
    lat = ds["lat"][:]
    depth = ds["depth"][:]
    X,Y = DIVAnd.ndgrid(lon,lat)
    L = splitobs(X,Y,domains,default_label)

    itime = 1
    for itime = 1:length(TS)
        analysis = ds[varname][:,:,:,itime];
        units = ds[varname].attrib["units"]

        idomain = 4
        for idomain = 1:length(domainnames)
            @show domainnames[idomain],itime
            sel = DIVAnd.select(TS,itime,obstime) .& (obslabel .== idomain)
            @show sum(sel)

            #clf();pcolormesh(L')
            mean_analysis = zeros(length(depth))

            for k = 1:length(depth)
                mean_analysis[k] = mean(skipmissing(analysis[:,:,k][L .== idomain]))
            end

            clf();
            norm=matplotlib.colors.LogNorm(vmin=vmin,vmax = vmax)
            plt.hist2d(obsvalue[sel],-obsdepth[sel],cmap="gray_r",norm=norm,bins = 70)
            #plot(obsvalue[sel],-obsdepth[sel],"k.",alpha = 0.03)
            plot(mean_analysis,-depth,"b-")
            ylabel("depth")
            xlabel(units)

            colorbar()
            title("$(domainnames[idomain]); time=$(itime)/$(length(TS))")
            savefig(joinpath(figdir,"profile_$(domainnames[idomain])_$(itime).png"))
        end
    end
    close(ds)
end

function plot_section(
    fname,
    filenames_obs,
    bathname;
    suffix = "",
    figdir = joinpath(dirname(fname),"..","Figures"),
    quantile_colorbar = [0.1,0.9],
    bathisglobal = true)

    ds = NCDataset(fname)
    varname = ds.attrib["parameter_keyword"]

    @info "Variable: $varname"

    obsvalue,obslon,obslat,obsdepth,obstime,obsids = DIVAnd.loadobs(
        Float64,filenames_obs,varname)

    obslon = mod.(obslon .+ 180,360) .- 180

    lonr = ds["lon"][:]
    latr = ds["lat"][:]
    depthr = ds["depth"][:]
    units = ds[varname].attrib["units"]

    aspect_ratio = 1/cosd(mean(latr))
    #fig = figure(figsize = (12,8))
    fig = figure(figsize = (15,8))

    bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);

    #itime = 1
    for itime = 1:length(TS)
        fit = nomissing(ds[varname * suffix][:,:,:,itime],NaN);

        tmp = copy(fit)
        #tmp[erri .> .5] .= NaN;

        sel = DIVAnd.select(TS,itime,obstime)
        k=1
        @time @sync @distributed  for k = 1:size(fit,3)
            #@time @sync @distributed  for k = 1:16
            #@time for k = 1:32
            clf()
            fig.suptitle("$varname; time index $(itime); depth = $(depthr[k])")
            subplot(1,2,1)
            title("Observations")

            Δz = depthr[min(k+1,length(depthr))] - depthr[max(k-1,1)]
            @show k,Δz

            # select the data near depthr[k]
            sel_depth = sel .& (abs.(obsdepth .- depthr[k]) .<= Δz)

            #vmin = minimum(value[sel_depth])
            #vmax = maximum(value[sel_depth])

            tmpk = tmp[:,:,k]
            #vmin,vmax = extrema(tmpk[isfinite.(tmpk)])
            vmin,vmax = quantile(tmpk[isfinite.(tmpk)],quantile_colorbar)

            # plot the data
            scatter(obslon[sel_depth],obslat[sel_depth],10,obsvalue[sel_depth];
                    vmin = vmin, vmax = vmax)
            xlim(minimum(lonr),maximum(lonr))
            ylim(minimum(latr),maximum(latr))
            colorbar(orientation="horizontal")
            contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
            gca().set_aspect(aspect_ratio)

            # plot the analysis
            subplot(1,2,2)
            title("Analysis")
            pcolormesh(lonr,latr,permutedims(tmp[:,:,k],[2,1]);
                   vmin = vmin, vmax = vmax)
            colorbar(orientation="horizontal")
            contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
            gca().set_aspect(aspect_ratio)
            savefig(joinpath(figdir,"analysis-$(varname * suffix)-$(itime)-$(depthr[k]).png"))
        end
    end
    PyPlot.close()
end
