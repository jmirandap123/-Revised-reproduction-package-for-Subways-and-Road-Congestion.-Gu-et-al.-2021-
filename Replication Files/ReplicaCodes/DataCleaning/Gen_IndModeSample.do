/**************************************************/
/*** Gen_IndModeSample.do						***/
/*** Individual-level mode choice				***/
/*** Generate regression sample at the individual level ***/
/**************************************************/
clear all
set more off

clear
set more off
timer clear
set matsize 11000
cd "/Users/bzou/research/Speed/"
global datapath "/Users/bzou/Dropbox/UrbanBeijing/Data_TravelSurvey/"


/**************************************************/
/*** I. Individual mode choice, 2010 and 2015	***/
/**************************************************/
/*** I.1 Trips 2010 ***/
use "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Trip.dta", clear

/* drop trips with walking and cycling*/
drop if inlist(mode,1,12,13,14)

/* code modes */
gen mode_sub = (mode == 6)
gen mode_bus = (mode == 7)
gen mode_car = (inlist(mode,2,3,4,5,8,9,10,11))

/* collapse to person level: ever use? */
* collapse (max) mode_sub mode_bus mode_car (first) HHid, by(Pid)
collapse (sum) mode_sub mode_bus mode_car (first) HHid, by(Pid)
replace mode_bus = int((mode_bus)/1.5)
replace mode_car = int(mode_car/1.5)

/* merge to get personal chars */
drop HHid
# delimit ;
merge 1:1 Pid using "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Person Data.dta"
	, keepusing(industry job gender role age hukou education persontype HHid) 
;
# delimit cr
	/* has a trip record if merged */
gen hastrip = (_merge == 3)
drop _merge
rename education edu
replace job = 0 if job == .
replace industry = 0 if industry == .

gen work = (inlist(persontype,1,2))
drop persontype
gen BJ_hk = (inlist(hukou,1,2))
drop hukou

/* merge to get new HHid */
merge m:1 HHid using Data2/HouseholdVKT/ProcessData4_HHd2010.dta, keepusing(NewHHid day1 day2)
keep if _merge == 3
drop _merge

gen year = 2010

/* save */
save Data2/HouseholdVKT/IndMode_ProcessData_2010.dta, replace

/*** I.2 Trips 2015 ***/
use "$datapath/2015/Cleaned_Dta/trip_location_2015.dta", clear

/* drop trips with walking and cycling*/
drop if inlist(mode,1,12,13,14)

/* code modes */
gen mode_sub = (mode == 6)
gen mode_bus = (mode == 7)
gen mode_car = (inlist(mode,21,22,23,3,4,5,8,9,10,11))

/* collapse to person level: ever use? */
* collapse (max) mode_sub mode_bus mode_car (first) HHid, by(Pid)
collapse (sum) mode_sub mode_bus mode_car (first) HHid, by(Pid)
replace mode_bus = int(mode_bus/1.5)
replace mode_car = int(mode_car/1.5)
drop HHid 
# delimit ;
merge 1:1 Pid using "$datapath/2015/Cleaned_Dta/person_2015.dta", 
	keepusing(gender role age hukou edu persontype job industry HHid)
;
# delimit cr
	/* has a trip record if merged */
gen hastrip = (_merge == 3)
drop _merge
replace job = 0 if job == .
replace industry = 0 if industry == .

gen work = (inlist(persontype,1,2))
drop persontype
gen BJ_hk = (inlist(hukou,1,2))
drop hukou

/* merge to get new HHid */
merge m:1 HHid using Data2/HouseholdVKT/ProcessData5_HHd2015.dta, keepusing(NewHHid day1 day2)
keep if _merge == 3
drop _merge

gen year = 2015

/*** I.3 Append trips 2010 and 2015  ***/
append using Data2/HouseholdVKT/IndMode_ProcessData_2010.dta
erase Data2/HouseholdVKT/IndMode_ProcessData_2010.dta

summ 

/*** I.4 Merge with household info and TAZ info ***/
merge m:1 NewHHid using Data2/HouseholdVKT/RegSample.dta
keep if _merge == 3
drop _merge


/*** I.5 Label vars ***/
label var Pid "new person id: TAZ id (6 digits) + household sequence number (6 digits) + person"
label var mode_sub "# of subway rides"
label var mode_bus "# of bus rides"
label var mode_car "# of car rides"
label var HHid "household id: TAZ id (6 digits) + household sequence number (5 digits)"
label var gender "1 male 2 female"
label var role "relationship to the household head: 0-8; 0 = head"
label var age "age"
label var edu "education"
label var job	"job type: 1-16"
label var industry "industry"
label var hastrip "=1 if has any trip"
label var work "=1 if work"  
label var BJ_hk "=1 if has Beijing Hukou"
label var day1 "day when the questionaire was dropped off"
label var day2 "day when the questionaire was collected"
label var NewHHid "household ID, group(HHid)"
label var year "year, 2010 or 2015"
label var houseownership "housetypes housing type: 1-8"
label var floorarea "floor area, in square meters"
label var income_bracket "Income of last year, in bracket"
label var income "Income of last year, in level,s calculated from brackets"
label var moved "whether had moved"
label var moved_year "year last moved"
label var PreAdd_taz2010 "TAZ (2010 code) of the previous residence"
label var taz2010 "TAZ (2010 code) of the current residence"
label var head_gender "gender of household head: 1 male 2 female"
label var head_age "age of household head"
label var head_hukou "hukou of household head"
label var head_edu	"education of household head"
label var head_persontype "employment status of household head"
label var head_occ "occupation of household head"
label var head_ind  "industry of household head"
label var hhd_size  "household size"
label var N_workers "# of workers in the household"
label var havekid	"=1 if have kid between 0 and 18"
label var buildingtype	"1.正规楼房; 2.中式楼房; 3.简易楼房; 4.别墅; 5.公寓; 6.平房; 7.其他"
label var housingtype  "1.商品房; 2.房改房; 3.经济适用房; 4.其他"
label var N_cars "# of cars in the household"
label var mileage "total mileage from all cars in the last 12 months"
label var enginecapacity "motor vehicle engine capacity (litre), = 0 if no motor vehicle"
label var odometer   "odometer reading of the oldest vehicle"
label var vehicleage  "age of the oldest car"
label var subway_numli "# of subway lines in the TAZ"
label var subway_numst "# of subway stations in the TAZ"
label var subway_leng  "subway line length (km) in the TAZ"
label var subway_lden  "subway line density (km/sqkm) in the TAZ"
label var code         "county code"
label var taz         "TAZ (2010 code)"
label var distance_2010  "TAZ distance to subway in 2010"
label var distance_2014  "TAZ distance to subway in 2014"
label var dln_dist2stn_1015 "change in log distance to the subway station between 2010 and 2015"
label var ln_dist2stn    "log distance to subway station (in the corresponding year)"

save Data2/HouseholdVKT/IndModeSample.dta, replace
* end
