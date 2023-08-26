*  Stepwise regression analysis for money demand in Viet-Nam
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"		    // Set the directory
capture log close                               
log using an2.smcl, replace

capture ssc install actest                  //-> Note 1

// ARDL 

regress D.ln_m2dc L.ln_m2dc D.l(2/4).ln_m2dc ///
L.ln_ner D.l(1/6).ln_ner ///
L.ln_gdpc_sa D.l(0 2 3 5 6).ln_gdpc_sa ///
L.ir3 D.l(0 1).ir3

capture predict fitted_ardl
capture predict r_ardl, residuals 

twoway (tsline d.ln_m2dc) (tsline fitted_ardl)

// Normality of residuals

sktest r_ardl
swilk r_ardl
sfrancia r_ardl

qnorm r_ardl
graph rename qnorm_ardl, replace
capture graph export qnorm_ardl.png, replace
capture graph export qnorm_ardl.pdf, replace
graph close qnorm_ardl

pnorm r_ardl
graph rename pnorm_ardl, replace
capture graph export pnorm_ardl.png, replace
capture graph export pnorm_ardl.pdf, replace
graph close pnorm_ardl

histogram r_ardl, frequency addlabel normal
graph rename normality_ardl, replace
capture graph export normality_ardl.png, replace
capture graph export normality_ardl.pdf, replace


// Autocorrelation of residuals

estat dwatson
estat durbinalt
estat durbinalt, lags(1/6)
estat durbinalt, lags(1/6) small

estat bgodfrey, lags(1/6)
estat bgodfrey, lags(1/6) nomiss0 small

// Autocorrelation of residuals: Q-stat

forvalues y = 1/12 {              
        wntestq r_ardl, lags(`y')
}
// Cumby–Huizinga (C-H) test statistic

actest r_ardl, lags(6) small
actest r_ardl, lags(6) bp small


// Heteroscedasticity of residuals

estat imtest, white
estat hettest
estat archlm, lags(1/6)

// NARDL

regress D.ln_m2dc /// 
L.ln_m2dc /// 
L.ln_ner_pos L.ln_ner_neg ///
ln_gdpc_sa ir3 ///
D.l(1).ln_m2dc ///
D.ln_ner_pos ///
D.ln_ner_neg ///
D.l(1/11).ln_ner_pos ///
D.l(1/11).ln_ner_neg

capture predict fitted_nardl
capture predict r_nardl, residuals 

twoway (tsline d.ln_m2dc) (tsline fitted_ardl)

// Normality of residuals

sktest r_nardl
swilk r_nardl
sfrancia r_nardl

qnorm r_nardl
graph rename qnorm_nardl, replace
capture graph export qnorm_nardl.png, replace
capture graph export qnorm_nardl.pdf, replace
graph close qnorm_nardl

pnorm r_nardl
graph rename pnorm_nardl, replace
capture graph export pnorm_nardl.png, replace
capture graph export pnorm_nardl.pdf, replace
graph close pnorm_nardl

histogram r_nardl, frequency addlabel normal
graph rename normality_nardl, replace
capture graph export normality_nardl.png, replace
capture graph export normality_nardl.pdf, replace


// Autocorrelation of residuals

estat dwatson
estat durbinalt
estat durbinalt, lags(1/12)
estat durbinalt, lags(1/12) small

estat bgodfrey, lags(1/12)
estat bgodfrey, lags(1/12) nomiss0 small

// Autocorrelation of residuals: Q-stat

forvalues y = 1/12 {              
        wntestq r_nardl, lags(`y')
}

// Cumby–Huizinga (C-H) test statistic

actest r_nardl, lags(12) small
actest r_nardl, lags(12) bp small

// Heteroscedasticity of residuals

estat imtest, white
estat hettest
estat archlm, lags(1/12)

// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_an2.dta", ///
replace

log close
exit

Description
-----------

These stepwise regressions aims at checking the validity of the chosen
lag structure for the ARDL and NARDL models.


Notes :
-------

1) The actest command offers a more versatile framework for 
	auto-correlation testing.
	* https://www.stata.com/meeting/new-orleans13/abstracts
	* /materials/nola13-baum.pdf
2) ...