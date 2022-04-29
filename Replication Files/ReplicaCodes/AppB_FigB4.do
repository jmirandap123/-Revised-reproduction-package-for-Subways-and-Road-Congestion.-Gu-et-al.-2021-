/*********************************************************************/
/*** Appendix B: Additional Evidence on Differential Seasonality	***/
/*** Alternative, cities with only 1 period of subway line opening (singleton launches) ***/
/*** Placebo tests for singleton launches							***/
/*********************************************************************/
clear
set more off
timer clear
set matsize 11000
timer on 1
cap log close
log using "LogFiles/AppB_FigB4", replace

/************************************************/
/*** I. Lines launched before Apr 30, 2017 
		and there was no additional line launched before Jan 31, 2018
		in the same city.
		Placebo opening date 12/31/2017
***/
/************************************************/
/*** I.1 Actual effect ***/
use Data/BaseSamp.dta, clear

gen Grp1 = (inlist(case,7,8,9,11,12,13,14,15,16,32,34))
keep if Grp1 == 1

	/*** week-to-open between [-8,8]***/
keep if inrange(wk2open,-8,8)

	/*** PERIODS X TREAT  ***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

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

	/*** Estimate and extract ***/
set more off
/*** Weekly ***/
/*** Set minus 1 as zero 		 ***/
# delimit ;
reghdfe lnspd_res
	Am8-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
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


	/*** Graph ***/
clear

svmat A
gen A_lo = A2 - 1.96 * A3
gen A_hi = A2 + 1.96 * A3

gen b_Am1 = round(A2,0.001) if A1 == -1
gen se_Am1 = round(A3,0.001) if A1 == -1
	
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("Lines launched before April 2017, Actual")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)8, angle(45))
		ylabel(-0.1(0.05)0.15, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB4_A.pdf", replace


/*** I.2 Placebo Effect ***/
use Data/BaseSamp.dta, clear

gen Grp1 = (inlist(case,7,8,9,11,12,13,14,15,16,32,34))
keep if Grp1 == 1

	/*** Placebo week of treatment ***/
replace wk2open = wk2open - 51 if case == 7
replace wk2open = wk2open - 72 if case == 8
replace wk2open = wk2open - 51 if case == 9
replace wk2open = wk2open - 60 if case == 11
replace wk2open = wk2open - 38 if case == 12
replace wk2open = wk2open - 67 if case == 13
replace wk2open = wk2open - 52 if case == 14
replace wk2open = wk2open - 62 if case == 15
replace wk2open = wk2open - 62 if case == 16
replace wk2open = wk2open - 74 if case == 32
replace wk2open = wk2open - 49 if case == 34
	
	/*** week-to-open between [-8,3]***/
keep if inrange(wk2open,-8,3)

	/*** PERIODS X TREAT  ***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

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

/*** Regression and Extraction ***/
/*** Set minus 1 as zero 		 ***/
# delimit ;
reghdfe lnspd_res
	Am8-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
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


	/*** Graph ***/
clear

svmat A
gen A_lo = A2 - 1.96 * A3
gen A_hi = A2 + 1.96 * A3
	
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("Placebo opening on 12/31/2017")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)8, angle(45))
		ylabel(-0.1(0.05)0.15, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB4_B.pdf", replace


/************************************************/
/*** II. Lines launched after Apr 30, 2017 
		 and there was no line launched between Aug 1, 2016 and Apr 30, 2017
		 in the same city.
	Placebo opening date 12/31/2016	 
***/
/************************************************/
/*** II.1 Actual effect ***/
use Data/BaseSamp.dta, clear

gen Grp2 = (inlist(case,3,21,22,33,38,10,23,24,25,26,37,45,21,22))
keep if Grp2 == 1
	
	/*** week-to-open between [-8,12]***/
keep if inrange(wk2open,-8,12)

	/*** PERIODS X TREAT  ***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

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

	/*** Estimate and extract ***/
/*** Set minus 1 as zero 		 ***/

# delimit ;
reghdfe lnspd_res
	Am8-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
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


	/*** Graph ***/
clear

svmat A
gen A_lo = A2 - 1.96 * A3
gen A_hi = A2 + 1.96 * A3
	
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("Lines launched after April 2017, Actual")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)12, angle(45))
		ylabel(-0.1(0.05)0.15, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB4_C.pdf", replace


/*** II.2 Placebo ***/
use Data/BaseSamp.dta, clear

gen Grp2 = (inlist(case,3,21,22,33,38,10,23,24,25,26,37,45,21,22))
keep if Grp2 == 1

	/*** Placebo week of treatment ***/
replace wk2open = wk2open + 26 if case == 3
replace wk2open = wk2open + 52 if case == 10
replace wk2open = wk2open + 28 if case == 21
replace wk2open = wk2open + 35 if case == 22
replace wk2open = wk2open + 49 if case == 23
replace wk2open = wk2open + 36 if case == 24
replace wk2open = wk2open + 22 if case == 25
replace wk2open = wk2open + 22 if case == 26
replace wk2open = wk2open + 23 if case == 33
replace wk2open = wk2open + 53 if case == 37
replace wk2open = wk2open + 33 if case == 38
replace wk2open = wk2open + 52 if case == 45

	/*** week-to-open between [-4,12]***/
keep if inrange(wk2open,-4,12)

	/*** PERIODS X TREAT  ***/
summ wk2open
local Amax = `r(max)'
local Amin = `r(min)'
mat A = J(`=`Amax'-`Amin'+1',3,.)

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

	/*** Estimate and extract ***/
set more off
/*** Set minus 1 as zero 		 ***/
# delimit ;
reghdfe lnspd_res
	Am4-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
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

/*** Estimate 2: adjusted for seasonality ***/
/*** Set minus 1 as zero 		 ***/
# delimit ;
reghdfe lnspd_res
	Am4-Am2 A0 Ap* 
	treat
	, a(linkid case_wk2open yrwk##c.(lnpop lngdppc lnpop2 lngdppc2)) cluster(case)
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

	/*** Graph ***/
clear

svmat A
gen A_lo = A2 - 1.96 * A3
gen A_hi = A2 + 1.96 * A3


# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("Placebo opening on 12/31/2016")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)12, angle(45))
		ylabel(-0.1(0.05)0.15, angle(45))
		xline(0)
		legend(off)
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB4_D.pdf", replace


* end
timer off 1
timer list 1
cap log close
