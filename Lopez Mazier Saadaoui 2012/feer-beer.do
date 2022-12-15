***********************************************************
******** Co-integration analysis for EER ******************
***********************************************************
***********************************************************

**# Reference: Lòpez-Villavicencio, A., Mazier, J., 
**  & Saadaoui, J. (2012). Temporal dimension and equilibrium 
**  exchange rate: A FEER/BEER comparison. 
**  Emerging Markets Review, 13(1), 58-77.
**  https://doi.org/10.1016/j.ememar.2011.10.001

version 12.1
set more off

cd "C:\Users\jamel\Documents\GitHub\ResearchPapers\"
cd "Lopez Mazier Saadaoui 2012"	// Set the directory

cls
clear

capture log close _all                            
log using feerbeer, name(feerbeer) text replace

*Import the data from Excel

import excel data\data.xlsx, /// 
sheet("Feuil1") firstrow clear // Note 1

xtset country period

xtdescribe

encode names, generate(cn)

label list cn

capture ssc install xtpmg, replace

// Table 2 in the paper

xtpmg d.logfeer d.logbeer, lr(l.logfeer logbeer) ec(ec) replace pmg

outreg2 using tables\results_table_2, ///
excel pvalue replace dec(3) ///
title("Dependent variable: D.logfeer") ///
cttop() addnote(Notes:)

xtpmg d.logfeer d.logbeer if period>=1994, ///
  lr(l.logfeer logbeer) ec(ec) replace pmg

xtpmg d.logfeer d.logbeer if period<=1994, ///
  lr(l.logfeer logbeer) ec(ec) replace pmg

// Table B1 in the paper

capture drop advanced
generate advanced = 0
replace advanced = 1 if  ///
		names=="USA" | names=="UK" | ///
		names=="JPN" | names=="EU"

tabulate advanced
		
xtpmg d.logfeer d.logbeer ///
 if advanced!=1, ///
 lr(l.logfeer logbeer) ec(ec) replace pmg

outreg2 using tables\results_table_B1, ///
excel pvalue replace dec(3) ///
title("Dependent variable: D.logfeer") ///
cttop() addnote(Notes:)

// Save the data
save data\feerbeer.dta, replace

log close feerbeer
exit

Description
-----------

This file aims at analyzing the long run relationship
between FEERs and BEERs.

Notes :
-------

1)
