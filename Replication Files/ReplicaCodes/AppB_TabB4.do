/*********************************************************************/
/*** Appendix B: City-level Mode Substitutions					   ***/
/*********************************************************************/

*/ This section aims to present descriptive evidence of transport mode substitution after subway expansion based on household-level travel data in Beijing.*/

clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/AppB_TabB4", replace

use Data/PublicTransits.dta, clear

/******************************/
/*** I. Keep variables		***/
/******************************/


*/ Relevant variables for estimation are maintained: annual subway ridership, bus ridership, and car ownership, by year and city*/

keep city year citypop10k buspassenger10k subwayridership10k ncivilvehicle10k ncar10k busmileage10kkm



*/Empty data is removed*/

/* dalian does not have subway in 2002 */
replace subwayridership10k = . if city == "Dalian" & year == 2002

/* fill out 2009 */
sort city year
count if subwayridership10k & year == .
replace subwayridership10k = (subwayridership10k[_n-1] + subwayridership10k[_n+1])/2 if year == 2009

/*** 2002-2016 ***/
keep if inrange(year,2002,2016)
replace subwayridership10k = 0 if subwayridership10k == .
count if buspassenger10k== .

/* per capita values */
gen BusRidePC = buspassenger10k/citypop10k
gen SubwayRidePC = subwayridership10k/citypop10k
gen BusMileagePC = busmileage10kkm/citypop10k * 100

gen lnBusRidePC = ln(BusRidePC)
gen lnSubwayRidePC = ln(SubwayRidePC)
gen lnBusMileagePC = ln(BusMileagePC)

gen BusRiderPerMile = buspassenger10k/busmileage10kkm

/* cars */
replace ncivilvehicle10k = . if ncivilvehicle10k == 0
replace ncar10k = . if  ncar10k == 0

gen NCivVehPC = ncivilvehicle10k/citypop10k * 10000
gen NCarPC = ncar10k/citypop10k * 10000

/* other */
egen citycode = group(city)
gen t = year - 2001 

/******************************/
/*** II. Regressions		***/
/******************************/
eststo clear

*/they investigate the correlations between the number of subway passengers and the volumes of the different methods of transport while controlling for fixed effects of year and city.*/

/* Bus Ridership on Subway Ridership */
reghdfe BusRidePC SubwayRidePC, a(citycode year) cluster(citycode)
eststo Col1
estadd scalar CityFE = 1
estadd scalar YearFE = 1
qui tab citycode if e(sample) == 1
return list
estadd scalar NCity = `r(r)'
sum BusRidePC if e(sample) == 1
estadd scalar MeanDep = `r(mean)'

*/Same regression as above but changes Bus Mileage on Subway Ridership*/

reghdfe BusMileagePC SubwayRidePC, a(citycode year) cluster(citycode)
eststo Col2
estadd scalar CityFE = 1
estadd scalar YearFE = 1
qui tab citycode if e(sample) == 1
return list
estadd scalar NCity = `r(r)'
sum BusMileagePC if e(sample) == 1
estadd scalar MeanDep = `r(mean)'

*/Same regression as above but changes Vehicle ownership on Subway Ridership*/
reghdfe NCivVehPC SubwayRidePC, a(citycode year) cluster(citycode)
eststo Col3
estadd scalar CityFE = 1
estadd scalar YearFE = 1
qui tab citycode if e(sample) == 1
return list
estadd scalar NCity = `r(r)'
sum NCivVehPC if e(sample) == 1
estadd scalar MeanDep = `r(mean)'

*/The results of the previous graphs due to the fact that there is a moderate substitution between
subway rides and car ownership.*/

/******************************/
/*** III. Table				***/
/******************************/

# delimit ;
esttab Col*,
	b(3) se(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Subway and Other Modes of Transportation")
	mtitle(BusRiderPC BusMileagePC CarsPC)
	stats(CityFE YearFE N NCity MeanDep, fmt(%6.0f %6.0f %6.0f %6.0f %6.3f))
;
# delimit cr

# delimit ;
esttab Col* using TablesFigures/AppB_TabB4.tex
	, replace
	b(3) se(3)
	star(* 0.1 ** 0.05 *** 0.01)
	title("Subway and Other Modes of Transportation")
	mtitle(BusRiderPC BusMileagePC CarsPC)
	stats(CityFE YearFE N NCity MeanDep, fmt(%6.0f %6.0f %6.0f %6.0f %6.3f))
;
# delimit cr

* end
timer off 1
timer list 1
cap log off
