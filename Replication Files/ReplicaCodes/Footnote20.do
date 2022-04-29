/*********************************************************************/
/*** Footnote 20: Effect at 1 km away from subway				   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Footnote20", replace
use "Data/ExtendSample.dta", clear

gen ln_dist2line = ln(link2_nearest_treat_line_km)
gen Dp_lndist2line = Dp * ln_dist2line
# delimit ;
reghdfe lnspd_res 
	Dp Dp_lndist2line
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc) ln_dist2line##c.(case_linkid)) 
	cluster(case)
;
# delimit cr

* end
timer off 1
timer list 1
cap log close

