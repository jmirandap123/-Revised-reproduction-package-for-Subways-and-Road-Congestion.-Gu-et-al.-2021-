/**********************************************************************/
/*** Tab 6: Model Choice and Hhd VKT								***/
/*** Columns 4-5: Hhd VKT									   		***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Tab6_Cols45_error", replace

* NOTE: Dataset needed to run this do-file is not provided 
* See README for details

/*** Data from Beijing Household Travel Survey, Restricted Use ***/
	/*** Data not provided in the replication packet***/
use Data/HhdVKTSample.dta, clear

/**************************************************/
/*** I. Additional Variables					***/
/**************************************************/
	/* Trim mileage at 95th percentile */
summ mileage if mileage > 0, de
replace mileage = `r(p95)' if mileage > `r(p95)'

gen ln_mileage = ln(mileage + 1)
gen ln_floorarea = ln(floorarea)
gen d_car = (N_cars > 0)
gen ln_inc = ln(income)
gen ln_subwayleng = ln(subway_leng + 1)
egen taz2010_incbr = group(taz2010  income_bracket)

/**************************************************/
/*** II. Regressions							***/
/**************************************************/
eststo clear
set more off

/*** Panel A: All households ***/
# delimit ;
reghdfe ln_mileage ln_dist2stn
	ln_floorarea N_workers havekid hhd_size
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColA1
summ ln_mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mileage ln_dist2stn
	ln_floorarea N_workers havekid hhd_size
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColA2
summ mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'


/*** Panel B: Non-movers ***/
# delimit ;
reghdfe ln_mileage ln_dist2stn 
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009))
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColB1
summ ln_mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mileage ln_dist2stn 
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009))
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColB2
summ mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'


/*** Panel C: Non-movers and car owners***/
# delimit ;
reghdfe ln_mileage ln_dist2stn
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & ((d_car == 1 & year == 2010) | (d_car == 1 & vehicleage>=5 & year == 2015))
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColC1
summ ln_mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mileage ln_dist2stn
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & ((d_car == 1 & year == 2010) | (d_car == 1 & vehicleage>=5 & year == 2015))
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColC2
summ mileage if e(sample) == 1
estadd scalar dvmean = `r(mean)'


/**************************************************/
/*** III. Display and Save						***/
/**************************************************/
/*** Display ***/
set more off
# delimit ;
esttab ColA*
	, se(3) b(3)
	kee(ln_dist2stn)
	title("Panel A: All Households")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))
;
# delimit cr

# delimit ;
esttab ColB*
	, se(3) b(3)
	kee(ln_dist2stn)
	title("Panel B: Non-movers")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))	
;
# delimit cr

# delimit ;
esttab ColC*
	, se(3) b(3)
	kee(ln_dist2stn)
	title("Panel C: Non-movers and car-owners")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))	
;
# delimit cr

/*** Save ***/
set more off
# delimit ;
esttab ColA* using TablesFigures/Tab6_PanelA_Cols45.tex
	, replace
	se(3) b(3)
	kee(ln_dist2stn)
	title("Panel A: All Households")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))
;
# delimit cr

# delimit ;
esttab ColB* using TablesFigures/Tab6_PanelB_Cols45.tex
	, replace
	se(3) b(3)
	kee(ln_dist2stn)
	title("Panel B: Non-movers")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))	
;
# delimit cr

# delimit ;
esttab ColC* using TablesFigures/Tab6_PanelC_Cols45.tex
	, replace
	se(3) b(3)
	kee(ln_dist2stn)
	title("Panel C: Non-movers and car-owners")
	mtitle("lnVKT VKT")
	star(* 0.1 ** 0.05 *** 0.01)
	stat(N dvmean, fmt(%6.0f %6.3f))	
;
# delimit cr
* end

timer off 1
timer list 1
cap log close
