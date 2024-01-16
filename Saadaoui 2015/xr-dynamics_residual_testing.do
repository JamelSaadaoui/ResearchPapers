***********************************************************
**#***** Co-integration analysis for XR dynamics **********
***********************************************************
***********************************************************

**# Reference: Saadaoui, J. (2015). Global imbalances: 
**  Should we use fundamental equilibrium exchange rates?
**  Economic Modelling, 47, 383-398. 
**  https://doi.org/10.1016/j.econmod.2015.02.007

version 15.1
set more off

cd "C:\Users\jamel\Documents\GitHub\ResearchPapers\"
cd "Saadaoui 2015"	// Set the directory

cls
clear

capture log close _all                            
log using xrdynamics, name(xrdynamics) text replace

*Import the data from Excel


import excel EXCEL_0215a.xlsx, /// 
sheet("data_fin") firstrow clear // Note 1

*Generate variable in logarithm

generate logreer = ln(reer)
generate logfeer = ln(feer)
generate logreer_cs = ln(reer_cs)
generate logfeer_cs = ln(feer_cs)

*Panel setting (N=26; T=29; N*T=754)

gen datayear = yofd(period)
encode country, generate(cn)
order cn datayear, first

xtset cn datayear, yearly
xtdescribe

****************************************************************

**#Install User-Written Stata Programs

/*
capture ssc install pescadf // Note 2
capture ssc install xtwest
capture ssc install xtpmg
capture ssc install xtmg
capture ssc install ltimbimata
capture ssc install xtdolshm
capture ssc install outreg2
capture net install xtdcce2 , ///
 from("https://janditzen.github.io/xtdcce2/")
*/

**#UNIT ROOT TEST
*CADF test (Pesaran, 2007)

pescadf  logfeer, lags(1) trend
pescadf  logreer, lags(1) trend
pescadf  d.logfeer, lags(1) trend
pescadf  d.logreer, lags(1) trend

*COINTEGRATION TESTS
*Persyn & Westerlund (2008)

xtwest logreer logfeer, lags (0 2) 
xtwest logfeer logreer, lags (0 2)

*set matsize 800

*xtwest logreer logfeer, lags (0 2) bootstrap(100)
*xtwest logfeer logreer, lags (0 2) bootstrap(100)

**# ESTIMATION OF THE ERROR-CORRECTION MODEL THANKS TO
// THE PMG (CPMG) ESTIMATOR
// PESARAN et al. (1999)

xtpmg d.logreer d.logfeer, ///
lr(l.logreer logfeer) ec(ec) replace pmg full

// Residual testing (start)

/*
https://www.statalist.org/forums/forum/
general-stata-discussion/general/1333633-
residual-testing-for-pooled-mean-group-estimator
*/

capture drop yhat
gen yhat = .
forval cn = 1/26 {
predict temp if cn ==`cn', eq(cn_`cn')
replace yhat = temp if cn == `cn'
drop temp
}

gen residuals = d.logreer - yhat

xtline d.logreer yhat

xtcdf residuals

// Residual testing (end)

// Implied path

gen path = logreer + yhat

xtline logreer path if country == "BRA"

outreg2 using tables\results_pmg_1, ///
excel pvalue replace ///
cttop(D.logreer) addnote(Notes:) // Note 2

xtpmg d.logfeer d.logreer, ///
lr(l.logfeer logreer) ec(ec) replace pmg

outreg2 using tables\results_pmg_2, /// 
excel pvalue replace ///
cttop(D.logfeer) addnote(Notes:)

xtpmg d.logreer d.logfeer d.logreer_cs d.logfeer_cs, /// 
lr(l.logreer logfeer l.logreer_cs logfeer_cs) ///
ec(ec) replace pmg full

// Residual testing (start)

capture drop yhat
gen yhat = .
forval cn = 1/26 {
predict temp if cn ==`cn', eq(cn_`cn')
replace yhat = temp if cn == `cn'
drop temp
}

xtcdf residuals_cs

// Residual testing (end)

// Prediction of long run val. (Discussion with Kamila and Hiro)

/*
// Common constant

generate cst = 1

xtpmg d.logreer d.logfeer, ///
lr(l.logreer logfeer cst) ec(ect) replace pmg full nocons

cap drop ecT
generate ecT = l.logreer - (_b[logfeer])*logfeer - 1.156936 

cap drop check
gen check = ect-ecT // equal to zero

cap drop logreer_star
gen logreer_star = (_b[logfeer])*logfeer + 1.156936

xtline logreer logreer_star if country == "FRA"
xtline logreer logreer_star if country == "ARG"
xtline logreer logreer_star if country == "USA"

// Filter

tsfilter hp cycle_logfeer = logfeer, trend(trend_logfeer)

xtline logfeer trend_logfeer cycle_logfeer ///
 if country == "FRA"
 
xtline logfeer trend_logfeer cycle_logfeer ///
 if country == "ARG"
 
xtline logfeer trend_logfeer cycle_logfeer ///
 if country == "USA" 

cap drop logreer_star_hp
gen logreer_star_hp = (_b[logfeer])*trend_logfeer + 1.156936

set scheme stgcolor_alt

xtline logreer logreer_star_hp if country == "FRA"
xtline logreer logreer_star_hp if country == "ARG"
xtline logreer logreer_star_hp

//
 */

outreg2 using tables\results_cpmg_1, ///
excel pvalue replace ///
cttop(D.logreer) addnote(Notes:)

xtpmg d.logfeer d.logreer d.logfeer_cs d.logreer_cs, ///
lr(l.logfeer logreer l.logfeer_cs logreer_cs) ///
ec(ec) replace pmg

outreg2 using tables\results_cpmg_2, ///
excel pvalue replace ///
cttop(D.logfeer) addnote(Notes:)

**# STUDY SHORT RUN DYNAMICS

xtpmg d.logreer d.logfeer, ///
lr(l.logreer logfeer) ec(ec) replace pmg full

outreg2 using tables\results_pmg_1_SR, ///
excel pvalue replace ///
cttop(D.logreer) addnote(Notes:)

xtpmg d.logfeer d.logreer, ///
lr(l.logfeer logreer) ec(ec) replace pmg full

outreg2 using tables\results_pmg_2_SR, ///
excel pvalue replace ///
cttop(D.logfeer) addnote(Notes:)

xtpmg d.logreer d.logfeer d.logreer_cs d.logfeer_cs, ///
lr(l.logreer logfeer l.logreer_cs logfeer_cs) ///
ec(ec) replace pmg full

outreg2 using tables\results_cpmg_1_SR, ///
excel pvalue replace ///
cttop(D.logreer) addnote(Notes:)

xtpmg d.logfeer d.logreer d.logfeer_cs d.logreer_cs, ///
lr(l.logfeer logreer l.logfeer_cs logreer_cs) ///
ec(ec) replace pmg full

outreg2 using tables\results_cpmg_2_SR, ///
excel pvalue replace ///
cttop(D.logfeer) addnote(Notes:)

**# PESARAN (2006) COMMON CORRELATED EFFECTS 
// MEAN GROUP ESTIMATOR

xtmg logreer logfeer, cce robust

outreg2 using tables\results_ccemg_1, /// 
excel pvalue replace ///
cttop() addnote(Notes:)

xtmg logfeer logreer, ///
cce robust

outreg2 using tables\results_ccemg_2, ///
excel pvalue replace ///
cttop() addnote(Notes:)

**# PESARAN & SMITH (1995) 
// MEAN GROUP ESTIMATOR

// smg = static mg estimator

xtmg logreer logfeer, robust

outreg2 using tables\results_smg_1, ///
excel pvalue replace ///
cttop() addnote(Notes:)

xtmg logfeer logreer, robust

outreg2 using tables\results_smg_2, ///
excel pvalue replace ///
cttop() addnote(Notes:)

**# KAO & CHIANG (2000) DOLS ESTIMATOR

xtdolshm logreer logfeer, nla(2) nle(2)
outreg2 using tables\results_dols_1, ///
excel pvalue replace ///
cttop() addnote(Notes:)

xtdolshm logfeer logreer, nla(2) nle(2)
outreg2 using tables\results_dols_2, ///
excel pvalue replace ///
cttop() addnote(Notes:)

**# JAN DITZEN (2021) DCCE PMG

xtcse2 logreer logfeer

xtdcce2 d.logreer d.logfeer, lr(L.logreer logfeer) ///
p(L.logreer logfeer) cross(_all) cr_lags(0) exponent

/*
// variables partialled out = 78 (26 cons, (2*26) 
   logreer_cs logfeer_cs in T)
// variables in mean group regression = 28 
 ((26) D.logfeer + (2) Cross Sectional Averaged Variables: 
   logreer logfeer)
*/

***************

xtdcce2 d.logreer d.logfeer, lr(L.logreer logfeer) ///
 p(L.logreer logfeer) cross(_all) ///
 cr_lags(2) exponent

*cap drop res

*predict res, residuals

/*
// variables partialled out = 182 (26 cons, (6*26) 
   logreer_cs logfeer_cs in T, T+1 and T+2)
// variables in mean group regression = 28 
 ((26) D.logfeer + (2) Cross Sectional Averaged Variables: 
   logreer logfeer)
*/

*cap graph drop res

xtcd2, pesaran cdw reps(50)


***************

/*
xtdcce2 d.logreer d.logfeer, lr(L.logreer logfeer) ///
p(L.logreer logfeer) cross(_all) cr_lags(2) exponent ///
absorb(cn)

*cap drop res_fe

*predict res_fe, residuals

/*
// variables partialled out = 156 ((6*26) 
   logreer_cs logfeer_cs in T, T+1 and T+2)
   absorb(cn): individual FE no longer partialled out
// variables in mean group regression = 28 
 ((26) D.logfeer + (2) Cross Sectional Averaged Variables: 
   logreer logfeer)
*/

*cap graph drop res_fe

xtcd2, pesaran cdw reps(50) ///
 seed(9045)
*/
  
// Save the data
save data\xrdynamics.dta, replace

*log close xrdynamics
exit

Description
-----------

This file aims at analyzing the long run relationship
between actual REERs and equilibrium REERs. The equilibrium 
rates are obtained  thanks to a FEER approach.

Notes :
-------

1) Replace the "..." by the path of the current directory.
2) We use the capture command to override message when 
   variables are already generated or packages already 
   installed.
3) With the Excel option of the STATA command outreg2, I
   recommend using the useful package excel2latex.
4) I am grateful to Roy Wada, Markus Eberhardt,
   Damiaan Persyn, Edward F. Blackburne III, Mark W. Frank, 
   Piotr Lewandowski and Ibrahima Amadou Diallo for making 
   publicly available their STATA codes.