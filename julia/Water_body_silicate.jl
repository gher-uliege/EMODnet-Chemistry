
# patch near (-24. < obslon < -16) & (55.  < obslat < 58.4)

badid = Set(["681-RNODC_Bottle_14822_44/v0","681-RNODC_Bottle_14822_46/v0","681-RNODC_Bottle_14822_47/v0","681-RNODC_Bottle_14822_49/v0","681-RNODC_Bottle_14822_50/v0","681-RNODC_Bottle_14822_52/v0","681-RNODC_Bottle_14822_53/v0","681-RNODC_Bottle_14822_55/v0","681-RNODC_Bottle_14822_56/v0","681-RNODC_Bottle_14822_58/v0","681-RNODC_Bottle_14822_59/v0","681-RNODC_Bottle_14822_61/v0","681-RNODC_Bottle_14822_62","681-RNODC_Bottle_14822_65","681-RNODC_Bottle_14822_67","681-RNODC_Bottle_14822_68","681-RNODC_Bottle_14822_70","681-RNODC_Bottle_14822_71","681-RNODC_Bottle_14822_73","681-RNODC_Bottle_14822_74","681-RNODC_Bottle_14822_76","681-RNODC_Bottle_14822_77","681-RNODC_Bottle_14822_79"])

bad = [id in badid for id in obsids]

#sel = (obslon .<= -17) .& (obsvalue .>= 30) .& (Dates.month.(obstime) .== 9)
#bad = (obslon .<= -17) .& (obsvalue .>= 30) .& (Dates.month.(obstime) .== 9)
@show "remove $(count(bad))"

sel = .!bad;
obslon = obslon[sel]
obslat = obslat[sel]
obsdepth = obsdepth[sel]
obstime = obstime[sel]
obsvalue = obsvalue[sel]
obsids = obsids[sel]
rdiag = rdiag[sel]
