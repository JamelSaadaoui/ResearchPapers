**# "Replication of Financial development, international reserves, and real exchange rate dynamics: Insights from the Europe and Central Asia region" by Jamel Saadaoui

cls
clear

cd C:\Users\jamel\Dropbox\Latex\PROJECTS\
cd 24-09-rer-fd-ecs\Revision_FRL\Replication

capture log close _all                                
log using RERTOT_FRL.smcl, name(RERTOT_FRL) smcl replace

use datafintransformed-22-11-17, clear

set scheme stcolor

*search xthreg

**# Table 1: Descriptive statistics.

sum lreer lto ltot lres lgdppk_m100 lgovexp
qui: outreg2 using sum.doc, ///
 replace sum(log) keep(lreer lto ltot lres lgdppk_m100 lgovexp)
 
sum fd fi fm fmd if count_lgovexp==20
qui: outreg2 using sum1.doc if count_lgovexp==20, ///
 replace sum(log) keep(fd fi fm fmd)

**# Table 2. Panel threshold regressions and financial development.

// Column 1

**# Financial Dev - Full sample**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20, ///
rx(etot_L1lres) qx(l2.fd) thnum(1) grid(300) bs(300)

// Column 2

**Financial Institutions - Full sample**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fi) thnum(1) grid(600) bs(100) trim(0.10)
	
sum fm if fi <= 0.4806 & count_lgovexp==20
sum fm if fi > 0.4806 & count_lgovexp==20

// Column 3

**Financial Markets - Full sample**	
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
    , ///
	rx(etot_L1lres) qx(l2.fm) thnum(1) grid(300) bs(300)

// Column 4

**# Financial Markets - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L2.fm) thnum(1) grid(300) bs(300)
sum fm if fm <= 0.0217 & rn==2 & count_lgovexp==20
sum fm if fm > 0.0217 & rn==2 & count_lgovexp==20

// Column 5

**# Financial Markets Depth - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L2.fmd) thnum(1) grid(300) bs(300)
sum fmd if fmd <= 0.0234 & rn==2 & count_lgovexp==20
sum fmd if fmd > 0.0234 & rn==2 & count_lgovexp==20

**# Fig. 1. Threshold effect in the ECS region.

gen resgdp = (res/gdp)*100
by cn: egen resgdp_full = mean(resgdp)
by cn: egen resgdp_before = mean(resgdp) if year<2008
by cn: egen resgdp_after = mean(resgdp) if year>2009
by cn: egen resgdp_full_sd = sd(resgdp)
by cn: egen resgdp_before_sd = sd(resgdp) if year<2008
by cn: egen resgdp_after_sd = sd(resgdp) if year>2009

graph hbar resgdp_before resgdp_after ///
if region=="ECS" & eurozone==0, over(cn, sort(2) ///
label(labsize(small))) ///
legend(pos(6) label(1 "Before the financial crisis (2007-2009)") label(2 "After the financial crisis (2010-2020)")) yline(17.28) ///
title("Buffer effect in the ECS region without EZ") ///
note(Source: see the main text.) xsize(7)

graph rename Graph Thres_Res, replace
graph export Thres_Res.png, as(png) name("Thres_Res") width(3000) replace

**# Fig. 2, Fig. 3 present the construction of the confidence intervals for the threshold models in the ECS region, focusing on the Financial Markets Index (FM) and Financial Market Depth (FMD).

// Column 4

**# Financial Markets - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L2.fm) thnum(1) grid(300) bs(300)
sum fm if fm <= 0.0217 & rn==2 & count_lgovexp==20
sum fm if fm > 0.0217 & rn==2 & count_lgovexp==20

*ereturn list

capture graph drop LR_FMECS	

_matplot e(LR), title("ECS FM - buffer effect") ///
yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) ///
mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") ///
recast(line) name(LR_FMECS)

graph export LR_FMECS.png, as(png) name("LR_FMECS") width(3000) replace

// Column 5

**# Financial Markets Depth - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L2.fmd) thnum(1) grid(300) bs(300)
sum fmd if fmd <= 0.0234 & rn==2 & count_lgovexp==20
sum fmd if fmd > 0.0234 & rn==2 & count_lgovexp==20

*ereturn list

capture graph drop LR_FMDECS	

_matplot e(LR), title("ECS FMD - buffer effect") ///
yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) ///
mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") ///
recast(line) name(LR_FMDECS)

graph export LR_FMDECS.png, as(png) name("LR_FMDECS") width(3000) replace

**# Appendix A. Robustness checks

**# Robustness 1: Financial Markets Depth - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L3.fmd) thnum(1) grid(300) bs(300)
sum fmd if fmd <= 0.0268 & rn==2 & count_lgovexp==20
sum fmd if fmd > 0.0268 & rn==2 & count_lgovexp==20


capture graph drop LR_FMDECSR	

_matplot e(LR), title("ECS FMD - buffer effect (third lag)") ///
yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) ///
mlabs(zero) ytitle("LR Statistics") xtitle("Threshold Parameter") ///
recast(line) name(LR_FMDECSR)

graph export LR_FMDECSR.png, as(png) name("LR_FMDECSR") width(3000) replace

**# Robustness 2: Financial Markets Depth - ECS**
xthreg lreer lgdppk_m100 lgovexp if count_lgovexp==20 ///
& rn==2, ///
rx(etot_L1lres) qx(L2.fmd) thnum(2) grid(300) bs(300 300)

capture graph drop LR21 LR22
capture graph drop LR_ECSFMD2

_matplot e(LR21), columns(1 2) yline(7.35, lpattern(dash)) connect(direct) ///
msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") ///
xtitle("First Threshold") recast(line) name(LR21) nodraw title("ECS FMD - buffer effect (Double Threshold)")
_matplot e(LR22), columns(1 2) yline(7.35, lpattern(dash)) connect(direct) ///
msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") ///
xtitle("Second Threshold") recast(line) name(LR22) nodraw
graph combine LR21 LR22, cols(1)

graph rename Graph LR_ECSFMD2

graph export LR_ECSFMD2.png, as(png) name("LR_ECSFMD2") width(3000) replace

log close _all
exit

**# End of Program