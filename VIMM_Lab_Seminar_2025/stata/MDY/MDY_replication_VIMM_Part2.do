**# Replicaction package for 
* "Monetary policy reaction to geopolitical risks in unstable environments"

capture log close _all                                
log using MP_GPR_VIMM.smcl, name(MP_GPR_VIMM) smcl replace

use data_mp_gpr_VIMM_without_3outliers.dta, clear

graph set window fontface "Times New Roman"
set scheme stcolor

**# Figure 3. GPR on interest rates (Full sample).

locproj RATE, shock(gpr) ///
 z h(12) yl(2) sl(2) ///
 c(l(1/2).impact_gap l(1/2).INF rec) ///
 fe cluster(imfcode) conf(90 95) ///
 title(`"GPR on Interest rates (Baseline Model)"') ///
 save irfname(gpr_full) noisily ///
 robust
 
 *vce(bootstrap, reps(200) seed(8425))

graph rename Graph gpr_full, replace
graph export gpr_full.png, as(png) width(4000) replace
*graph export gpr_full.pdf, as(pdf)

**# Figure 4. GPR on interest rates (Developed countries).

locproj RATE if idc==1, shock(gpr) ///
 z h(12) yl(2) sl(2) ///
 c(l(1/2).impact_gap l(1/2).INF rec) ///
 fe cluster(imfcode) conf(90 95) ///
 title(`"GPR on Interest rates (Baseline Model)"') ///
 save irfname(gpr_idc) noisily ///
 robust
 
 *vce(bootstrap, reps(200) seed(8425))
 
graph rename Graph gpr_idc, replace
graph export gpr_idc.png, as(png) width(4000) replace
*graph export gpr_idc.pdf, as(pdf)

**# Figure D.1. GPR on interest rates (State-dependent LPs).

egen gpr_p75 = pctile(gpr), p(75)

sum gpr, detail

cap drop D
gen D = 0
replace D = 1 if gpr>gpr_p75

locproj RATE D#c.gpr if idc==1, lcs(1.D#c.gpr) ///
 z h(15) yl(2) sl(1) ///
 c(l(1/2).impact_gap l(1/2).INF rec) ///
 fe cluster(imfcode) conf(95) ///
 title(`"GPR on Interest rates (High GPR)"') ///
 save irfname(high) r noisily stats
 graph rename Graph high, replace
 
locproj RATE D#c.gpr if idc==1, lcs(0.D#c.gpr) ///
 z h(15) yl(2) sl(1) ///
 c(l(1/2).impact_gap l(1/2).INF rec) ///
 fe cluster(imfcode) conf(95) ///
 title(`"GPR on Interest rates (Low GPR)"') ///
 save irfname(below)
 graph rename Graph below, replace
cap by imfcode: gen N = _n-1

graph combine high below, ycommon ///
 title(`"Panel LP for GPR shocks on RATE (Industrialized countries)"') ///
 subtitle(`"State Dependent LPs - (shock on GPR)"') ///
 note("Note: High/Low GPR is defined as above/below Q3 for GPR." ///
 "State dependence is measured with a dummy for High/Low GPR." ///
 "The shock is on GPR. 95% Confidence Intervals.", size(small))

graph export SD_LPs_GPR.png, as(png) width(4000) replace

**# Figure 6. GPR on interest rates (United Kingdom).

// Set scheme colors

tsline RATE if LOCATION=="GBR" || ///
 tsline gpr if LOCATION=="GBR", yaxis(2) ///
 legend(off) name(GBRG, replace)

irf set comparemodels.irf, replace
quietly lpirf RATE impact_gap INF if LOCATION=="GBR", ///
  step(13) lags(1/2) ///
  exog(L(0/2).gpr)
irf create LP 

irf graph dm, impulse(gpr) response(RATE)   ///
  irf(LP) level(95) xlabel(1(1)12) name(GBR, replace)
graph export GBR.png, as(png) replace

**# Figure 7. GPR on interest rates (Canada).

tsline RATE if LOCATION=="CAN" || ///
 tsline gpr if LOCATION=="CAN", yaxis(2) ///
 legend(off) name(CANG, replace)

irf set comparemodels.irf, replace
quietly lpirf RATE impact_gap INF if LOCATION=="CAN", ///
  step(13) lags(1/2) ///
  exog(L(0/2).gpr)
irf create LP 

irf graph dm, impulse(gpr) response(RATE)   ///
  irf(LP) level(95) xlabel(1(1)12) name(CAN, replace)
graph export GBR.png, as(png) replace

**# Figure 8. GPR on interest rates (Israel).

tsline RATE if LOCATION=="ISR" || ///
 tsline gpr if LOCATION=="ISR", yaxis(2) ///
 legend(off) name(ISRG, replace)

irf set comparemodels.irf, replace
quietly lpirf RATE impact_gap INF if LOCATION=="ISR", ///
  step(13) lags(1/2) ///
  exog(L(0/2).gpr)
irf create LP 

irf graph dm, impulse(gpr) response(RATE)   ///
  irf(LP) level(95) xlabel(1(1)12) name(ISR, replace)
graph export ISR.png, as(png) replace

**# Figure 9. GPR on interest rates in an unstable environment (United Kingdom).

////////////// Execute the routine //////////////
qui do "tvpreg.ado"
/////////////////////////////////////////////////

keep if LOCATION=="GBR"

tsset period

foreach v in RATE impact_gap INF gpr {
    forvalues i = 1(1)2 {
	gen `v'_l`i' = l`i'.`v'
}
}

gen dummyGFC = 0
replace dummyGFC = 1 if period > tm(2009m6)

rename rec REC
lab var REC "Recession"

lab var dummyGFC "Post-GFC"

summ gpr, detail
gen dummyGPR = 0
replace dummyGPR = 1 if gpr > `r(p75)'

gen Recession = 0
replace Recession = 1 ///
 if period >= tm(2008m4) & period <= tm(2009m10)
replace Recession = 1 ///
 if period >= tm(2020m1) & period <= tm(2020m4) 

///// Estimator II: TVP-LP /////
// Short-term rates to a one-unit geopolitical risk shock (GPR)
mat define cmat = (0,3,6,9,12,15)
tvpreg RATE gpr RATE_l* impact_gap_l* INF_l* gpr_l*, ///
 cmatrix(cmat) nhor(0/15) getband newey chol

tvpplot, plotcoef(RATE:gpr) plotconst name(figure_RATE_gpr_UK)
graph export figure_RATE_gpr_UK.png, as(png) replace

**# Fig 10. GPR on interest rates after Global Financial Crisis (United Kingdom).

tvpplot, plotcoef(RATE:gpr) plotconst period(dummyGFC) name(GFC)
graph export GFC_UK.png, as(png) replace

**# Fig 11. GPR on interest rates after Global Financial Crisis (United Kingdom).

tvpplot, plotcoef(RATE:gpr) plotconst period(dummyGPR) name(GPR)
graph export GPR_UK.png, as(png) replace

set scheme sj

**# Figure 12. Time-varying parameter plot at horizon t=2 (United Kingdom).

tvpplot, plotcoef(RATE:gpr) plotnhor(2) ///
 plotconst name(figure_2_UK) period(Recession)
graph export figure_2_UK.png, as(png) replace

**# Figure 13. Time-varying parameter plot at horizon t=3 (United Kingdom).

tvpplot, plotcoef(RATE:gpr) plotnhor(15) ///
 plotconst name(figure_15_UK) period(Recession)
graph export figure_15_UK.png, as(png) replace

// Loop

foreach i in 1 2 15 {
 tvpplot, plotcoef(RATE:gpr) plotnhor(`i') ///
 plotconst name(F`i')
 }

// Bonus

****************************************************************

// Summarize the observation to know the degree of freedom
summ RATE impact_gap INF gpr
	
// Display the post-estimation matrices
ereturn list

// Important informations
*number of lags = 2
*sample size for the shortest series = 265
*e(T) =  263 (265-2)
*e(q) =  63 (4 variables*2 lags + 1 constant + 1 y(t) + 1 shock)
*e(beta) :  176 (16x11) x 263

// Start the time-varying plots at the beginging of the sample
display tm(2000m4)
drop if period<483 // After 2 lags for the shortest series
	
// Drop previous estimator paths and lower/upper bounds
cap drop a_* 
cap drop lb_* 
cap drop ub_*
cap drop airf_*
cap drop lbirf_*
cap drop ubirf_*

// Store the time-varying IRF estimates in a matrix and transpose it  
matrix list e(beta)
matrix tvlp_path=e(beta)'

// Put the time-varying IRF estimates in series
svmat double tvlp_path, name(a_) 

// Remove the abbrevation of the variables
set varabbrev off

// Use a loop to plot time-varying IRF
set scheme stcolor
forvalues i = 1(11)166 {
	local graphs `graphs' (tsline a_`i' if a_`i'!=0, legend(off) ///
	title("Time-varying IRF") xtitle("Time") yline(0) ///
	 plotregion(margin(large)))
	}	
graph twoway `graphs', name(TVplots, replace)

// Use a loop to keep the IRFs and drop the other series to save space
forvalues i = 1(11)166 {
	rename a_`i' airf_`i', replace
	}
drop a_*

***************************************************************	

**# Step 2: store the lower bounds

// Store the time-varying IRFs' lower bounds in a matrix and transpose it  
matrix list e(beta_lb)
matrix tvlp_path_lb=e(beta_lb)'

// Put the time-varying IRF estimates in series
svmat double tvlp_path_lb, name(lb_) 

// Remove the abbrevation of the variables
set varabbrev off

// Use a loop to plot time-varying IRF lower bounds
forvalues i = 1(11)166 {
	local graphslb `graphslb' (tsline lb_`i' if lb_`i'!=0, legend(off) ///
	title("Time-varying IRF lower bounds") xtitle("Time") yline(0) ///
	 plotregion(margin(large)))
	}
graph twoway `graphslb', name(TVplots_lb, replace)

// Use a loop to keep the lower bounds and drop the other series to save space
forvalues i = 1(11)166 {
	rename lb_`i' lbirf_`i', replace
	}
drop lb_*


***************************************************************	

**# Step 3: store the upper bounds

// Store the time-varying IRFs' upper bounds in a matrix and transpose it  
matrix list e(beta_ub)
matrix tvlp_path_ub=e(beta_ub)'

// Put the time-varying IRF estimates in series
svmat double tvlp_path_ub, name(ub_) 

// Remove the abbrevation of the variables
set varabbrev off

// Use a loop to plot time-varying IRF upper bounds
set scheme stcolor
forvalues i = 1(11)166 {
	local graphsub `graphsub' (tsline ub_`i' if ub_`i'!=0, legend(off) ///
	title("Time-varying IRF upper bounds") xtitle("Time") yline(0) ///
	 plotregion(margin(large)))	
	}
graph twoway `graphsub', name(TVplots_ub, replace)

// Use a loop to keep the upper bounds and drop the other series to save space
forvalues i = 1(11)166 {
	rename ub_`i' ubirf_`i', replace
	}
drop ub_*
 
// Use the previous informations and change the scheme
*i = i = 1(11)166
set scheme s1mono

// Start a counter that will help us to label the graphs
local x = 0 

// Start the loop for the graphs
forvalues i = 1(11)166 {
	
lab var lbirf_`i' "95% Lower Bound"
lab var airf_`i' "Time-varying parameter"
lab var ubirf_`i' "95% Upper Bound"
lab var gpr "Geopolitical Risk for the the UK"

twoway (tsline lbirf_`i' airf_`i' ubirf_`i' if airf_`i'!=0, ///
 yline(0) lpattern(dash solid dash)) ///
 bar gpr period, yaxis(2) color(blue*0.4%20) ///
 title("Reaction to GPR at Horizon `x'") ///
 legend(order(3 "95% Upper Bound" ///
 2 "Time-varying parameter" 1 "95% Lower Bound" ///
 4 "Geopolitical Risk - UK")) ///
 xti("") ///
 name(TVG_`x', replace)
local ++x
}

// Save the graphs
*forvalues i = 1(11)166 {	
 *gr dis TVplotsENEP_OF_`i'
 *gr export MPplots_gpr_`i'.pdf, as(pdf) replace
 *} 

log close _all
exit

**# End of Program