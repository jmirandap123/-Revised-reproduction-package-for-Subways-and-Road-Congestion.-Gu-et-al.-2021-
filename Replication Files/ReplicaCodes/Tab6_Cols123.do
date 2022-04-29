/**********************************************************************/
/*** Tab 6: Model Choice and Hhd VKT								***/
/*** Columns 1-3: Individual Model Choices					   		***/
/**********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Tab6_Cols123_error", replace

* NOTE: Dataset needed to run this do-file is not provided 
* See README for details

/*** Data from Beijing Household Travel Survey, Restricted Us ***/
	/*** Data not provided in the replication packet***/
use Data/IndModeSample.dta, replace

/**************************************************/
/*** I. Additional Variables					***/
/**************************************************/
gen ln_mileage = ln(mileage + 1)
gen ln_floorarea = ln(floorarea)
gen d_car = (N_cars > 0)
gen ln_inc = ln(income)
gen ln_subwayleng = ln(subway_leng + 1)
gen abv_retire_age = ((age>= 60 & gender == 1) | (age>= 55 & gender == 2))
egen taz2010_incbr = group(taz2010  income_bracket)
gen dow1 = dow(day1)
gen dow2 = dow(day2)
gen subway_leng_hghinc = subway_leng * (income_bracket >= 2)
gen subway_leng_edu = subway_leng * (edu==7 | edu==8)

/**************************************************/
/*** II. Regressions								***/
/**************************************************/
/*** Panel A: Mode of transportation, cluster at the taz level ***/
set more off
# delimit ;
reghdfe mode_sub ln_dist2stn 
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColA1
summ mode_sub if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_bus ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColA2
summ mode_bus if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_car ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColA3
summ mode_car if e(sample) == 1 
estadd scalar dvmean = `r(mean)'


/*** Panel B: Households not moved between 2009 and 2014 ***/
set more off
# delimit ;
reghdfe mode_sub ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColB1
summ mode_sub if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_bus ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColB2
summ mode_bus if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_car ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColB3
summ mode_car if e(sample) == 1 
estadd scalar dvmean = `r(mean)'


/*** Panel C: Households not moved between 2009 and 2014, owned a car since 2009 ***/
set more off
# delimit ;
reghdfe mode_sub ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & ((d_car == 1 & year == 2010) | (d_car == 1 & vehicleage>=5 & year == 2015)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColC1
summ mode_sub if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_bus ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & ((d_car == 1 & year == 2010) | (d_car == 1 & vehicleage>=5 & year == 2015)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColC2
summ mode_bus if e(sample) == 1 
estadd scalar dvmean = `r(mean)'

# delimit ;
reghdfe mode_car ln_dist2stn
	work age i.edu i.job i.industry
	ln_floorarea N_workers havekid hhd_size
	if (moved == . | moved == 0 | (moved == 1 & moved_year <= 2009)) & ((d_car == 1 & year == 2010) | (d_car == 1 & vehicleage>=5 & year == 2015)) & hastrip == 1
	, a(taz2010 year income_bracket houseownership
		head_gender head_age head_hukou head_edu head_persontype  head_occ head_ind) 
	cluster(taz2010)
;
# delimit cr
eststo ColC3
summ mode_car if e(sample) == 1 
estadd scalar dvmean = `r(mean)'


/*** II.3 Display and save ***/
	/*** Display ***/
# delimit ;
esttab ColA*
	, se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColB*
	, se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice: non movers")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColC*
	, se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice: non movers and car owners")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

	/*** Save ***/
# delimit ;
esttab ColA* using TablesFigures/Tab6_PanelA_Cols123.tex
	, replace
	se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColB* using TablesFigures/Tab6_PanelB_Cols123.tex
	, replace
	se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice: non movers")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

# delimit ;
esttab ColC* using TablesFigures/Tab6_PanelC_Cols123.tex
	, replace
	se(3) b(3)
	mtitle(sub bus car)
	keep(ln_dist2stn)
	stat(N dvmean,fmt(%6.0f %6.3f))
	title("Individual Mode Choice: non movers and car owners")
	star(* 0.1 ** 0.05 *** 0.01)
	addnote("Clustered at the TAZ level")
	modelwidth(7)
;
# delimit cr

* end
timer off 1
timer list 1
cap log close
