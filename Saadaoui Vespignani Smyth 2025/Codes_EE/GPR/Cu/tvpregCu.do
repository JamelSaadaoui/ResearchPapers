**# Start of Program for the Time-varying Local Projections

capture log close _all                            
log using tvpregCu, name(tvpregCu) text replace

////////////// Execute the routine //////////////
qui do "tvpreg.ado"
/////////////////////////////////////////////////

*cd C:\Users\jamel\Dropbox\stata\tvpreg\tvpreg\code

set scheme sj

use datasetCu.dta, clear
des

tsset period

foreach v in LGPR GECON LGINF LCu e1 {
    forvalues i = 1(1)12 {
	gen `v'_l`i' = l`i'.`v'
}
}

gen dummyGFC = 0
replace dummyGFC = 1 if period > tm(2009m6)
lab var dummyGFC "Post-GFC"

summ GPR, detail
gen dummyGPR = 0
replace dummyGPR = 1 if GPR > `r(p90)'
lab var dummyGPR "High-GFC"

summ GECON, detail
gen dummyGECON = 0
replace dummyGECON = 1 if GECON < `r(p10)'
lab var dummyGECON "Low-GECON"

///// Estimator II: TVP-LP /////
// Commo price rates to a one-unit geopolitical risk shock (GPR)
mat define cmat = (0,3,6,9,12,15)
tvpreg LCu e1 LGPR_l* GECON_l* LGINF_l* LCu_l* e1_l*, ///
 cmatrix(cmat) nhor(0/48) getband newey chol

tvpplot, plotcoef(LCu:e1) plotconst name(e1_Cu)
graph export e1_Cu.png, as(png) width(4000) replace


matrix tvlp_path=e(beta)
putexcel set GPR_Cu, replace
putexcel A1=matrix(tvlp_path) 
// Line 3025 for horizon 48 in Excel


tvpplot, plotcoef(LCu:e1) plotconst period(dummyGFC) name(GFCTV)
tvpplot, plotcoef(LCu:e1) plotconst period(dummyGPR) name(GPRTV)
tvpplot, plotcoef(LCu:e1) plotconst period(dummyGECON) name(GECONTV)

foreach i in GFCTV GPRTV GECONTV {
 gr dis `i' 
 gr export `i'.png, as(png) width(4000) replace
 }


forvalues i = 1(1)48 {
tvpplot, plotcoef(LCu:e1) plotnhor(`i') ///
 plotconst name(figCu_`i') period(dummyGECON)
 }
 
foreach i in 1 6 12 24 36 48 {
 gr dis figCu_`i'
 gr export figCu_`i'.png, as(png) width(4000) replace
 }

****************************************************************

log close _all
exit

**# End of Program for the Time-varying Local Projections