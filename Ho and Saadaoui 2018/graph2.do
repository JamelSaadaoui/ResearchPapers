* Plot the dynamic multipliers for the NARDL models
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"		    // Set the directory
capture log close                               
log using graph2.smcl, replace

use "C:\Users\jamel\Dropbox\stata\vn\data_an1.dta", clear

set scheme sj

nardl ln_m2dc ln_ner, deterministic(ln_gdpc_sa ir3) p(2) q(12) ///
horizon(60) residuals plot bootstrap(100) level(95)

matrix list e(nardl_cdm)

matrix nardl_var=e(nardl_cdm)
svmat double nardl_var, name(x)                 //-> Note 1
list x1 in 1/5
list x2 in 1/5
list x3 in 1/5
/* list x4 in 1/5
list x5 in 1/5 */                               // With 2 exo. regressors

matrix list e(nardl_asym)

matrix nardl_asym=e(nardl_asym)
svmat double nardl_asym, name(asym)
list asym1 in 1/5
list asym2 in 1/5
/* list asym3 in 1/5 */                         // With 2 exo. regressors

matrix list e(nardl_asym_qu)

matrix asym_qu=e(nardl_asym_qu)
svmat double asym_qu, name(upperbound)
list upperbound1 in 1/5
list upperbound2 in 1/5
/* list upperbound3 in 1/5 */                   // With 2 exo. regressors

matrix list e(nardl_asym_ql)

matrix asym_ql=e(nardl_asym_ql)
svmat double asym_ql, name(lowerbound)
list lowerbound1 in 1/5
list lowerbound2 in 1/5
/* list lowerbound3 in 1/5 */                   // With 2 exo. regressors

/* twoway rarea asym_ql1 asym_qu1 horizon, col("210 220 235") || ///
scatter x1p horizon, c(l) ms(i) lpattern(dash) lc("0 160 60") || ///
|| scatter x1n horizon, c(l) ms(i) lpattern(longdash) lc("160 0 60") || ///
|| scatter asym1 horizon, c(l) ms(i) lpattern(solid) lc("0 0 160") || ///
, title("Cumulative effect of LN_NER on LN_M2DC") ///
note(`"Note: 95% bootstrap CI is based on 100 replications"') ///
xlabel(,grid) ylabel(,grid) legend(region(lwidth(none)) ///
cols(2) order("2 3 4 1") label(1 "CI for asymmetry")) */

label variable x2 "Positive change"
label variable x3 "Negative change"
label variable asym2 "Asymmetry"

// twoway rarea lowerbound2 upperbound2 lowerbound1, color(gs12)|| ///
// scatter x2 x1, c(l) ms(i) lpattern(dash) || ///
// || scatter x4 x1, c(l) ms(i) lpattern(longdash) || /// 
// || scatter asym2 asym1, c(l) ms(i) lpattern(solid) || ///
// , title("Cumulative effect of LN_NER on LN_M2DC") ///
// note(`"Note: 95% bootstrap CI is based on 100 replications"') ///
// xlabel(,grid) ylabel(,grid) legend(region(lwidth(none)) ///
// cols(2) order("2 3 4 1") label(1 "CI for asymmetry"))

twoway rarea lowerbound2 upperbound2 lowerbound1, color(gs12)|| ///
scatter x2 x1, c(l) ms(i) lpattern(shortdash) || ///
|| scatter x3 x1, c(l) ms(i) lpattern(longdash) || /// 
|| scatter asym2 asym1, c(l) ms(i) lpattern(solid) || ///
, title(Asymmetric effect of NER on M2D) ///
legend( label(1 "CI asymmetry") label(2 "Pos. change") ///
label(3 "Neg. change") label(4 "Asymmetry") position(3) rows(4) ) ///
ytitle("Predicted Value") xtitle("Time") xlabel(,grid) ylabel(,grid)

graph rename dyn_nardl_aic_sj, replace
capture graph export dyn_nardl_aic_sj.png, replace
capture graph export dyn_nardl_aic_sj.pdf, replace

graph combine dyn_ardl_aic_sj dyn_nardl_aic_sj, ///
xcommon cols(1) imargin(zero)
graph rename dyn_ardl_nardl_aic_sj, replace
capture graph export dyn_ardl_nardl_aic_sj.png, replace
capture graph export dyn_ardl_nardl_aic_sj.pdf, replace
graph export dyn_ardl_nardl_aic_sj.svg, width(4000) replace


// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_graph2.dta", ///
replace

log close
exit

Description
-----------

These graphs aim at ...


Notes :
-------

1) The svmat command...