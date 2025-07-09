**# Start of Program for the Time-varying Local Projections

capture log close _all                            
log using tvpregPt, name(tvpregPt) text replace

////////////// Execute the routine //////////////
qui do "tvpreg.ado"
/////////////////////////////////////////////////

*cd C:\Users\jamel\Dropbox\stata\tvpreg\tvpreg\code

set scheme sj

use datasetPt.dta, clear
des

tsset period

foreach v in LGPR GECON LGINF LPt e1 {
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
tvpreg LPt e1 LGPR_l* GECON_l* LGINF_l* LPt_l* e1_l*, ///
 cmatrix(cmat) nhor(0/48) getband newey chol

tvpplot, plotcoef(LPt:e1) plotconst name(e1_Pt)
graph export e1_Pt.png, as(png) width(4000) replace

matrix tvlp_path=e(beta)
putexcel set GPR_Pt, replace
putexcel A1=matrix(tvlp_path) 
// Line 3025 (63*48, TV param*horizon) for horizon 48 in Excel


tvpplot, plotcoef(LPt:e1) plotconst period(dummyGFC) name(GFCTV)
tvpplot, plotcoef(LPt:e1) plotconst period(dummyGPR) name(GPRTV)
tvpplot, plotcoef(LPt:e1) plotconst period(dummyGECON) name(GECONTV)

foreach i in GFCTV GPRTV GECONTV {
 gr dis `i' 
 gr export `i'.png, as(png) width(4000) replace
 }


forvalues i = 1(1)48 {
tvpplot, plotcoef(LPt:e1) plotnhor(`i') ///
 plotconst name(figPt_`i') period(dummyGECON)
 }
 
foreach i in 1 6 12 24 36 48 {
 gr dis figPt_`i'
 gr export figPt_`i'.png, as(png) width(4000) replace
 }

****************************************************************

log close _all
exit

**# End of Program for the Time-varying Local Projections