/**********************************************************************/
/*** AppB_Dist2Stn: Heterogeneous Effects w.r.t distance to subway  ***/
/*** 				line and subway station							***/
/**********************************************************************/

*/This section has the objective of understanding what is presented in section 3.2, analyzing other events that take place at the same time
in the inauguration of a new metro line such as the opening of new stores, rerouting of buses and changes in traffic patterns on surface roads*/
*/The motivation for this is to analyze whether these variables bring new traffic to the road segments near the metro stations and less traffic on the road sections further away from the stations */

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

*The interaction of the post-trade variable with the segment variables of distance to the nearest subway line and distance from the subway station is created.*/
*/ The interaction between the distance to the nearest metro station and the first interaction is also created */
gment distance to the nearest treated (or control) line (km)

gen Dp_dist2line = Dp * link2_nearest_treat_line_km
gen Dp_dist2stn = Dp * dist2stn
gen Dp_dist2line_dist2stn = Dp_dist2line * dist2stn

/*Heterogeneous effects (3 groups) are created depending on the distance in km and the distance segment.*/

cap drop hetero
cap drop Dp_hetero*
cap drop case_wk2open_hetero
gen hetero = 1 if inrange(link2_nearest_treat_line_km,0,1) & inrange(dist2stn,0,0.5)
replace hetero = 2 if inrange(link2_nearest_treat_line_km,0,1) & inrange(dist2stn,0.5,1)
replace hetero = 3 if inrange(link2_nearest_treat_line_km,1,.) | (inrange(link2_nearest_treat_line_km,0,1) & dist2stn>1)
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)

*/ the variable that represents the heterogeneous effects is created for the post treated variable */
gen Dp_hetero1 = Dp * (hetero==1)
gen Dp_hetero2 = Dp * (hetero==2)
gen Dp_hetero3 = Dp * (hetero==3)


/*********************************************************************/
/*** II. Regression												   ***/
/*********************************************************************/

*/The following regressions show the heterogeneous effects by distance from the section of track to the treated metro and its stations.*/

set more off
# delimit ;

*/It seeks to explain the effect of the distance to the treated line and the treated stations.*/

reghdfe lnspd_res 
	Dp Dp_dist2line
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A1

# delimit ;

*/It seeks to explain the effect of the distance to the treated line and the treated stations.*/

reghdfe lnspd_res 
	Dp Dp_dist2stn
	treat
	if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo A2

*/ conditional regression on the distance of the treated line versus the speed of the road sections near the station.*/

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

*/Splits the road non-parametrically: those within 1 kilometer of the treated line and within 500 meters of a treated station; those within 1 kilometer of the treated line but more than 500
meters from a treated station; and those more than 1 kilometer away from the treaty.*/
line. */

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


