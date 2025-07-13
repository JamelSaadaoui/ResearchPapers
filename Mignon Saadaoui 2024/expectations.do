**#*************** BCI *****************************************

cap dbnomics import, pr(OECD) d(MEI_CLI) ///
         sdmx(BSCICP03.G-20.M) clear

destring value, replace
rename   value BCI
split    period_start_day, parse(-)

gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate mth = month(date2)
drop     period
generate period = mofd(date2)
format   period %tm

order    period BCI, first
keep     period BCI

la var   BCI "OECD Business Confidence Index (BCI)"

save     BCI.dta, replace

**#*************** CCI *****************************************

cap dbnomics import, pr(OECD) d(MEI_CLI) ///
         sdmx(CSCICP03.G-20.M) clear

destring value, replace
rename   value CCI
split    period_start_day, parse(-)

gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate mth = month(date2)
drop     period
generate period = mofd(date2)
format   period %tm

order    period CCI, first
keep     period CCI

la var   CCI "Consumer Confidence Index (CCI)"

save     CCI.dta, replace

**#*************** CCI *****************************************

cap dbnomics import, pr(OECD) d(MEI_CLI) ///
         sdmx(LOLITOAA.G-20.M) clear

destring value, replace
rename   value CLI
split    period_start_day, parse(-)

gen      string = period_start_day3 + ///
         "/" + period_start_day2 + ///
         "/" + period_start_day1
gen      date2 = date(string, "DMY")
format   date2 %td
generate mth = month(date2)
drop     period
generate period = mofd(date2)
format   period %tm

order    period CLI, first
keep     period CLI

la var   CLI "Composite Leading Indicator (CLI)"

save     CLI.dta, replace

*********** Merge **********************************************

merge  1:1 period using CCI
drop   _merge
merge  1:1 period using BCI
drop   _merge

tsset period

rename period Period

save expectations.dta, replace

****************************************************************