**#************ Data exploration *******************************

cls

clear

*global Docs = "C:\Users\jamel\Dropbox\Latex\"
*global Proj = "PROJECTS\22-12-reer-tot-res-pm\"
*global Fig = "Figures\"
*global Data = "Data\"
 
*cd "${Docs}"
*cd "${Proj}"
*cd "${Data}"

capture log close _all                                
log using dataEX.log, name(dataEX) text replace

**#************* Daily FX **************************************

import fred DEXBZUS DEXCAUS DEXCHUS DEXDNUS DEXHKUS ///
            DEXINUS DEXJPUS DEXKOUS DEXMAUS DEXMXUS ///
			DEXNOUS DEXSDUS DEXSFUS DEXSIUS DEXSLUS ///
			DEXSZUS DEXTAUS DEXTHUS DEXUSAL DEXUSEU ///
			DEXUSNZ DEXUSUK DEXVZUS, clear

save fx-data-daily.dta, replace
*Board of Governors of the Federal Reserve System (US)

			
tsset daten			
tsfill, full
tsset daten			

describe

stack       DEXBZUS DEXCAUS DEXCHUS DEXDNUS DEXHKUS ///
            DEXINUS DEXJPUS DEXKOUS DEXMAUS DEXMXUS ///
			DEXNOUS DEXSDUS DEXSFUS DEXSIUS DEXSLUS ///
			DEXSZUS DEXTAUS DEXTHUS DEXUSAL DEXUSEU ///
			DEXUSNZ DEXUSUK DEXVZUS, into(FX) clear ///
			wide
rename      _stack cn

gen code = .
tostring code, replace
replace code = "BRA" in 1
replace code = "BRA" if cn == 1		
replace code = "CAN" if cn == 2
replace code = "RMB" if cn == 3
replace code = "DNK" if cn == 4
replace code = "HKG" if cn == 5
replace code = "JPN" if cn == 6
replace code = "IND" if cn == 7
replace code = "KOR" if cn == 8
replace code = "MYS" if cn == 9
replace code = "MEX" if cn == 10
replace code = "NOR" if cn == 11
replace code = "SWE" if cn == 12
replace code = "ZAF" if cn == 13
replace code = "SGP" if cn == 14
replace code = "SLK" if cn == 15
replace code = "CHE" if cn == 16
replace code = "TWN" if cn == 17
replace code = "THA" if cn == 18
replace code = "AUS" if cn == 19
replace code = "EUR" if cn == 20
replace code = "NZD" if cn == 21
replace code = "GBP" if cn == 22
replace code = "VNZ" if cn == 23

			
capture drop        date
bysort cn: generate date = _n - 1 + 4021
format %td          date

drop  DEX*     
order date, first			

keep if date >= td(01jan2020)

xtset cn date
xtdescribe
generate dFX = 100*( (FX - l.FX) / l.FX )

display dofd(mdy(5,1,2021)) 
xtline FX if code=="JPN", overlay     ///
       graphregion(margin(l+10 r+15)) ///
	   xline(22401) title(Japanese Yen)  

save fx-data-daily-collapse.dta, replace

**#********** Cross-sectional FX changes ***********************

*dbnomics data, provider(IMF) dataset(IFS) clear

dbnomics import, pr(IMF) d(IFS) ///
         sdmx(M..ENDA_XDC_USD_RATE) clear

split  series_name, parse(–)
encode series_name2, generate(cn)
encode ref_area, generate(iso2c) 
keep   cn iso2c period_start_day value
order  cn iso2c period_start_day value

destring value, replace force
rename   value FX

split    period_start_day, parse(-)
gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate mth = month(date2)
generate period = mofd(date2)
format   period %tm

decode  iso2c, generate(iso)
kountry iso, from(iso2c) to(imfn) m
list    iso _IMFN_ MARKER /// 
        if period == tm(2020m1) & MARKER == 0
drop    if MARKER == 0
rename  _IMFN_ imfcode
keep    cn iso2c iso imfcode period FX
order   cn iso2c iso imfcode period FX, first
drop    if imfcode == .

save monthly-fx.dta, replace

xtset   cn period
keep    if period == tm(2021m5) | period == tm(2022m9)
sort    iso
capture drop dFX
xtset   cn period
by cn:  gen     dFX = 100*( ( FX[_n] - FX[_n-1] ) / FX[_n-1])
drop    if dFX == .

save monthly-fx-cross-section.dta

**#********** International FX reserves ************************


dbnomics data, provider(WB) dataset(WDI) clear
*dbnomics find "B6BLTT02.STSA.Q", clear // find a series

// International reserves

dbnomics import, provider(WB) dataset(WDI) ///
         indicator("FI.RES.XGLD.CD") clear
rename   value RES
destring RES, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period RES
order    cn country period RES
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period RES
xtset    cn period
save     fx-reserves-wdi.dta, replace

// Current GDP

dbnomics import, provider(WB) dataset(WDI) ///
         indicator("NY.GDP.MKTP.CD") clear
rename   value CURGDP
destring CURGDP, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period CURGDP
order    cn country period CURGDP
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period CURGDP
xtset    cn period
save     current-gdp-wdi.dta, replace

// International reserves-to-GDP

use   fx-reserves-wdi, clear
xtset cn period
xtdescribe

use   current-gdp-wdi, clear
xtset cn period
xtdescribe

merge  1:1 cn period using fx-reserves-wdi.dta
gen    RESGDP = 100*(RES/CURGDP)
drop   if imfcode == .
drop   _merge
save   fx-reserves-gdp-wdi.dta, replace

// Final Data

use   fx-reserves-gdp-wdi.dta, clear
xtset imfcode period
keep  if period == 2021
drop  CURGDP RES
drop  if RESGDP == . 
save  fx-reserves-gdp-wdi-cross-section.dta, replace

use    monthly-fx-cross-section.dta, clear
sort   imfcode
save   monthly-fx-cross-section.dta, replace
merge  1:1 imfcode using fx-reserves-gdp-wdi-cross-section.dta

keep  if _merge == 3
keep  cn iso2c country imfcode FX dFX RESGDP  
order cn iso2c country imfcode FX dFX RESGDP

// Final Data (2020)

use    fx-reserves-gdp-wdi.dta, clear
xtset  imfcode period
keep   if period == 2020
drop   CURGDP RES
drop   if RESGDP == . 
rename RESGDP RESGDP2020
save   fx-reserves-gdp-wdi-cross-section-2020.dta, replace

use    monthly-fx-cross-section.dta, clear
sort   imfcode
merge  1:1 imfcode using                                   ///
           fx-reserves-gdp-wdi-cross-section-2020.dta

keep  if _merge == 3
keep  cn iso2c country imfcode FX dFX RESGDP2020  
order cn iso2c country imfcode FX dFX RESGDP2020
save  cross-section-data-alt.dta, replace


// Scatter plot

capture use cross-section-data, clear

scatter dFX RESGDP if dFX>0 & dFX<70,           ///
        xtitle("FXReserves_i,2020")                  ///
		ytitle("FXUSDReturn_i,may2021-sep2022")      ///
		title("Effectiveness of FXReserves_i, 2020") ///
		name(FXReserves_i_2020, replace)             /// 
		mlabel(iso2c) ||                             ///
		lfit dFX RESGDP if dFX>0 & dFX<70

list cn if dFX>50
// 78 countries with dFX>0 without Lybia & Zimbabwe
// 70 countries with 50>dFX>0 without Lybia & Zimbabwe
	   
graph export ${Fig}FXReserves_i_2021.pdf, replace
graph export ${Fig}FXReserves_i_2021.png, replace

*save cross-section-data.dta, replace

/*

import delimited WS_CBPOL_D_csv_row.csv, /// 
       varnames(2) rowrange(10) clear 
	   
destring   arargentina auaustralia brbrazil ///
		   cacanada chswitzerland clchile   ///
		   cnchina cocolombia czczechia     ///
		   dkdenmark gbunitedkingdom        ///
		   hkhongkongsar hrcroatia          ///
		   huhungary idindonesia ilisrael   ///
		   inindia isiceland jpjapan        ///
		   krkorea mknorthmacedonia         ///
		   mxmexico mymalaysia nonorway     ///
		   nznewzealand peperu              ///
		   phphilippines plpoland roromania ///
		   rsserbia rurussia sasaudiarabia  ///
		   sesweden ththailand trturkey     ///
		   usunitedstates xmeuroarea        ///
		   zasouthafrica, replace force

split referencearea, parse(-)

gen string = referencearea3 + "/" + ///
             referencearea2 + "/" + ///
			 referencearea1

gen    date = date(string, "DMY")
format date %td

drop   referencearea*
rename string date2
order  date2 date, first

save policy-rates.dta, replace

*/

**#********** Cross-sectional FX changes (Economics Letters) ***

use monthly-fx.dta, replace

xtset   cn period
keep    if period == tm(2021m11) | period == tm(2022m9)
*sort    iso
rename  FX FX2021m11
capture drop dFX
by cn: gen  dFX2021m11 = 100*( ( FX[_n] - FX[_n-1] ) / FX[_n-1])
drop    if dFX2021m11 == .

save monthly-fx-cross-section2021m11.dta, replace

// Final Data (2020)

use    monthly-fx-cross-section2021m11.dta, clear
sort   imfcode
merge  1:1 imfcode using                                   ///
           fx-reserves-gdp-wdi-cross-section-2020.dta

keep  if _merge == 3
keep  cn iso2c country imfcode FX dFX RESGDP2020  
order cn iso2c country imfcode FX dFX RESGDP2020
save  cross-section-data-2021m11.dta, replace

// Scatter plot

use cross-section-data-2021m11.dta, clear

scatter dFX2021m11 RESGDP if dFX>0 & dFX<100,                ///
        xtitle("FXReserves_i,2020")                          ///
		ytitle("FXUSDReturn_i,november2021-sep2022")         ///
		title("Effectiveness of FXReserves_i, 2020")         ///
		name(FXReserves_i_2020, replace)                     ///
		mlabel(iso2c) ||                                     ///
		lfit dFX RESGDP if dFX>0 & dFX<100, legend(pos(2)    ///
		ring(0))
		
reg dFX2021m11 RESGDP if dFX>0 & dFX<100, robust
reg dFX2021m11 RESGDP if dFX<100, robust

list cn if dFX>50

log close _all
exit

**# End of Program