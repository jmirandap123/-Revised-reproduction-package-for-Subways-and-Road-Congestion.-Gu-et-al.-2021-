/**********************************************************************/
/*** Tab 4: Length of pre-period									***/
/*** Section A (Cols 1-3): Length of pre-periods					***/
/*** Section B: (Cols 4-6) Discountinuity around the launch			***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Tab4", replace

use Data/BaseSamp.dta, replace


/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*** Week-to-opening olynomials, by treatment status and pre-post ***/
gen wk2open_pre_treat = abs(wk2open) * (post==0) * treat
gen wk2open_post_treat = abs(wk2open) * (post==1) * treat
gen wk2open2_pre_treat = abs(wk2open)^2 * (post==0) * treat
gen wk2open2_post_treat = abs(wk2open)^2 * (post==1) * treat
gen wk2open3_pre_treat = abs(wk2open)^3 * (post==0) * treat
gen wk2open3_post_treat = abs(wk2open)^3 * (post==1) * treat
gen wk2open4_pre_treat = abs(wk2open)^4 * (post==0) * treat
gen wk2open4_post_treat = abs(wk2open)^4 * (post==1) * treat
gen wk2open5_pre_treat = abs(wk2open)^5 * (post==0) * treat
gen wk2open5_post_treat = abs(wk2open)^5 * (post==1) * treat

/*********************************************************************/
/*** II.A: Length of pre-periods 								   ***/
/***
	Col 1: 12 weeks prior to launch
	Col 2: 24 weeks prior to launch
	col 3: 48 weeks prior to launch
***/
/*********************************************************************/
eststo clear

/*** Col 1 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-12,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col1

/*** Col 2 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-24,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col2

/*** Col 3 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-48,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col3


/*********************************************************************/
/*** II.B Discontinuity around the launch						   ***/
/***
	Treat-specific time trend polynomial
	Col 4: linear
	Col 5: up to 3rd order
	Col 6: up to 5th order
***/
/*********************************************************************/
# delimit ;
xi: reghdfe lnspd_res TP treat 
	wk2open_pre_treat wk2open_post_treat
	if inrange(wk2open,-48,47)	
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col4

# delimit ;
xi: reghdfe lnspd_res TP treat 
	wk2open_pre_treat wk2open_post_treat
	wk2open2_pre_treat wk2open2_post_treat
	wk2open3_pre_treat wk2open3_post_treat
	if inrange(wk2open,-48,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;# delimit cr
eststo Col5

# delimit ;
xi: reghdfe lnspd_res TP treat 
	wk2open_pre_treat wk2open_post_treat
	wk2open2_pre_treat wk2open2_post_treat
	wk2open3_pre_treat wk2open3_post_treat
	wk2open4_pre_treat wk2open4_post_treat
	wk2open5_pre_treat wk2open5_post_treat	
	if inrange(wk2open,-48,47)	
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col6

/*********************************************************************/
/*** III. Display and save tables								   ***/
/*********************************************************************/
/*** Display ***/
# delimit ;
esttab Col*
	, keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 4")
	mtitle(1 2 3 4 5 6)
	modelwidth(7)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab Col* using "TablesFigures/Tab4.tex"
	, replace
	keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 4")
	mtitle(1 2 3 4 5 6)
	modelwidth(7)
;
# delimit cr


* end
timer off 1
timer list 1
cap log close
