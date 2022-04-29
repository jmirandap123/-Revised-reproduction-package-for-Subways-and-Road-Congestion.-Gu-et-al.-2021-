/************************************/
/*** Appendix B: Baseline Regression in one step  ***/
/*** Corresponds to Table 3, but in one-step		  ***/
/************************************/
clear
cap log close
set more off
timer clear
timer on 1
log using "LogFiles/AppB_TabB5", replace


use "Data/HourlySample.dta", clear


*/This regression aims to replicate the estimate in Table 3, with the difference in sizes between weeks using a one-step baseline./

*/Table 3, which is estimated through two steps, is irrelevant, since the two-step approach takes the average residual value of the
logging rate per hour at the weekly level, then each weekly observation is treated equally. The problem is that, due to
national holidays, missing data, not every week has 20 hours. The second reason is that the two-step approach uses an estimated variable as the dependent variable, which makes
the standard error in the second step is incorrect.

*/ It is run through DID, Two Way FE, no control, no seasonality and Two-way FE, with control, account for seasonality */

/*** 1. Stacked DID, seasonality***/
# delimit ;
reghdfe lnspd treat_post post treat
	, a(case_wk2open link_dow_hour yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col1

/*** 2. Two-way FE, no control, no seasonality ***/
# delimit ;
reghdfe lnspd treat_post
	if treat == 1
	, a(link_dow_hour yrwk) cluster(case)
;
# delimit cr
eststo Col2

/*** 3. Two-way FE, with control, account for seasonality ***/
# delimit ;
reghdfe lnspd treat_post
	if treat == 1
	, a(link_dow_hour yrwk yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col3

timer off 2
timer list 2



*/Concluding the previous estimate, no differences in magnitude are found with the regression to be replicated, so the conclusions are not affected.*/

/*** Display ***/
# delimit ;
esttab Col*
	, keep(treat_post)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 3")
	mtitle(stack twoway-treatonly-noseason twoway-treatonly)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab Col* using "TablesFigures/AppB_Tab5.tex"
	, replace
	keep(treat_post)
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

