/*********************************************************************/
/*** Fig 4: Longer pre-periods									   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Fig4", replace

use Data/BaseSamp.dta, replace


/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/

/* It is maintained 48 weeks before and 47 weeks after the opening of the metro line */

/*** week to launch between [-48,47] ***/
keep if inrange(wk2open,-48,47)

*/The problem with pretreatment trends is that when you focus on the effect in a narrow neighborhood around the launch date (fweeks closest to week 0) */
*/Because of the above, the difference in discontinuity models are estimated by including a flexible time trend with up to the 5th polynomial, separately for the treated and
control segments, and separately for before and after periods.*/

/*** Week-to-opening olynomials, by treatment status and pre-post ***/
gen post = (wk2open >= 0)
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

*/From here it is not very clear to me what happens with the variables that are created, but if it is understood that they are creating the matrices that include the periods per treatment (before, during and after the opening of the stations)*/

/*** Matrices ***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

/*** PERIODS X TREAT  ***/
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

/*********************************************************************/
/*** II. Regressions											   ***/
/*********************************************************************/

*/ The following regression has the objective of estimating week by week (48 weeks before treatment) and checking the effect just at the moment the meter opens.*/

/*** Fig 4A: stacked DID ***/
set more off
# delimit ;
reghdfe lnspd_res
	Am48-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
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


/*********************************************************************/
/*** III. Prepare for graph										   ***/
/*********************************************************************/
clear

	/* 95% confidence intervals */
foreach mt in A {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}


/*********************************************************************/
/*** IV. Graphs													   ***/
/*********************************************************************/
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-48(4)48, angle(45))
		ylabel(-0.05(0.05)0.1)
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/Fig4.pdf", replace

* end
timer off 1
timer list 1
cap log close
