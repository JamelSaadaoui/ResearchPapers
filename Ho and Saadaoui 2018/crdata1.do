* Prepare the data for analysing money demand in Viet-Nam
*-------------------------------------------------------------------------

version 17.0
set more off
cd "C:\Users\jamel\Dropbox\stata\vn"			    // Set the directory
capture log close                               
log using crdata1.smcl, replace

import excel C:\Users\jamel\Dropbox\stata\vn\data_final.xlsx,/*
*/ sheet("Data") firstrow clear

generate qtr = tq(2000q4) + _n-1
format %tq qtr

rename ( M2_current_price NFA_current_price M2D_current_price ///
M2_constant_price M2_constant_price_SA M2D_constant_price ///
M2D_constant_price_SA GDP_constant_price GDP_constant_price_SA ///
GDP_current_price Deflator NER) (m2 nfa m2d m2c m2c_sa m2dc ///
m2dc_sa gdpc gdpc_sa gdp defla ner ), dryrun

rename ( M2_current_price NFA_current_price M2D_current_price ///
M2_constant_price M2_constant_price_SA M2D_constant_price ///
M2D_constant_price_SA GDP_constant_price GDP_constant_price_SA ///
GDP_current_price Deflator NER) (m2 nfa m2d m2c m2c_sa m2dc ///
m2dc_sa gdpc gdpc_sa gdp defla ner )


label variable m2 "Money supply current price (M2)"
label variable nfa "Net foreign asset"
label variable m2d " = M2 - NFA"
label variable m2c "deflated by GDP deflator"
label variable m2c_sa " M2_constant_price_(seasonal ajusted) "
label variable m2dc " M2D_constant_price (deflated by GDP deflator) "
label variable m2dc_sa " M2D_constant_price (deflated & seasonal adj) "
label variable gdpc " 2010 = 100 "
label variable gdpc_sa " 2010 = 100 "
label variable defla "GDP current price/GDP constant price"
label variable ner "USD/VND: e VND = 1 USD"
label variable ir3 "deposit rate 3 month"       // Note 1

capture generate ln_m2c = log(m2c)              // Note 2
la var ln_m2c "Natural log of money supply"     // Note 3

capture generate ln_m2c_sa = log(m2c_sa)
la var ln_m2c_sa "Natural log of (seas. adj.) money supply"

capture generate ln_m2dc = log(m2dc)
la var ln_m2dc "Natural log of money supply - nfa"

capture generate ln_m2dc_sa = log(m2dc_sa)
la var ln_m2dc_sa "Natural log of (seas. adj.) money supply - nfa"

capture generate ln_gdpc = log(gdpc)
la var ln_gdpc "Natural log of gdp (const. price)"

capture generate ln_gdpc_sa = log(gdpc_sa)
la var ln_gdpc_sa "Natural log of gdp (seas. adj.)"

capture generate ln_ner = log(ner)              
la var ln_ner "Natural log of nominal XR (e VND = 1 USD)" 

drop Time-t

order qtr, first
order ir3, last

// Declare time series

tsset qtr, quarterly

// Apply the Stata Journal scheme

set scheme sj

foreach v in m2dc m2dc_sa gdpc gdpc_sa ner ir3 {
twoway (line `v' qtr)
capture graph rename `v', replace
capture graph export `v'.png, replace
capture graph export `v'.pdf, replace
*graph close `v'
}

foreach v in m2dc m2dc_sa gdpc gdpc_sa ner {
twoway (line ln_`v' qtr)
capture graph rename ln_`v', replace
capture graph export ln_`v'.png, replace
capture graph export ln_`v'.pdf, replace
*graph close ln_`v'
}

foreach v in ln_ner ln_gdpc ln_gdpc_sa ir3 {
	generate `v'_pos  = 0
	generate `v'_neg  = 0
	generate d`v'_pos = max(0,D.`v')
	generate d`v'_neg = min(0,D.`v')
	capture replace  `v'_pos  = L.`v'_pos + d`v'_pos if _n>1
	capture replace  `v'_neg  = L.`v'_neg + d`v'_neg if _n>1
	}

la var ln_ner_pos "XR Positive partial sums" 
la var ln_ner_neg "XR Negative partial sums"

la var ln_gdpc_pos "GDP Positive partial sums" 
la var ln_gdpc_neg "GDP Negative partial sums"

la var ln_gdpc_sa_pos "GDP SA Positive partial sums" 
la var ln_gdpc_sa_neg "GDP SA Negative partial sums"

la var ir3_pos "IR Positive partial sums" 
la var ir3_neg "IR Negative partial sums"

// Plot the variables and the partial sums

foreach v in ln_ner_pos ln_ner_neg ln_gdpc_pos ln_gdpc_neg ///
             ln_gdpc_sa_pos ln_gdpc_sa_neg ir3_pos ir3_neg {
			 twoway (bar d`v' qtr, yaxis(2))  ///
			 (line `v' qtr), name(cum_`v', replace)
             capture graph export cum_`v'.png, replace
			 capture graph export cum_`v'.pdf, replace
			 *graph close cum_`v'
}

twoway (bar dln_ner_neg qtr) (bar dln_ner_pos qtr), ///
name(cum_ner_check, replace)
capture graph export cum_ner_check.png, replace
capture graph export cum_ner_check.pdf, replace

twoway (bar dln_gdpc_neg qtr) (bar dln_gdpc_pos qtr), ///
name(cum_gdpc_check, replace)
capture graph export cum_gdpc_check.png, replace
capture graph export cum_gdpc_check.pdf, replace

twoway (bar dln_gdpc_sa_neg qtr) (bar dln_gdpc_sa_pos qtr), ///
name(cum_gdpc_sa_check, replace)
capture graph export cum_gdpc_sa_check.png, replace
capture graph export cum_gdpc_sa_check.pdf, replace

twoway (bar dir3_neg qtr) (bar dir3_pos qtr), ///
name(cum_ir3_check, replace)
capture graph export cum_ir3_check.png, replace
capture graph export cum_ir3_check.pdf, replace

twoway (bar dln_ner_neg qtr) (bar dln_ner_pos qtr) /// 
(line ln_ner qtr, yaxis(2)), ///
name(cum_ner_check_line, replace) legend(col(1))
capture graph export cum_ner_check_line.png, replace
capture graph export cum_ner_check_line.pdf, replace

describe

sum
summarize, detail

// Save the data
save ///
"C:\Users\jamel\Dropbox\stata\vn\data_crdata1.dta", ///
replace

log close
exit

Description
-----------

This file aims at preparing the data for the analysis of money demand in 
Viet-Nam. We setup the database and calculate the partial sums.
Afterwards, we produce some descriptive statistics.
 

Notes :
-------

1) All the variables are expressed in Vietnamese Dong. The data comes
   from State Bank of Viet-Nam, General Statistics Office of Viet-Nam or
   Reuters.
2) We use the capture command to overide message when variables are
   already generated. 
3) The abbreviation la var stands for label variable.