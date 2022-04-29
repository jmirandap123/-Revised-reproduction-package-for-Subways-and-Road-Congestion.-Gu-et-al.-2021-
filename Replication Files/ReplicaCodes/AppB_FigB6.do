/**********************************************************************/
/*** AppB_FigB6: Case-by-case estimates						***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_FigB6", replace

use Data/BaseSamp.dta, replace

/**********************************************/
/*** I. Variables							***/
/**********************************************/
/*** week-to-open within -6 and 47 ***/
keep if inrange(wk2open,-6,47)

/*** Road segment coordinates ***/
merge m:1 linkid using "Data/linkInfo_new.dta", keepusing(x_mid y_mid)
keep if _merge == 3
drop _merge

/*** PERIODS X TREAT  ***/
gen Dp = treat * (wk2open >= 0)

/**********************************************/
/*** I. Simple case-by-case regressions		***/
/**** Beijing Xijiao Line and Guangzhou Guang-Fo Line not included***/
/**********************************************/
mat B = J(45,4,.)
qui forvalues i = 1/45 {
	mat B[`i',2] = `i'
	if `i'!=28 & `i'!=44 {
	# delimit ;
	xi: reg2hdfespatial lnspd_res Dp treat 
		i.yrwk|lnpop i.yrwk|lngdppc
		if case == `i'
		, timevar(wk2open) panelvar(linkid) lat(y_mid) lon(x_mid) 
		distcutoff(50) lagcutoff(20)
	;
	# delimit cr

	mat B[`i',2] = _b[Dp]
	mat B[`i',3] = _se[Dp]
	mat B[`i',4] = _b[Dp]/_se[Dp]
	}
	noisily dis "I: `i' out of 45 is done."
}

mat colnames B = case b se t
matlist B
preserve
	clear 
	svmat B, name(col)
	save "TablesFigures/AppB_CasebyCase_Result1.dta", replace
restore

/**********************************************/
/*** II. Simple case-by-case regressions, [-6,6]	***/
/**********************************************/
set more off
mat B = J(45,4,.)
	
qui forvalues i = 1/45 {
	mat B[`i',2] = `i'
	if `i'!=28 & `i'!=44 {
	# delimit ;
	xi: reg2hdfespatial lnspd_res Dp treat 
		i.yrwk|lnpop i.yrwk|lngdppc
		if case == `i' & inrange(wk2open,-6,6)
		, timevar(wk2open) panelvar(linkid) lat(y_mid) lon(x_mid) 
		distcutoff(50) lagcutoff(12)
	;
	# delimit cr

	mat B[`i',2] = _b[Dp]
	mat B[`i',3] = _se[Dp]
	mat B[`i',4] = _b[Dp]/_se[Dp]
	}
	noisily dis "II: `i' out of 45 is done."
}

mat colnames B = case b se t
matlist B
clear 
svmat B, name(col)
replace case = _n if case == .
save "TablesFigures/AppB_CasebyCase_Result2.dta", replace

/**********************************************/
/*** VIII. Graphs							***/
/**********************************************/
/*** 0. merge ***/
use "TablesFigures/AppB_CasebyCase_Result1.dta", clear
rename b b_conv
rename se se_conv
rename t t_conv
replace case = _n
merge 1:1 case using "Data/Subway_Lines_Cases.dta"
drop _merge

merge 1:1 case using "TablesFigures/AppB_CasebyCase_Result2.dta"
drop _merge
rename b b_conv2
rename se se_conv2
rename t t_conv2

gen linename = city + line
labmask case, values(linename_eng)

/*** 2. Conventional ***/
	/*** [-6,47] ***/
gsort b_conv
gen n_conv = _n
labmask n_conv, values(linename_eng)
gen p2p5_conv = b_conv - 1.96*se_conv
gen p97p5_conv = b_conv + 1.96*se_conv 

# delimit ;
twoway (scatter n_conv b_conv , lcolor(dknavy) msize(small) msymbol(square))
	(rcap p2p5_conv p97p5_conv n_conv, horizontal lcolor(teal) lwidth(thin))
	if p2p5_conv != .
	, ytitle(" ") ylabel(1(1)43, labels labsize(vsmall) angle(zero) valuelabel) 
	xline(0)
	xlabel(-0.2(0.2)0.4)
	legend(on order(1 "coeff." 2 "95% C.I.") cols(1) region(lcolor(none)))
	xsize(7) ysize(9)
	graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_CasebyCase1.pdf", replace

	/*** [-6,6] ***/
gsort b_conv2
gen n_conv2 = _n
labmask n_conv2, values(linename_eng)
gen p2p5_conv2 = b_conv2 - 1.96*se_conv
gen p97p5_conv2 = b_conv2 + 1.96*se_conv 

# delimit ;
twoway (scatter n_conv2 b_conv2 , lcolor(dknavy) msize(small) msymbol(square))
	(rcap p2p5_conv2 p97p5_conv2 n_conv2, horizontal lcolor(teal) lwidth(thin))
	if p2p5_conv2 != .
	, ytitle(" ") ylabel(1(1)43, labels labsize(vsmall) angle(zero) valuelabel) 
	xline(0)
	xlabel(-0.2(0.2)0.4)	
	legend(on order(1 "coeff." 2 "95% C.I.") cols(1) region(lcolor(none)))
	xsize(7) ysize(9)
	graphregion(color(white))
;
# delimit cr
graph export "TablesFigures/AppB_CasebyCase2.pdf", replace

* end
timer off 1
timer list 1
cap log close
