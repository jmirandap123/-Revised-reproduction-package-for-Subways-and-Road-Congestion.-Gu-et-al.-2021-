/**********************************************************************/
/*** Tab 5: Subsamples by time of launch							***/
/**********************************************************************/
clear all
set more off
set matsize 11000
set seed 190512
timer clear
timer on 1
cap log close
log using "LogFiles/Tab5", replace

use Data/BaseSamp.dta, replace

*/The objective of this code is to report the correlations between the distance of the HAZs to one meter and the choice of the residents of
modes of transport*/


/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*** Three line groups ***/
gen early_lines = (opendate <= date("20170131","YMD"))
gen mid_lines = (opendate > date("20170131","YMD") & opendate <= date("20171130","YMD"))
gen late_lines = (opendate > date("20171130","YMD"))


/*********************************************************************/
/*** II. Regressions, clustered s.e.							   ***/
/*********************************************************************/
eststo clear

/*The following models are controlled by TAZ and fixed effects per year. The explanatory variable is the log-average distance from TAZ to the nearest metro station.*/
*/The estimates change depending on the three groups of lines*/

/*** Col 1: All lines, week-to-open between [-6,3] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col1

/*** Col 2: Lines launched earlier, [-6,47] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if early_lines == 1 & inrange(wk2open,-6,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col2

/*** Col 3: Lines launched in the middle, [-20,20] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if mid_lines == 1 & inrange(wk2open,-20,20)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col3

/*** Col 4: Lines launched later, [-47,3] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if late_lines == 1 & inrange(wk2open,-47,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo Col4


/*** Display ***/
# delimit ;
esttab Col*
	, keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 4, Columns 7-10, clustered s.e.")
	mtitle(7 8 9 10)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab Col* using "TablesFigures/Tab5.tex"
	, replace
	keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Table 4, Columns 7-10, clustered s.e.")
	mtitle(7 8 9 10)
;
# delimit cr


/*********************************************************************/
/*** III. Wild bootstrapping									   ***/
/*********************************************************************/

*/ Taking into account the previous results, the estimated dependent variable is predicted and get residuals */


/*** Col 1: All lines, week-to-open between [-6,3] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc), save)  resid(res1)
;
# delimit cr
local b1 = _b[TP]
predict yhat1, xbd

/*** Col 2: Lines launched earlier, [-6,47] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if early_lines == 1 & inrange(wk2open,-6,47)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc), save)  resid(res2)
;
# delimit cr
local b2 = _b[TP]
predict yhat2, xbd

/*** Col 3: Lines launched in the middle, [-20,20] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if mid_lines == 1 & inrange(wk2open,-20,20)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc), save)  resid(res3)
;
# delimit cr
local b3 = _b[TP]
predict yhat3, xbd

/*** Col 4: Lines launched later, [-47,3] ***/
# delimit ;
reghdfe lnspd_res
	TP treat
	if late_lines == 1 & inrange(wk2open,-47,3)
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc), save)  resid(res4)
;
# delimit cr
local b4 = _b[TP]
predict yhat4, xbd


/*** Bootstrap ***/

*/Finally, the bootstrap allows you to perform simulations for 499 data and thus generate estimates for household VKT and individual transport mode options*/

local B = 499
forvalues i=2/4 {
	mat Bstrp`i'_ = J(`=`B'+1',1,.)
}

sort case
by case: gen casen = _n

set more off
qui forvalues b = 1/`B' {
	cap drop yhatb*
	cap drop d D

	/*** Re-generate psuedo outcome ***/
	gen d = runiform() if casen == 1
	bysort case: egen D = mean(d)
	
	forvalues i=2/4 {
		gen yhatb`i' = yhat`i' + res`i' if D >= 0.5
		replace yhatb`i' = yhat`i' - res`i' if D < 0.5
	}
	
	/*** Col 2: Lines launched earlier, [-6,47] ***/
	# delimit ;
	reghdfe yhatb2
		TP treat
		if early_lines == 1 & inrange(wk2open,-6,47)
		, a(linkid case_wk2open yrwk##c.(lnpop lngdppc))
	;
	# delimit cr
	mat Bstrp2_[`b',1] = _b[TP]

	/*** Col 3: Lines launched in the middle, [-20,20] ***/
	# delimit ;
	reghdfe yhatb3
		TP treat
		if mid_lines == 1 & inrange(wk2open,-20,20)
		, a(linkid case_wk2open yrwk##c.(lnpop lngdppc))
	;
	# delimit cr
	mat Bstrp3_[`b',1] = _b[TP]

	/*** Col 4: Lines launched later, [-47,3] ***/
	# delimit ;
	reghdfe yhatb4
		TP treat
		if late_lines == 1 & inrange(wk2open,-47,3)
		, a(linkid case_wk2open yrwk##c.(lnpop lngdppc))
	;
	# delimit cr
	mat Bstrp4_[`b',1] = _b[TP]
	
	sleep 2000
	
	noisily dis "`b' out of `B' bootstrap done!"
}
	
	/* original estiamtes */
forvalues i =2/4 {
	mat Bstrp`i'_[`=`B'+1',1] = `b`i''
}

/*** Save ***/
clear
forvalues i =2/4 {
	svmat Bstrp`i'_, names("Col`i'_")
}

forvalues i =2/4 {
	dis "Col`i'_"
	_pctile Col`i'_1, p(2.5 97.5)
	return list
}

save TablesFigures/Tab5_Bstrp.dta, replace

* end
timer off 1
timer list 1
cap log close
