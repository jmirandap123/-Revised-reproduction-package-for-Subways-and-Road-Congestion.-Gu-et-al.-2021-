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

*/The goal of this code is to do the second robustness check. For this case, they restricted the sample to 12, 24 and 48 weeks before the launch of the metro.*/

/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/

* The coefficient associated with the treated variable × post indicates the discontinuous change in road speed at the time of
launch of the metro relative to that of the control segments.*

/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*** Week-to-opening polynomials, by treatment status and pre-post ***/
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

*/They estimate the discontinuity difference model by including a flexible time trend up to the fifth polynomial (for treated and control).*/

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

*/ In the code there are 4 calculating missing, which refers to column 7, 8 and 9 of the table being estimated. What this estimate is looking for is that the observations of each treated line must be within 6 weeks before and 48 weeks after the opening, the number of post-opening periods in the sample different between the treated lines. For this, he reduced the sample period to 6 weeks before and 3 weeks after the opening of the metro line so that the treaty × publication coefficient is estimated from the same set of weeks relative to the opening of the line* /
*/ So the estimates would be as follows: */

/*** Col 7 for all lines***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open, -6,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col1

*/ Filling in the missing columns in the code, they divided the treated lines into three subsamples: 21 lines launched before January 31, 2017; 9 lines launched between February 1 and November 30, 2017; and 15 lines launched as of December 1, 2017. We include the maximum time that all lines have to cover a specific subsample.*/
*/I propose the following code:*/

/*** Col 8 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col2

/*** Col 9 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-20,20)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col3

/*** Col 10 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col2

/*** Col 9 ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-49,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
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
