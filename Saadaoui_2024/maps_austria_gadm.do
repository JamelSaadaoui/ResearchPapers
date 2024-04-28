**# **** Maps with GADM data for Austria (Level 1) *************

spshape2dta gadm41_AUT_1, ///
 saving(gadm41_AUT_1) replace

use gadm41_AUT_1.dta, clear

generate length = strlen(NAME_1)

grmap length using gadm41_AUT_1_shp.dta, ///
	fcolor(Blues) ///
	ndfcolor(gray) clmethod(quantile) ///
	polygon(data(gadm41_AUT_1_shp.dta) ///
	select(keep if inlist(_ID,1,9)) ///
	fc(red) os(vvthin)) ///
	os(vvthin ..) ndsize(vvthin) ///
	title("Region name length [length]") ///
	label(xcoord(_CX) ycoord(_CY) ///
	select(keep if inlist(_ID,1,2,7,9)) ///
	label(NAME_1) size(5) length(22) pos(11) angle(340) ///
	gap(-3)) ///
	legend(pos(11) size(5)) legcount

graph rename Graph map_austria_1, replace
graph export map_austria_1.png, as(png) ///
 width(4000) replace
graph export map_austria_1.pdf, as(pdf) ///
 replace
 
**# **** Maps with GADM data for Austria (Level 2) *************

spshape2dta gadm41_AUT_2, ///
 saving(gadm41_AUT_2) replace

use gadm41_AUT_2.dta, clear

generate length = strlen(NAME_2)

grmap length using gadm41_AUT_2_shp.dta, ///
	fcolor(Blues) ///
	ndfcolor(gray) clmethod(quantile) ///
	polygon(data(gadm41_AUT_2_shp.dta) ///
	select(keep if inlist(_ID,2,94)) ///
	fc(red) os(vvthin)) ///
	os(vvthin ..) ndsize(vvthin) ///
	title("Region name length [length]") ///
	label(xcoord(_CX) ycoord(_CY) ///
	select(keep if inlist(_ID,2,83,94)) ///
	label(NAME_2) size(5) length(22) pos(11) angle(340) ///
	gap(-3)) ///
	legend(pos(11) size(5)) legcount
 
graph rename Graph map_austria_2, replace
graph export map_austria_2.png, as(png) ///
 width(4000) replace
graph export map_austria_2.pdf, as(pdf) ///
 replace 
 
**# **** Maps with GADM data for Austria (Level 3) *************
 
spshape2dta gadm41_AUT_3, ///
 saving(gadm41_AUT_3) replace

use gadm41_AUT_3.dta, clear

generate length = strlen(NAME_3)

grmap length using gadm41_AUT_3_shp.dta, id(_ID) ///
 fcolor(Reds)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(gadm41_AUT_3_shp.dta) ///
   select(keep if _ID==24 | ///
  _ID==2100 | _ID==1814) fc(yellow) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==24 | ///
  _ID==2100 | _ID==1814) ///
 label(NAME_3) size(5) length(22) pos(11) angle(340) ///
  gap(-3)) ///
 legend(pos(11) size(5)) legcount 
 
graph rename Graph map_austria_3, replace
graph export map_austria_3.png, as(png) ///
 width(4000) replace
graph export map_austria_3.pdf, as(pdf) ///
 replace

**# **** Maps with GADM data for Austria (Level 4) *************
 
spshape2dta gadm41_AUT_4, ///
 saving(gadm41_AUT_4) replace

use gadm41_AUT_4.dta, clear

generate length = strlen(NAME_4)

grmap length using gadm41_AUT_4_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(gadm41_AUT_4_shp.dta) select(keep if ///
  _ID==7810 | _ID==25 | _ID==7406) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) //////
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==7810 | ///
  _ID==7810 | _ID==25 | _ID==7406) ///
  label(NAME_4) size(5) length(13) pos(8) angle(340) ///
  gap(0) color(black)) ///
 legend(pos(11) size(5)) legcount 
 
graph rename Graph map_austria_4, replace
graph export map_austria_4.png, as(png) ///
 width(4000) replace
graph export map_austria_4.pdf, as(pdf) ///
 replace
 
**# **** Maps with GADM data for Austria (Level 4 Zoom) ********

spshape2dta gadm41_AUT_4, ///
 saving(gadm41_AUT_4) replace

use gadm41_AUT_4.dta, clear

generate length = strlen(NAME_4)

grmap length using gadm41_AUT_4_shp.dta if _ID>=7762, ///
 fcolor(Blues) ///
 ndfcolor(gray) clmethod(quantile) ///
 polygon(data(gadm41_AUT_4_shp.dta) ///
 select(keep if inlist(_ID,7791,7810)) ///
 fc(red) os(vvthin)) ///
 os(vvthin ..) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) ///
 select(keep if inlist(_ID,7791,7810)) ///
 label(NAME_4) size(5) length(13) pos(8) angle(340) ///
 gap(0) color(black)) ///
 legend(pos(11) size(5)) legcount 

graph rename Graph map_austria_4bis, replace
graph export map_austria_4bis.png, as(png) ///
 width(8000) replace
graph export map_austria_4bis.pdf, as(pdf) ///
 replace
 
save maps_austria_gadm.dta, replace 
 
**#**** End of the program *************************************