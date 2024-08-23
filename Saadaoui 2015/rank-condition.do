**# ** Testing the rank condition

*do xr-dynamics_residual_testing.do

xtdcce2  logreer logfeer, crosssectional(_all, rcclassifier)

estat ic, model(logreer logfeer)

xtdcce2  logfeer logreer, crosssectional(_all, rcclassifier)

estat ic, model(logfeer logreer)

label var logreer_cs ///
 "CSA of Log Real Effective Exchange Rates" 

label var logfeer_cs ///
 "CSA of Log Fundamental Equilibrium Exchange Rates"

set scheme stcolor

xtline logreer_cs, overlay xtitle("") ///
 name(logreer_cs, replace)

xtline logfeer_cs, overlay xtitle("") ///
 name(logfeer_cs, replace)