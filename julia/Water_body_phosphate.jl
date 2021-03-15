
if analysistype == "monthly"
    #    epsilon2 = 0.1    # too noisy
end

maxit = 100

#TSmonthly = DIVAnd.TimeSelectorYearListMonthList(
#    [1970:2020],
#    [m:m for m in 1:1])

BS = repeat((26.5 .<= lonr .<= 41.95) .& (40 .<= latr' .<= 47.95),inner=(1,1,length(depthr)))

@show mean(lenx[BS])
@show mean(leny[BS])

# reduce CL in Black Sea
#lenx[BS] .= lenx[BS] / lb / 1.5
#lenx[BS] .= lenx[BS] / lb
lenx[BS] .= lenx[BS] / 3

@show mean(lenx[BS])
@show mean(leny[BS])

hxi,hyi,h = DIVAnd.load_bath(bathname,bathisglobal,lonr,latr)
mask2D,(pm2D,pn2D) = DIVAnd.domain(bathname,bathisglobal,lonr,latr)

h[.!mask2D] .= 0

slen = (50e3,50e3)
hf = DIVAnd.diffusion(mask2D,(pm2D,pn2D),slen,h)

bath_RL = DIVAnd.lengraddepth((pm2D,pn2D),hf,20e3; hmin = 30)
clamp!(bath_RL,0.5,1);
bath_RL[.!mask2D] .= NaN
#bath_RLf = DIVAnd.diffusion(mask2D,(pm2D,pn2D),slen,bath_RL)

#=
clf(); pcolormesh(lonr,latr,bath_RL'); colorbar();
figdir = joinpath(datadir,"Figures")
mkpath(figdir)
savefig(joinpath(figdir,"bath_RL_$(deltalon).png"))
=#

bath_RL = DIVAnd.ufill(bath_RL,mask2D)

# This also updates leny
lenx .= bath_RL .* lenx

@show mean(lenx[BS])
@show mean(leny[BS])

suffix = "bathcl-noerr"
