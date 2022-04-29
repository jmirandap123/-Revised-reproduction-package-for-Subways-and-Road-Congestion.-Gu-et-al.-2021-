/**********************************************************************/
/*** AppB_Dist2Stn: Heterogeneous Effects w.r.t distance to subway  ***/
/*** 				line and subway station							***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_TabB3", replace
use "Data/ExtendSample.dta", clear

/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
/*** Dist to line and dist to station ***/
eststo clear

gen Dp_dist2line = Dp * link2_nearest_treat_line_km
gen Dp_dist2stn = Dp * dist2stn
gen Dp_dist2line_dist2stn = Dp_dist2line * dist2stn

cap drop hetero
cap drop Dp_hetero*
cap drop case_wk2open_hetero
gen hetero = 1 if inrange(link2_nearest_treat_line_km,0,1) & inrange(dist2stn,0,0.5)
replace hetero = 2 if inrange(link2_nearest_treat_line_km,0,1) & inrange(dist2stn,0.5,1)
replace hetero = 3 if inrange(link2_nearest_treat_line_km,1,.) | (inrange(link2_nearest_treat_line_km,0,1) & dist2stn>1)
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)

gen Dp_hetero1 = Dp * (hetero==1)
gen Dp_hetero2 = Dp * (hetero==2)
gen Dp_hetero3 = Dp * (hetero==3)


/*********************************************************************/
/*** II. Regression												   ***/
/*********************************************************************/
set more off
# delimit ;
reghdfe lnspd_res 
	Dp Dp_dist2line
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A1

# delimit ;
reghdfe lnspd_res 
	Dp Dp_dist2stn
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A2

# delimit ;
reghdfe lnspd_res 
	Dp
	Dp_dist2line Dp_dist2stn 
	Dp_dist2line_dist2stn
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A3

# delimit ;
reghdfe lnspd_res 
	Dp_hetero1 Dp_hetero2 
	Dp_hetero3
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A4


/*********************************************************************/
/*** III. Display and save										   ***/
/*********************************************************************/
# delimit ;
esttab A*,
	se(3) b(3)
	keep(Dp*)
	star(* 0.1 ** 0.05 *** 0.01)
;
# delimit cr

# delimit ;
esttab A* using "TablesFigures/AppB_TabB3.tex"
	, replace
	se(3) b(3)
	keep(Dp*)
	star(* 0.1 ** 0.05 *** 0.01)
;
# delimit cr

* end
timer off 1
timer list 1
cap log close


