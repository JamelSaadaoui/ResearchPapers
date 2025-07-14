**# Estimates

cls

clear

*global Docs = "C:\Users\jamel\Dropbox\Latex\"
*global Proj = "PROJECTS\22-12-reer-tot-res-pm\"
*global Fig = "Figures\"
*global Data = "Data\"
*global Estimates = "Estimation\"
 
*cd "${Docs}"
*cd "${Proj}"
*cd "${Estimates}"

capture log close _all                                
log using estimates.smcl, name(estimates) smcl replace

use   cross-section-data-22-alt-EL.dta, clear


**# Fig. 2. Cross-country distribution of FX depreciation from May 2021 to September 2022. Note: FX depreciation on the y-axis corresponds to the percent depreciation against the US dollar.

set scheme stcolor

graph bar dFX if dFX>0 & dFX<100,						///
      over(country, label(angle(90)						///
	  labsize(vsmall))									///
	  gap(25) sort(1) descending)						///
	  ytitle(FX Depreciation (%)) xsize(8)
	  graph rename fx_depre, replace

graph export fx_depre.png, replace
graph export fx_depre.pdf, replace
graph export fx_depre.tif, width(4000) replace

**# Table 1. Dependent variable: FX change from May 2021 - Sep 2022 (%), depreciations only

reg       dFX RESGDP2020                      ///
	      if dFX>0 & dFX<100                  ///
	      , robust
estimate  store dfx_1_EL
		  
reg       dFX RESGDP2020 c.RATE20q4                          ///
          dRATE22q2_21q2                                     ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX>0 & dFX<100                                 ///
	      , robust
estimate  store dfx_2_EL

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                                   ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_3_EL

stepwise, pr(.2):                                                 ///
reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                                   ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_4_EL

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019 DEBT_2019                         ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_5_EL

reg       dFX c.RESGDP2020##c.sum_FXI_broad_proxy_GDP_m  		  ///
          RATE20q4                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                         ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_6_EL

local     switches "dec(4) word se e(rmse)"
outreg2   [dfx_*] ///
          using "dfx_depre.04.08.2023.tex", replace `switches'

**# Fig. 3. Ex ante reserves and FX depreciation from June 16–18, 2021.

scatter   dFXdaily RESGDP2020                                /// 
          if dFXdaily>0 & RESGDP2020<80,                     ///
		  xtitle("Reserves/GDP, 2020")                       ///
		  ytitle("FX Depreciation, June 16-18 2021 (%)")     ///
		  name(FXDReserves_i_2020, replace)                  /// 
		  mlabel(iso2c) xsize(8) ||                          ///
		  lfit dFXdaily RESGDP2020 if                        ///
		  dFXdaily>0 & RESGDP2020<80, legend(off)
		  
graph export fx_depre_daily.png, replace
graph export fx_depre_daily.pdf, replace
graph export fx_depre_daily.tif, width(4000) replace


**# Table A.1: Descriptive statistics

sum       dFX RESGDP2020 RATE20q4 dRATE22q2_21q2      ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019            ///
	      NIIP_19 kaopen_2019 ers_2019 OPEN_2019      ///
	      FUELX_2019 FUELM_2019 DEBT_2019
outreg2   using sum.doc, replace sum(log)             ///
          keep(dFX RESGDP2020 RATE20q4 dRATE22q2_21q2 ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019            ///
	      NIIP_19 kaopen_2019 ers_2019 OPEN_2019      ///
	      FUELX_2019 FUELM_2019 DEBT_2019 FI_2019)

**# Figure A.1: Ex-ante reserves and FX depreciation from May 2021 - Sep 2022

scatter   dFX RESGDP2020 if dFX>0 & dFX<100,            ///
		  xtitle("FX Reserves/GDP, 2020 (%)")           ///
		  ytitle("FX Depreciation, 2021−22, (%)")       ///
		  title("Depreciations Only")                   ///
		  name(A, replace)              /// 
		  mlabel(iso2c) ||                              ///
		  lfit dFX RESGDP if dFX>0 & dFX<100, legend(off)
		  
scatter   dFX RESGDP2020 if dFX!=0 & dFX<100,            ///
		  xtitle("FX Reserves/GDP, 2020 (%)")           ///
		  ytitle("FX Depreciation, 2021−22, (%)")       ///
		  title("Depreciations and Appreciations")      ///
		  name(B, replace)           /// 
		  mlabel(iso2c) ||                              ///
		  lfit dFX RESGDP if dFX!=0 & dFX<100, legend(off)

graph combine A B, ///
 name(FXReserves_i_2020, replace)  
 
graph close A B Graph		  
		  
**# Table A.3: Dependent variable: FX change from May 2021 - Sep 2022 (%), appreciations and depreciations

reg       dFX RESGDP2020                       ///
	      if dFX!=0 & dFX<100                  ///
	      , robust
estimate  store dfxapp_1_EL
		  
reg       dFX RESGDP2020 c.RATE20q4                               ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                                   ///
	      if dFX!=0 & dFX<100                                      ///
	      , robust
estimate  store dfxapp_2_EL

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                                   ///
	      if dFX!=0 & dFX<100                                      ///
	      , robust
estimate  store dfxapp_3_EL

stepwise, pr(.2):                                                 ///
reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019                                   ///
	      if dFX!=0 & dFX<100                                      ///
	      , robust
estimate  store dfxapp_4_EL

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019 DEBT_2019                         ///
	      if dFX!=0 & dFX<100                                      ///
	      , robust
estimate  store dfxapp_5_EL

reg       dFX c.RESGDP2020##c.sum_FXI_broad_proxy_GDP_m  		   ///
          RATE20q4                                                 ///
          dRATE22q2_21q2                                           ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                         ///
	      NIIP_19 ers_2019 OPEN_2019                               ///
	      FUELX_2019 FUELM_2019                                    ///
	      if dFX!=0 & dFX<100                                      ///
	      , robust
estimate  store dfxapp_6_EL

**# Table A.4: Regressions with additional covariates, depreciations only

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019									  ///
		  dCTOT DEBT_2019 RULE_2019 REERmis2019                   ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_1_EL_A4

reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019									  ///
		  dCTOT RULE_2019 REERmis2019                   ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_2_EL_A4

stepwise, pr(.2): ///
reg       dFX RESGDP2020 c.RESGDP2020#c.FI_2019					  ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                       ///
          dRATE22q2_21q2                                          ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                        ///
	      NIIP_19 ers_2019 OPEN_2019                              ///
	      FUELX_2019 FUELM_2019									  ///
		  dCTOT RULE_2019 REERmis2019                   ///
	      if dFX>0 & dFX<100                                      ///
	      , robust
estimate  store dfx_3_EL_A4

**# Table A.5: Regressions with country group interactions, depreciations only

// Country groups

stepwise, pr(.2):                                                       ///
reg       dFX c.RESGDP##c.lac c.RATE20q4##c.kaopen_2019          ///
          dRATE22q2_21q2                                         ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                       ///
	      NIIP_19 ers_2019 OPEN_2019                             ///
	      FUELX_2019 FUELM_2019                                  ///
	      if dFX>0 & dFX<70                        ///
	      , robust 
estimate  store dfxc_1_dFX_EL_A5

/*
Mexico
Jamaica
Guatemala
Honduras
Nicaragua
Peru
Costa Rica
Chile
*/

stepwise, pr(.2):                                                ///
reg       dFX c.RESGDP##c.mena c.RATE20q4##c.kaopen_2019  ///
          dRATE22q2_21q2                                         ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                       ///
	      NIIP_19 ers_2019 OPEN_2019                             ///
	      FUELX_2019 FUELM_2019                                  ///
	      if dFX>0 & dFX<70                       ///
	      , robust 
estimate  store dfxc_2_dFX_EL_A5

/*
Kuwait
Israel
Morocco
Egypt
*/
stepwise, pr(.2):                                                ///
reg       dFX c.RESGDP##c.ssa c.RATE20q4##c.kaopen_2019   ///
          dRATE22q2_21q2                                         ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                       ///
	      NIIP_19 ers_2019 OPEN_2019                             ///
	      FUELX_2019 FUELM_2019                                  ///
	      if dFX>0 & dFX<70                       ///
	      , robust 
estimate  store dfxc_3_dFX_EL_A5
/*
Rwanda
Mauritius
Madagascar
Botswana
Eswatini
South Africa
Namibia
*/
		  
**# Table A.6: Dependent variable: FX change from November 2021 - Sep 2022 (%), depreciations only

reg       dFX2021m11 RESGDP2020                              ///
	      if dFX2021m11>0 & dFX2021m11< 70                   ///
	      , robust
estimate  store dfx_1_EL_A6

reg       dFX2021m11 RESGDP2020                              ///
          RATE20q4                                           ///
          dRATE22q2_21q2                                     ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX2021m11>0 & dFX2021m11< 70                   ///
	      , robust
estimate  store dfx_2_EL_A6

reg       dFX2021m11 RESGDP2020 c.RESGDP2020#c.FI_2019       ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                  ///
          dRATE22q2_21q2                                     ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX2021m11>0 & dFX2021m11< 70                   ///
	      , robust
estimate  store dfx_3_EL_A6

stepwise, pr(.2):                                            ///
reg       dFX2021m11 RESGDP2020 c.RESGDP2020#c.FI_2019       ///
          RATE20q4 c.RATE20q4##c.kaopen_2019                 ///
          dRATE22q2_21q2                                     ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX2021m11>0 & dFX2021m11< 70                   ///
	      , robust
estimate  store dfx_4_EL_A6

reg       dFX2021m11 RESGDP2020 c.RESGDP2020#c.FI_2019       ///
          RATE20q4 c.RATE20q4#c.kaopen_2019                 ///
          dRATE22q2_21q2                                     ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019 DEBT_2019                    ///
	      if dFX2021m11>0 & dFX2021m11< 70                   ///
	      , robust
estimate  store dfx_5_EL_A6		  
		  
**# Table A.7: Dependent variable: Exchange Market Pressure from May 2021 - Sep 2022

sum sEMP

cap gen sEMP100 = sEMP*100	  

reg		  sEMP100 RESGDP2020 if dFX>=0 & dFX<100 & imf!=111, ///
          robust
estimate  store emp_1_EL_A7

reg       sEMP100 RESGDP2020                                 ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX>=0 & dFX<100 & imf!=111,                    ///
	      robust
estimate  store emp_2_EL_A7
		  
reg		  sEMP100 RESGDP2020 if dFX<100 & imf!=111, ///
          robust
estimate  store emp_3_EL_A7

reg       sEMP100 RESGDP2020                                 ///
          RGDP_PK_2019 RPCPI_2019 CAB_2019                   ///
	      NIIP_19 ers_2019 OPEN_2019                         ///
	      FUELX_2019 FUELM_2019                              ///
	      if dFX<100 & imf!=111,                    ///
	      robust
estimate  store emp_4_EL_A7		  
		  
log close _all
exit

**# End of Program		  
