********************************************************************************

**# Start of the replication program for Geopolitical Turning Points
// and Macroeconomic Volatility: A Bilateral Identification Strategy 
// (Journal of Comparative Economics)

// Code by Jamel Saadaoui (jamelsaadaoui@gmail.com)

capture log close _all                                
log using Saadaoui_2026_JCE.log, name(Saadaoui_2026_JCE) text replace

**# Choose the main directory (Replace with your own path)

cd C:\Users\jamel\Dropbox\Latex\PROJECTS\25-08-oil-pri-iv\Replication_JCE

**# Load the dataset

use Saadaoui_2026_JCE.dta, clear

*label var d2pri "Second difference of PRI US-China"
*label var d2pri_jp "Second difference of PRI Japan-China"

**# Set the fonts and choose the scheme

set scheme stcolor

graph set window fontface "Palatino Linotype"

**# Install the packages

ssc install locproj

**# Figure 1. Original PRI and the second difference of PRI (US–China).

tw (tsline pri) (bar d2.pri Period, yaxis(2)), ///
 legend(col(1) pos(6)) ///
 name(Figure_1, replace)  ///
  text(-7 428 "{it:Taiwan Strait Crisis}", ///
  size(small) orient(vertical) box) ///
    text(-7 448 "{it:Jiang Zemin's visit}", ///
  size(small) orient(vertical) box) ///
    text(-8 466 "{it:NATO bombing}", ///
  size(small) orient(vertical) box) ///
    text(-6.5 692 "{it:Trade war}", ///
  size(small) orient(vertical) box)  ///
    text(-5 737 "{it:Winter Olympics}", ///
  size(small) orient(vertical) box)
graph export Figure_1.png, as(png) width(4000) replace

**# Figure 2. Exclusion restriction and identification channel (economic content).

// See the main text.

**# Figure 3. Lead (non-anticipation) test: reaction of oil prices to future geopolitical turning points.

gen F2_d2pri = F2.d2pri

locproj lwti F2_d2pri llwip d.llgop l2lwip d.l2lgop ///
 d.lpri_*, ///
 h(0/48) yl(3) sl(2) r ///
 title("Lead Test: Reaction of Oil Prices to Geopolitical Turnig points") ///
 grname(Figure_3)
graph export Figure_3.png, as(png) width(4000) replace

**# Figure 4. Oil price reaction to an improvement of PRI between the US and China.

locproj lwti lpri llwip d.llgop l2lwip d.l2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivregress gmm) ///
 instr(d2.pri) ivtest(firststage) noisily stats z ///
 grname(Figure_4) conf(90 95) r lcolor(green) ///
 save irfn(Mean) tti(Months)
graph export Figure_4.png, as(png) width(4000) replace

**# Figure 5. Oil price reaction to an improvement of PRI between the US and China for different quantiles.

cap gen dllgop = d.llgop
cap gen dl2lgop = d.l2lgop 

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(25) vce(r) conf(90) ///
 save irfn(Q25)

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(50) conf(90) ///
 save irfn(Q50)

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(75) conf(90) ///
 save irfn(Q75)

lpgraph Mean, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP) ///
 lcolor(green) z

lpgraph Mean Q25 Q50 Q75, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP) ti2(Low - Q25) ///
 ti3(Median) ti4(High - Q75) ///
 lcolor(green) z grname(Figure_5)
graph export Figure_5.png, as(png) width(4000) replace

graph close Graph

**# Figure A1. Relevance of the instrument.

tw (sc D.lpri d2.pri) (lfit D.lpri d2.pri), name(Figure_A1, replace)
graph export Figure_A1.png, as(png) width(4000) replace

**# Figure A2. Orthogonality of the instrument (descriptive).

tw (sc D.lwti d2.pri) (lfit D.lwti d2.pri), name(Figure_A2, replace)
graph export Figure_A2.png, as(png) width(4000) replace

**# Table A1. First-Stage Regression Diagnostics for IV-LP.

locproj lwti lpri llwip d.llgop l2lwip d.l2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivregress gmm) ///
 instr(d2.pri) ivtest(firststage) noisily stats z nograph
 
**# Table A2. IV Endogeneity Tests across Horizons (0–48).
 
locproj lwti lpri llwip d.llgop l2lwip d.l2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivregress gmm) ///
 instr(d2.pri) ivtest(endogenous) noisily stats z nograph
 
**# Figure B1. Original PRI and the second difference of PRI (Japan-China).

tw (tsline pri_jp) (bar d2.pri_jp Period, yaxis(2)), ///
 legend(col(1) pos(6)) ///
 name(Figure_B1, replace) ///
 text(-3 601 "{it:Rare-earth export ban}", ///
  size(small) orient(vertical) box) ///
    text(-3.5 625 "{it:Senkaku Islands}", ///
  size(small) orient(vertical) box) ///
    text(1.5 693 "{it:Li Keqiang visit}", ///
  size(small) orient(vertical) box)
graph export Figure_B1.png, as(png) width(4000) replace

**# Figure B2. Oil price reaction to an improvement of PRI between Japan and China.

locproj lwti lpri_jp llwip d.llgop l2lwip d.l2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivregress gmm) ///
 instr(d2.pri_jp) ivtest(firststage) noisily stats z ///
 grname(Figure_B2) conf(90 95) r lcolor(green) ///
 save irfn(Mean) tti(Months)
graph export Figure_B2.png, as(png) width(4000) replace

**# Figure B3. Oil price reaction to an improvement of PRI between Japan and China for different quantiles.

cap gen dllgop = d.llgop
cap gen dl2lgop = d.l2lgop 

locproj lwti lpri_jp llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress smooth) ///
 instr(d2pri_jp) noisily stats q(25) vce(r) conf(90) ///
 save irfn(Q25)

locproj lwti lpri_jp llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress smooth) ///
 instr(d2pri_jp) noisily stats q(50) conf(90) ///
 save irfn(Q50)

locproj lwti lpri_jp llwip dllgop l2lwip dl2lgop ///
 , ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress smooth) ///
 instr(d2pri_jp) noisily stats q(75) conf(90) ///
 save irfn(Q75)

lpgraph Mean, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP_jp) ///
 lcolor(green) z

lpgraph Mean Q25 Q50 Q75, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP) ti2(Low - Q25) ///
 ti3(Median) ti4(High - Q75) ///
 lcolor(green) z grname(Figure_B3) 
graph export Figure_B3.png, as(png) width(4000) replace
 
graph close Graph 
 
**# Figure C1. Bilateral relations with China.

// West

// Last nonmissing value for each series
foreach v in lpri_jp lpri_aus lpri_fra lpri_ger lpri_uk lpri {
    quietly summarize Period if !missing(`v'), meanonly
    local t_`v' = r(max)
    quietly summarize `v' if Period==`t_`v'', meanonly
    local val_`v' = r(mean)
}

// 2) Build legend order (descending by last value) — FIXED MATA
mata:
    vals = ( `val_lpri_jp' \ `val_lpri_aus' \ `val_lpri_fra' \ `val_lpri_ger' \ `val_lpri_uk' \ `val_lpri' )
    idx  = ( 1 \ 2 \ 3 \ 4 \ 5 \ 6 )
    ord = order(-vals,1)
    idx_ord = idx[ord]
    st_local("legend_nums", invtokens(strofreal(idx_ord')))
end

// Plot with dynamic legend order and readable labels
tsline lpri_jp lpri_aus lpri_fra lpri_ger lpri_uk lpri, ///
    legend(order(`legend_nums') pos(2) col(1) size(2.5) ///
           label(1 "Japan") ///
           label(2 "Australia") ///
           label(3 "France") ///
           label(4 "Germany") ///
           label(5 "United Kingdom") ///
           label(6 "United States")) ///
    name(Figure_C1a, replace) xti("") yline(0) ///
	ti("Relations with China (Log-modulus transform)", ///
	size(small))
graph export Figure_C1a.png, as(png) width(4000) replace

	
// East

// 1) Last nonmissing value for each series
foreach v in lpri_indo lpri_pak lpri_rus lpri_vn lpri_india lpri_cds {
    quietly summarize Period if !missing(`v'), meanonly
    local t_`v' = r(max)
    quietly summarize `v' if Period==`t_`v'', meanonly
    local val_`v' = r(mean)
}

// Build legend order (descending by last value) — Mata
mata:
    vals = ( ///
        `val_lpri_indo' \ ///
        `val_lpri_pak'  \ ///
        `val_lpri_rus'  \ ///
        `val_lpri_vn'   \ ///
        `val_lpri_india'\ ///
        `val_lpri_cds' )
    idx  = (1 \ 2 \ 3 \ 4 \ 5 \ 6)
    ord = order(-vals,1)
    idx_ord = idx[ord]
    st_local("legend_nums", invtokens(strofreal(idx_ord')))
end

// Plot with dynamic legend order and readable labels
tsline lpri_indo lpri_pak lpri_rus lpri_vn lpri_india lpri_cds, ///
    legend(order(`legend_nums') pos(2) col(1) size(2.5) ///
           label(1 "Indonesia") ///
           label(2 "Pakistan")  ///
           label(3 "Russia")    ///
           label(4 "Vietnam")   ///
           label(5 "India")     ///
           label(6 "South Korea"))     ///
    name(Figure_C1b, replace) xti("") yline(0) ///
	ti("Relations with China (Log-modulus transform)", ///
	size(small))
graph export Figure_C1b.png, as(png) width(4000) replace
 
**# Figure C2. Oil price reaction to an improvement of PRI between the US and China, controlling for military alliances.

cap gen dllgop = d.llgop
cap gen dl2lgop = d.l2lgop 

locproj lwti lpri llwip d.llgop l2lwip d.l2lgop ///
 d.lpri_*, ///
 h(0/48) yl(3) sl(2) ///
 m(ivregress gmm) ///
 instr(d2.pri) z noisily stats ///
 conf(90) r lcolor(green) ///
 save irfn(Mean) tti(Months)

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 dlpri_*, ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(25) vce(r) conf(90) ///
 save irfn(Q25)

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 dlpri_*, ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(50) conf(90) ///
 save irfn(Q50)

locproj lwti lpri llwip dllgop l2lwip dl2lgop ///
 dlpri_*, ///
 h(0/48) yl(3) sl(2) ///
 m(ivqregress iqr) ///
 instr(d2pri) noisily stats q(75) conf(90) ///
 save irfn(Q75)

lpgraph Mean, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP) ///
 lcolor(green) z

lpgraph Mean Q25 Q50 Q75, h(0/48) tti(Months) ///
 separate ///
 tti(Months) ti1(IV-LP) ti2(Low - Q25) ///
 ti3(Median) ti4(High - Q75) ///
 lcolor(green) z grname(Figure_C2)
graph export Figure_C2.png, as(png) width(4000) replace

graph close Graph

log close _all
exit

**# End of program

********************************************************************************