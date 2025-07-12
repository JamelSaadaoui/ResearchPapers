**# Replicaction package for 
* "Real exchange rate and international reserves in the era of financial integration"

capture log close _all                                
log using RERTOT_JIMF.smcl, name(RERTOT_JIMF) smcl replace

use datafintransformed-22-11-17, clear

**# Variable definition

// Some explanations about the variable definition

/*
generate lreer = log(reer)
generate lto = log(1+((exppercent+imppercent)/2))
generate ltot = log(1*(expvalunit/impvalunit))
generate lres = log(1+100*(res/gdp))
generate lgdppk = log(gdppk)
generate lgovexp = log(govexp)

gen ner2010 = ner if year==2010
egen ner2010basis = mean(ner2010), by(cn)
gen nerbasis = (ner/ner2010basis)*100
gen lnerbasis = log(nerbasis)

gen reer2010 = reer if year==2010
egen reer2010basis = mean(reer2010), by(cn)
gen reerbasis = (reer/reer2010basis)*100
capture generate lreerbasis = log(reerbasis)

// Cross-sectional averages for main variables

egen mean_pop = mean(pop), by(cn)
egen mean_ltot = mean(ltot), by(year)
egen mean_lres = mean(lres), by(year)
egen mean_lto = mean(lto), by(year)
egen mean_lreer = mean(lreer), by(year)
egen mean_lreerbasis = mean(lreerbasis), by(year)
egen mean_lgdppk = mean(lgdppk), by(year)
egen mean_ka_open = mean(ka_open), by(year)

order gdppk lgdppk mean_lgdppk, first

gen lgdppk_m = lgdppk/mean_lgdppk

*First observation for lgdppk_m: 
*gdppk <=> (log(x)/9.1899)=0.9543

gen lgdppk_m100 = log(100)*(lgdppk/mean_lgdppk)

*First observation for lgdppk_m100: 
*gdppk <=> log(100)*(log(x)/9.1899)=4.3949

generate lgdppk_us = lgdppk if cn==107
sort year lgdppk_us
order cn year lgdppk lgdppk_us
*help carryforward
bysort year: carryforward lgdppk_us, gen(lgdppk_usd)
order cn year lgdppk lgdppk_us lgdppk_usd
gen lgdppk_c = (lgdppk/lgdppk_usd)
order cn year lreer lto ltot lres, first

label variable lreer /// 
"Real effective exchange rate in Natural Log"
label variable lreerbasis /// 
"Real effective exchange rate in Natural Log (2010=100)"
label variable lto "Trade openness in Natural Log"
label variable ltot "Terms-of-trade in Natural Log"
label variable lres "International reserves in Natural Log"

// Time and country dummies

forvalue num=2001(1)2020 {
		gen yr`num' = 0
        replace yr`num' = 1 if year==`num'
}

forvalue cn=2001(1)2020 {
		gen yr`num' = 0
        replace yr`num' = 1 if year==`num'
}

forvalue num=1(1)110 {
		gen cny`num' = 0
        replace cny`num' = 1 if cn==`num'
}

tabstat lgdppk lgovexp ka_open inf lnerbasis, ///
statistics(count) by(cn) save

egen count_lgovexp = count(lgovexp), by (cn)
egen count_inf = count(inf), by (cn)
egen count_lnerbasis = count(lnerbasis), by (cn)
egen count_ka_open = count(ka_open), by (cn)

*/

// Install package
ssc install xtendothresdpd, replace
search xthenreg
*Then, click on: net install st0573
ssc install moremata, replace
ssc install locproj, replace
ssc install xtcdf, replace
ssc install regife, replace

**# Table 1. Descriptive statistics.

sum lreer lto ltot etot lres lgdppk_m100 lgovexp

outreg2   using sum.tex, replace sum(log)             ///
          keep(lreer lto ltot etot lres lgdppk_m100 lgovexp)


**# Fig. 1. Large holders of international reserves as percent of GDP (before and after the GFC).

gen resgdp = (res/gdp)*100

label list cn

*** Big holders of international reserves ***

generate bigres = 0

replace bigres = 1 if cn == 2 | cn == 14 | cn == 19 | ///
				cn == 20 | cn == 21 | cn == 26 | ///
				cn == 44 | cn == 46 | cn == 45 | ///
				cn == 49 | cn == 55 | cn == 68 | ///
				cn == 65 | cn == 85 | cn == 86 | ///
				cn == 87 | cn == 90 | cn == 92 | ///	
				cn == 94 | cn == 101 | cn == 104 | ///
				cn == 97 | cn == 4

*** Eurozone ***

cap drop eurozone
generate eurozone = 0

replace eurozone = 1 if cn == 7 | cn == 11 | cn == 25 | ///
				cn == 32 | cn == 34 | cn == 35 | ///
				cn == 38 | cn == 40 | cn == 48 | ///
				cn == 50 | cn == 59 | cn == 61 | ///
				cn == 62 | cn == 75 | cn == 88 | ///
				cn == 95 | cn == 96 | cn == 98	
				
by cn: egen resgdp_full = mean(resgdp)

by cn: egen resgdp_before = mean(resgdp) if year<2008

by cn: egen resgdp_after = mean(resgdp) if year>2009

by cn: egen resgdp_full_sd = sd(resgdp)

by cn: egen resgdp_before_sd = sd(resgdp) if year<2008

by cn: egen resgdp_after_sd = sd(resgdp) if year>2009

**# Before and after the GFC

set scheme sj

graph hbar resgdp_before resgdp_after ///
if bigres==1, over(cn, sort(1) label(labsize(small))) ///
legend(col(1)) ///
title("Before and after the financial crisis")


graph rename Graph Bef_Af_Res, replace
graph export Bef_Af_Res.png, as(png) name("Bef_Af_Res") replace
graph export Bef_Af_Res.pdf, as(pdf) name("Bef_Af_Res") replace

**# Table 2. Baseline nonlinear regression.

// One lag for reserves + Balanced panel
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20, ///
absorb(cn) vce(bootstrap, reps(200))

estimates store BASE

*Run local command and subsequent `strings' together 
local     switches "dec(4) tex se e(rmse)"
outreg2   [BASE*] ///
          using "BASE.tex", replace `switches'

**# Fig. 2. 3-D plot for the buffer effect.

**One lag for reserves + Balanced panel**
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres yr* ///
if count_lgovexp==20, ///
absorb(cn) vce(bootstrap, reps(200))

// Create predictions for the interaction and store them
margins, at( L1lres=(1(0.1)5) etot=(1(0.1)5))

matrix predictions =r(at) , r(b)'

clear

svmat predictions, names(col)

rename r1 pred_lreer

save contour-plot-08-19-yr-effects, replace

// Use python to plot the 3-D figure

python search

*cmd then, "C:\Users\jamel\AppData\Local\Programs\Python\Python313\python.exe" -m pip install matplotlib

clear

python:

import pandas as pd
data = pd.read_stata("contour-plot-08-19-yr-effects.dta")
data[['etot','L1lres','pred_lreer']]

end

// Create the three-dimensional surface plot with Python
// Install matplotlib with conda (cmd)
python:
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # Needed for 3D plots

# Load the Stata dataset
data = pd.read_stata("contour-plot-08-19-yr-effects.dta")

# Create a new 3D figure
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Plot the 3D surface using triangular surface interpolation
ax.plot_trisurf(
    data['etot'],
    data['L1lres'],
    data['pred_lreer'],
    cmap=plt.cm.Spectral_r
)

# Set axis ticks
ax.set_xticks(np.arange(1, 5, step=1))
ax.set_yticks(np.arange(1, 5, step=1))
ax.set_zticks(np.arange(4.42, 4.62, step=0.04))

# Set title and axis labels (only once!)
ax.set_title("Buffer Effect")
ax.set_xlabel("Log of effective terms of trade")
ax.set_ylabel("Log of lagged reserves")
ax.zaxis.set_rotate_label(False)
ax.set_zlabel("Predicted REER", rotation=90)

# Set the view angle (elevation and azimuth)
ax.view_init(elev=30, azim=75)

# Save the figure in high resolution
plt.savefig("Margins3d.png", dpi=1200)
plt.savefig("Margins3d.pdf", dpi=1200)

# Close the plot to prevent duplicate displays
plt.close()
end

**# Table 3. Regional baseline regressions.

use datafintransformed-22-11-17, clear

label list rn
// East Asia and Pacific (nT=13*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==1, ///
absorb(cn) vce(bootstrap, reps(200)) 
// Europe and Central Asia (nT=40*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==2, ///
absorb(cn) vce(bootstrap, reps(200)) 
// Latin American Countries (nT=17*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==3, ///
absorb(cn) vce(bootstrap, reps(200)) 
// Middle East and North Africa (nT=6*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 ///
& rn==4 & cn!=60, ///
absorb(cn) vce(bootstrap, reps(200))
// North America (nT=2*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==5, ///
absorb(cn) vce(bootstrap, reps(200)) 
// South Asia (nT=5*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==6, ///
absorb(cn) vce(bootstrap, reps(200)) 
// Subsaharan Africa (nT=16*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & rn==7, ///
absorb(cn) vce(bootstrap, reps(200))

**# Table 4. Panel threshold regressions and financial development.

// Financial development (Threshold regression) //

// Full sample //

**Financial Development - Full sample**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fd) thnum(1) grid(300) bs(300)

**Financial Institutions - Full sample**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fi) thnum(1) grid(600) bs(100) trim(0.10)
	
sum fm if fi <= 0.48 & count_lgovexp==20
sum fm if fi > 0.48 & count_lgovexp==20

**Financial Markets - Full sample**	
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fm) thnum(1) grid(300) bs(300)

// Europe and Central Asia + North America //

**Financial Development - Europe and Central Asia + North America**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    & rn==2 | rn==5, ///
	rx(etot_L1lres) qx(L2.fd) thnum(1) grid(300) bs(300)

**Financial Insitutions - Europe and Central Asia + North America**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    & rn==2 | rn==5, ///
	rx(etot_L1lres) qx(l2.fi) thnum(1) grid(100) bs(300)
	
**Financial Markets - Europe and Central Asia + North America**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    & rn==2 | rn==5, ///
	rx(etot_L1lres) qx(L2.fm) thnum(1) grid(100) bs(300)
	
sum fm if fm <= 0.0219 & rn==2 | rn==5 & count_lgovexp==20
sum fm if fm > 0.0219 & rn==2 | rn==5 & count_lgovexp==20

/*
capture graph drop LR_FMECS	

_matplot e(LR), yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") recast(line) name(LR_FMECS)

graph export LR_FMECS.pdf, as(pdf) name("LR_FMECS") replace
*/

**Financial Markets Depth - Europe and Central Asia + North America**

xthreg lreer lgdppk_m lgovexp if count_lgovexp==20 ///
    & rn==2 | rn==5, ///
	rx(etot_L1lres) qx(L2.fmd) thnum(1) grid(100) bs(300)

sum fm if fmd <= 0.0241 & rn==2 | rn==5 & count_lgovexp==20
sum fm if fmd > 0.0241 & rn==2 | rn==5 & count_lgovexp==20

/*
capture graph drop LR_FMDECS	

_matplot e(LR), yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") recast(line) name(LR_FMDECS)

graph export LR_FMDECS.pdf, as(pdf) name("LR_FMDECS") replace
*/

**# Fig. 3. Construction of the confidence interval in the threshold model – FI.

**Financial Institutions - Full sample**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fi) thnum(1) grid(600) bs(100) trim(0.10)
	
sum fm if fi <= 0.48 & count_lgovexp==20
sum fm if fi > 0.48 & count_lgovexp==20

capture graph drop LR_FI	

_matplot e(LR), yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") recast(line) name(LR_FI)

graph export LR_FI.pdf, as(pdf) name("LR_FI") replace

**# Table 5. Panel threshold regression and financial openness.

**Financial openness - Full sample**

xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & ///
count_ka_open==19, ///
rx(etot_L1lres) qx(l2.ka_open_m) ///
thnum(2) grid(900) bs(300 300) trim(0.10 0.01)

sum ka_open_m if count_lgovexp==20 & count_ka_open==19
sum ka_open_m if ka_open_m <= -0.1144

**# Table B.1. Panel AR(1) regression for the international reserves.

// AR coefficients

xtreg lres l.lres if count_lgovexp==20, ///
fe

estimate store ar

local switches "dec(4) word se e(rmse)"

outreg2 [ar*] using "ar.rtf", replace `switches'

label list cn

drop if count_lgovexp!=20
encode cntry, gen(cn2)

forval i = 1(1)100 {
	reg lres l.lres if cn2 ==`i'
	estimates store ar_`i'
}

outreg2 [ar_*] using "ar_all.xml", replace `switches'

**# Table B.2. Panel threshold regressions.

label list rn

xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20, ///
rx(etot) qx(l.lres) thnum(1) grid(100) bs(100)

// East Asia and Pacific + South Asia
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & ///
rn==1 | rn==6, ///
rx(etot) qx(l.lres) thnum(1) grid(100) bs(300)
	
// Europe and Central Asia
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & ///
rn==2, ///
rx(etot) qx(l.lres) thnum(1) grid(100) bs(300)
sum L1lres if L1lres <= 2.90 & rn==2 & count_lgovexp==20
sum L1lres if L1lres > 2.90 & rn==2 & count_lgovexp==20

// Latin American Countries
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & ///
rn==3, ///
rx(etot) qx(l.lres) thnum(1) grid(100) bs(300)
	
// Middle East and North Africa
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & ///
rn==4 & cn!=60, ///
rx(etot) qx(l.lres) thnum(1) grid(200) bs(200)
sum L1lres if L1lres <= 3.34 & rn==4 & cn!=60 & count_lgovexp==20
sum L1lres if L1lres > 3.34 & rn==4 & cn!=60 & count_lgovexp==20

**# Fig. B.1. Threshold effect in the ECS region.

gen resgdp = (res/gdp)*100
by cn: egen resgdp_full = mean(resgdp)
by cn: egen resgdp_before = mean(resgdp) if year<2008
by cn: egen resgdp_after = mean(resgdp) if year>2009
by cn: egen resgdp_full_sd = sd(resgdp)
by cn: egen resgdp_before_sd = sd(resgdp) if year<2008
by cn: egen resgdp_after_sd = sd(resgdp) if year>2009

**# Threshold effect in the ECS region

graph hbar resgdp_before resgdp_after ///
if region=="ECS" & eurozone==0, over(cn, sort(2) ///
label(labsize(small))) ///
legend(col(1)) yline(17.28) ///
title("Threshold in the ECS region without EZ")

graph rename Graph Thres_Res, replace
graph export Thres_Res.png, as(png) name("Thres_Res") replace
graph export Thres_Res.pdf, as(pdf) name("Thres_Res") replace

**# Table B.3. Dynamic threshold panel model (Kremer et al., 2013).

**Dynamic panel threshold

*ssc install xtendothresdpd

xtendothresdpd lreer l.lreer lgdppk_m100 lgovexp ///
if count_lgovexp==20, sig(0.05) ///
thresv(l2.fi) stub(enr) pivar(etot_L1lres) ///
dgmmiv(lres, lagrange(6 9)) ///
fodeviation lagsret(1) 

estat sargan

ereturn list

twoway line enr_lrofgamma enr_gamma if __000001, ///
       title("Confidence Interval Construction for the Threshold Model") ///
	   xtitle("Threshold parameter") ytitle("LR statistics") sort ///
       yline(7.352276694155739, lcolor(black)) name(enr_dethgrp, replace)

graph export "DPTR_LR.pdf", as(pdf) name("enr_dethgrp") replace

/*
set seed 542020

xtendothresdpdtest, comdline(`e(cmdline)') reps(50)

ereturn list

matrix list e(b)
*/

**# Table B.4. Dynamic threshold panel model (Seo and Shin, 2016).

*search xthenreg
*net install st0573.pkg
*ssc install moremata

xtdescribe

by cn: egen idfour = seq(), block(3)
foreach v of varlist lreer fi lgdppk_m100 lgovexp etot_lres irr kaopen {
    sort cn idfour
	by cn idfour: egen double avg_`v' = mean(`v')
    }

collapse (first) avg_lreer avg_fi avg_lgdppk_m100 avg_lgovexp ///
 avg_etot_lres avg_irr avg_kaopen, by(cn idfour)

xtset cn idfour

xtdescribe
 
xthenreg avg_lreer avg_fi ///
         avg_lgdppk_m100 avg_lgovexp avg_irr avg_kaopen ///
		 , ///
		 endogenous(avg_etot_lres) ///
		 grid_num(150) boost(50)
		 
/*
sum avg_fi if avg_fi <= 0.6466778
sum avg_fi if avg_fi > 0.6466778
*/

/*
ereturn list
matrix list e(b)
matrix list e(V)
matrix list e(CI)
scalar list
display e(bs)
*/


**# Fig. B.2. Panel LP for the buffer effect on the RER.

use datafintransformed-22-11-17, clear

ssc install locproj

 locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust ///
 lcs((c.etot#c.L1lres)) title(`"lcs((c.etot#c.L1lres))"')
 
 graph rename Graph ivfi_lcs, replace
 
 locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust ///
 lcs(etot+(c.etot#c.L1lres)) title(`"lcs(etot+(c.etot#c.L1lres))"')
 
 graph rename Graph ivfi_lcs1, replace
 
 locproj lreer etot L1lres (c.etot#c.L1lres) l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr if count_lgovexp==20, fe ///
 z robust ///
 lcs(L1lres+(c.etot#c.L1lres)) title(`"lcs(L1lres+(c.etot#c.L1lres))"')
 
 graph rename Graph ivfi_lcs2, replace
 
 graph combine ivfi_lcs ivfi_lcs1 ivfi_lcs2, row(1) ///
 title(`"Panel LP for the Buffer Effect on the RER"')

 graph export "PANEL_LP.pdf", as(pdf) name("Graph") replace


**# Fig. B.3. Panel LP for the buffer effect on the RER.

reg d.lres lreer cny* if count_lgovexp==20, robust 
capture drop residuals_lres
predict residuals_lres, residuals
histogram residuals_lres, kdensity

reg d.etot lreer cny* if count_lgovexp==20, robust
capture drop residuals_etot
predict residuals_etot, residuals
histogram residuals_etot, kdensity

locproj lreer (c.residuals_etot#c.residuals_lres) ///
 if count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Full sample"') ///
 save irfname(full) 
 
graph rename Graph full, replace

locproj lreer (c.residuals_etot#c.residuals_lres) if l2.fi<0.48 ///
 & count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Below the threshold for FI"') ///
 save irfname(below) 
 
graph rename Graph belowfi, replace 

locproj lreer (c.residuals_etot#c.residuals_lres) if l2.fi>=0.48 ///
 & count_lgovexp==20, ///
 c(l(1).lgdppk_m100 ///
 l(1).lgovexp l(1).irr) ///
 z h(4) yl(1) sl(1) fe cluster(cn) conf(90 95) ///
 title(`"Above the threshold for FI"') ///
 save irfname(above) 
 
graph rename Graph abovefi, replace 

graph combine full belowfi abovefi, row(1) ///
title(`"Panel LP for the Buffer Effect on the RER"') ///
subtitle(`"Term-of-trade shock - (shock on c.residuals_etot#c.residuals_lres)"')

graph export "PANEL_LP_RES.pdf", as(pdf) name("Graph") replace

**# Table B.5. Factor augmented panel regressions.

*ssc install xtcdf

**CS mean of lreer**
areg lreer lgdppk_m100 lgovexp mean_lreer c.etot##c.L1lres ///
if count_lgovexp==20, ///
absorb(cn) vce(bootstrap, reps(200))
capture drop lreer_resid
predict lreer_resid if count_lgovexp==20, residuals
xtcdf lreer_resid

**Year effects**
areg lreer lgdppk_m100 lgovexp yr2006-yr2020 c.etot##c.L1lres ///
if count_lgovexp==20, ///
absorb(cn) vce(bootstrap, reps(200))
capture drop lreer_resid
predict lreer_resid if count_lgovexp==20, residuals
xtcdf lreer_resid

**Heterogenous factor loadings**

capture drop resid
regife lreer lgdppk_m100 lgovexp etot L1lres etot_L1lres ///
if year!=2020, a(cn year) ife(cn year, 1) residuals(resid)
xtcdf resid

**# Table B.6. Before and after the Global Financial Crisis.

**# *** Controls for GFC ***

areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres ///
if count_lgovexp==20 & year<2009, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store gfc_before

areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres ///
if count_lgovexp==20 & year>=2009, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store gfc_after

xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 & year>=2009, ///
rx(etot_L1lres) qx(l2.fi) thnum(1) grid(600) bs(100) trim(0.10)
estimate store gfc_after_fi

local switches "dec(4) excel se e(rmse)"

outreg2 [gfc*] using "gfc.xml", replace `switches'

**# Table B.7. Baseline regressions for different country groups.

*** Table B4 - Aizenman, Riera-Crichton 2006 ***

cap drop manufactured
generate manufactured = 0

replace manufactured = 1 if cn == 55 | cn == 34 | cn == 38 | ///
					cn == 100 | cn == 11 | cn == 52 | ///
					cn == 50 | cn == 35

*** Eurozone ***

cap drop eurozone
generate eurozone = 0

replace eurozone = 1 if cn == 7 | cn == 11 | cn == 25 | ///
				cn == 32 | cn == 34 | cn == 35 | ///
				cn == 38 | cn == 40 | cn == 48 | ///
				cn == 50 | cn == 59 | cn == 61 | ///
				cn == 62 | cn == 75 | cn == 88 | ///
				cn == 95 | cn == 96 | cn == 98			 

// Malta is not in the sample

**# *** OECD (at least 20 year of membership) ***

generate oecd = 0

replace oecd = 1 if cn == 6 | cn == 7 | cn == 11 | ///
                    cn == 18 | cn == 26 | cn == 27 | ///
                    cn == 34 | cn == 35 | cn == 38 | ///
                    cn == 40 | cn == 44 | cn == 48 | ///
                    cn == 50 | cn == 52 | cn == 55 | ///
                    cn == 62 | cn == 68 | cn == 98 | ///
                    cn == 75 | cn == 76 | cn == 80 | ///
                    cn == 87 | cn == 87 | cn == 88 | ///
                    cn == 95 | cn == 98 | cn == 100 | ///
                    cn == 104 | cn == 106 | cn == 107

**# *** Natural resources ***
								 
generate natres = 0

replace natres = 1 if cn == 6 | cn == 18 | cn == 19 | ///
            cn == 56 | cn == 68 | cn == 78 | ///
            cn == 80 | cn == 90 | cn == 92 | ///
            cn == 97

**# *** Commodity exporters ***

generate commodity = 0

replace commodity = 1 if cn == 2 | cn == 3 | cn == 4 | ///
            cn == 8 | cn == 14 | cn == 19 | ///
            cn == 21 | cn == 23 | cn == 29 | ///
			cn == 41 | cn == 46 | cn == 53  | ///
			cn == 53 | cn == 65 | cn == 81 | ///
			cn == 84 | cn == 85 | cn == 90  | ///
			cn == 102 | cn == 108

summarize

*** Controls - OECD vs non-OECD ***

areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & ///
oecd==1, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store country_oecd

areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & ///
oecd==0, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store country_non_oecd

*** Controls - ECS without EZ ***

// Europe and Central Asia without EZ (nT=22*19)
areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & ///
rn==2 & eurozone==0, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store country_ecs_without_ez
 
*** Controls - Commodities after 2008 ***

areg lreer lgdppk_m100 lgovexp c.etot##c.L1lres if count_lgovexp==20 & commodity==1 & year>2008, ///
absorb(cn) vce(bootstrap, reps(200))
estimate store country_commodities

outreg2 [country*] using "country.xml", replace `switches'

log close _all
exit

**# End of Program