**#** 23 March 2023 ***

** Replication package for

/*
International reserves, currency depreciation and public debt:
new evidence of buffer effects in Africa

Issiaka Coulibaly (a), Blaise Gnimassoun (b), Hamza Mighri (c), 
Jamel Saadaoui (d)
a African Development Bank Group, Bamako, Mali
b University of Lorraine, University of Strasbourg, BETA, CNRS, 
67000, Strasbourg, France
c International Monetary Fund, Washington, D.C., United States
d University of Strasbourg, University of Lorraine, BETA, CNRS, 
67000, Strasbourg, France
*/


***** This code has been written by Blaise Gnimassoun ***********

// Replace the path with your own path

*use "RegressionData.dta", clear

use RegressionData.dta, clear

// Create a subfolder named Results

// You are ready to launch the estimations

preserve

****************************************************************************
**# *** 2022 depreciation: War in Ukraine and Tightening of US monetary **** 
******* policy *************************************************************
****************************************************************************

keep if year==2022  
reg NERgrowth LagRES_GDP_EWN if LagRES_GDP_EWN<50 & CFAZ!=1
mat b=e(b)
mat v=e(V)
local a:di %5.2f b[1,1]
local se_a:di %5.2f v[1,1]
local F:di %5.2f e(F)
twoway scatter NERgrowth LagRES_GDP_EWN if LagRES_GDP_EWN<50 & CFAZ!=1, mlabel(ISO) mlabsize(small) title("National currency depreciation rate and FX reserves", size(medium)) subtitle("Slope = `a', Std. error = `se_a',  F-stat = `F'", size(small)) xtitle(FX reserves in 2021 (% GDP), size(medium)) xlabel(, labsize(medium) tlength(0.5) ) ytitle(Depreciation rate in 2022 (%), size(medium)) ylabel(, labsize(medium) tlength(0.5) ) || (lfit NERgrowth LagRES_GDP_EWN if LagRES_GDP_EWN<50 & CFAZ!=1, legend(off)), name(Graph1, replace)
graph save Graph1 "Results\Graph1.gph", replace
graph export "Results\Graph1.png", as(png) replace width(4000)
graph export "Results\Graph1.pdf", as(pdf) replace

**# *** NER depreciation
reg NERgrowth LagRES_GDP_EWN if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) replace 
reg NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) append 
reg NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) append 

**# *** High depreciation episodes
gen NERgrowth2=NERgrowth*curdepepisodes
reg NERgrowth2 LagRES_GDP_EWN if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) append 
reg NERgrowth2 LagRES_GDP_EWN lnGDPpc inflation TOPEN if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) append 
reg NERgrowth2 LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp if year==2022, r
outreg2 using "Results\Table1.xls", ctitle(OLS) dec(3) label keep(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) sortvar(NERgrowth LagRES_GDP_EWN lnGDPpc inflation TOPEN CAgdp) append 

restore

**# *** Pooled regressions

reg debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth, r
outreg2 using "Results\Table2.xls", ctitle(OLS) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) replace

reg debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1, r
outreg2 using "Results\Table2.xls", ctitle(OLS) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) append

drop x1
gen x1=pegc
label var x1 "CFA zone/Peg currency system"
reg debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1, r
outreg2 using "Results\Table2.xls", ctitle(OLS) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) append

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth, lag(3)
outreg2 using "Results\Table2.xls", ctitle(DK)dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, No) append

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth , fe lag(3)
outreg2 using "Results\Table2.xls", ctitle(DK) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append


*****************************************************
**# ************** Peg currency system **************
*****************************************************

**# *** Pooled regressions

reg debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1, r
outreg2 using "Results\Table3.xls", ctitle(OLS) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) replace 

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1,lag(3)
outreg2 using "Results\Table3.xls", ctitle(DK)dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, No) append

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1, fe lag(3)
outreg2 using "Results\Table3.xls", ctitle(DK) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append

*****************************************************
**# **************** Non Peg currency system ********
*****************************************************

**# *** Pooled regressions
reg debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, r
outreg2 using "Results\Table3.xls", ctitle(OLS) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) append

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, lag(3)
outreg2 using "Results\Table3.xls", ctitle(DK)dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, No) append

xtscc debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, fe lag(3)
outreg2 using "Results\Table3.xls", ctitle(DK) dec(3) label keep(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append



********************************************************************
**# ***************** Revision ************************************
********************************************************************
tsset id year 
gen ldebtgdp=l.debtgdp

label var ldebtgdp "Lagged debt-to-GDP ratio"

**# *** Pooled regressions

reg debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth, r
outreg2 using "Results\Table2_rev.xls", ctitle(OLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) replace

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth , fe lag(3)
outreg2 using "Results\Table2_rev.xls", ctitle(DK) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append


**# *** 2SLS
xtivreg2 debtgdp ldebtgdp (LagRES_GDP_EWN=l.LagRES_GDP_EWN l2.LagRES_GDP_EWN) curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth, small fe robust
outreg2 using "Results\Table2_rev.xls", ctitle(2SLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, No, Country FE, Yes, Hansen J stat P-value, 0.738) append



*****************************************************
**# ************** Peg currency system **************
*****************************************************

**# *** Pooled regressions

reg debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1, r
outreg2 using "Results\Table3_rev.xls", ctitle(OLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) replace 

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1, fe lag(3)
outreg2 using "Results\Table3_rev.xls", ctitle(DK) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append

**# *** 2SLS
xtivreg2 debtgdp ldebtgdp (LagRES_GDP_EWN=l.LagRES_GDP_EWN l2.LagRES_GDP_EWN) curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc==1, small fe robust
outreg2 using "Results\Table3_rev.xls", ctitle(2SLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, No, Country FE, Yes, Hansen J stat P-value, 0.762) append


*****************************************************
**# **************** Non Peg currency system ********
*****************************************************

**# *** Pooled regressions
reg debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, r
outreg2 using "Results\Table3_rev.xls", ctitle(OLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) append

**# *** Driscoll and Kraay's covariance estimator: FE, CS/Time correlations, Time FE

xtscc debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, fe lag(3)
outreg2 using "Results\Table3_rev.xls", ctitle(DK) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, Yes, Country FE, Yes) append

xtivreg2 debtgdp ldebtgdp (LagRES_GDP_EWN=l.LagRES_GDP_EWN l2.LagRES_GDP_EWN) curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth if pegc!=1, small fe robust
outreg2 using "Results\Table3_rev.xls", ctitle(2SLS) dec(3) label keep(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) sortvar(debtgdp ldebtgdp LagRES_GDP_EWN curdepepisodes RESdepEp GDPpcgrowth Govcons FINopen TOPEN DCPSB_GDP democ Privcons GFCF_GDP Bmoneygrowth x1) addtext(Cross-sectional dependence, No, Country FE, Yes, Hansen J stat P-value, 0.400) append









