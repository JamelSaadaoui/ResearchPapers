cd "C:\Users\jamel\Documents\GitHub\ResearchPapers\"
cd "Saadaoui 2015"	// Set the directory

cls
clear

*capture log close _all                            
*log using xrdynamics, name(xrdynamics) text replace

*Import the data from Excel


use data\jasa2.dta, clear

keep if year>=1962

encode nation, generate(cn)

xtset cn year, yearly

/*
xtpmg d.c d.pi d.y if year>=1962, ///
lr(l.c pi y) ec(ec) replace pmg
*/

xtpmg d.c d.pi d.y if year>=1962, ///
lr(l.c pi y) ec(ec) replace pmg full

capture drop yhat
gen yhat = .
forval cn = 1/24 {
predict temp if cn ==`cn', eq(cn_`cn')
replace yhat = temp if cn == `cn'
drop temp
}

gen Dc = d.c

xtline Dc yhat if cn==24, name(yhat, replace)


xtpmg d.c d.pi d.y if year>=1962, ///
lr(l.c pi y) ec(ec) replace pmg full nocons

// Common constant

generate cst = 1

xtpmg d.c d.pi d.y if year>=1962, ///
lr(l.c pi y cst) ec(ect) replace pmg full nocons

cap drop ecT
generate ecT = l.c - (_b[pi])*pi - (_b[y])*y - (_b[cst])*cst

cap drop check
gen check = ect-ecT // equal to zero

capture drop yhat2
gen yhat2 = .
forval cn = 1/24 {
predict temp if cn ==`cn', eq(cn_`cn')
replace yhat2 = temp if cn == `cn'
drop temp
}

xtline Dc yhat2 if cn==24, name(yhat2, replace)

cap drop c_star
gen c_star = (_b[pi])*pi + (_b[y])*y + (_b[cst])*cst

xtline c c_star if cn==24, name(yhatLR, replace)

// XTMG

xtmg c pi y

cap drop yhatLR2
predict yhatLR2
xtline c yhatLR2 if cn==24, name(yhatLR2, replace)

exit

**#*************************************************************

