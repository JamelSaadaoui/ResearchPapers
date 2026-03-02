**# Start of Program for the Time-varying Local Projections

capture log close _all                            
log using tvpreg, name(tvpregO) text replace

////////////// Execute the routine //////////////
qui do "tvpreg.ado"
/////////////////////////////////////////////////

*cd C:\Users\jamel\Dropbox\stata\tvpreg\tvpreg\code

set scheme sj

use dataset25march.dta, clear
des

tsset time

foreach v in ///
       BRENT GECON EIA_PROD UCT PCI {
    forvalues i = 1(1)2 {
	gen `v'_l`i' = l`i'.`v'
}
}


///// Estimator II: TVP-LP /////
// Commo price rates to a one-unit geopolitical risk shock (GPR)
mat define cmat = (0,3,6,9,12,15)
tvpreg BRENT PCI GECON_l* EIA_PROD_l* UCT_l* BRENT_l*, ///
 cmatrix(cmat) nhor(0/40) getband newey chol level(95)

tvpplot, plotcoef(BRENT:PCI) plotconst name(BRENT_PCI) ///
 title(Time-varying IRF at different horizons)
graph export BRENT_PCI.pdf, as(pdf) replace
graph export BRENT_PCI.png, as(png) replace

forvalues i = 40(1)40 {
tvpplot, plotcoef(BRENT:PCI) plotnhor(`i') ///
 name(figtvp_`i')  title(Time-varying coefficients at Horizon `i')
 }
 
