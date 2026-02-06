**# Replicaction package for 
* "Impact of Climate Vulnerability on Fiscal Risk:
*  Do Religious Tensions and Financial Development Matter?"

// Code by Jamel Saadaoui (jamelsaadaoui@gmail.com)

capture log close _all                                
log using SLP_EE.smcl, name(SLP_EE) text replace

// Version of Stata 

version 19.5

// Set scheme

set scheme Cleanplots

graph set window fontface "Arial Narrow"

// Clear consol and data

cls 

clear

// Set the paths

*global Docs = "C:\Users\jamel\Dropbox\Latex\"
*global Proj = "PROJECTS\24-03-emft-adb\estimates"
 
*cd "${Docs}"
*cd "${Proj}"

**# Install the packages (may require to install of other related required packages)

ssc install locproj, replace
ssc install heatplot, replace
ssc install ridgeline, replace
ssc install outreg2, replace
ssc install schemepack, replace

**# Data preparation

use emft-adb-new-v3.dta, clear

xtset imfcode period
xtdes
des
sum 

gen vul100 =100*vul
gen read100=100*read
gen Dvul100=D.vul100


merge 1:1 imfcode period using emdat.dta, ///
			 keep(1 3) nogen
			 
**# Table 1. Descriptive statistics for the variables involved

// Run everything for Table 1

#delimit;
local variables "vul bonds_tw sovrate CAB GDebt GDeficit cpi_tw banking currency debt  msciworld_gw bondsUS_tw VIXCLS";

summ `variables' if period>1995;

#delimit cr
outreg2 using sum if period>1995, word replace ///
 sum(detail) keep(`variables') ///
 eqkeep(N mean p25 p50 p75 sd min max) // dec(2)
 
// Prepare the data for the heatplot

encode   country, generate(CN)
kountry  country, from(iso3c)
rename   NAMES_STD cn
encode   cn, generate(cnnum)

sum vul, detail

format vul %4.2f

by imfcode: egen mean_vul = mean(vul)
 
**# Figure 1. Heat plot for the low vulnerability score

// Run everything between preserve and restore

preserve
drop if mean_vul > .3722011
drop if period<1995
drop if period>2021

summ period
  local x1 = `r(min)'
  local x2 = `r(max)'
heatplot vul i.cnnum period if mean_vul< .3722011 , ///
 yscale(noline) ///
 ylabel(, nogrid labsize(*0.5)) ///
 xlabel(`x1'(5)`x2', labsize(*0.75) angle(vertical) nogrid) ///
 color(viridis) ///  
 levels(8) ///
  ramp(right  space(14)  format(%4.2f)) ///
  p(lcolor(black%10) lwidth(*0.1)) ///
  ytitle("") ///
  xtitle("", size(vsmall)) ///
  xdiscrete name(vulQ1, replace) ///
 title("Vulnerability Index (below Q1)") ///
  note("Data source: Notre Dame Global Adaptation Initiative.", ///
  size(vsmall))
graph export vulQ1.png, as(png) width(4000) replace
restore

**# Figure 2. Heat plot for the high vulnerability score

// Run everything between preserve and restore

preserve
drop if mean_vul < .5174853
drop if period<1995
drop if period>2021

summ period
  local x1 = `r(min)'
  local x2 = `r(max)'
heatplot vul i.cnnum period if mean_vul> .5174853 , ///
 yscale(noline) ///
 ylabel(, nogrid labsize(*0.5)) ///
 xlabel(`x1'(5)`x2', labsize(*0.75) angle(vertical) nogrid) ///
 color(inferno, reverse) ///  
 levels(8) ///
  ramp(right  space(14)  format(%4.2f)) ///
  p(lcolor(black%10) lwidth(*0.1)) ///
  ytitle("") ///
  xtitle("", size(vsmall)) ///
  xdiscrete name(vulQ3, replace) ///
 title("Vulnerability Index (above Q3)") ///
  note("Data source: Notre Dame Global Adaptation Initiative.", ///
  size(vsmall))
graph export vulQ3.png, as(png) width(4000) replace
restore


**# Table 2. Comparing fundamentals and institutional features for different levels of vulnerability

gen vul100Q4 = 0

summ vul100 if period>1995, detail
local x1 = `r(p75)'
replace vul100Q4 = 1 if vul100 < `x1'
replace vul100Q4 = . if vul100 ==.

label define vul100Q4lab 0 "VUL High" 1 "VUL Low"
label values vul100Q4 vul100Q4lab

lab var milpol "ICRG index - Military in Politics"

putdocx clear
putdocx begin, font("Times New Roman", 7)

#delimit;
local variables "vul read bonds_tw bills_tw sovrate ka_open ers FI FM extconf corruption bureau demoacc ethnictens govstab intconf laworder milpol reltensions";

summ `variables' if period>1995;

dtable `variables' if period>1995, 
   by(vul100Q4, totals tests) 
   column(by(hide)) 
   sample(, place(seplabels)) 
   title(Descriptive statistics Full sample after 1995) 
   titlestyles(font(, size(12) color(blue) bold)) 
   nformat(%6.0fc frequency) 
   nformat(%6.2f  mean sd cv) 
   continuous(, statistic(mean sd cv)) 
   halign(right) 
   note(Mean (Standard deviation) Coefficient of Variation: 
   p-value from a pooled t-test.) 
   note(Frequency (Percent%): p-value from Pearson test.);
   

collect style putdocx, halign(center) 
  layout(autofitcontents);
 
putdocx collect;
 
putdocx save ds_table2.docx, replace;

#delimit cr

**# Figure 3. Scatter plot for the vulnerability score and bond yields

twoway (lfit vul bonds_tw) (scatter vul bonds_tw), ///
 name(bonds, replace)

graph export bonds.png, as(png) width(4000) replace

**# Figure 4. Scatter plot for the vulnerability score and the sovereign ratings

lab var sovrate "Foreign currency long-term sovereign debt ratings, index from 1-21 [best]"

twoway (lfit vul sovrate) (scatter vul sovrate), ///
 name(sovrate, replace) xlabel(0(5)27)

graph export sovrate.png, as(png) replace width(4000)

**# Figure 5a. Ridgeline for the changes in climate vulnerability scores

set scheme white_tableau
graph set window fontface "Arial Narrow" 

ridgeline Dvul100 if mean_vul< .3722011 & period<2018, ///
 by(period) name(JoyplotQ1, replace) ///
 overlap(8) bwid(0.1) palette(CET C1) alpha(100) ///
 lc(white) lw(0.2) xlabel(-1.5(0.5)1.5) laboff(-0.25) norm(local) ///
 xtitle("Change in vulnerability") ytitle("Period") ///
 title("{fontface Arial Bold:Ridgeline for the low vulnerability score}") ///
 subtitle("Below Q1")  ///
 note("Data source: Notre Dame Global Adaptation Initiative.", size(vsmall))  
graph export joyQ1.png, as(png) width(4000) replace

**# Figure 5b. Ridgeline for the changes in climate vulnerability scores
 
ridgeline Dvul100 if mean_vul> .5174853 & period<2018, ///
 by(period) name(JoyplotQ3, replace) ///
 overlap(8) bwid(0.25) palette(CET C1) alpha(100) ///
 lc(white) lw(0.2) xlabel(-6(1)6) off(-0.25) norm(local) ///
 xtitle("Change in vulnerability") ytitle("Period") ///
 title("{fontface Arial Bold:Ridgeline for the high vulnerability score}") ///
 subtitle("Above Q3")  ///
 note("Data source: Notre Dame Global Adaptation Initiative.", size(vsmall))  
graph export joyQ3.png, as(png) width(4000) replace 

**# Table 3. Reverse causality

// Run everything

areg D.vul100 L(0/4).bonds_tw i.period, absorb(imfcode) robust

estimate  store m1

local     switches "dec(2) word pvalue e(rmse)"
outreg2   [m1] ///
          using "bonds.rtf", replace `switches'

areg D.vul100 L(0/4).sovrate i.period, absorb(imfcode) robust

estimate  store m2

local     switches "dec(2) word pvalue e(rmse)"
outreg2   [m2] ///
          using "sov.rtf", replace `switches'
		  
**# Figure 6. Panel LP - impact of change in vulnerability on bond yields (Baseline)

locproj bonds_tw, shock(Dvul100) ///
 z h(5) yl(1) sl(3) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Change in Vulnerability on Bonds Yields"') ///
 save irfname(bonds_TZ) noisily stats grname(TZ1)
 
graph export bond_vul_jan25_TZ.png, as(png) width(4000) replace

**# Figure 7. Impact of change in vulnerability on bond yields (Climate vulnerability)

egen vul100_p25 = pctile(vul100), p(25)
 
sum vul100, detail

cap drop D1
gen D1 = 0
replace D1 = 1 if l.vul100>l.vul100_p25

locproj bonds_tw D1#c.Dvul100, lcs(1.D1#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Vulnerability"') ///
 save irfname(belowbv) zero
 graph rename Graph belowbv, replace
 
locproj bonds_tw D1#c.Dvul100, lcs(0.D1#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low Vulnerability"') ///
 save irfname(highbv) zero
graph rename Graph highbv, replace

graph close belowbv highbv

graph combine belowbv highbv, row(1) ///
 name(vul_bonds, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Vulnerability is defined as above/below Q1 for VUL." "State dependence is measured with a dummy for High/Low Vulnerability score." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bondvulSLPQ1_apr25.png, as(png) width(4000) replace

**# Figure 8. Panel LP - impact of change in vulnerability on sovereign ratings (Baseline)

locproj sovrate, shock(Dvul100) ///
 z h(5) yl(1) sl(3) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Change in Vulnerability on Ratings"') ///
 save irfname(sovrate_TZ) noisily stats grname(TZ2)
 
graph export sov_vul_jan25_TZ.png, as(png) width(4000) replace

**# Figure 9. Impact of change in vulnerability on sovereign ratings (Climate vulnerability)

locproj sovrate D1#c.Dvul100, lcs(1.D1#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Vulnerability"') ///
 save irfname(belowbv) zero
 graph rename Graph belowsv, replace
 
locproj sovrate D1#c.Dvul100, lcs(0.D1#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low Vulnerability"') ///
 save irfname(highbv) zero
graph rename Graph highsv, replace

graph close belowbv highsv

graph combine belowsv highsv, row(1) ///
 name(vul_bonds, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Sovereign Rating"') ///
 note("Note: High/Low Vulnerability is defined as above/below Q1 for VUL." "State dependence is measured with a dummy for High/Low Vulnerability score." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export sovratevulSLPQ1_apr25.png, as(png) width(4000) replace

**# Figure 10. Panel LP - impact of change in vulnerability on bond yields (Financial Institutions)

egen FI_p75 = pctile(FI), p(75)
 
sum FI, detail

cap drop D2
gen D2 = 0
replace D2 = 1 if l.FI>l.FI_p75

locproj bonds_tw D2#c.Dvul100, lcs(1.D2#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High FI"') ///
 save irfname(belowbf) zero
 graph rename Graph belowbf, replace
 
locproj bonds_tw D2#c.Dvul100, lcs(0.D2#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low FI"') ///
 save irfname(highbf) zero
graph rename Graph highbf, replace

graph close belowbf highbf

graph combine belowbf highbf, row(1) ///
 name(vul_fi, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Financial Institutions is defined as above/below Q3 for FI." "State dependence is measured with a dummy for High/Low Financial Institutions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bondFISLPQ3_apr25.png, as(png) width(4000) replace

**# Figure 11. Panel LP - impact of change in vulnerability on sovereign ratings (Financial Institutions)

locproj sovrate D2#c.Dvul100, lcs(1.D2#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High FI"') ///
 save irfname(belowbf) zero
 graph rename Graph belowbf, replace
 
locproj sovrate D2#c.Dvul100, lcs(0.D2#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low FI"') ///
 save irfname(highbf) zero
graph rename Graph highbf, replace

graph close belowbf highbf

graph combine belowbf highbf, row(1) ///
 name(vul_fi, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Sovereign Ratings"') ///
 note("Note: High/Low Financial Institutions is defined as above/below Q3 for FI." "State dependence is measured with a dummy for High/Low Financial Institutions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export sovFISLPQ3_apr25.png, as(png) width(4000) replace

**# Figure 12. Panel LP - impact of change in vulnerability on bond yields (Religious Tensions)

egen reltensions_p50 = pctile(reltensions), p(50)

sum reltensions, detail

cap drop D3
gen D3 = 0
replace D3 = 1 if l.reltensions<l.reltensions_p50

locproj bonds_tw D3#c.Dvul100, lcs(1.D3#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Religious Tensions"') ///
 save irfname(belowbr) zero
graph rename Graph belowbr, replace
 
locproj bonds_tw D3#c.Dvul100, lcs(0.D3#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"Low Religious Tensions"') ///
 save irfname(highbr) zero
graph rename Graph highbr, replace

graph close belowbr highbr

graph combine belowbr highbr, row(1) ///
 name(vul_rel, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Religious Tensions is defined as below/above Q2 for reltensions." "State dependence is measured with a dummy for High/Low Religious Tensions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bondreltensSLPQ2_apr25.png, as(png) width(4000) replace

// Wald test for religious tensions regimes

forvalues v = 0(1)5{

qui locproj bonds_tw D3#c.Dvul100, lcs(1.D3#c.Dvul100) ///
 h(`v') yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Religious Tensions"') ///
 save irfname(belowbv) zero ///
stats nograph

test (_b[0.D3#c.Dvul100] = ///
 _b[1.D3#c.Dvul100])

}

**# Figure 13. Panel LP - impact of change in vulnerability on sovereign ratings (Religious Tensions)

locproj sovrate D3#c.Dvul100, lcs(1.D3#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Religious Tensions"') ///
 save irfname(belowbr) zero
graph rename Graph belowbr, replace
 
locproj sovrate D3#c.Dvul100, lcs(0.D3#c.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"Low Religious Tensions"') ///
 save irfname(highbr) zero
graph rename Graph highbr, replace

graph close belowbr highbr

graph combine belowbr highbr, row(1) ///
 name(vul_rel, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Sovereign Ratings"') ///
 note("Note: High/Low Religious Tensions is defined as below/above Q2 for reltensions." "State dependence is measured with a dummy for High/Low Religious Tensions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export sovratereltensSLPQ3_apr25.png, as(png) width(4000) replace

**# Figure 14. Panel LP - impact of change in VUL_N on bond yields

// Data preparation

merge 1:1 imfcode period using VUL_N.dta, ///
			 keep(1 3) nogen force

// PCA (first)

pca FOOD_03 WATE_03 ECOS_​04 ECOS_​05 ECOS_​06 INFR_​03 ///
 INFR_​04

pca FOOD_03 WATE_03 ECOS_​04 ECOS_​05 ECOS_​06 INFR_​03 ///
 INFR_​04, mineigen(1)

cap drop pc*
estat loadings
predict pc1 pc2 pc3, score

// Local Projection (Second)

locproj bonds_tw, shock(D.pc1) ///
 z h(4) yl(1) sl(5) ///
 c(F(1/5).D.pc1 l(1).CAB l(1).cpi_tw l(1).GDebt l(1).GDeficit  ///
   l(1).banking l(1).currency l(1).debt i.period) ///
   title("Impact of change in the first component of less correlated vulnerability") ///
   ttitle("Horizon") ///
 fe conf(90 95) noisily	stats grname(TZ3)
 
graph export bond_pca_jan25_TZ.png, as(png) width(4000) replace

**# Figure 15. Panel LP - impact of change in VUL_N on sovereign ratings

locproj sovrate, shock(D.pc1) ///
 z h(4) yl(1) sl(5) ///
 c(F(1/5).D.pc1 l(1).CAB l(1).cpi_tw l(1).GDebt l(1).GDeficit  ///
   l(1).banking l(1).currency l(1).debt i.period) ///
   title("Impact of change in the first component of less correlated vulnerability") ///
   ttitle("Horizon") ///
 fe conf(90 95) noisily grname(TZ4)
 
graph export sovrate_pca_jan25_TZ.png, as(png) width(4000) replace

**# Figure C1. Panel LP - impact of change in vulnerability on bond yields

set scheme stcolor

xtvar bonds_tw Dvul100 if vul>.3722011, lags(3) maxldep(4) ///
 fd collapse 

vargranger

irf create lags, set(example1) step(6) replace

irf graph irf, irf(lags) name(irf, replace)

*irf cgraph (lags Dvul100 bonds_tw irf) ///
  (lags bonds_tw Dvul100 irf), ///
  ycommon name(oirf, replace)
  
graph export bonds_var_irf.png, as(png) width(4000) replace

**# Figure D1. Panel LP - impact of natural disasters on bond yields

locproj bonds_tw, shock(disaster) ///
 z h(5) yl(5) sl(3) ///
 c(f(1/7).disaster i.period) ///
 fe cluster(imfcode) conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Disasters on Bonds Yields"') ///
 save irfname(bonds_DTZ) noisily stats grname(DTZ1)
 
locproj bonds_tw if inc!=4, shock(disaster) ///
 z h(5) yl(7) sl(6) ///
 c(f(1/7).disaster i.period) ///
 fe cluster(imfcode) conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Disasters on Bonds Yields (Other than high income countries)"') ///
 save irfname(bonds_DTZ) noisily stats grname(DTZ2)

graph combine DTZ1 DTZ2, row(1) ///
 name(vul_bonds_combine, replace) ycommon
graph export disasterbondsapr25.png, as(png) width(4000) replace  

**# Figure E1. Panel VAR - impact of natural disasters on bond yields

xtvar bonds_tw disaster, lags(3) maxldep(8) ///
 fd collapse 

vargranger

irf create lags, set(example1) step(6) replace

irf graph irf, irf(lags) name(irf2, replace)

*irf cgraph (lags disaster bonds_tw irf) ///
  (lags bonds_tw disaster irf), ///
  ycommon name(oirf, replace)

graph export bonds_var_irf_disaster.png, as(png) width(4000) replace

**# Addition to the codes

**# Figure F1. Panel LP - impact of change in vulnerability on bond yields (Robustness)

locproj bonds_tw, shock(L.Dvul100) ///
 z h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe cluster(imfcode) conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Change in Vulnerability on Bonds Yields"') ///
 save irfname(bonds_TZR1) noisily stats grname(TZ1)
 
graph export bonds_TZR1.png, as(png) width(4000) replace

// Bootstrap

locproj bonds_tw, shock(L.Dvul100) ///
 z h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe conf(90 95) ///
 ttitle("Horizon") ///
 title(`"Impact of Change in Vulnerability on Bonds Yields"') ///
 save irfname(bonds_TZR1boot) noisily stats grname(TZ1) vce(bootstrap, reps(999))
 
graph export bonds_TZR1boot.png, as(png) width(4000) replace
 
**# Figure F2. Impact of change in vulnerability on bond yields (Climate vulnerability - Robustness)

cap egen vul100_p25 = pctile(vul100), p(25)
 
sum vul100, detail

cap cap drop D1
gen D1 = 0
replace D1 = 1 if l.vul100>l.vul100_p25

locproj bonds_tw D1#c.L.Dvul100, lcs(1.D1#c.L.Dvul100) ///
 h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/5).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Vulnerability"') ///
 save irfname(belowbv) zero noisily stats
 graph rename Graph belowbv, replace
 
locproj bonds_tw D1#c.L.Dvul100, lcs(0.D1#c.L.Dvul100) ///
 h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low Vulnerability"') ///
 save irfname(highbv) zero noisily stats
graph rename Graph highbv, replace

graph close belowbv highbv

graph combine belowbv highbv, row(1) ///
 name(vul_bonds, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Vulnerability is defined as above/below Q1 for VUL." "State dependence is measured with a dummy for High/Low Vulnerability score." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bonds_SLP_VUL_R1.png, as(png) width(4000) replace
 
**# Figure F3. Panel LP - impact of change in vulnerability on bond yields (Financial Institutions - Robustness)

cap egen FI_p75 = pctile(FI), p(75)
 
sum FI, detail

cap drop D2
gen D2 = 0
replace D2 = 1 if l.FI>l.FI_p75

locproj bonds_tw D2#c.L.Dvul100, lcs(1.D2#c.L.Dvul100) ///
 h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High FI"') ///
 save irfname(belowbf) zero noisily stats
 graph rename Graph belowbf, replace
 
locproj bonds_tw D2#c.L.Dvul100, lcs(0.D2#c.L.Dvul100) ///
 h(4) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   banking currency debt) i.period) ///
 fe cluster(imfcode) conf(95) ///
  title(`"Low FI"') ///
 save irfname(highbf) zero noisily stats
graph rename Graph highbf, replace

graph close belowbf highbf

graph combine belowbf highbf, row(1) ///
 name(vul_fi, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Financial Institutions is defined as above/below Q3 for FI." "State dependence is measured with a dummy for High/Low Financial Institutions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bonds_SLP_FI_R1.png, as(png) width(4000) replace
 
**# Figure F4. Panel LP - impact of change in vulnerability on bond yields (Religious Tensions - Robustness)

cap egen reltensions_p50 = pctile(reltensions), p(50)

sum reltensions, detail

cap drop D3
gen D3 = 0
replace D3 = 1 if l.reltensions<l.reltensions_p50

locproj bonds_tw D3#c.L.Dvul100, lcs(1.D3#c.L.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit  ///
   ) i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Religious Tensions"') ///
 save irfname(belowbr) zero noisily stats
graph rename Graph belowbr, replace
 
locproj bonds_tw D3#c.L.Dvul100, lcs(0.D3#c.L.Dvul100) ///
 h(5) yl(1) sl(1) ///
 c(f(1/2).Dvul100 l(1/2).(CAB cpi_tw GDeficit ///
   ) i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"Low Religious Tensions"') ///
 save irfname(highbr) zero noisily stats
graph rename Graph highbr, replace

graph close belowbr highbr

graph combine belowbr highbr, row(1) ///
 name(vul_rel, replace) ycommon ///
title(`"State-Dependent LP for Change in Vunerability on Bond Yields"') ///
 note("Note: High/Low Religious Tensions is defined as below/above Q2 for reltensions." "State dependence is measured with a dummy for High/Low Religious Tensions." "The shock is on D.vul100. Time FE included.", size(vsmall))
 
graph export bonds_SLP_REL_R1.png, as(png) width(4000) replace

// Wald test for religious tensions regimes

forvalues v = 0(1)5{

qui locproj bonds_tw D3#c.Dvul100, lcs(1.D3#c.Dvul100) ///
 h(`v') yl(1) sl(1) ///
 c(f(1/5).Dvul100 i.period) ///
 fe cluster(imfcode) conf(95) ///
 title(`"High Religious Tensions"') ///
 save irfname(belowbv) zero ///
stats nograph

test (_b[0.D3#c.Dvul100] = ///
 _b[1.D3#c.Dvul100])

}

**# Table F1. Predictability of Change in ND-GAIN overall vulnerability

eststo m1: reghdfe Dvul100 L(1/2).bonds_tw ///
    L(1/2).(CAB cpi_tw GDeficit banking currency debt), ///
    absorb(imfcode period) vce(cluster imfcode)
test L1.bonds_tw L2.bonds_tw

esttab m1, se stats(r2 N F, fmt(%7.2f)) ///
 star(* 0.10 ** 0.05 *** 0.01) b(%7.4f) 
 
eststo m2: reghdfe Dvul100 L(1/2).bonds_tw, ///
    absorb(imfcode period) vce(cluster imfcode)
test L1.bonds_tw L2.bonds_tw

esttab m2, se stats(r2 N F, fmt(%7.2f)) ///
 star(* 0.10 ** 0.05 *** 0.01) b(%7.4f)
 
esttab using pred.rtf, replace ///
 se stats(r2 N F, fmt(%7.2f)) ///
 star(* 0.10 ** 0.05 *** 0.01) b(%7.4f)

log close _all
exit

**# End of Program