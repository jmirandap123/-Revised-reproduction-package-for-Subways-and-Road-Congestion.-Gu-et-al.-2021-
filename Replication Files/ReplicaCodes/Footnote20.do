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


*/ This regression is not addressed much in the paper since it is a footer, however what is sought to estimate is the average distance weighted by the population to the nearest metro line calculated as the average
distance from the TAZ to the nearest metro line weighted by population. */

*/ The base model includes the terms (1) lndistl and (2) ) Postgw*lndistl, which represent the logarithmic distance to the treated metro line (for segments in treated cities) or control (for segments in control cities) and possible heterogeneous trends for road segments with different distances from the metro line.*/

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

*/β0 indicates the effect at 1 kilometer from the metro with a value of 0.03, which indicates that the road speed increases by 3% */

* end
timer off 1
timer list 1
cap log close

