/**********************************************************************/
/*** Fig 5: Lines by date of launch									***/
/*** Panel C: Lines launched after 11/30/2017   					***/
/**********************************************************************/
clear all
set more off
set matsize 11000
set seed 190512
timer clear
timer on 1
cap log close
log using "LogFiles/Fig5C", replace

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
	a(linkid case_wk2open yrwk##c.(lnpop lngdppc), save) resid(A_res)
;
# delimit cr
predict A_hat, xbd

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
/*** III. Bootstrap					***/
/**************************************/
local B = 499
mat AA = J(`=`Amax'-`Amin'+1',`B',.)

sort case
by case: gen casen = _n

set more off
qui forvalues b = 1/`B' {
	cap drop A_hatb
	cap drop d D
	
	/*** Re-generate psuedo outcome ***/
	gen d = runiform() if casen == 1
	bysort case: egen D = mean(d)
	gen A_hatb = A_hat + A_res if D >= 0.5
	replace A_hatb = A_hat - A_res if D < 0.5
		
	/*** Estimation ***/	
	/*** Set minus 1 as zero 		 ***/
	# delimit ;
	qui reghdfe A_hatb
		Am48-Am2 A0 Ap* 
		treat
		, a(linkid case_wk2open yrwk##c.(lnpop lngdppc))
	;
	# delimit cr

		/*** Feed matrix ***/
		/* prior to opening */
	local n = 1
	forvalues i = `Amin'/-2 {
		local j = abs(`i')
		mat AA[`n',`b'] = _b[Am`j']
		local n = `n' + 1
	}

		/* Am1 */
	mat AA[`n',`b'] = 0
	local n = `n' + 1

		/* week of opening */
	mat AA[`n',`b'] = _b[A0]
	local n = `n' + 1

		/* posterior to opening */
	forvalues i = 1/`Amax' {
		mat AA[`n',`b'] = _b[Ap`i']
		local n = `n' + 1
	}

	noisily dis "`b' out of `B' bootstraps done!"
}

/**************************************/
/*** IV. Prepare for graph	 		***/
/**************************************/
clear

foreach mt in A {
	svmat `mt'
	gen `mt'_lo = `mt'2 - 1.96 * `mt'3
	gen `mt'_hi = `mt'2 + 1.96 * `mt'3
}


svmat AA
egen AA_P2p5 = rowpctile(A2 AA*) , p(2.5)
egen AA_P97p5 = rowpctile(A2 AA*) , p(97.5)


/**************************************/
/*** V. Graph				 		***/
/**************************************/
# delimit ;
twoway  (scatter A2 A1, msize(medium) mcolor(teal) msymbol(circle))
		(rcap AA_P2p5 AA_P97p5 A1, lcolor(teal) lwidth(medium) lpattern(solid))
		, title("")
		ytitle("coeff.") xtitle("weeks to subway opening")
		xlabel(-48(4)3, angle(45))
		xline(0)
		legend(off order(1 "weekly") cols(1) region(lwidth(none)))
		graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/Fig5C.pdf", replace

timer off 1
timer list 1
cap log close
* end


