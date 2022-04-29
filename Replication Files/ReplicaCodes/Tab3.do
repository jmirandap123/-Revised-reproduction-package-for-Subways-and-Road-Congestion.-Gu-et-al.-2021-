/**********************************************************************/
/*** Tab 3: Baseline												***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Tab3", replace

use Data/BaseSamp.dta, replace


/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*********************************************************************/
/*** II. Regressions											   ***/
/***
	Col 1: stacked DID
	Col 2: twoway FEs with treated only
	Col 3: twoway FEs with treated only, adj. for differential seasonality
***/
/*********************************************************************/
eststo clear

/*** Col 1 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col1

/*** Col 2 ***/
# delimit ;
reghdfe lnspd_res
	TP
	if treat == 1 & inrange(wk2open,-6,47)
	, a(linkid yrwk) cluster(case)
;
# delimit cr
eststo Col2

/*** Col 3 ***/
# delimit ;
reghdfe lnspd_res
	TP
	if treat == 1 & inrange(wk2open,-6,47)
	, a(linkid yrwk yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col3

/*********************************************************************/
/*** III. Display and save tables								   ***/
/*********************************************************************/
/*** Display ***/
# delimit ;
esttab Col*
	, keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 3")
	mtitle(stack twoway-treatonly-noseason twoway-treatonly)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab Col* using "TablesFigures/Tab3.tex"
	, replace
	keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 3")
	mtitle(stack stack-season twoway-treatonly twoway)
;
# delimit cr

* end
timer off 1
timer list 1
cap log close
