**#******** Download the map files *****************************

spshape2dta ne_10m_admin_1_states_provinces, replace

// Download Regional GDP for China and merge it

import excel Regional_GDP.xlsx, sheet("Feuil1") ///
 cellrange(B1:G32) firstrow clear

save Regional_GDP.dta, replace 

use ne_10m_admin_1_states_provinces.dta, replace

merge 1:1 _ID using "Regional_GDP.dta", nogenerate

**#*** Draw the map for Chinese regions ************************

// Run everything between preserve and restore

grmap, activate

generate length = strlen(name)

preserve

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap length using ne_10m_admin_1_states_provinces_shp.dta, ///
 fcolor(Blues) ///
 osize(vvthin ..) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5))
 
graph rename Graph map_china_regions, replace

graph export map_china_regions.png, as(png) ///
 width(4000) replace
graph export map_china_regions.pdf, as(pdf) ///
 replace

restore

// Run everything between preserve and restore

preserve

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap length using ne_10m_admin_1_states_provinces_shp.dta, ///
 fcolor(Blues) ///
 osize(vvthin ..) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name_zht) size(*.5))

graph rename Graph map_china_regions_cn, replace

graph export map_china_regions_cn.png, as(png) ///
 width(4000) replace
graph export map_china_regions_cn.pdf, as(pdf) ///
 replace
 
restore

**#*** Draw the map for Chinese regional GDP *******************

// Download Regional GDP for China and merge it

import excel Regional_GDP.xlsx, sheet("Feuil1") ///
 cellrange(B1:G32) firstrow clear

save Regional_GDP.dta, replace 

use ne_10m_admin_1_states_provinces.dta, replace

// Merging regional GDP and IDs
merge 1:1 _ID using "Regional_GDP.dta", nogenerate

// Run everything between preserve and restore

preserve

format GDP_* %4.2f

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap GDP_2021 using ///
 ne_10m_admin_1_states_provinces_shp.dta, ///
 fcolor(YlOrRd)  ///
 osize(vvthin ..) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("GDP per capita in thousands of Chinese Yuan (2021)") ///
 label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5) length(50))
 
graph rename Graph map_china_regions_gdp, replace

graph export map_china_regions_gdp.png, as(png) ///
 width(4000) replace
graph export map_china_regions_gdp.pdf, as(pdf) ///
 replace
 
restore

save maps_china_ne.dta, replace 
 
**#**** End of the program *************************************