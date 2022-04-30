/**********************************************************************/
/*** Appendix Fig B.7: Subgroups without differential seasonality	***/
/*** Panel A: Lines launched before 1/31/2017				   		***/
/*** Panel B: Lines launched between 2/1/2017-11/30/2017	   		***/
/*** Panel C: Lines launched after 12/1/2017				   		***/
/**********************************************************************/
clear all
set more off
eststo clear
set matsize 11000
set seed 190512
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_FigB7", replace

**The objective of this code is to make the seasonal differences through 3 groups: Panel A: Lines launched before 1/31/2017, Panel B: Lines launched between 2/1/2017-11/30/2017 and Panel C : Lines launched after 12/1/2017, through the standard regression of the model.*/
*/ The regression is run against the treaties before, during and after the launch of the metro lines. The rest refer to the base model*/
*What is seen in this command can be compared with the estimates in figure 5 already mentioned above. The same methodology is followed.*/

********************************************************************************
* PANEL A: Lines launched before 1/31/2017
********************************************************************************
use Data/BaseSamp.dta, replace
/**********************************************/
/*** I. Include only EARLIER lines			***/
/**********************************************/
gen early_lines = (opendate <= date("20170131","YMD"))
keep if early_lines == 1

	/* week-to-open within -6 and 47 */
keep if inrange(wk2open,-6,47)

	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)


/*** Week-to-open X Treat  ***/
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

/**************************************/
/*** II. Estimation and extract 	***/
/**************************************/

*/ The regression is run against the treaties before, during and after the launch of the metro lines. The rest refer to the base model*/

set more off
# delimit ;
reghdfe lnspd_res 
	Am6-Am2 A0 Ap*  
	post treat, 
	a(linkid case_wk2open) cluster(case)
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


/**************************************/
/*** III. Static specification 	***/
/**************************************/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-6,47)
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr
eststo Col1

/**************************************/
/*** IV. Prepare for graph	 		***/
/**************************************/
clear

foreach mt in A {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}

/**************************************/
/*** V. Graph				 		***/
/**************************************/
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-8(4)48, angle(45))
		xline(0)
		legend(off order(1 "weekly") cols(1) region(lwidth(none)))
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB7A.pdf", replace


********************************************************************************
* PANEL B: Lines launched between 2/1/2017-11/30/2017
********************************************************************************
use Data/BaseSamp.dta, replace
/**********************************************/
/*** I. Include only MIDDLE lines			***/
/**********************************************/
gen mid_lines = (opendate > date("20170131","YMD") & opendate <= date("20171130","YMD"))
keep if mid_lines == 1

	/* week-to-open within -20 and 20 */
keep if inrange(wk2open,-20,20)

	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)


/*** Week-to-open X Treat  ***/
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

/**************************************/
/*** II. Estimation and extract 	***/
/**************************************/
set more off

# delimit ;
reghdfe lnspd_res 
	Am20-Am2 A0 Ap*  
	post treat, 
	a(linkid case_wk2open) cluster(case)
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

/**************************************/
/*** III. Static specificaiton 		***/
/**************************************/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-20,20)
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr
eststo Col2

/**************************************/
/*** IV. Prepare for graph	 		***/
/**************************************/
clear

foreach mt in A {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}


/**************************************/
/*** V. Graph				 		***/
/**************************************/
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-20(4)20, angle(45))
		xline(0)
		legend(off order(1 "weekly") cols(1) region(lwidth(none)))
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB7B.pdf", replace


********************************************************************************
* PANEL C: Lines launched after 12/1/2017
********************************************************************************
use Data/BaseSamp.dta, replace
/**********************************************/
/*** I. Include only LATER lines			***/
/**********************************************/
gen late_lines = (opendate > date("20171130","YMD"))
keep if late_lines == 1

	/* week-to-open within -48 and 3 */
keep if inrange(wk2open,-48,3)

	/* Treat X Post */
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/*** Week-to-open X Treat  ***/
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

/**************************************/
/*** II. Estimation and extract 	***/
/**************************************/
set more off

# delimit ;
reghdfe lnspd_res 
	Am48-Am2 A0 Ap*  
	post treat, 
	a(linkid case_wk2open) cluster(case)
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

/**************************************/
/*** III. Static specification 		***/
/**************************************/
# delimit ;
reghdfe lnspd_res
	TP treat
	if inrange(wk2open,-47,3)
	, a(linkid case_wk2open) cluster(case)
;
# delimit cr
eststo Col3

/**************************************/
/*** IV. Prepare for graph	 		***/
/**************************************/
clear

foreach mt in A {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}

/**************************************/
/*** V. Graph				 		***/
/**************************************/
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap A_lo A_hi A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-48(4)3, angle(45))
		xline(0)
		legend(off order(1 "weekly") cols(1) region(lwidth(none)))
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB7C.pdf", replace


********************************************************************************
* Table
********************************************************************************
/*** Display ***/
# delimit ;
esttab Col*
	, keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Subgroups, clustered s.e., no diff season")
	mtitle(early middle late)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab Col* using "TablesFigures/AppB_FigB7_Tab.tex"
	, replace
	keep(TP)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Subgroups, clustered s.e.,  no diff season")
	mtitle(early middle late)
;
# delimit cr

* ending
timer off 1
timer list 1
cap log close
* end


