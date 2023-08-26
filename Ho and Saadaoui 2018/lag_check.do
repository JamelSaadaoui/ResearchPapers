* Checking the lag order in the ARDL and NARDL models 
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"			    // Set the directory
capture log close                               
log using lag_check.log, replace


// Checking lag orders for the ARDL model

forvalue x=1/11 {
         regress D.ln_m2dc L.ln_m2dc D.l(1/`x').ln_m2dc ///
         L.ln_ner D.l(0/`x').ln_ner ///
		 L.ln_gdpc D.l(0/`x').ln_gdpc ///
		 L.ir3 D.l(0/`x').ir3
		 estat ic                               //-> Note 1						  
}                                               

vselect D_ln_m2dc ///
L1_ln_m2dc L1_ln_ner L1_ln_gdpc_sa L1_ir3 ///
D_L1_ln_m2dc D_L2_ln_m2dc D_L3_ln_m2dc D_L4_ln_m2dc ///
D_L5_ln_m2dc D_L6_ln_m2dc ///
D_ln_ner D_L1_ln_ner D_L2_ln_ner D_L3_ln_ner D_L4_ln_ner ///
D_L5_ln_ner D_L6_ln_ner ///
D_ln_gdpc_sa D_L1_ln_gdpc_sa D_L2_ln_gdpc_sa D_L3_ln_gdpc_sa ///
D_L4_ln_gdpc_sa D_L5_ln_gdpc_sa D_L6_ln_gdpc_sa ///
D_ir3 D_L1_ir3 D_L2_ir3 D_L3_ir3 D_L4_ir3 D_L5_ir3 D_L6_ir3 /// 
, backward aic                                  

test L1_ln_m2dc L1_ln_ner L1_ln_gdpc L1_ir3

pssbounds, fstat(20.13) obs(63) case(3) k(4) tstat(-8.69)


// Checking lag orders for the NARDL model


forvalue x=1/11 {

regress D.ln_m2dc /// 
L.ln_m2dc /// 
L.ln_ner_pos L.ln_ner_neg ///
l.ln_gdpc_sa l.ir3 ///
D.l(1).ln_m2dc ///
D.l(1).ln_gdpc_sa ///
D.l(1).ir3 ///
D.l(0/`x').ln_ner_pos ///
D.l(0/`x').ln_ner_neg

		 estat ic                               //-> Note 2						  
}

forvalue x=2/12 {

        nardl ln_m2dc ln_ner, deterministic(L1_ln_gdpc_sa L1_ir3 ///
        D_L1_ln_gdpc_sa D_L1_ir3) p(2) q(`x') ///
        horizon(60) 

		 estat ic                               						  
}

forvalue x=2/12 {

        nardl ln_m2dc ln_ner, deterministic(ln_gdpc_sa ir3 ///
        ) p(2) q(`x') ///
        horizon(60) 

		 estat ic                               						  
}

// Without D_L1_ln_gdpc_sa D_L1_ir3

forvalue x=2/12 { 

        nardl ln_m2dc ln_ner, deterministic(L1_ln_gdpc_sa L1_ir3 ///
        ) p(2) q(`x') ///
        horizon(60) 

		 estat ic                               						  
}

nardl ln_m2dc ln_ner, deterministic(L1_ln_gdpc_sa L1_ir3) p(2) q(12) ///
horizon(60) residuals plot bootstrap(100) level(95)
graph rename nardl_212_lag_check, replace
capture graph export nardl_212_lag_check.png, replace  // SR asym. not LR

* bootstrap result stored in nardl_212_lag_check_final.pdf

regress D_ln_m2dc L1_ln_m2dc L1_ln_ner_pos L1_ln_ner_neg ///
L1_ln_gdpc_sa L1_ir3 ///
D_L1_ln_m2dc ///
D_ln_ner_pos D_L1_ln_ner_pos D_L2_ln_ner_pos D_L3_ln_ner_pos ///
D_L4_ln_ner_pos D_L5_ln_ner_pos D_L6_ln_ner_pos D_L7_ln_ner_pos ///
D_L8_ln_ner_pos D_L9_ln_ner_pos D_L10_ln_ner_pos D_L11_ln_ner_pos ///
D_ln_ner_neg D_L1_ln_ner_neg D_L2_ln_ner_neg D_L3_ln_ner_neg ///
D_L4_ln_ner_neg D_L5_ln_ner_neg D_L6_ln_ner_neg D_L7_ln_ner_neg ///
D_L8_ln_ner_neg D_L9_ln_ner_neg D_L10_ln_ner_neg D_L11_ln_ner_neg

// Asymmetry tests

test (_b[L1_ln_ner_pos] = _b[L1_ln_ner_neg])      // LR

test (_b[D_ln_ner_pos] + _b[D_L1_ln_ner_pos]+ _b[D_L2_ln_ner_pos] ///
+ _b[D_L3_ln_ner_pos]+_b[D_L4_ln_ner_pos]+_b[D_L5_ln_ner_pos] ///
+_b[D_L6_ln_ner_pos]+_b[D_L8_ln_ner_pos]+_b[D_L9_ln_ner_pos] ///
+_b[D_L10_ln_ner_pos]+_b[D_L11_ln_ner_pos]=_b[D_ln_ner_neg] ///
+ _b[D_L1_ln_ner_neg]+_b[D_L2_ln_ner_neg]+_b[D_L6_ln_ner_neg] ///
+_b[D_L7_ln_ner_neg]+_b[D_L8_ln_ner_neg]+_b[D_L10_ln_ner_neg])     // SR

vselect D_ln_m2dc L1_ln_m2dc L1_ln_ner_pos L1_ln_ner_neg ///
L1_ln_gdpc_sa L1_ir3 ///
D_L1_ln_m2dc D_L1_ln_gdpc_sa D_L1_ir3 ///
D_ln_ner_pos D_L1_ln_ner_pos D_L2_ln_ner_pos D_L3_ln_ner_pos ///
D_L4_ln_ner_pos D_L5_ln_ner_pos D_L6_ln_ner_pos D_L7_ln_ner_pos ///
D_L8_ln_ner_pos D_L9_ln_ner_pos D_L10_ln_ner_pos D_L11_ln_ner_pos ///
D_ln_ner_neg D_L1_ln_ner_neg D_L2_ln_ner_neg D_L3_ln_ner_neg ///
D_L4_ln_ner_neg D_L5_ln_ner_neg D_L6_ln_ner_neg D_L7_ln_ner_neg ///
D_L8_ln_ner_neg D_L9_ln_ner_neg D_L10_ln_ner_neg D_L11_ln_ner_neg ///
, backward aic

test L1_ln_m2dc L1_ln_ner_pos L1_ln_ner_neg L1_ln_gdpc L1_ir3

pssbounds, fstat(6.63) obs(59) case(3) k(5) tstat(-5.18)

// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_lag_check.dta", ///
replace

log close
exit

Description
-----------

This file aims at ...
 

Notes :
-------

1) The ARDL model with p=7 and q=7 is the best model for starting backward
   selection based on ECM, RMSE and AIC.
2) The NARDL with p=2 and q=12 is the best model for starting backward selection 
   based on ECM, RMSE and AIC.