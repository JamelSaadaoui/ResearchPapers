* Regression analysis for money demand in Viet-Nam
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"		    // Set the directory
capture log close                               
log using an1.smcl, replace

set seed 029350                                 // Random seed 

capture ssc install dynardl                      // Install dynamac

capture net from http://www.marco-sunder.de/stata/
capture net install nardl.pkg                   // Install nardl

capture ssc install vselect                    // Install vselect

regress ln_m2dc ln_ner ln_gdpc_sa ir3

foreach v in ln_m2dc ln_ner ln_gdpc_sa ir3 ln_ner_pos ln_ner_neg {
        
		des `v'

        pperron `v', lags(3)
        dfgls `v', maxlag(4)
				
		
}

foreach v in ln_m2dc ln_ner ln_gdpc_sa ir3 ln_ner_pos ln_ner_neg {
        
		des `v'
		
        pperron D.`v', lags(3)
        dfgls D.`v', maxlag(4)
				
		
}

// Create lags and lagdiffs

foreach v in ln_m2dc ln_ner ln_ner_pos ln_ner_neg ln_gdpc ln_gdpc_sa ///
             ln_gdpc_pos ln_gdpc_neg ir3 ir3_pos ir3_neg {
	    forvalue num=1/11 {
             capture gen L`num'_`v' = L`num'.`v'
}
}

foreach v in ln_m2dc ln_ner ln_ner_pos ln_ner_neg ln_gdpc ln_gdpc_sa ///
             ln_gdpc_pos ln_gdpc_neg ir3 ir3_pos ir3_neg {
		forvalue num=1/11 {	 
             capture gen D_`v' = D.`v'
             capture gen D_L`num'_`v' = D.L`num'_`v'
}
}

// ARDL with optimal lags structure

*varsoc ln_m2dc ln_ner ln_gdpc

/* forvalue x=1/3 {
forvalue y=0/3 {
forvalue z=0/3 {
         regress D.ln_m2dc L.ln_m2dc D.l(1/`x').ln_m2dc ///
         L.ln_gdpc D.l(0/`y').ln_gdpc ///
         L.ln_ner D.l(0/`z').ln_ner
		 estat ic                               
}										  
}
} */

regress D.ln_m2dc L.ln_m2dc D.l(1/6).ln_m2dc ///
L.ln_ner D.l(0/6).ln_ner ///
L.ln_gdpc_sa D.l(0/6).ln_gdpc_sa ///
L.ir3 D.l(0/6).ir3

estat ic                                        // AIC / BIC

vselect D_ln_m2dc ///
L1_ln_m2dc L1_ln_ner L1_ln_gdpc_sa L1_ir3 ///
D_L1_ln_m2dc D_L2_ln_m2dc D_L3_ln_m2dc D_L4_ln_m2dc ///
D_L5_ln_m2dc D_L6_ln_m2dc ///
D_ln_ner D_L1_ln_ner D_L2_ln_ner D_L3_ln_ner D_L4_ln_ner ///
D_L5_ln_ner D_L6_ln_ner ///
D_ln_gdpc_sa D_L1_ln_gdpc_sa D_L2_ln_gdpc_sa D_L3_ln_gdpc_sa ///
D_L4_ln_gdpc_sa D_L5_ln_gdpc_sa D_L6_ln_gdpc_sa  ///
D_ir3 D_L1_ir3 D_L2_ir3 D_L3_ir3 D_L4_ir3 D_L5_ir3 D_L6_ir3  ///
, backward aic                                  //-> Note 1

estat ic                                        // AIC / BIC

test L1_ln_m2dc L1_ln_ner L1_ln_gdpc L1_ir3

// F-stat = 20.13 ; ECM's t-stat = -8.13

pssbounds, fstat(20.13) obs(63) case(3) k(4) tstat(-8.69) // Note 1

estimates store ardl_66_vselect
estimates stats ardl_66_vselect                           // Note 2

// Cusum tests

estat sbcusum, generate(cusumrec_ardl) name(cusumrec_ardl, replace)
capture graph export cusumrec_ardl.png, replace
capture graph export cusumrec_ardl.pdf, replace
*graph close cusumrec

estat sbcusum, ols generate(cusumols_ardl) name(cusumols_ardl, replace)
capture graph export cusumols_ardl.png, replace
capture graph export cusumols_ardl.pdf, replace
*graph close cusumols


// Dynamic Simulations of ARDL Models

set matsize 5000

dynardl ln_m2dc ln_ner ln_gdpc_sa ir3, ///
lags(1, 1, 1, 1) diffs(., ., 1, 1) lagdiffs(2/4, 1/6, 2 3 5 6, 1) ///
shockvar(ln_ner) shockval(-1) ///
time(10) range(60) graph ec rarea sims(1000)
pssbounds                                       // Note 3

// Long run multipliers 

scalar  Lner = - _b[L1_ln_ner] / _b[L1_ln_m2dc]
display Lner
testnl (-1) * _b[L1_ln_ner] / _b[L1_ln_m2dc] = 0

scalar  Lgdp = - _b[L1_ln_gdpc_sa] / _b[L1_ln_m2dc]
display Lgdp
testnl (-1) * _b[L1_ln_gdpc_sa] / _b[L1_ln_m2dc] = 0

scalar  Lir3 = - _b[L1_ir3] / _b[L1_ln_m2dc]
display Lir3
testnl (-1) * _b[L1_ir3] / _b[L1_ln_m2dc] = 0

graph rename ardl_66_dyn, replace
capture graph export ardl_66_dyn.png, replace
capture graph export ardl_66_dyn.pdf, replace

local switches ///
"excel cttop(D.ln_m2dc) pvalue adjr2 e(rmse) addnote(Notes:)"

*ssc install outreg2

outreg2 [ardl_*] using "HOA_strat", replace `switches'

/* shellout HOA_strat */

// Static asymmetric

/* regress ln_m2dc ln_ner_neg ln_ner_pos ln_gdpc_sa
test ln_ner_neg = ln_ner_pos */

// NARDL with one exogenous variable

*varsoc ln_m2dc ln_ner_pos ln_ner_neg, exog(ln_gdpc_pos ln_gdpc_neg)

nardl ln_m2dc ln_ner, deterministic(ln_gdpc_sa ir3) p(2) q(12) ///
horizon(60) residuals plot bootstrap(100) level(95)      
graph rename nardl_212, replace
capture graph export nardl_212.png, replace
capture graph export nardl_212.pdf, replace
graph close nardl_212                            //-> Note 4

graph use "C:\Users\jamel\Dropbox\stata\vn\_nardlplot1.gph"
graph rename dyn_multi_nardl_412, replace
capture graph export nardl_212_dyn.png, replace
capture graph export nardl_212_dyn.pdf, replace

// Restricting some coefficients to zero (for re-named variables): 

// NARDL with long-run coefficients (SR & LR asymmetry)

/* constraint 1 L2._dy L3._dy L4._dy L5._dy L6._dy L7._dy L8._dy L9._dy L10._dy L11._dy
constraint 2 L._dx1n L2._dx1n L3._dx1n L4._dx1n L5._dx1n L6._dx1n L7._dx1n L8._dx1n L9._dx1n L10._dx1n L11._dx1n
constraint 3 L._dx1p L2._dx1p L3._dx1p L4._dx1p L5._dx1p L6._dx1p L7._dx1p L8._dx1p L9._dx1p L10._dx1p L11._dx1p
constraint 4 _dx2n L._dx2n L2._dx2n L3._dx2n L4._dx2n L5._dx2n L6._dx2n L7._dx2n L8._dx2n L9._dx2n L10._dx2n L11._dx2n
constraint 5 _dx2p L._dx2p L2._dx2p L3._dx2p L4._dx2p L5._dx2p L6._dx2p L7._dx2p L8._dx2p L9._dx2p L10._dx2p L11._dx2p
constraint 6 L._dx3n L2._dx3n L3._dx3n L4._dx3n L5._dx3n L6._dx3n L7._dx3n L8._dx3n L9._dx3n L10._dx3n L11._dx3n
constraint 7 L._dx3p L2._dx3p L3._dx3p L4._dx3p L5._dx3p L6._dx3p L7._dx3p L8._dx3p L9._dx3p L10._dx3p L11._dx3p
constraint 8 L1._x2p = L1._x2n
constraint 9 L1._x3p = L1._x3n

nardl ln_m2dc ln_ner ln_gdpc_sa ir3, p(12) q(12) ///
horizon(60) constraint(1 4/9) plot bootstrap(100) level(95)

test (L._y L._x1p L._x1n L._x2p L._x2n L._x3p L._x3n)

pssbounds, fstat(7.66) obs(59) case(3) k(4) tstat(-5.91) */

/* nardl ln_m2dc ln_ner, deterministic(ln_gdpc_sa ir3) p(3) q(12) ///
horizon(60) residuals plot bootstrap(100) level(95) */

// In levels

/* nardl m2dc ner, deterministic(gdpc_sa ir3) p(2) q(12) ///
horizon(60) plot */   


// NARDL with regress

vselect D_ln_m2dc L1_ln_m2dc L1_ln_ner_pos L1_ln_ner_neg ///
ln_gdpc_sa ir3 ///
D_L1_ln_m2dc ///
D_ln_ner_pos D_L1_ln_ner_pos D_L2_ln_ner_pos D_L3_ln_ner_pos ///
D_L4_ln_ner_pos D_L5_ln_ner_pos D_L6_ln_ner_pos D_L7_ln_ner_pos ///
D_L8_ln_ner_pos D_L9_ln_ner_pos D_L10_ln_ner_pos D_L11_ln_ner_pos ///
D_ln_ner_neg D_L1_ln_ner_neg D_L2_ln_ner_neg D_L3_ln_ner_neg ///
D_L4_ln_ner_neg D_L5_ln_ner_neg D_L6_ln_ner_neg D_L7_ln_ner_neg ///
D_L8_ln_ner_neg D_L9_ln_ner_neg D_L10_ln_ner_neg D_L11_ln_ner_neg ///
, backward aic

regress D.ln_m2dc /// 
L.ln_m2dc /// 
L.ln_ner_pos L.ln_ner_neg ///
ln_gdpc_sa ir3 ///
D.l(1).ln_m2dc ///
D.ln_ner_pos ///
D.ln_ner_neg ///
D.l(1/11).ln_ner_pos ///
D.l(1/11).ln_ner_neg

regress D_ln_m2dc L1_ln_m2dc L1_ln_ner_pos L1_ln_ner_neg ///
ln_gdpc_sa ir3 ///
D_L1_ln_m2dc ///
D_ln_ner_pos D_L1_ln_ner_pos D_L2_ln_ner_pos D_L3_ln_ner_pos ///
D_L4_ln_ner_pos D_L5_ln_ner_pos D_L6_ln_ner_pos D_L7_ln_ner_pos ///
D_L8_ln_ner_pos D_L9_ln_ner_pos D_L10_ln_ner_pos D_L11_ln_ner_pos ///
D_ln_ner_neg D_L1_ln_ner_neg D_L2_ln_ner_neg D_L3_ln_ner_neg ///
D_L4_ln_ner_neg D_L5_ln_ner_neg D_L6_ln_ner_neg D_L7_ln_ner_neg ///
D_L8_ln_ner_neg D_L9_ln_ner_neg D_L10_ln_ner_neg D_L11_ln_ner_neg

scalar  Lgdp = - _b[ln_gdpc_sa] / _b[L1_ln_m2dc]
display Lgdp
testnl (-1) * _b[ln_gdpc_sa] / _b[L1_ln_m2dc] = 0

scalar  Lir3 = - _b[ir3] / _b[L1_ln_m2dc]
display Lir3
testnl (-1) * _b[ir3] / _b[L1_ln_m2dc] = 0

estimates store nardl_212
estimates stats nardl_212

test L1_ln_m2dc /// 
L1_ln_ner_pos L1_ln_ner_neg

// F-stat = 11.27 ; ECM's t-stat = -5.72
pssbounds, fstat(11.27) obs(58) case(3) k(3) tstat(-5.72)

local switches ///
"excel cttop(D.ln_m2dc) pvalue adjr2 e(rmse) addnote(Notes:)"

outreg2 [nardl_*] using "HOA1_strat", replace `switches'

/* shellout HOA1_strat */

// Cusum tests

estat sbcusum, generate(cusumrec_nardl) name(cusumrec_nardl, replace)
capture graph export cusumrec_nardl.png, replace
capture graph export cusumrec_nardl.pdf, replace
*graph close cusumrec

estat sbcusum, ols generate(cusumols_nardl) name(cusumols_nardl, replace)
capture graph export cusumols_nardl.png, replace
capture graph export cusumols_nardl.pdf, replace
*graph close cusumols


// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_an1.dta", ///
replace

log close
exit

Description
-----------

This is an analysis of money demand in Viet-Nam. The asymmetric
effect of exchange rate variations are captured thanks to an ARDL model.
We follow the intuition of R. Mundell that adds to the canonical ISLM 
money demand, the exhange rate. Our objective is to determine whether 
depreciations and appreciations have different effects in the short 
and / or in the long run for the Vietnamese economy.


Notes :
-------

1) Allow up to 6 lags. Based on the small-sample F-statistics, we have
    relatively strong evidence of cointegration. T-test values are not 
    precisely tailored for small samples.
2) To produce the Akaike information criterion and the Bayesian 
	information criterion.
3) The pssbounds test can be run as a post estimation command.
4) Best NARDL model based on the lowest RMSE.