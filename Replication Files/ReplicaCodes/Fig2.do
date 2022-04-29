/*********************************************************************/
/*** Fig 2: Baseline Weekly										   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Fig2", replace

use Data/BaseSamp.dta, replace


/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
/*** week to launch between [-6,47] ***/
keep if inrange(wk2open,-6,47)

/*** Matrices 
	A = stacked DID, not adjusted for differential seasonality 
	B = stacked DID, adjusted for differential seasonality
	C = Twoway FE, treated units only
	D = Twoway FE, treated and control units, adjusted for differential seasonality
***/
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
mat D = A

/*********************************************************************/
/*** II. Regressions											   ***/
/*********************************************************************/

/**The objective of making these estimates is to run the difference-in-differences model with the aim of estimating the change in the residual speed record in road sections treated before and after the launch of a new metro line with the change contemporary speed control road sections. However, both the treated and control cities are statistically different in certain characteristics, so it is necessary to check the base assumption of the DID methodology that is parallel trends. This implies that the trend that is observed in the variable of interest or outcome for the comparison group is equal to the trend that would have been observed in the treatment group if it had not received the intervention. Three graphs are made where panels A and C control the differential seasonality by allowing the specific effects of the week to differ according to the characteristics of the city.*/

/*** Fig 2A: stacked DID, adjusted for differential seasonality***/
set more off
# delimit ;
reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
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


/*** Fig 2B: Twoway FE, treated units only ***/
set more off
# delimit ;
reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	if treat == 1
	, a(linkid yrwk) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat B[`n',2] = _b[Am`j']
	mat B[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat B[`n',2] = 0
mat B[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat B[`n',2] = _b[A0]
mat B[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat B[`n',2] = _b[Ap`i']
	mat B[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}


/*** Fig 2C: Twoway FE, treated units only, accounting for differential seasonality ***/
set more off
# delimit ;
reghdfe lnspd_res
	Am6-Am2 A0 Ap* 
	if treat == 1
	, a(linkid yrwk yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr

	/*** Feed matrix ***/
	/* prior to opening */
local n = 1
forvalues i = `Amin'/-2 {
	local j = abs(`i')
	mat C[`n',2] = _b[Am`j']
	mat C[`n',3] = _se[Am`j']
	local n = `n' + 1
}

	/* Am1 */
mat C[`n',2] = 0
mat C[`n',3] = 0
local n = `n' + 1

	/* week of opening */
mat C[`n',2] = _b[A0]
mat C[`n',3] = _se[A0]
local n = `n' + 1

	/* posterior to opening */
forvalues i = 1/`Amax' {
	mat C[`n',2] = _b[Ap`i']
	mat C[`n',3] = _se[Ap`i']	
	local n = `n' + 1
}



/*********************************************************************/
/*** III. Prepare for graph										   ***/
/*********************************************************************/
clear

	/* 95% confidence intervals */
foreach mt in A B C D {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}


/*********************************************************************/
/*** IV. Graphs													   ***/
/*********************************************************************/
/* Panel A: Stacked DID, adjusted for differential seasonality */
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		ylabel(-0.05(0.05)0.1)
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/Fig2A.pdf", replace

/* Panel B: Twoway FE, treated units only */
# delimit ;
twoway  (scatter B2 B1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap B_lo B_hi B1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		ylabel(-0.05(0.05)0.1)
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/Fig2B.pdf", replace

/* Panel C: Twoway FE, treated units only, accounting for seasonality */
# delimit ;
twoway  (scatter C2 C1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap C_lo C_hi C1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		ylabel(-0.05(0.05)0.1)
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/Fig2C.pdf", replace


* end
timer off 1
timer list 1
cap log close
