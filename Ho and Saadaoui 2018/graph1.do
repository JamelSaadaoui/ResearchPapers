* Plot the dynamic multipliers for the ARDL models
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"		    // Set the directory
capture log close                               
log using graph1.smcl, replace


use "C:\Users\jamel\Dropbox\stata\vn\dynardl_results.dta", clear 

/* twoway rarea ll_95 ul_95 time || rarea ll_90 ul_90 time ///
|| rarea ll_75 ul_75 time|| line mean time, legend(off) /// 
ytitle("Predicted Value") xtitle("Time") lpattern(longdash dot) ///
lwidth(medium) xlabel(,grid) */

twoway rarea ll_95 ul_95 time, color(gs12) ///
|| line mean time, title(Symmetric effect of NER on M2D) ///
legend( label(1 "95% CI") label(2 "NER variation") ///
position(3) rows(2) ) ytitle("Predicted Value") xtitle("Time") ///
lpattern(longdash dot) lwidth(medium) xlabel(,grid)

graph rename dyn_ardl_aic_sj, replace
capture graph export dyn_ardl_aic_sj.png, replace
capture graph export dyn_ardl_aic_sj.pdf, replace


// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_graph1.dta", ///
replace

log close
exit

Description
-----------

These graphs aim at ...


Notes :
-------

1) ...