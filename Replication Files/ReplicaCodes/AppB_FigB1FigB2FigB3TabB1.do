/**********************************************************************/
/*** Appendix B: Fig B.1, Fig B.2, Fig B.3						   	***/
/*** More details on Differential Seasonality		   				***/
/***
	Fig B.1: Accounting for Differential Seasonality
	Fig B.2: How Much Does Differential Seasonality Matter
	Fig B.3: Visualizing Seasonality by City Characteristics
***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_FigB1FigB2FigB3TabB1", replace

use Data/BaseSamp.dta, replace

/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
	/* week to launch between [-6,47] */
keep if inrange(wk2open,-6,47)

	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*** PERIODS X TREAT  ***/
/*** Mats, 
	A = No control, 
	B = lnpop, 
	C = lnGDP per capita 
	D = lnpop + ln GDPpc
	E = lnpop + ln GDPpc, quadratic
***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

/*** A. Weekly ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-1 {
	mat A[`n',1] = `i'
	
	local j = abs(`i')
	gen Am`j' = treat * (wk2open == `i')
	
	local n = `n' + 1
}

	/* week of opening */
mat A[`n',1] = 0

gen A0 = treat * (wk2open == 0)
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat A[`n',1] = `i'
	
	gen Ap`i' = treat * (wk2open == `i')
	
	local n = `n' + 1
}

mat B = A
mat C = A
mat D = A
mat E = A

/*********************************************************************/
/*** II. Estimation and extract 								   ***/
/*********************************************************************/
/**************************************/
/*** II.A No hetero					***/
/**************************************/

/*The following regressions are run through the base model of the paper, with the difference estimated as follows. Panel A does not take into account the seasonality differential between cities. Panel B includes the log population and its interaction with calendar week dummy variables. Group C
includes logarithm of GDP per capita and its interaction with calendar week dummies. Panel D includes log population and log GDP per capita and their interactions with calendar week dummy variables. Panel E adds quadratic terms.

/* Col 1: None */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr
eststo Col1

	/* Col 2: log population */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop)) cluster(case)
;
# delimit cr
eststo Col2

	/* Col 3: log GDP pc */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open yrwk##c.(lngdppc)) cluster(case)
;
# delimit cr
eststo Col3


	/* Col 4: log population + log GDP pc */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col4

	/* Col 5: log population + log GDP pc + quadratic */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
;
# delimit cr
eststo Col5

	/* Col 6: log population + log GDP pc + cubic */
# delimit ;
reghdfe lnspd_res
	TP
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2 lnpop3 lngdppc3)) cluster(case)
;
# delimit cr
eststo Col6

	/* Display and save */
# delimit ;
esttab Col*
	, se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	mtitle(none pop gdppc both qua cub)
	stat(N, fmt(%6.0f))
	modelwidth(8)
;
# delimit cr

# delimit ;
esttab Col* using TablesFigures/AppB_DiffSeasonality_Tab.tex
	, replace
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	mtitle(none pop gdppc both qua cub)
	stat(N, fmt(%6.0f))
;
# delimit cr

/**************************************/
/*** II.A No hetero					***/
/**************************************/
set more off
# delimit ;
reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat A[`n',2] = _b[Am`j']
	mat A[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat A[`n',2] = 0
mat A[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat A[`n',2] = _b[A0]
mat A[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat A[`n',2] = _b[Ap`i']
	mat A[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}

/**************************************/
/*** II.B lnpop 					***/
/**************************************/
mat HB = J(71,3,.)

set more off
# delimit ;
xi: reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	i.yrwk|lnpop
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat B[`n',2] = _b[Am`j']
	mat B[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat B[`n',2] = 0
mat B[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat B[`n',2] = _b[A0]
mat B[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat B[`n',2] = _b[Ap`i']
	mat B[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}

	/* Feed seasonality coeffs */
local n = 1
forvalues yw = 201632/201635 {
	mat HB[`n',1] = `yw'
	mat HB[`n',2] = _b[_IyrwXlnp_`yw']
	mat HB[`n',3] = _se[_IyrwXlnp_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201637/201641 {
	mat HB[`n',1] = `yw'
	mat HB[`n',2] = _b[_IyrwXlnp_`yw']
	mat HB[`n',3] = _se[_IyrwXlnp_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201648/201652 {
	mat HB[`n',1] = `yw'
	mat HB[`n',2] = _b[_IyrwXlnp_`yw']
	mat HB[`n',3] = _se[_IyrwXlnp_`yw']
	
	local n = `n' + 1	
}

forvalues yw = 201701/201752 {
	mat HB[`n',1] = `yw'
	mat HB[`n',2] = _b[_IyrwXlnp_`yw']
	mat HB[`n',3] = _se[_IyrwXlnp_`yw']
	
	local n = `n' + 1	
}


forvalues yw = 201801/201805 {
	mat HB[`n',1] = `yw'
	mat HB[`n',2] = _b[_IyrwXlnp_`yw']
	mat HB[`n',3] = _se[_IyrwXlnp_`yw']
	
	local n = `n' + 1	
}

/**************************************/
/*** II.C lngdppc 					***/
/**************************************/
mat HC = J(71,3,.)

set more off
# delimit ;
xi: reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	i.yrwk|lngdppc	
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat C[`n',2] = _b[Am`j']
	mat C[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat C[`n',2] = 0
mat C[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat C[`n',2] = _b[A0]
mat C[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat C[`n',2] = _b[Ap`i']
	mat C[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}

	/* Feed seasonality coeffs */
local n = 1
forvalues yw = 201632/201635 {
	mat HC[`n',1] = `yw'
	mat HC[`n',2] = _b[_IyrwXlng_`yw']
	mat HC[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201637/201641 {
	mat HC[`n',1] = `yw'
	mat HC[`n',2] = _b[_IyrwXlng_`yw']
	mat HC[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201648/201652 {
	mat HC[`n',1] = `yw'
	mat HC[`n',2] = _b[_IyrwXlng_`yw']
	mat HC[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}

forvalues yw = 201701/201752 {
	mat HC[`n',1] = `yw'
	mat HC[`n',2] = _b[_IyrwXlng_`yw']
	mat HC[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}


forvalues yw = 201801/201805 {
	mat HC[`n',1] = `yw'
	mat HC[`n',2] = _b[_IyrwXlng_`yw']
	mat HC[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}


/**************************************/
/*** II.D lnpop + lngdppc 			***/
/**************************************/
mat HDA = J(71,3,.)
mat HDB = J(71,3,.)

set more off
# delimit ;
xi: reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	i.yrwk|lnpop i.yrwk|lngdppc
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat D[`n',2] = _b[Am`j']
	mat D[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat D[`n',2] = 0
mat D[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat D[`n',2] = _b[A0]
mat D[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat D[`n',2] = _b[Ap`i']
	mat D[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}

	/* Feed seasonality coeffs */
local n = 1
forvalues yw = 201632/201635 {
	mat HDA[`n',1] = `yw'
	mat HDA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HDA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HDB[`n',1] = `yw'
	mat HDB[`n',2] = _b[_IyrwXlng_`yw']
	mat HDB[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201637/201641 {
	mat HDA[`n',1] = `yw'
	mat HDA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HDA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HDB[`n',1] = `yw'
	mat HDB[`n',2] = _b[_IyrwXlng_`yw']
	mat HDB[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1
}

forvalues yw = 201648/201652 {
	mat HDA[`n',1] = `yw'
	mat HDA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HDA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HDB[`n',1] = `yw'
	mat HDB[`n',2] = _b[_IyrwXlng_`yw']
	mat HDB[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}

forvalues yw = 201701/201752 {
	mat HDA[`n',1] = `yw'
	mat HDA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HDA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HDB[`n',1] = `yw'
	mat HDB[`n',2] = _b[_IyrwXlng_`yw']
	mat HDB[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}


forvalues yw = 201801/201805 {
	mat HDA[`n',1] = `yw'
	mat HDA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HDA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HDB[`n',1] = `yw'
	mat HDB[`n',2] = _b[_IyrwXlng_`yw']
	mat HDB[`n',3] = _se[_IyrwXlng_`yw']
	
	local n = `n' + 1	
}

	/*** HDA and HDB to data file ***/
preserve
	clear
	svmat HDA 
	rename HDA1 yrwk
	save "TablesFigures/HDA_temp.dta", replace
	
	clear 
	svmat HDB
	rename HDB1 yrwk
	save "TablesFigures/HDB_temp.dta", replace
restore

preserve
	merge m:1 yrwk using "TablesFigures/HDA_temp.dta"
	drop _merge
	merge m:1 yrwk using "TablesFigures/HDB_temp.dta"
	drop _merge
	
	gen Effect = HDA2 * lnpop + HDB2 * lngdppc
	
	/*** STANDARD ERROR PENDING ***/
	
	collapse (mean) Effect, by(case treat yrwk)
	
	reshape wide Effect, i(case yrwk) j(treat)
	gen dEffect = Effect1 - Effect0
	
	collapse (mean) dEffect, by(yrwk)
	
	merge 1:1 yrwk using "TablesFigures/AppB_yrwk_temp.dta"
	drop _merge
	
	merge 1:1 date using "TablesFigures/AppB_yrwk_temp2.dta"
	drop _merge
	
	gen h = 0.06 if inlist(date,20715,20735,20821,20853,20914,20941,20970,21101,21186)

	gen holiday = ""
	replace holiday = "Mid Autumn" if date == 20715
	replace holiday = "National Day" if date == 20735 
	replace holiday = "New Year" if date == 20821 
	replace holiday = "Chinese New Year" if date == 20853 
	replace holiday = "Qingming" if date == 20914
	replace holiday = "Labor Day" if date == 20941
	replace holiday = "Duanwu" if date == 20970
	replace holiday = "National Day" if date == 21101
	replace holiday = "New Year" if date == 21186

	# delimit ;
	twoway  (connect dEffect date if inrange(yrwk,201632,201641), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
			(connect dEffect date if inrange(yrwk,201648,201805), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
			(scatter h date, mcolor(none) mlabel(holiday) mlabsize(vsmall) mlabcolor(maroon) mlabposition(6) mlabangle(forty_five))
			, title("Avg. effect due to differential seasonality effect")
			subtitle("hetero seasonality w.r.t log population and log GDP per capita")
			ytitle("coeff.") xtitle("")
			xlabel(20667(28)21213, angle(45) labsize(small))
			xline(20712 20714 20728 20734 20820 20846 20852 20911 20913 20940 20967 20969 21093 21100 21185, lcolor(gs8))
			legend(off)
			graphregion(color(white))
	;
	# delimit cr
	graph export "TablesFigures/AppB_SeasonalityCityChars_D1.pdf", replace
restore

/**************************************/
/*** II.E lnpop + lngdppc, quadratic***/
/**************************************/
mat HEA = J(71,3,.)
mat HEB = J(71,3,.)
mat HEC = J(71,3,.)
mat HED = J(71,3,.)

# delimit ;
reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
;
# delimit cr

summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat E[`n',2] = _b[Am`j']
	mat E[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat E[`n',2] = 0
mat E[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat E[`n',2] = _b[A0]
mat E[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat E[`n',2] = _b[Ap`i']
	mat E[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}

set more off
# delimit ;
xi: reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	treat
	i.yrwk|lnpop i.yrwk|lngdppc
	i.yrwk|lnpop2 i.yrwk|lngdppc2
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr

	/* Feed seasonality coeffs */
local n = 1
forvalues yw = 201632/201635 {
	mat HEA[`n',1] = `yw'
	mat HEA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HEA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HEB[`n',1] = `yw'
	mat HEB[`n',2] = _b[_IyrwXlng_`yw']
	mat HEB[`n',3] = _se[_IyrwXlng_`yw']
	mat HEC[`n',1] = `yw'
	mat HEC[`n',2] = _b[_IyrwXlnpa`yw']
	mat HEC[`n',3] = _se[_IyrwXlnpa`yw']
	mat HED[`n',1] = `yw'
	mat HED[`n',2] = _b[_IyrwXlnga`yw']
	mat HED[`n',3] = _se[_IyrwXlnga`yw']
	
	local n = `n' + 1
}

forvalues yw = 201637/201641 {
	mat HEA[`n',1] = `yw'
	mat HEA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HEA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HEB[`n',1] = `yw'
	mat HEB[`n',2] = _b[_IyrwXlng_`yw']
	mat HEB[`n',3] = _se[_IyrwXlng_`yw']
	mat HEC[`n',1] = `yw'
	mat HEC[`n',2] = _b[_IyrwXlnpa`yw']
	mat HEC[`n',3] = _se[_IyrwXlnpa`yw']
	mat HED[`n',1] = `yw'
	mat HED[`n',2] = _b[_IyrwXlnga`yw']
	mat HED[`n',3] = _se[_IyrwXlnga`yw']
	
	local n = `n' + 1
}

forvalues yw = 201648/201652 {
	mat HEA[`n',1] = `yw'
	mat HEA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HEA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HEB[`n',1] = `yw'
	mat HEB[`n',2] = _b[_IyrwXlng_`yw']
	mat HEB[`n',3] = _se[_IyrwXlng_`yw']
	mat HEC[`n',1] = `yw'
	mat HEC[`n',2] = _b[_IyrwXlnpa`yw']
	mat HEC[`n',3] = _se[_IyrwXlnpa`yw']
	mat HED[`n',1] = `yw'
	mat HED[`n',2] = _b[_IyrwXlnga`yw']
	mat HED[`n',3] = _se[_IyrwXlnga`yw']
	
	local n = `n' + 1	
}

forvalues yw = 201701/201752 {
	mat HEA[`n',1] = `yw'
	mat HEA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HEA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HEB[`n',1] = `yw'
	mat HEB[`n',2] = _b[_IyrwXlng_`yw']
	mat HEB[`n',3] = _se[_IyrwXlng_`yw']
	mat HEC[`n',1] = `yw'
	mat HEC[`n',2] = _b[_IyrwXlnpa`yw']
	mat HEC[`n',3] = _se[_IyrwXlnpa`yw']
	mat HED[`n',1] = `yw'
	mat HED[`n',2] = _b[_IyrwXlnga`yw']
	mat HED[`n',3] = _se[_IyrwXlnga`yw']
	
	local n = `n' + 1	
}


forvalues yw = 201801/201805 {
	mat HEA[`n',1] = `yw'
	mat HEA[`n',2] = _b[_IyrwXlnp_`yw']
	mat HEA[`n',3] = _se[_IyrwXlnp_`yw']
	mat HEB[`n',1] = `yw'
	mat HEB[`n',2] = _b[_IyrwXlng_`yw']
	mat HEB[`n',3] = _se[_IyrwXlng_`yw']
	mat HEC[`n',1] = `yw'
	mat HEC[`n',2] = _b[_IyrwXlnpa`yw']
	mat HEC[`n',3] = _se[_IyrwXlnpa`yw']
	mat HED[`n',1] = `yw'
	mat HED[`n',2] = _b[_IyrwXlnga`yw']
	mat HED[`n',3] = _se[_IyrwXlnga`yw']
	
	local n = `n' + 1	
}

	/*** HDA and HDB to data file ***/
preserve
	clear
	svmat HEA 
	rename HEA1 yrwk
	save "TablesFigures/HEA_temp.dta", replace
	
	clear 
	svmat HEB
	rename HEB1 yrwk
	save "TablesFigures/HEB_temp.dta", replace
	
	clear
	svmat HEC
	rename HEC1 yrwk
	save "TablesFigures/HEC_temp.dta", replace
	
	clear 
	svmat HED
	rename HED1 yrwk
	save "TablesFigures/HED_temp.dta", replace
restore

preserve
	merge m:1 yrwk using "TablesFigures/HEA_temp.dta"
	drop _merge
	merge m:1 yrwk using "TablesFigures/HEB_temp.dta"
	drop _merge
	merge m:1 yrwk using "TablesFigures/HEC_temp.dta"
	drop _merge
	merge m:1 yrwk using "TablesFigures/HED_temp.dta"
	drop _merge
		
	gen Effect = HEA2 * lnpop + HEB2 * lngdppc + HEC2 * lnpop2 + HED2 * lngdppc2
	
	/*** STANDARD ERROR PENDING ***/
	
	collapse (mean) Effect, by(case treat yrwk)
	
	reshape wide Effect, i(case yrwk) j(treat)
	gen dEffect = Effect1 - Effect0
	
	collapse (mean) dEffect, by(yrwk)
	
	merge 1:1 yrwk using "TablesFigures/AppB_yrwk_temp.dta"
	drop _merge
	
	merge 1:1 date using "TablesFigures/AppB_yrwk_temp2.dta"
	drop _merge
	
	gen h = 0.06 if inlist(date,20715,20735,20821,20853,20914,20941,20970,21101,21186)

	gen holiday = ""
	replace holiday = "Mid Autumn" if date == 20715
	replace holiday = "National Day" if date == 20735 
	replace holiday = "New Year" if date == 20821 
	replace holiday = "Chinese New Year" if date == 20853 
	replace holiday = "Qingming" if date == 20914
	replace holiday = "Labor Day" if date == 20941
	replace holiday = "Duanwu" if date == 20970
	replace holiday = "National Day" if date == 21101
	replace holiday = "New Year" if date == 21186

	# delimit ;
	twoway  (connect dEffect date if inrange(yrwk,201632,201641), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
			(connect dEffect date if inrange(yrwk,201648,201805), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
			(scatter h date, mcolor(none) mlabel(holiday) mlabsize(vsmall) mlabcolor(maroon) mlabposition(6) mlabangle(forty_five))
			, title("Avg. effect due to differential seasonality effect")
			subtitle("hetero seasonality w.r.t log population and log GDP per capita, squared")
			ytitle("coeff.") xtitle("")
			xlabel(20667(28)21213, angle(45) labsize(small))
			xline(20712 20714 20728 20734 20820 20846 20852 20911 20913 20940 20967 20969 21093 21100 21185, lcolor(gs8))
			legend(off)
			graphregion(color(white))
	;
	# delimit cr
	graph export "TablesFigures/AppB_SeasonalityCityChars_E1.pdf", replace
restore

/**************************************/
/*** IV. Prepare for graph	 		***/
/**************************************/
clear

foreach mt in A B C D E HB HC {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}

save "TablesFigures/AppB_DiffSeasonality_Results.dta", replace

/**************************************/
/*** V. Graph				 		***/
/**************************************/
/* A. None */
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("no heterogeneity")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_A.pdf", replace


/* B. lnpop */
# delimit ;
twoway  (scatter B2 B1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap B_lo B_hi B1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("heterogeneity: log population")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_B.pdf", replace

/* C. lnGDP pc */
# delimit ;
twoway  (scatter C2 C1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap C_lo C_hi C1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("heterogeneity: log GDP per capita")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_C.pdf", replace

/* D. ln pop + lnGDP pc */
# delimit ;
twoway  (scatter D2 D1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap D_lo D_hi D1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("heterogeneity: log population and log GDP per capita")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_D.pdf", replace

/* E. ln pop + lnGDP pc, squared */
# delimit ;
twoway  (scatter E2 E1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap E_lo E_hi E1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("heterogeneity: log population and log GDP per capita, squared")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_E.pdf", replace


/* F. Compare */
# delimit ;
twoway  (connect A2 A1, mcolor(gs4) msymbol(circle) lwidth(thick) lcolor(gs4) lpattern(solid))
		(connect B2 B1, mcolor(teal) msymbol(square) lwidth(medium) lcolor(teal))
		(connect C2 C1, mcolor(sand) msymbol(X) lwidth(medium) lcolor(sand))
		(line D2 D1, lwidth(medium) lcolor(gs8) lpattern(dash))
		(line E2 E1, lwidth(thick) lcolor(gs10) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(on order(1 "none" 2 "population" 3 "GDP per capita" 4 "both" 5 "quadratic") cols(3))
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_F.pdf", replace


/* G. Plot seasonality/heterogeneous trends */
preserve
	clear
	set obs 549
	gen date = 20666 + _n
	gen year = year(date)
	gen week = week(date)
	gen yrwk = year * 100 + week
	sort yrwk date
	by yrwk: gen n = _n
	save "TablesFigures/AppB_yrwk_temp2.dta", replace
	keep if n == 1
	keep date yrwk
	format %td date
	save "TablesFigures/AppB_yrwk_temp.dta", replace
restore

use "TablesFigures/AppB_DiffSeasonality_Results.dta",clear
rename HB1 yrwk
drop if yrwk == .
merge 1:1 yrwk using "TablesFigures/AppB_yrwk_temp.dta"
drop _merge

summ HB2
replace HB2 = HB2 - `r(mean)'
replace HB_lo = HB_lo - `r(mean)'
replace HB_hi = HB_hi - `r(mean)'

summ HC2
replace HC2 = HC2 - `r(mean)'
replace HC_lo = HC_lo - `r(mean)'
replace HC_hi = HC_hi - `r(mean)'

merge 1:1 date using "TablesFigures/AppB_yrwk_temp2.dta"
drop _merge


gen h = 0.085 if inlist(date,20715,20735,20821,20853,20914,20941,20970,21101,21186)
gen holiday = ""
replace holiday = "Mid Autumn" if date == 20715
replace holiday = "National Day" if date == 20735 
replace holiday = "New Year" if date == 20821 
replace holiday = "Chinese New Year" if date == 20853 
replace holiday = "Qingming" if date == 20914
replace holiday = "Labor Day" if date == 20941
replace holiday = "Duanwu" if date == 20970
replace holiday = "National Day" if date == 21101
replace holiday = "New Year" if date == 21186

# delimit ;
twoway  (connect HB2 date if inrange(yrwk,201632,201641), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
		(connect HB2 date if inrange(yrwk,201648,201805), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
		(scatter h date, mcolor(none) mlabel(holiday) mlabsize(vsmall) mlabcolor(maroon) mlabposition(6) mlabangle(forty_five))
		(rcap HB_lo HB_hi date, lpattern(solid) lwidth(medium) lcolor(teal))
		, title("Coeff. of (log population X calendar week dummies)")
		ytitle("coeff.") xtitle("")
		xlabel(20667(28)21213, angle(45) labsize(small))
		xline(20712 20714 20728 20734 20820 20846 20852 20911 20913 20940 20967 20969 21093 21100 21185, lcolor(gs8))
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_G.pdf", replace


replace h = 0.17 if inlist(date,20715,20735,20821,20853,20914,20941,20970,21101,21186)
# delimit ;
twoway  (connect HC2 date if inrange(yrwk,201632,201641), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
		(connect HC2 date if inrange(yrwk,201648,201805), mcolor(teal) msymbol(circle) lwidth(medium) lcolor(gs4) lpattern(solid))
		(scatter h date, mcolor(none) mlabel(holiday) mlabsize(vsmall) mlabcolor(maroon) mlabposition(6) mlabangle(forty_five))
		(rcap HC_lo HC_hi date, lpattern(solid) lwidth(medium) lcolor(teal))
		, title("Coeff. of (log GDP per capita X calendar week dummies)")
		ytitle("coeff.") xtitle("")
		xlabel(20667(28)21213, angle(45) labsize(small))
		xline(20712 20714 20728 20734 20820 20846 20852 20911 20913 20940 20967 20969 21093 21100 21185, lcolor(gs8))
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_SeasonalityCityChars_H.pdf", replace

* end
erase "TablesFigures/HEA_temp.dta"
erase "TablesFigures/HEB_temp.dta"
erase "TablesFigures/HEC_temp.dta"
erase "TablesFigures/HED_temp.dta"

timer off 1
timer list 1
cap log close
