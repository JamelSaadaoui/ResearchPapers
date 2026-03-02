capture log close _all                            
log using lp, name(lp) text replace


import excel "datav2.xlsx", sheet("Sheet1") firstrow clear

destring UCT, replace

**#**** Partisan shock *****************************************

**# PCI:UCT

summ

display tm(1993m1)

gen time = 396+ _n-1

format %tm time

tsset time

set scheme stcolor


labvars UCT WIP GECON BRENT PCI EIA_PROD WTI IGREA  ///
 "US-China Tensions" ///
 "World Industrial Production" ///
 "Global Economic Condition" ///
 "Global Price of Brent Crude" ///
 "Partisan Conflict Index" ///
 "Global Oil Production" ///
 "Global Price of WTI Crude" ///
 "Index of Global Real Economic Activity"
 
twoway (tsline BRENT WTI) ///
 (tsline UCT, yaxis(2) legend(pos(6) ring(1) ///
  cols(2) size(small))), ///
 xtitle("") name(G1, replace)
graph export G1.png, as(png) width(3000) replace

twoway ///
 (tsline UCT PCI, yaxis(2) legend(pos(6) ring(1) ///
  cols(2) size(small)) graphregion(margin(r+5))), ///
 xtitle("") name(G1A, replace)
graph export G1A.png, as(png) width(3000) replace

replace IGREA=IGREA/100

twoway (tsline GECON IGREA, yline(0))  ///
 (tsline EIA_PROD WIP , yaxis(2) legend(pos(6) ring(1) ///
  cols(2) size(small))), ///
 xtitle("") name(G2, replace)
graph export G2.png, as(png) width(3000) replace

// Descriptive statistics

summarize UCT WIP GECON BRENT PCI EIA_PROD WTI IGREA
global X UCT WIP GECON BRENT PCI EIA_PROD WTI IGREA
outreg2 using x.doc, replace sum(log) keep($X)

// Scapegoat theory: Rise in Political disagreement in the US → Rise in US-China tensions to win the election in the US.

// PCI -> UCT
  
irf set comparemodels.irf, replace
quietly lpirf BRENT GECON EIA_PROD UCT, step(41) lags(1/2) ///
  exog(L(0/1).PCI) 
  
irf create LP 

irf graph dm, impulse(PCI) response(BRENT)   ///
  irf(LP) yline(0) name(G3, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3.png, as(png) width(3000) replace

irf graph dm, impulse(PCI) response(UCT)   ///
  irf(LP) yline(0) name(G3A, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3A.png, as(png) width(3000) replace

graph combine G3 G3A, ycommon name(G3B, replace)
graph export G3B.png, as(png) width(3000) replace
   
// WTI

irf set comparemodels.irf, replace
quietly lpirf WTI GECON EIA_PROD UCT, step(41) lags(1/2) ///
  exog(L(0/1).PCI)
  
irf create LP 

irf graph dm, impulse(PCI) response(WTI)   ///
  irf(LP) yline(0) name(G4, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G4.png, as(png) width(3000) replace

irf graph dm, impulse(PCI) response(UCT)   ///
  irf(LP) yline(0) name(G4A, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G4A.png, as(png) width(3000) replace

graph combine G4 G4A, ycommon name(G4B, replace)
graph export G4B.png, as(png) width(3000) replace
   
// Extended Lags
   
irf set comparemodels.irf, replace
quietly lpirf BRENT GECON EIA_PROD UCT  , step(41) lags(1/12) ///
  exog(L(0/1).PCI)
  
irf create LP 

irf graph dm, impulse(PCI) response(BRENT)   ///
  irf(LP) yline(0) name(G3R, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3R.png, as(png) width(3000) replace

irf graph dm, impulse(PCI) response(UCT)   ///
  irf(LP) yline(0) name(G3RA, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3RA.png, as(png) width(3000) replace

graph combine G3R G3RA, ycommon name(G3B, replace)
graph export G3RB.png, as(png) width(3000) replace

// WIP

irf set comparemodels.irf, replace
quietly lpirf BRENT WIP EIA_PROD UCT  , step(41) lags(1/2) ///
  exog(L(0/1).PCI)
  
irf create LP 

irf graph dm, impulse(PCI) response(BRENT)   ///
  irf(LP) yline(0) name(G3R1, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3R1.png, as(png) width(3000) replace

irf graph dm, impulse(PCI) response(UCT)   ///
  irf(LP) yline(0) name(G3R1A, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3R1A.png, as(png) width(3000) replace

graph combine G3R1 G3R1A, ycommon name(G3R1B, replace)
graph export G3R1B.png, as(png) width(3000) replace

// REA

irf set comparemodels.irf, replace
quietly lpirf BRENT IGREA EIA_PROD UCT  , step(41) lags(1/2) ///
  exog(L(0/1).PCI)
  
irf create LP 

irf graph dm, impulse(PCI) response(BRENT)   ///
  irf(LP) yline(0) name(G3R2, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3R2.png, as(png) width(3000) replace

irf graph dm, impulse(PCI) response(UCT)   ///
  irf(LP) yline(0) name(G3R2A, replace) ///
   xlabel(0(10)40) level(90) ylab(#10) byopts(note(""))
graph export G3R2A.png, as(png) width(3000) replace

graph combine G3R2 G3R2A, ycommon name(G3R2B, replace)
graph export G3R2B.png, as(png) width(3000) replace


// Threat-unity theory: Rise in US-China tensions → Reduction in Political disagreement in the US due to a rally around the flag effect.
   
irf set comparemodels.irf, replace
quietly lpirf BRENT GECON EIA_PROD PCI  , step(41) lags(1/2) ///
  exog(L(0/1).UCT)
irf create LP1 

irf graph dm, impulse(UCT) response(BRENT PCI)   ///
  irf(LP1) yline(0) name(G4, replace) ///
   xlabel(0(10)40) level(90) ylab(#10)
graph export G4.png, as(png) width(3000) replace
   
// WTI

irf set comparemodels.irf, replace
quietly lpirf WTI GECON EIA_PROD PCI  , step(41) lags(1/2) ///
  exog(L(0/1).UCT)
  
irf create LP1 

irf graph dm, impulse(UCT) response(WTI PCI)   ///
  irf(LP1) yline(0) name(G4A, replace) ///
   xlabel(0(10)40) level(90) ylab(#10)
graph export G4A.png, as(png) width(3000) replace
   
// Extended Lags

irf set comparemodels.irf, replace
quietly lpirf BRENT GECON EIA_PROD PCI  , step(41) lags(1/12) ///
  exog(L(0/1).UCT) 
irf create LP1 

irf graph dm, impulse(UCT) response(BRENT PCI)   ///
  irf(LP1) yline(0) name(G4R, replace) ///
   xlabel(0(10)40) level(90) ylab(#10)
graph export G4R.png, as(png) width(3000) replace

// WIP

irf set comparemodels.irf, replace
quietly lpirf BRENT WIP EIA_PROD PCI  , step(41) lags(1/2) ///
  exog(L(0/1).UCT)
  
irf create LP 

irf graph dm, impulse(UCT) response(BRENT PCI)   ///
  irf(LP) yline(0) name(G4R1, replace) ///
   xlabel(0(10)40) level(90) ylab(#10)
graph export G4R1.png, as(png) width(3000) replace

// REA

irf set comparemodels.irf, replace
quietly lpirf BRENT IGREA EIA_PROD PCI  , step(41) lags(1/2) ///
  exog(L(0/1).UCT)
  
irf create LP 

irf graph dm, impulse(UCT) response(BRENT PCI)   ///
  irf(LP) yline(0) name(G4R2, replace) ///
   xlabel(0(10)40) level(90) ylab(#10)
graph export G4R2.png, as(png) width(3000) replace

keep UCT WIP GECON BRENT PCI EIA_PROD WTI IGREA time

save dataset25march.dta, replace

****************************************************************

var PCI UCT, lags(1)

varstable, graph

*varsoc

vargranger

irf create VAR1, ///
 set(example1) step(50) replace

irf graph irf, irf(VAR1) ///
 name(irf, replace)
 
graph export irf.png, as(png) width(3000) replace

****************************************************************

log close _all

exit