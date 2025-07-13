**#  Analysing US-CHN tensions on oil price
*---------------------------------------------------------------

cls
clear

set scheme stcolor

version 18.0
*set more off

// Please change the path with your own folder

cd "C:\Users\jamel\Dropbox\latex\PROJECTS"
cd "23-05-geopolitical-risk-pol-tension-oil-price"
cd "Data and command\Codes_EE"

capture log close                               
log using lpirf_PRI_GPR_EE.smcl, replace

import excel .\data_svar.xlsx,/*
*/ sheet("data") firstrow clear

generate Period = tm(1960m1) + _n-1
format %tm Period

drop if Period > tm(2019m12)

label variable pri "Political Relationship Index"
label variable pri_s "PRI Standardized"
label variable gop "Global Oil Production"
label variable rspri "Real Spot Price"
label variable wip "World Industrial Production"
label variable dinv "Variation of Inventories"
label variable gprcn ///
	  "Percent of Articles on China in the Bil. GPR"
label variable igrea ///
	  "Index of Global Real Economic Activity"
	  
rename gop pro
rename wip dem
rename rspri rpo

capture generate lpro = log(pro)
la var lpro "Natural log of PRO"
capture generate lrpo = log(rpo)
la var lrpo "Natural log of RPO"
capture generate ldem = log(dem)
la var ldem "Natural log of DEM"

drop t
order Period, first

/* Another transformation for the PRI index */
gen lpri = sign(pri) * log(1 + abs(pri))

label variable lpri "Political Relationship Index"

gen ligrea = sign(igrea) * log(1 + abs(igrea))

label variable ligrea "Global Real Economic Activity"

summarize lpri lpro ldem lrpo gprcn ligrea if Period>tm(2000m1)
/*
outreg2   using sum.doc if Period>tm(2000m1), replace sum(log) ///
          keep(lpri lpro ldem lrpo gprcn) dec(3)
*/

**#  Declare time series

tsset Period, monthly

save database_pri_gpr.dta, replace

twoway (tsline lpri if Period>tm(2000m1)) ///
       (tsline gprcn if Period>tm(2000m1), yaxis(2)), ///
	   name(G0, replace) legend(off)
	   
graph export "G0.svg", as(svg) replace
graph export "G0.pdf", as(pdf) replace
graph export "G0.png", as(png) width(4000) replace
	   
matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

svar lpri lpro ldem lrpo if Period>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var lpri lpro ldem lrpo if Period>tm(2000m1)
capture drop epsilon*
predict double epsilon1 if Period>tm(2000m1),residual eq(#1)
predict double epsilon2 if Period>tm(2000m1),residual eq(#2)
predict double epsilon3 if Period>tm(2000m1),residual eq(#3)
predict double epsilon4 if Period>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat epsilon*, matrix(epsilon) 
/* compute e_t matrix of structural shocks */
matrix e = (BA*epsilon')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double e

label variable epsilon1 "Reduced-form shocks - PRI"
label variable e1 "Structural shocks - PRI"

twoway (tsline e1 if Period>tm(2000m1)) (tsline epsilon1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G1, replace) legend(position(6)) graphregion(margin(r+5))
 
graph export "G1.svg", as(svg) replace
graph export "G1.png", as(png) width(4000) replace
graph export "G1.pdf", as(pdf) replace

irf set comparemodels.irf, replace

lpirf lpro ldem lrpo, step(48) lags(1/24) ///
  exog(L(0/24).e1) vce(robust)
irf create lpmodel 

var lpro ldem lrpo, lags(1/24)            ///
  exog(L(0/24).e1)
irf create varmodel, step(48)

irf graph dm, impulse(e1) response(lrpo)   ///
  irf(lpmodel varmodel) level(95) name(G2, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) yline(-.05 0 .05 .1, lcolor(blue))

graph export "G2.svg", replace
graph export "G2.png", as(png) width(4000) replace
graph export "G2.pdf", as(pdf) replace

/* GPR */

matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

svar gprcn lpro ldem lrpo if Period>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var gprcn lpro ldem lrpo if Period>tm(2000m1)
capture drop epsilon_*
predict double epsilon_1 if Period>tm(2000m1),residual eq(#1)
predict double epsilon_2 if Period>tm(2000m1),residual eq(#2)
predict double epsilon_3 if Period>tm(2000m1),residual eq(#3)
predict double epsilon_4 if Period>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat epsilon_*, matrix(epsilon_) 
/* compute e_t matrix of structural shocks */
matrix e_ = (BA*epsilon_')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double e_

label variable epsilon_1 "Reduced-form shocks - GPR"
label variable e_1 "Structural shocks - GPR"

twoway (tsline e_1 if Period>tm(2000m1)) (tsline epsilon_1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G3, replace) legend(position(6)) graphregion(margin(r+5))

graph export "G3.svg", as(svg) replace
graph export "G3.png", as(png) width(4000) replace
graph export "G3.pdf", as(pdf) replace

irf set comparemodels1.irf, replace
quietly lpirf lpro ldem lrpo, step(48) lags(1/24) ///
  exog(L(0/24).e_1) vce(robust)
irf create lpmodel1

quietly var lpro ldem lrpo, lags(1/24)            ///
  exog(L(0/24).e_1)
irf create varmodel1, step(48)

irf graph dm, impulse(e_1) response(lrpo)   ///
  irf(lpmodel1 varmodel1) level(95) name(G4, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) yline(-.05 0 .05 .1, lcolor(blue))

graph export "G4.svg", replace
graph export "G4.png", as(png) width(4000) replace
graph export "G4.pdf", as(pdf) replace

twoway (tsline e1 if Period>tm(2000m1)) (tsline e_1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G5, replace) legend(position(6)) graphregion(margin(r+5))

graph export "G5.svg", replace
graph export "G5.png", as(png) width(4000) replace
graph export "G5.pdf", as(pdf) replace

pwcorr lrpo e1 e_1, obs sig listwise star(5) sidak

twoway (scatter lrpo e1) (lfit lrpo e1), name(G6, replace)
graph export "G6.svg", replace
graph export "G6.png", as(png) width(4000) replace
graph export "G6.pdf", as(pdf) replace

twoway (scatter lrpo e_1) (lfit lrpo e_1), name(G7, replace)
graph export "G7.svg", replace
graph export "G7.png", as(png) width(4000) replace
graph export "G7.pdf", as(pdf) replace

save lpirf_PRI_GPR, replace

****************************************************************
**# Robustness with IGREA **************************************
****************************************************************

matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

svar lpri lpro ligrea lrpo if Period>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var lpri lpro ligrea lrpo if Period>tm(2000m1)
capture drop upsilon*
predict double upsilon1 if Period>tm(2000m1),residual eq(#1)
predict double upsilon2 if Period>tm(2000m1),residual eq(#2)
predict double upsilon3 if Period>tm(2000m1),residual eq(#3)
predict double upsilon4 if Period>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat upsilon*, matrix(upsilon) 
/* compute e_t matrix of structural shocks */
matrix u = (BA*upsilon')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double u

label variable upsilon1 "Reduced-form shocks - PRI (Robustness)"
label variable u1 "Structural shocks - PRI (Robustness)"

twoway (tsline u1 if Period>tm(2000m1)) (tsline upsilon1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G1R, replace) legend(position(6)) graphregion(margin(r+5))
 
graph export "G1R.svg", replace
graph export "G1R.png", as(png) width(4000) replace
graph export "G1R.pdf", as(pdf) replace
 
irf set comparemodels.irf, replace
quietly lpirf lpro ligrea lrpo, step(48) lags(1/24) ///
  exog(L(0/24).u1) vce(robust)
irf create lpmodel 

quietly var lpro ligrea lrpo, lags(1/24)            ///
  exog(L(0/24).u1)
irf create varmodel, step(48)

irf graph dm, impulse(u1) response(lrpo)   ///
  irf(lpmodel varmodel) level(95) name(G2R, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) yline(-.05 0 .05 .1, lcolor(blue))

graph export "G2R.svg", replace
graph export "G2R.png", as(png) width(4000) replace
graph export "G2R.pdf", as(pdf) replace

/* GPR */

matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

svar gprcn lpro ligrea lrpo if Period>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var gprcn lpro ligrea lrpo if Period>tm(2000m1)
capture drop epsilon_*
predict double upsilon_1 if Period>tm(2000m1),residual eq(#1)
predict double upsilon_2 if Period>tm(2000m1),residual eq(#2)
predict double upsilon_3 if Period>tm(2000m1),residual eq(#3)
predict double upsilon_4 if Period>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat upsilon_*, matrix(upsilon_) 
/* compute e_t matrix of structural shocks */
matrix u_ = (BA*upsilon_')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double u_

label variable upsilon_1 "Reduced-form shocks - GPR (Robustness)"
label variable u_1 "Structural shocks - GPR (Robustness)"

twoway (tsline u_1 if Period>tm(2000m1)) (tsline upsilon_1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G3R, replace) legend(position(6)) graphregion(margin(r+5))

graph export "G3R.svg", as(svg) replace
graph export "G3R.png", as(png) width(4000) replace
graph export "G3R.pdf", as(pdf) replace

irf set comparemodels1.irf, replace
quietly lpirf lpro ligrea lrpo, step(48) lags(1/24) ///
  exog(L(0/24).u_1) vce(robust)
irf create lpmodel1

quietly var lpro ligrea lrpo, lags(1/24)            ///
  exog(L(0/24).u_1)
irf create varmodel1, step(48)

irf graph dm, impulse(u_1) response(lrpo)   ///
  irf(lpmodel1 varmodel1) level(95) name(G4R, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) yline(-.05 0 .05 .1, lcolor(blue))

graph export "G4R.svg", replace
graph export "G4R.png", as(png) width(4000) replace
graph export "G4R.pdf", as(pdf) replace

twoway (tsline u1 if Period>tm(2000m1)) (tsline u_1 ///
if Period>tm(2000m1), yaxis(1)), ///
 name(G5R, replace) legend(position(6)) graphregion(margin(r+5))

graph export "G5R.svg", replace
graph export "G5R.png", as(png) width(4000) replace
graph export "G5R.pdf", as(pdf) replace

pwcorr lrpo u1 u_1, obs sig listwise star(5) sidak

twoway (scatter lrpo u1) (lfit lrpo u1), name(G6R, replace)
graph export "G6R.svg", replace
graph export "G6R.png", as(png) width(4000) replace
graph export "G6R.pdf", as(pdf) replace

twoway (scatter lrpo u_1) (lfit lrpo u_1), name(G7R, replace)
graph export "G7R.svg", replace
graph export "G7R.png", as(png) width(4000) replace
graph export "G7R.pdf", as(pdf) replace

**#************* Expectations **********************************

use database_pri_gpr.dta, clear

merge 1:1 Period using expectations

drop _merge

// PRI ----> Expectations

graph drop _all

sum BCI CLI CCI lpri 

tvgc CCI lpri, trend window(80) sizecontrol(60) p(2)     ///
 d(1) seed(123) boot(499) robust prefix(CCI) graph pdf   ///
 notitle
 
tvgc BCI lpri, trend window(80) sizecontrol(60) p(2)      ///
 d(1) seed(123) boot(499) robust prefix(BCI) graph pdf    ///
 notitle
 
tvgc CLI lpri, trend window(80) sizecontrol(60) p(2)      ///
 d(1) seed(123) boot(499) robust prefix(CLI) graph pdf    ///
 notitle

// GPRCN ----> Expectations 
 
sum BCI CLI CCI gprcn 
 
tvgc CCI gprcn, trend window(80) sizecontrol(40) p(2)     ///
 d(1) seed(123) boot(499) robust prefix(CCI) graph pdf    ///
 notitle
 
tvgc BCI gprcn, trend window(80) sizecontrol(40) p(2)     ///
 d(1) seed(123) boot(499) robust prefix(BCI) graph pdf    ///
 notitle
 
tvgc CLI gprcn, trend window(80) sizecontrol(40) p(2)     ///
 d(1) seed(123) boot(499) robust prefix(CLI) graph pdf    ///
 notitle
 
save database_pri_gpr_final.dta, replace

log close _all

/*
lpirf lpri lpro ldem lrpo if Period>tm(2000m1), lags(1/24) step(48)
irf set myirfs.irf, replace
irf create modelbaum
irf graph oirf, individual iname(baum, replace) yline(0)

lpirf lpri lpro ligrea lrpo if Period>tm(2000m1), lags(1/24) step(48)
irf set myirfs.irf, replace
irf create modelkil
irf graph oirf, individual iname(kil, replace) yline(0)
*/

exit