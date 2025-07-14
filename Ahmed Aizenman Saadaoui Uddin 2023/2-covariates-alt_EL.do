**#************ Covariates *************************************

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
log using covariates.log, name(covariates) text replace

**#************ Interest rates *********************************

*dbnomics data, provider(IMF) dataset(IFS) clear

dbnomics import, pr(IMF) d(IFS) ///
         sdmx(Q..FPOLM_PA) clear

split  series_name, parse(–)
encode series_name2, generate(cn)
encode ref_area, generate(iso2c) 
rename series_name2 cn2
keep   cn cn2 ref_area iso2c period_start_day value
order  cn cn2 ref_area iso2c period_start_day value

destring value, replace force
rename   value PRATE

split    period_start_day, parse(-)
gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate qtr = quarter(date2)
generate period = qofd(date2)
format   period %tq

kountry  ref_area, from(iso2c) to(imfn)
rename   _IMFN_ imfcode
xtset    iso2c period
tsfill,  full
decode   iso2c, generate(ISO2C)
kountry  ISO2C, from(iso2c) to(imfn)
rename   _IMFN_ imfcode2
keep     cn cn2 iso2c ISO2C iso ref_area imfcode2 period PRATE
order    cn cn2 iso2c ISO2C iso ref_area imfcode2 period PRATE, first
drop     if period <= tq(2015q1)
drop     if imfcode2 == .

tabstat PRATE, by(period) stat(count) 

save quaterly-polrates.dta, replace

use  quaterly-polrates.dta, clear

xtset   iso2c period
keep    if period == tq(2020q4) | period == tq(2021q2) | ///
           period == tq(2022q2)
keep    if period == tq(2020q4)
rename  PRATE PRATE20q4
drop    if PRATE20q4 == .
rename  imfcode2 imfcode

save pratesbefore.dta, replace

use  quaterly-polrates.dta, clear

xtset   iso2c period
keep    if period == tq(2021q2) | ///
           period == tq(2022q2)
sort    ISO2C		   
by      ISO2C:  gen dPRATE = ( ( PRATE[_n] - PRATE[_n-1] ) )
rename  dPRATE dPRATE22q2_21q2
drop    if dPRATE22q2_21q2 == .
drop    PRATE
rename  imfcode2 imfcode

save pratesduring.dta, replace

// Merge

use    cross-section-data-alt.dta, clear // RESGDP2020
sort   imfcode
merge  1:1 imfcode using pratesbefore.dta
drop   cn2 ISO2C ref_area period _merge
drop   if FX == .
sort imfcode
merge  1:1 imfcode using pratesduring.dta
drop   cn2 ISO2C ref_area period _merge
drop   if FX == .
mdesc  PRATE20q4 dPRATE22q2_21q2 if dFX > 0

tabstat PRATE20q4 dPRATE22q2_21q2, by(country) stat(count) 

save   cross-section-data-1.dta, replace

scatter dPRATE22q2_21q2 PRATE20q4, mlabel(iso2c) ///
        xtitle(PRATE20q4)

*		
*		
*
*		
**#************ Deposit rates **********************************

*dbnomics data, provider(IMF) dataset(IFS) clear

dbnomics import, pr(IMF) d(IFS) ///
         sdmx(Q..FIDR_PA) clear

split  series_name, parse(–)
encode series_name2, generate(cn)
encode ref_area, generate(iso2c) 
rename series_name2 cn2
keep   cn cn2 ref_area iso2c period_start_day value
order  cn cn2 ref_area iso2c period_start_day value

destring value, replace force
rename   value DRATE

split    period_start_day, parse(-)
gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate qtr = quarter(date2)
generate period = qofd(date2)
format   period %tq

kountry  ref_area, from(iso2c) to(imfn)
rename   _IMFN_ imfcode
xtset    iso2c period
tsfill,  full
decode   iso2c, generate(ISO2C)
kountry  ISO2C, from(iso2c) to(imfn)
rename   _IMFN_ imfcode2
keep     cn cn2 iso2c ISO2C iso ref_area imfcode2 period DRATE
order    cn cn2 iso2c ISO2C iso ref_area imfcode2 period DRATE, first
drop     if period <= tq(2015q1)
drop     if imfcode2 == .

tabstat DRATE, by(period) stat(count) 

save quaterly-drates.dta, replace

use  quaterly-drates.dta, clear

xtset   iso2c period
keep    if period == tq(2020q4) | period == tq(2021q2) | ///
           period == tq(2022q2)
keep    if period == tq(2020q4)
rename  DRATE DRATE20q4
drop    if DRATE20q4 == .
rename  imfcode2 imfcode

save dratesbefore.dta, replace

use  quaterly-drates.dta, clear

xtset   iso2c period
keep    if period == tq(2021q2) | ///
           period == tq(2022q2)
sort    ISO2C		   
by      ISO2C:  gen dDRATE = ( ( DRATE[_n] - DRATE[_n-1] ) )
rename  dDRATE dDRATE22q2_21q2
drop    if dDRATE22q2_21q2 == .
drop    DRATE
rename  imfcode2 imfcode

save dratesduring.dta, replace

// Merge

use    cross-section-data-1.dta, clear
sort   imfcode
merge  1:1 imfcode using dratesbefore.dta
drop   cn2 ISO2C ref_area period _merge
drop   if FX == .
sort imfcode
merge  1:1 imfcode using dratesduring.dta
drop   cn2 ISO2C ref_area period _merge
drop   if FX == .
mdesc  DRATE20q4 dDRATE22q2_21q2 if dFX > 0

tabstat DRATE20q4 dDRATE22q2_21q2, by(country) stat(count) 

gen     RATE20q4 = PRATE20q4
replace RATE20q4 = DRATE20q4 if PRATE20q4 == . 

gen     dRATE22q2_21q2 = dPRATE22q2_21q2
replace dRATE22q2_21q2 = dDRATE22q2_21q2 if dPRATE22q2_21q2 == .

mdesc  RATE20q4 dRATE22q2_21q2 if dFX > 0

scatter dRATE22q2_21q2 RATE20q4 if dFX > 0, ///
        mlabel(iso2c) xtitle(RATE20q4)		

reg dFX RESGDP RATE20q4 dRATE22q2_21q2 if ///
        dFX>0 & dFX<50, robust
		 
save   cross-section-data-2.dta, replace		
		
**#************* GDP per capita ********************************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("NY.GDP.PCAP.KD") clear
rename   value GDP_PK
destring GDP_PK, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period GDP_PK
order    cn country period GDP_PK
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period GDP_PK
xtset    cn period
egen     reference = total((country == "USA") * ///
         GDP_PK), by(period)
gen      RGDP_PK = 100*(GDP_PK/reference)
save     gdp-per-capita-wdi.dta, replace

use      gdp-per-capita-wdi.dta, replace
keep     if period == 2019
rename   RGDP_PK RGDP_PK_2019
keep     cn country imfcode period RGDP_PK_2019
drop     if imfcode == .
sort     imfcode
save     RGDP_PK_2019.dta, replace

use      gdp-per-capita-wdi.dta, replace
keep     if period == 2020
rename   RGDP_PK RGDP_PK_2020
keep     cn country imfcode period RGDP_PK_2020
drop     if imfcode == .
sort     imfcode
save     RGDP_PK_2020.dta, replace

// Merge

use    cross-section-data-2.dta, clear
sort   imfcode
merge  1:1 imfcode using RGDP_PK_2019.dta
drop   period _merge
drop   if FX == .
merge  1:1 imfcode using RGDP_PK_2020.dta
drop   period _merge
drop   if FX == .
save   cross-section-data-3.dta, replace

**#***************** Consumer Price Index **********************

dbnomics import, provider(IMF) dataset(IFS)  ///
         sdmx(A..PCPI_IX) clear
rename   value PCPI
destring PCPI, replace force 
split    series_name, parse(–)
encode   series_name2, generate(cn)
keep     cn ref_area period PCPI
order    cn ref_area period PCPI
kountry  ref_area, from(iso2c) to(imfn) m
list     cn ref_area _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0 & _IMFN_ == .
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn ref_area imfcode period PCPI
xtset    cn period
egen     reference = total((ref_area == "US") * ///
         PCPI), by(period)
gen      RPCPI = 100*(PCPI/reference)
save     rcpi-wdi.dta, replace

use      rcpi-wdi.dta, replace
keep     if period == 2019
rename   RPCPI RPCPI_2019
keep     cn ref_area imfcode period RPCPI_2019
drop     if imfcode == .
sort     imfcode
save     RPCPI_2019.dta, replace

use      rcpi-wdi.dta, replace
keep     if period == 2020
rename   RPCPI RPCPI_2020
keep     cn ref_area imfcode period RPCPI_2020
drop     if imfcode == .
sort     imfcode
save     RPCPI_2020.dta, replace

// Merge

use    cross-section-data-3.dta, clear
sort   imfcode
merge  1:1 imfcode using RPCPI_2019.dta
drop   ref_area period _merge
drop   if FX == .
merge  1:1 imfcode using RPCPI_2020.dta
drop   ref_area period _merge
drop   if FX == .
save   cross-section-data-4.dta, replace

**#***************** Current account balance *******************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("BN.CAB.XOKA.GD.ZS") clear
rename   value CAB
destring CAB, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period CAB
order    cn country period CAB
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period
xtset    cn period
*egen     reference = total((country == "USA") * ///
*         GDP_PK), by(period)
*gen      RGDP_PK = 100*(GDP_PK/reference)
save     cab-wdi.dta, replace

use      cab-wdi.dta, replace
keep     if period == 2019
rename   CAB CAB_2019
keep     cn country imfcode period CAB_2019
drop     if imfcode == .
sort     imfcode
save     CAB_2019.dta, replace

use      cab-wdi.dta, replace
keep     if period == 2020
rename   CAB CAB_2020
keep     cn country imfcode period CAB_2020
drop     if imfcode == .
sort     imfcode
save     CAB_2020.dta, replace

// Merge

use    cross-section-data-4.dta, clear
sort   imfcode
merge  1:1 imfcode using CAB_2019.dta
drop   period _merge
drop   if FX == .
merge  1:1 imfcode using CAB_2020.dta
drop   period _merge
drop   if FX == .
save   cross-section-data-5.dta, replace

/*
gen    cnsmpl = 1 if RESGDP != . & RATE20q4 != . &     ///
       dRATE22q2_21q2 != .  & RGDP_PK_2019 != .  &     ///
	   RPCPI_2019 != . & CAB_2019 != .
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2 RGDP_PK_2019 /// 
       RPCPI_2019 CAB_2019 if dFX>0 & dFX<50,          /// 
	   cluster(imfcode)
*/

**#******** Net International Investment Position **************

import   excel EWN-dataset_12-2022_JS.xlsx,      ///
         sheet("Dataset (2)") firstrow clear
/*
change IMF code of Serbia from 942 to 965 for 
consistency in LMF
*/
rename   IFS_Code imfcode
rename   Year period	   
keep     Country imfcode period NIIP   
save     niip-lmf.dta, replace

use      niip-lmf.dta, replace
keep     if period == 2019
rename   NIIP NIIP_2019
keep     Country imfcode period NIIP_2019
drop     if imfcode == .
sort     imfcode
save     NIIP_2019.dta, replace

use      niip-lmf.dta, replace
keep     if period == 2020
rename   NIIP NIIP_2020
keep     Country imfcode period NIIP_2020
drop     if imfcode == .
sort     imfcode
save     NIIP_2020.dta, replace

// Merge

use    cross-section-data-5.dta, clear
sort   imfcode
merge  1:1 imfcode using NIIP_2019.dta
drop   Country period _merge
drop   if FX == .
merge  1:1 imfcode using NIIP_2020.dta
drop   Country period _merge
drop   if FX == .
save   cross-section-data-6.dta, replace

use    cross-section-data-6.dta, clear
gen    NIIP_19 = 100*NIIP_2019
gen    NIIP_20 = 100*NIIP_2020
save   cross-section-data-6.dta, replace

/*
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2  ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019    ///
	   NIIP_2019 if dFX>0 & dFX<50, robust
*/

**#******** Financial openness *********************************

use    kaopen_ci_2020.dta,  ///
       clear
/*
change IMF code of Serbia from 942 to 965 for 
consistency in LMF
*/
rename   cn imfcode
rename   year period	   
save     kaopen_ci.dta, replace

use      kaopen_ci.dta, replace
keep     if period == 2019
rename   kaopen kaopen_2019
keep     country_name ccode imfcode period kaopen_2019
order    country_name ccode imfcode period kaopen_2019, first

drop     if imfcode == .
sort     imfcode
save     kaopen_2019.dta, replace

use      kaopen_ci.dta, replace
keep     if period == 2020
rename   kaopen kaopen_2020
keep     country_name ccode imfcode period kaopen_2020
order    country_name ccode imfcode period kaopen_2020, first

drop     if imfcode == .
sort     imfcode
save     kaopen_2020.dta, replace

// Merge

use    cross-section-data-6.dta, clear
sort   imfcode
merge  1:1 imfcode using kaopen_2019.dta
drop   country_name ccode period _merge
drop   if FX == .
merge  1:1 imfcode using kaopen_2020.dta
drop   country_name ccode period _merge
drop   if FX == .
gen    RATE20q4_100 = RATE20q4/100  
egen   ref = total((country == "USA") * ///
       dRATE22q2_21q2)
gen    dRATE22q2_21q2_RUS = dRATE22q2_21q2 - ///
       ref 
drop   ref
save   cross-section-data-7.dta, replace

/*
reg    dFX RESGDP RATE20q4                    ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	   NIIP_19 kaopen_2019                    ///
	   if dFX<50, robust

reg    dFX RESGDP RATE20q4 dRATE22q2_21q2     ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	   NIIP_19 kaopen_2019                    ///
	   if dFX>0 & dFX<50, robust
*/

**#******** ERS ************************************************

use     trilemma_indexes_update2020.dta,  ///
        clear
/*
change IMF code of Serbia from 942 to 965 for 
consistency in LMF
*/

rename   cn imfcode
rename   year period
keep     imfcode country_name period ers	   
save     ers_aci.dta, replace

use      ers_aci.dta, replace
keep     if period == 2019
rename   ers ers_2019
keep     country_name imfcode period ers_2019
order    country_name imfcode period ers_2019, first

drop     if imfcode == .
sort     imfcode
save     ers_2019.dta, replace

use      ers_aci.dta, replace
keep     if period == 2020
rename   ers ers_2020
keep     country_name imfcode period ers_2020
order    country_name imfcode period ers_2020, first

drop     if imfcode == .
sort     imfcode
save     ers_2020.dta, replace

// Merge

use    cross-section-data-7.dta, clear
sort   imfcode
merge  1:1 imfcode using ers_2019.dta
drop   country_name period _merge
drop   if FX == .
merge  1:1 imfcode using ers_2020.dta
drop   country_name period _merge
drop   if FX == .
save   cross-section-data-8.dta, replace

/*
reg    dFX RESGDP RATE20q4                    ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	   NIIP_19 kaopen_2019 ers_2019           ///
	   if dFX<50, robust

hetreg    dFX RESGDP RATE20q4                    ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	      NIIP_19 kaopen_2019 ers_2019           ///
	      if dFX<50

reg    dFX RESGDP RATE20q4                    ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	   NIIP_19 kaopen_2019 ers_2019           ///
	   if dFX>0 & dFX<50, robust

hetreg    dFX RESGDP RATE20q4                    ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	      NIIP_19 kaopen_2019 ers_2019           ///
	      if dFX!=0 & dFX<50	  
*/

**#***************** Fin Dev ***********************************

dbnomics import, provider(IMF) dataset(FDI)  ///
         sdmx(A..FD_FD_IX) clear
rename   value FD
split    series_name, parse(–)
encode   series_name2, generate(cn)
keep     cn ref_area period FD
order    cn ref_area period FD
kountry  ref_area, from(iso2c) to(imfn) m
list     cn ref_area _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0 & _IMFN_ == .
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn ref_area imfcode period FD
xtset    cn period
save     fd-fdi.dta, replace

use      fd-fdi.dta, replace
keep     if period == 2019
rename   FD FD_2019
keep     cn ref_area imfcode period FD_2019
drop     if imfcode == .
sort     imfcode
save     FD_2019.dta, replace

use      fd-fdi.dta, replace
keep     if period == 2020
rename   FD FD_2020
keep     cn ref_area imfcode period FD_2020
drop     if imfcode == .
sort     imfcode
save     FD_2020.dta, replace

// Merge

use    cross-section-data-8.dta, clear
sort   imfcode
merge  1:1 imfcode using FD_2019.dta
drop   ref_area period _merge
drop   if FX == .
merge  1:1 imfcode using FD_2020.dta
drop   ref_area period _merge
drop   if FX == .
save   cross-section-data-9.dta, replace

**#***************** Fin Inst **********************************

dbnomics import, provider(IMF) dataset(FDI)  ///
         sdmx(A..FD_FI_IX) clear
rename   value FI
split    series_name, parse(–)
encode   series_name2, generate(cn)
keep     cn ref_area period FI
order    cn ref_area period FI
kountry  ref_area, from(iso2c) to(imfn) m
list     cn ref_area _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0 & _IMFN_ == .
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn ref_area imfcode period FI
xtset    cn period
save     fi-fdi.dta, replace

use      fi-fdi.dta, replace
keep     if period == 2019
rename   FI FI_2019
keep     cn ref_area imfcode period FI_2019
drop     if imfcode == .
sort     imfcode
save     FI_2019.dta, replace

use      fi-fdi.dta, replace
keep     if period == 2020
rename   FI FI_2020
keep     cn ref_area imfcode period FI_2020
drop     if imfcode == .
sort     imfcode
save     FI_2020.dta, replace

// Merge

use    cross-section-data-9.dta, clear
sort   imfcode
merge  1:1 imfcode using FI_2019.dta
drop   ref_area period _merge
drop   if FX == .
merge  1:1 imfcode using FI_2020.dta
drop   ref_area period _merge
drop   if FX == .
save   cross-section-data-10.dta, replace

reg    dFX RESGDP RATE20q4                    ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019       ///
	   NIIP_19 kaopen_2019 ers_2019           ///
	   FD_2019                                /// 
	   if dFX>0 & dFX<50, robust

**#***************** Fin Markets *******************************

dbnomics import, provider(IMF) dataset(FDI)  ///
         sdmx(A..FD_FM_IX) clear
rename   value FM
split    series_name, parse(–)
encode   series_name2, generate(cn)
keep     cn ref_area period FM
order    cn ref_area period FM
kountry  ref_area, from(iso2c) to(imfn) m
list     cn ref_area _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0 & _IMFN_ == .
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn ref_area imfcode period FM
xtset    cn period
save     fm-fdi.dta, replace

use      fm-fdi.dta, replace
keep     if period == 2019
rename   FM FM_2019
keep     cn ref_area imfcode period FM_2019
drop     if imfcode == .
sort     imfcode
save     FM_2019.dta, replace

use      fm-fdi.dta, replace
keep     if period == 2020
rename   FM FM_2020
keep     cn ref_area imfcode period FM_2020
drop     if imfcode == .
sort     imfcode
save     FM_2020.dta, replace

// Merge

use    cross-section-data-10.dta, clear
sort   imfcode
merge  1:1 imfcode using FM_2019.dta
drop   ref_area period _merge
drop   if FX == .
merge  1:1 imfcode using FM_2020.dta
drop   ref_area period _merge
drop   if FX == .
save   cross-section-data-11.dta, replace

stepwise, pr(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019            ///
	   if dFX!=0 & dFX<70, robust

**#************* Trade openness ********************************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("NE.TRD.GNFS.ZS") clear
rename   value OPEN
destring OPEN, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period OPEN
order    cn country period OPEN
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period OPEN
xtset    cn period
save     openness-wdi.dta, replace

use      openness-wdi.dta, replace
keep     if period == 2019
rename   OPEN OPEN_2019
keep     cn country imfcode period OPEN_2019
drop     if imfcode == .
sort     imfcode
save     OPEN_2019.dta, replace

use      openness-wdi.dta, replace
keep     if period == 2020
rename   OPEN OPEN_2020
keep     cn country imfcode period OPEN_2020
drop     if imfcode == .
sort     imfcode
save     OPEN_2020.dta, replace

// Merge

use    cross-section-data-11.dta, clear
sort   imfcode
merge  1:1 imfcode using OPEN_2019.dta
drop   period _merge
drop   if FX == .
merge  1:1 imfcode using OPEN_2020.dta
drop   period _merge
drop   if FX == .
save   cross-section-data-12.dta, replace

reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   if dFX!=0 & dFX<70, robust

stepwise, pr(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   if dFX!=0 & dFX<70, robust

stepwise, pe(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   if dFX!=0 & dFX<70, robust
	   
**#************ Fuel export on total exports *******************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("TX.VAL.FUEL.ZS.UN") clear
rename   value FUELX
destring FUELX, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period FUELX
order    cn country period FUELX
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period FUELX
xtset    cn period
*egen     reference = total((country == "USA") * ///
*         GDP_PK), by(period)
*gen      RGDP_PK = 100*(GDP_PK/reference)
save     fuelx-wdi.dta, replace

use      fuelx-wdi.dta, replace
keep     if period == 2019
rename   FUELX FUELX_2019
keep     cn country imfcode period FUELX_2019
drop     if imfcode == .
sort     imfcode
save     FUELX_2019.dta, replace

use      fuelx-wdi.dta, replace
keep     if period == 2020
rename   FUELX FUELX_2020
keep     cn country imfcode period FUELX_2020
drop     if imfcode == .
sort     imfcode
save     FUELX_2020.dta, replace

// Merge

use    cross-section-data-12.dta, clear
sort   imfcode
merge  1:1 imfcode using FUELX_2019.dta
drop   period _merge
drop   if FX == .
merge  1:1 imfcode using FUELX_2020.dta
drop   period _merge
drop   if FX == .
save   cross-section-data-13.dta, replace

reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019                              ///
	   if dFX!=0 & dFX<70, robust

stepwise, pr(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019                              ///
	   if dFX!=0 & dFX<70, robust

stepwise, pe(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019                              ///
	   if dFX!=0 & dFX<70, robust
	   
**#************ Fuel import on total imports *******************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("TM.VAL.FUEL.ZS.UN") clear
rename   value FUELM
destring FUELM, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period FUELM
order    cn country period FUELM
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period FUELM
xtset    cn period
*egen     reference = total((country == "USA") * ///
*         GDP_PK), by(period)
*gen      RGDP_PK = 100*(GDP_PK/reference)
save     fuelm-wdi.dta, replace

use      fuelm-wdi.dta, replace
keep     if period == 2019
rename   FUELM FUELM_2019
keep     cn country imfcode period FUELM_2019
drop     if imfcode == .
sort     imfcode
save     FUELM_2019.dta, replace

use      fuelm-wdi.dta, replace
keep     if period == 2020
rename   FUELM FUELM_2020
keep     cn country imfcode period FUELM_2020
drop     if imfcode == .
sort     imfcode
save     FUELM_2020.dta, replace

// Merge

use    cross-section-data-13.dta, clear
sort   imfcode
merge  1:1 imfcode using FUELM_2019.dta
drop   period _merge
drop   if FX == .
merge  1:1 imfcode using FUELM_2020.dta
drop   period _merge
drop   if FX == .
save   cross-section-data-14.dta, replace

sum    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019 FUELM_2019
	   
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019 FUELM_2019                   ///
	   if dFX!=0 & dFX<70 &                    ///
	   country!="USA", robust

stepwise, pr(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019 FUELM_2019                   ///
	   if dFX!=0 & dFX<70 &                    ///
	   country!="USA", robust

stepwise, pe(.2):                              ///
reg    dFX RESGDP RATE20q4 dRATE22q2_21q2      ///
       RGDP_PK_2019 RPCPI_2019 CAB_2019        ///
	   NIIP_19 kaopen_2019 ers_2019 OPEN_2019  ///
	   FUELX_2019 FUELM_2019                   ///
	   if dFX!=0 & dFX<70, robust

// Put the file provided by Hiro into the PERSONAL folder
// Using group_dummy provided by Hiroyuki Ito 
// (Skip the country dummies if you don't have the ado file)	   

rename cn cn2

rename imfcode cn
	   
group_dummy

rename cn imfcode

save   cross-section-data-15-alt.dta, replace

**#************ External debt stocks ***************************

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("DT.DOD.DECT.GN.ZS") clear
rename   value DEBT
destring DEBT, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period DEBT
order    cn country period DEBT
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period DEBT
xtset    cn period
*egen     reference = total((country == "USA") * ///
*         GDP_PK), by(period)
*gen      RGDP_PK = 100*(GDP_PK/reference)
save     debt-wdi.dta, replace

use      debt-wdi.dta, replace
keep     if period == 2019
rename   DEBT DEBT_2019
keep     cn country imfcode period DEBT_2019
drop     if imfcode == .
sort     imfcode
save     DEBT_2019.dta, replace

use      debt-wdi.dta, replace
keep     if period == 2020
rename   DEBT DEBT_2020
keep     cn country imfcode period DEBT_2020
drop     if imfcode == .
sort     imfcode
save     DEBT_2020.dta, replace

// Merge

use    cross-section-data-15-alt.dta, clear
sort   imfcode
merge  1:1 imfcode using DEBT_2019.dta
drop   period cn _merge
drop   if FX == .
merge  1:1 imfcode using DEBT_2020.dta
drop   period cn _merge
drop   if FX == .
save   cross-section-data-16-alt.dta, replace

**#************ Rule of Law ************************************

dbnomics import, provider(WB) dataset(WGI)      ///
         indicator("RL.EST") clear
rename   value RULE
destring RULE, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period RULE
order    cn country period RULE
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period RULE
xtset    cn period
*egen     reference = total((country == "USA") * ///
*         GDP_PK), by(period)
*gen      RGDP_PK = 100*(GDP_PK/reference)
save     rule-wgi.dta, replace

use      rule-wgi.dta, replace
keep     if period == 2019
rename   RULE RULE_2019
keep     cn country imfcode period RULE_2019
drop     if imfcode == .
sort     imfcode
save     RULE_2019.dta, replace

use      rule-wgi.dta, replace
keep     if period == 2020
rename   RULE RULE_2020
keep     cn country imfcode period RULE_2020
drop     if imfcode == .
sort     imfcode
save     RULE_2020.dta, replace

// Merge

use    cross-section-data-16-alt.dta, clear
sort   imfcode
merge  1:1 imfcode using RULE_2019.dta
drop   period cn _merge
drop   if FX == .
merge  1:1 imfcode using RULE_2020.dta
drop   period cn _merge
drop   if FX == .
save   cross-section-data-17-alt.dta, replace

*********** REER misalignment **********************************

use     REER_ANNUAL_WIDE_170.dta,  ///
        clear
/*
change IMF code of Serbia from 942 to 965 for 
consistency in BRUEGEL
*/

replace  cn = 965 if country_name == "Serbia"

rename   cn imfcode
rename   year period
rename   reer_ REER
keep     imfcode country_name period REER	   
order    country_name imfcode period REER
sort     imfcode period
encode   country_name, generate(cn)
order    cn country_name imfcode period REER
egen     REERmean = mean(REER) if period>=2014 & ///
                    period<=2018,                ///
				    by(imfcode)
*ssc     install carryforward
bysort   imfcode: carryforward REERmean, gen(REERm)
sort     imfcode period
drop     REERmean
gen      REERmis = (REER / REERm)*100
save     reer.dta, replace

use      reer.dta, replace
keep     if period == 2019
rename   REERmis REERmis2019
keep     country_name imfcode period REERmis2019
order    country_name imfcode period REERmis2019, first

drop     if imfcode == .
sort     imfcode
save     REERmis_2019.dta, replace

use      reer.dta, replace
keep     if period == 2020
rename   REERmis REERmis2020
keep     country_name imfcode period REERmis2020
order    country_name imfcode period REERmis2020, first

drop     if imfcode == .
sort     imfcode
save     REERmis_2020.dta, replace

// Merge

use    cross-section-data-17-alt.dta, clear
sort   imfcode
merge  1:1 imfcode using REERmis_2019.dta
drop   country_name period _merge
drop   if FX == .
merge  1:1 imfcode using REERmis_2020.dta
drop   country_name period _merge
drop   if FX == .
save   cross-section-data-18-alt.dta, replace

// Merge with dFX2021m11 (EL Revision)

use    cross-section-data-2021m11.dta, clear
drop   RESGDP2020
save   cross-section-data-2021m11bis.dta, replace 
use    cross-section-data-18-alt.dta, clear
sort   imfcode
merge  1:1 imfcode using cross-section-data-2021m11bis.dta
drop   cn _merge

save   cross-section-data-18-alt-EL.dta, replace

******** Variation of Commodity TOT *****************************

dbnomics import, pr(IMF) d(PCTOT) ///
         sdmx(M..xm_gdp.R_RW_IX) clear
		 
split  series_name, parse(–)
encode series_name2, generate(cn)
encode ref_area, generate(iso2c) 
keep   cn iso2c period_start_day value
order  cn iso2c period_start_day value

destring value, replace force
rename   value CTOT

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
keep    cn iso2c iso imfcode period CTOT
order   cn iso2c iso imfcode period CTOT, first
drop    if imfcode == .

save monthly-ctot.dta, replace

use monthly-ctot.dta, clear

xtset   cn period
tsfill, full
xtset   cn period
keep    if period == tm(2021m5) | period == tm(2022m9)
sort    cn
capture drop dCTOT
by cn:  gen  dCTOT = 100*( ( CTOT[_n] - CTOT[_n-1] ) / CTOT[_n-1])
drop    if dCTOT == .

save monthly-ctot-cross-section.dta

// Merge with cross-section-data-18-alt-EL (EL Revision)

use    cross-section-data-18-alt-EL.dta, clear
sort   imfcode
merge  1:1 imfcode using monthly-ctot-cross-section.dta
drop  if _merge == 2
drop   cn _merge period iso

save   cross-section-data-19-alt-EL.dta, replace

// Merge with cross-section-data-19-alt-EL (EL Revision)

use    cross-section-data-19-alt-EL.dta, clear
sort   imfcode
merge  1:1 imfcode using FXI_interventions.dta
drop  if _merge == 2
drop   _merge iso

save   cross-section-data-20-alt-EL.dta, replace

**#************ Daily Exchange rates (BIS) *********************

import excel "WS_XRU_D_ExportBIS_DailyXR.xlsx", ///
 sheet(daily) firstrow clear
 
drop D E F

kountry REF_AREA, from(iso2c) to(imfn) m
drop    if MARKER == 0
rename  _IMFN_ imfcode

drop CURRENCY NAMES_STD MARKER

save bis-daily-data.dta, replace

use    cross-section-data-20-alt-EL.dta, clear
sort   imfcode
merge  1:1 imfcode using bis-daily-data.dta
drop  if _merge == 2
drop   _merge REF_AREA REF_AREAName

save   cross-section-data-21-alt-EL.dta, replace

**#************ Exchange Rate Markets Pressure (EMP) ***********

use EMP_index_full.dta, clear

rename ifs imfcode

xtset   imfcode date
tsfill, full
xtset   imfcode date
xtdescribe
gen     EMP = emp_usd
keep    if date >= tm(2021m5) & date <= tm(2022m9)
sort    imfcode
capture drop sEMP
collapse (sum) sEMP=EMP, by(country imfcode)
replace sEMP=. if sEMP==0
*drop    if sEMP == .

*net install zscore.pkg
*zscore dEMP

*keep    emp_usd imfcode country_name date EMP dEMP z_dEMP 

save EMP_index_full_cross_section.dta, replace

use    cross-section-data-21-alt-EL.dta, clear
sort   imfcode
merge  1:1 imfcode using EMP_index_full_cross_section.dta
drop  if _merge == 2
drop   _merge country_name

save   cross-section-data-22-alt-EL.dta, replace

****************************************************************


log close _all
exit

**# End of Program