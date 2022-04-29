/**********************************************/
/*** Appendix B: Event Study 				***/
/*** Creates:
		Fig B.5: Event study
		Tab B.2: Regression Discontinuity Using Time as the Running Variable
***/
/**********************************************/
clear all
set more off
eststo clear
set matsize 11000
set seed 190512
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_FigB5TabB2", replace

use Data/BaseSamp.dta, replace

/**********************************************/
/*** I. Variables							***/
/**********************************************/
/*** wk2open within -48 and 47 ***/
keep if inrange(wk2open,-48,47)

/*** Polynomials ***/
forvalues i = 2/7 {
	gen wk2open`i' = wk2open ^ `i'
}
gen post = (wk2open >= 0)
gen post_wk2open = post * wk2open
forvalues i = 2/7 {
	gen post_wk2open`i' = post * wk2open`i'
}


/**********************************************/
/*** II. RD regs							***/
/**********************************************/

*/The following regression discontinuity shows that the performance variable is time relative to the opening of the subway */
*/It is done in order to control flexible temporal trends and identify a discontinuous change in the result in the vicinity of the policy change.*/

set more off
eststo clear

*/Includes a linear time trend for both treated and control groups Higher order polynomials are added in Columns 2 and 3, estimates for treated and control segments become smaller.*/

/*** A: treated ***/
reg lnspd_res post wk2open if treat == 1 & inrange(wk2open,-6,47), cluster(case) 
eststo ColA1
estadd scalar Poly = 1
reg lnspd_res post wk2open wk2open2-wk2open3 if treat == 1 & inrange(wk2open,-6,47), cluster(case) 
eststo ColA2
estadd scalar Poly = 3
reg lnspd_res post wk2open wk2open2-wk2open5 if treat == 1 & inrange(wk2open,-6,47), cluster(case) 
eststo ColA3
estadd scalar Poly = 5
reg lnspd_res post wk2open post_wk2open wk2open2-wk2open5 if treat == 1 & inrange(wk2open,-6,47), cluster(case) 
eststo ColA4
estadd scalar Poly = 5
reg lnspd_res post wk2open if treat == 1, cluster(case) 
eststo ColA5
estadd scalar Poly = 1
reg lnspd_res post wk2open wk2open2-wk2open3 if treat == 1, cluster(case) 
eststo ColA6
estadd scalar Poly = 3
reg lnspd_res post wk2open wk2open2-wk2open5 if treat == 1, cluster(case) 
eststo ColA7
estadd scalar Poly = 5
reg lnspd_res post wk2open post_wk2open wk2open2-wk2open5 if treat == 1, cluster(case) 
eststo ColA8
estadd scalar Poly = 5

/*** B: Control ***/
reg lnspd_res post wk2open if treat == 0 & inrange(wk2open,-6,47), cluster(case) 
eststo ColB1
estadd scalar Poly = 1
reg lnspd_res post wk2open wk2open2-wk2open3 if treat == 0 & inrange(wk2open,-6,47), cluster(case) 
eststo ColB2
estadd scalar Poly = 3
reg lnspd_res post wk2open wk2open2-wk2open5 if treat == 0 & inrange(wk2open,-6,47), cluster(case) 
eststo ColB3
estadd scalar Poly = 5
reg lnspd_res post wk2open post_wk2open wk2open2-wk2open5 if treat == 0 & inrange(wk2open,-6,47), cluster(case) 
eststo ColB4
estadd scalar Poly = 5
reg lnspd_res post wk2open if treat == 0, cluster(case) 
eststo ColB5
estadd scalar Poly = 1
reg lnspd_res post wk2open wk2open2-wk2open3 if treat == 0, cluster(case) 
eststo ColB6
estadd scalar Poly = 3
reg lnspd_res post wk2open wk2open2-wk2open5 if treat == 0, cluster(case) 
eststo ColB7
estadd scalar Poly = 5
reg lnspd_res post wk2open post_wk2open wk2open2-wk2open5 if treat == 0, cluster(case) 
eststo ColB8
estadd scalar Poly = 5


/*** Display ***/
# delimit ;
esttab ColA*,
	keep(post*)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N Poly, fmt(%6.0f %6.0f))
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColB*,
	keep(post*)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N Poly, fmt(%6.0f %6.0f))
	modelwidth(7)
;
# delimit cr

/*** Save ***/
# delimit ;
esttab ColA* using "TablesFigures/AppB_TabB2A.tex"
	, replace
	keep(post*)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N Poly, fmt(%6.0f %6.0f))
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColB* using "TablesFigures/AppB_TabB2B.tex"
	, replace
	keep(post*)
	se(3) b(3)
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N Poly, fmt(%6.0f %6.0f))
	modelwidth(7)
;
# delimit cr

/**********************************************/
/*** III. RD graphs							***/
/**********************************************/

*/A weekly average of the residual speed was made for the treated and control road sections. for each week relative to the opening of the metro line, first the averages are taken within each metro line, and then taken along 45 lines.

/*** Collapse to case-treat-wk2open		***/
/*** then further collapse to treat-wk2open***/
collapse (mean) lnspd_res, by(case treat wk2open)

collapse (mean) lnspd_res, by(treat wk2open)

*/ The residuals of the treated road segment are graphed, represented by red points, while the control points are represented by green.

/*** Graph		***/
gen lnspd_res_adj = lnspd_res + 0.0278767 if treat == 1
replace lnspd_res_adj = lnspd_res if treat == 0

# delimit ;
twoway  (scatter lnspd_res_adj wk2open if treat == 1, msymbol(circle_hollow) msize(medium) mcolor(maroon))
		(lowess lnspd_res_adj wk2open if treat == 1 & wk2open < 0, lwidth(thick) lcolor(maroon) lpattern(dash))
		(lowess lnspd_res_adj wk2open if treat == 1 & wk2open >= 0, lwidth(thick) lcolor(maroon) lpattern(dash))
		
		(scatter lnspd_res_adj wk2open if treat == 0, msymbol(X) msize(medium) mcolor(teal))
		(lowess lnspd_res_adj wk2open if treat == 0 & wk2open < 0, lwidth(thick) lcolor(teal) lpattern(dash))
		(lowess lnspd_res_adj wk2open if treat == 0 & wk2open >= 0, lwidth(thick) lcolor(teal) lpattern(dash))
		if inrange(wk2open,-6,47)
	, 
	/* title("Event Study") */
	title("")
	ytitle("mean residual log speed") xtitle("week to subway opening")
	xlabel(-8(4)48, angle(45)) ylabel(-0.04(0.02)0.08, angle(45))
	xline(0, lcolor(red) lwidth(thin) lpattern(solid))
	legend(on order(1 "treated" 4 "control"))
	graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_FigB5.pdf", replace


* ending
timer off 1
timer list 1
cap log close
* end
