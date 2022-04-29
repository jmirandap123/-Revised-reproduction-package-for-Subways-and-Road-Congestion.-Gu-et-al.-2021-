/*********************************************************************/
/*** Fig 6: Heterogeneous Effects								   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Fig6", replace

use "Data/ExtendSample.dta", clear

/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/

/*** INTERACTIONS  ***/
gen Dp_Roadtype12 = Dp * (roadtype == 1 | roadtype == 2)
gen Dp_Roadtype3 = Dp * (roadtype == 3)
gen Dp_Roadtype4 = Dp * (roadtype == 4)

gen Dp_dist2line_0to1 = Dp * (inrange(link2_nearest_treat_line_km,0,1))
gen Dp_dist2line_1to2 = Dp * (inrange(link2_nearest_treat_line_km,1,2))
gen Dp_dist2line_1to2p5 = Dp * (inrange(link2_nearest_treat_line_km,1,2.5))
gen Dp_dist2line_2to5 = Dp * (inrange(link2_nearest_treat_line_km,2,5))
gen Dp_dist2line_5to10 = Dp * (inrange(link2_nearest_treat_line_km,5,10))
gen Dp_dist2line_abv10 = Dp * (link2_nearest_treat_line_km > 10)

gen Dp_same_direct = Dp * same_direct
gen Dp_diff_direct = Dp * (same_direct == 0)
gen Dp_same_direct_roadtype12 = Dp * same_direct * (roadtype == 1 | roadtype == 2)
gen Dp_same_direct_roadtype3 = Dp * same_direct * (roadtype == 3)
gen Dp_same_direct_roadtype4 = Dp * same_direct * (roadtype == 4 | roadtype == 5)

gen Dp_MostAffectedLinks = Dp * MostAffectedLinks
gen Dp_NonMostAffectedLinks = Dp * (MostAffectedLinks == 0)

gen Dp_MoreCongested = Dp * (MoreCongested == 1)
gen Dp_LessCongested = Dp * (MoreCongested == 0)

/**************************************/
/*** VI. Estimation and extract 	***/
/**************************************/
set more off
mat E = J(20,4,.)

/*** Col 1: Baseline ***/
# delimit ;
reghdfe lnspd_res 
	Dp 
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0) 
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol1
mat E[1,1] = 1
mat E[1,2] = _b[Dp]
mat E[1,3] = _se[Dp]
qui summ CI if e(sample) == 1
mat E[1,4] = `r(mean)'


/*** Col 2: directly affected  ***/
cap drop hetero
cap drop case_wk2open_hetero
gen hetero = 1 if MostAffectedLinks == 1
replace hetero = 2 if MostAffectedLinks != 1
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)

# delimit ;
reghdfe lnspd_res 
	Dp_NonMostAffectedLinks Dp_MostAffectedLinks
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol2
mat E[2,1] = 3
mat E[2,2] = _b[Dp_MostAffectedLinks]
mat E[2,3] = _se[Dp_MostAffectedLinks]
summ CI if MostAffectedLinks == 1 & e(sample) == 1
mat E[2,4] = `r(mean)'
mat E[3,1] = 4
mat E[3,2] = _b[Dp_NonMostAffectedLinks]
mat E[3,3] = _se[Dp_NonMostAffectedLinks]
summ CI if MostAffectedLinks == 0 & e(sample) == 1
mat E[3,4] = `r(mean)'


/*** Col 3: distance to the treated line ***/
cap drop hetero
cap drop case_wk2open_hetero
gen hetero = 1 if inrange(link2_nearest_treat_line_km,0,1)
replace hetero = 2 if inrange(link2_nearest_treat_line_km,1,2.5)
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)

# delimit ;
reghdfe lnspd_res 
	Dp_dist2line_0to1 Dp_dist2line_1to2p5
	treat  if (link2_nearest_treat_line_km <= 2.5)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol3
mat E[4,1] = 6
mat E[4,2] = _b[Dp_dist2line_0to1]
mat E[4,3] = _se[Dp_dist2line_0to1]
summ CI if inrange(link2_nearest_treat_line_km,0,1)==1 & e(sample) == 1
mat E[4,4] = `r(mean)'
mat E[5,1] = 7
mat E[5,2] = _b[Dp_dist2line_1to2p5]
mat E[5,3] = _se[Dp_dist2line_1to2p5]
summ CI if inrange(link2_nearest_treat_line_km,1,2.5)==1 & e(sample) == 1
mat E[5,4] = `r(mean)'


/*** Col 4: parallel vs. orthogonal  ***/
cap drop hetero
cap drop case_wk2open_hetero
gen hetero = 1 if same_direct == 1
replace hetero = 2 if same_direct == 0 
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)
# delimit ;
reghdfe lnspd_res 
	Dp_same_direct Dp_diff_direct
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol4
mat E[6,1] = 9
mat E[6,2] = _b[Dp_same_direct]
mat E[6,3] = _se[Dp_same_direct]
summ CI if same_direct==1 & e(sample) == 1
mat E[6,4] = `r(mean)'
mat E[7,1] = 10
mat E[7,2] = _b[Dp_diff_direct]
mat E[7,3] = _se[Dp_diff_direct]
summ CI if same_direct==0 & e(sample) == 1
mat E[7,4] = `r(mean)'


/*** Col 5: congested & non-congested  ***/
cap drop hetero
cap drop case_wk2open_hetero
gen hetero = 1 if MoreCongested == 1
replace hetero = 2 if MoreCongested == 0
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)
	/* avg CI is 1.75 */
# delimit ;
reghdfe lnspd_res
	Dp_MoreCongested Dp_LessCongested
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol5
mat E[8,1] = 12
mat E[8,2] = _b[Dp_MoreCongested]
mat E[8,3] = _se[Dp_MoreCongested]
summ CI if MoreCongested == 1 & e(sample) == 1
mat E[8,4] = `r(mean)'
mat E[9,1] = 13
mat E[9,2] = _b[Dp_LessCongested]
mat E[9,3] = _se[Dp_LessCongested]
summ CI if MoreCongested == 0 & e(sample) == 1
mat E[9,4] = `r(mean)'

	
/*** Col 6: road type ***/
cap drop hetero
cap drop case_wk2open_hetero
gen hetero = 1 if inlist(roadtype,1,2)
replace hetero = 2 if roadtype == 3
replace hetero = 3 if roadtype == 4 | roadtype == .
tab hetero, m
egen case_wk2open_hetero = group(case wk2open hetero)
# delimit ;
reghdfe lnspd_res 
	Dp_Roadtype12 Dp_Roadtype3 Dp_Roadtype4
	treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol6
mat E[10,1] = 15
mat E[10,2] = _b[Dp_Roadtype12]
mat E[10,3] = _se[Dp_Roadtype12]
summ CI if inlist(roadtype,1,2) & e(sample) == 1
mat E[10,4] = `r(mean)'
mat E[11,1] = 16
mat E[11,2] = _b[Dp_Roadtype3]
mat E[11,3] = _se[Dp_Roadtype3]
summ CI if inlist(roadtype,3) & e(sample) == 1
mat E[11,4] = `r(mean)'
mat E[12,1] = 17
mat E[12,2] = _b[Dp_Roadtype4]
mat E[12,3] = _se[Dp_Roadtype4]
summ CI if inlist(roadtype,4) & e(sample) == 1
mat E[12,4] = `r(mean)'

	
/*** Col 7: With or Against Traffic ***/
	/*** In the sample, each observation is a road segment - week to open - morning/evening rush hour ***/
preserve
	merge 1:m case linkid wk2open using Data/WithAgainstTraffic.dta
	drop if _merge == 2
	drop _merge
	drop if WithTraffic == .
	
	gen Dp_WithTraffic = Dp * (WithTraffic == 1)
	gen Dp_AgainstTraffic = Dp * (WithTraffic == 0)

	cap drop hetero
	cap drop case_wk2open_hetero
	gen hetero = 1 if WithTraffic == 0
	replace hetero = 2 if WithTraffic == 1
	tab hetero, m
	egen case_wk2open_hetero = group(case wk2open hetero)

	# delimit ;
	reghdfe lnspd_res_WithAgainstTraffic 
		Dp_WithTraffic Dp_AgainstTraffic
		treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
		, a(case_wk2open case_linkid case_wk2open_hetero yrwk##c.(lnpop lngdppc)) cluster(case)
	;
	# delimit cr
	eststo ACol7
	mat E[13,1] = 19
	mat E[13,2] = _b[Dp_WithTraffic]
	mat E[13,3] = _se[Dp_WithTraffic]
	summ CI_WithAgainstTraffic if WithTraffic == 1 & e(sample) == 1
	mat E[13,4] = `r(mean)'
	mat E[14,1] = 20
	mat E[14,2] = _b[Dp_AgainstTraffic]
	mat E[14,3] = _se[Dp_AgainstTraffic]
	summ CI_WithAgainstTraffic if WithTraffic == 0 & e(sample) == 1
	mat E[14,4] = `r(mean)'
restore


/*** Col 8: Rush hour vs. non-rush hour ***/
	/*** In the sample, each observation is a road segment - week to open - rush/non-rush hour ***/
preserve
	cap drop lnspd_res 
	cap drop CI_res 
	cap drop CI 
	cap drop speed 
	cap drop lnspd
	merge 1:m case linkid wk2open using Data/RushNonrusHours.dta

	drop if _merge == 2
	drop _merge
	drop if rushhour == .
	
	gen Dp_Rush = Dp * (rushhour == 1)
	gen Dp_NoRush = Dp * (rushhour == 0)

	cap drop hetero
	cap drop case_wk2open_hetero
	gen hetero = 1 if rushhour == 0
	replace hetero = 2 if rushhour == 1
	tab hetero, m
	egen case_wk2open_hetero = group(case wk2open hetero)
	egen link_rushhour = group(linkid rushhou)

	# delimit ;
	reghdfe lnspd_res 
		Dp_Rush Dp_NoRush
		treat if (link2_nearest_treat_line_km <= 2.5 | treat == 0)
		, a(case_linkid case_wk2open_hetero link_rushhour yrwk##c.(lnpop lngdppc)) cluster(case)
	;
	# delimit cr
	eststo ACol8
	mat E[15,1] = 22
	mat E[15,2] = _b[Dp_Rush]
	mat E[15,3] = _se[Dp_Rush]
	summ CI if rushhour == 1 & e(sample) == 1
	mat E[15,4] = `r(mean)'
	mat E[16,1] = 23
	mat E[16,2] = _b[Dp_NoRush]
	mat E[16,3] = _se[Dp_NoRush]
	summ CI if rushhour == 0 & e(sample) == 1
	mat E[16,4] = `r(mean)'
restore

/*** Col 9: distance to lines ***/
/* Cat 1: dist to treated line <1 */
gen Dp_DistCat1 = Dp * (inrange(link2_nearest_treat_line_km,0,1))
/* Cat 2: dist to treated line [1,2.5], */
gen Dp_DistCat2 = Dp * (inrange(link2_nearest_treat_line_km,1,2.5))
/* Cat 3: dist to treated line > 2.5, dist to any line < 1*/
gen Dp_DistCat3 = Dp * (inrange(link2_nearest_treat_line_km,2.5,.) & inrange(link2_nearest_line_km,0,1))
/* Cat 4: dist to treated line > 2.5, dist to any line > 1*/
gen Dp_DistCat4 = Dp * (inrange(link2_nearest_treat_line_km,2.5,.) & inrange(link2_nearest_line_km,1,2.5))

# delimit ;
reghdfe lnspd_res 
	Dp_DistCat1 Dp_DistCat2 Dp_DistCat3 Dp_DistCat4
	treat if (link2_nearest_line_km <= 2.5 | treat == 0)
	, a(case_wk2open case_linkid yrwk##c.(lnpop lngdppc)) cluster(case)
;
# delimit cr
eststo ACol9
mat E[17,1] = 25
mat E[17,2] = _b[Dp_DistCat1]
mat E[17,3] = _se[Dp_DistCat1]
summ CI if (inrange(link2_nearest_treat_line_km,0,1)) & e(sample) == 1
mat E[17,4] = `r(mean)'
mat E[18,1] = 26
mat E[18,2] = _b[Dp_DistCat2]
mat E[18,3] = _se[Dp_DistCat2]
summ CI if (inrange(link2_nearest_treat_line_km,1,2.5)) & e(sample) == 1
mat E[18,4] = `r(mean)'
mat E[19,1] = 27
mat E[19,2] = _b[Dp_DistCat3]
mat E[19,3] = _se[Dp_DistCat3]
summ CI if (inrange(link2_nearest_treat_line_km,2.5,.) & inrange(link2_nearest_line_km,0,1)) & e(sample) == 1
mat E[19,4] = `r(mean)'
mat E[20,1] = 28
mat E[20,2] = _b[Dp_DistCat4]
mat E[20,3] = _se[Dp_DistCat4]
summ CI if (inrange(link2_nearest_treat_line_km,2.5,.) & inrange(link2_nearest_line_km,1,2.5)) & e(sample) == 1
mat E[20,4] = `r(mean)'

/**************************************/
/*** VII. Table and graph		 	***/
/**************************************/
/*** Table ***/
# delimit ;
esttab ACol*, 
	keep(Dp*)
	b(3) se(3) 
	title("Gradient")
	nostar
	modelwidth(7)
;
# delimi cr

# delimit ;
esttab ACol* using TablesFigures/Fig6_Table.tex
	, replace 
	keep(Dp*)
	b(3) se(3) 
	title("Heterogeneous Effects")
	nostar
	modelwidth(7)	
;
# delimi cr

/*** graph ***/
svmat E
gen E2_p2p5  = E2 - 1.96*E3
gen E2_p97p5 = E2 + 1.96*E3 

gen F1 = -E1
gen F2 = round(E2,0.001)
gen F3 = round(E3,0.001)
gen F5 = round(E4,0.01)
gen F = string(F2) + " (" + string(F3) + ")" + "		" + string(F5)
gen F4 = 0.08

replace F1 = 0 in 21
replace F = "coeff. (s.e.)	avg. congest index" in 21

cap label drop F
# delimit ;
label def F
	0  " "
	-1 "                      all"
	-3 "directly affected"
	-4 "non directly affected"
	-6 "d1=[0,1]"
	-7 "d1=(1,2.5]"
	-9 "parallel"
	-10 "orthogonal"
	-12 "more congested"
	-13 "less congested"	
	-15 "highway/expressway"
	-16 "arterial roads"
	-17 "sub-arterial roads"
	-19	"with traffic"
	-20	"against traffic"
	-22	"rush hour"
	-23	"off-peak hour"
	-25 "d1=[0,1]"
	-26 "d1=(1,2.5]" 
	-27 "d1=(2.5,.), d2=[0,1]"
	-28 "d1=(2.5,.), d2=(1,.)"
;
# delimit cr
label val F1 F

# delimit ;
twoway  (bar E2 F1, barwidth(0.8) fcolor(teal) horizontal) 
		(rcap E2_p2p5 E2_p97p5 F1,  horizontal) 
		(scatter F1 F4, mcolor(white) mlabel(F) mlabsize(vsmall) mlabcolor(black)) 
	if F1 <= 0
	,
	xline(0, lcolor(black))
	xlabel(-0.01 "-.01" 0 "0" 0.05 ".05" 0.1 ".1" 0.15 "", labsize(vsmall))
	yline(-24, lcolor(gs8) lwidth(medium) lpattern(dash))
	ylabel(0 -1 -3 -4 -6 -7 -9 -10 -12 -13 -15 -16 -17 -19 -20 -22 -23 -25 -26 -27 -28, 
		valuelabel angle(0) labsize(vsmall))
	xtitle("coeff.", size(small)) ytitle("")
	legend(off)
	graphregion(color(white))
	xsize(13) ysize(12)
;
# delimit cr

graph export "TablesFigures/Fig6.pdf", replace

* end
timer off 1
timer list 1
cap log close

