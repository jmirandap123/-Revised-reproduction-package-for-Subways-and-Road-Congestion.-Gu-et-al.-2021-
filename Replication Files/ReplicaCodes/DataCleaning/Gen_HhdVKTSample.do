/**************************************************/
/*** Gen_HhdVKTSample.do						***/
/*** Beijing hhd transp survey, 2010 and2015	***/
/*** How increase in subway access changes transportation mode ***/
/*** Generate regression sample at the household level***/
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
/*** I. Data compilation						***/
/**************************************************/
/*** I.1 2010-2015 subway growth in TAZ ***/
use Data2/HouseholdVKT/TAZ2010_subway_change.dta, clear

/****************************************************************
/* Change in the number of subway lines and subway length in the TAZ*/
gen dnumli = numli_2014 - numli_2010 
/* Change in whether having a subway line passing */
gen dsub = (numli_2010==0 & numli_2014>1)
/* Change in length of subway in TAZ */
gen dleng = leng_2014 - leng_2010
****************************************************************/
rename code taz2010
rename leng_2010 leng2010
rename leng_2014 leng2015
rename numli_2010 numli2010
rename numli_2014 numli2015
rename numst_2010 numst2010
rename numst_2014 numst2015
gen lden2010 = leng2010/area
gen lden2015 = leng2015/area

keep *2010 *2015
drop taz_2010 line_2010

reshape long leng numli numst lden, i(taz2010) j(year)
rename leng subway_leng
rename numli subway_numli
rename numst subway_numst
rename lden subway_lden

save Data2/HouseholdVKT/ProcessData1_SubwayExtension.dta, replace


/*** I.2 Vehicle info 2010 ***/
use "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Vehicle Data.dta", clear

/* trim sample and variables */
	/* keep only private cars */
keep if private == 1
	/* drop cars with extremely large mileage (or whether they are error codes */
drop if mileage >= 999999
	/* trim mileage at 99% */
summ mileage, de
replace mileage = `r(p99)' if mileage >= `r(p99)'
	/* vehicle type: passenger or truck */
gen passengercar = (inlist(vehicletype,1,2,3))
	/* engine capacity */
rename displacement enginecapacity 

/* keep variables */
# delimit ;
keep HHid  vehicleid mileage
	/* car chars */
	passengercar enginecapacity
;
# delimit cr

/* collapse to the household level */
gen N_cars = 1
collapse (sum) N_cars mileage  (max) enginecapacity, by(HHid)

/* HHid */
egen NewHHid = group(HHid)
tostring NewHHid, replace
replace NewHHid = "2010-"+NewHHid

save Data2/HouseholdVKT/ProcessData2_Vehicles2010.dta, replace


/*** I.3 Vehicle info 2015 ***/
use "$datapath/2015/Cleaned_Dta/vehicle_2015.dta", clear

/* trim sample and variables */
	/* vehicle type: passenger or truck */
gen passengercar = (inlist(vehicletype,1,2,3))
	/* mileage */
rename mileage12 mileage
summ mileage, de
replace mileage = `r(p99)' if mileage >= `r(p99)'
	/* vehicle id */
rename vehicle_id  vehicleid
	
/* keep variables */
# delimit ;
keep HHid  vehicleid mileage
	/* car chars */
	passengercar enginecapacity 
	odometer vehicleage
;
# delimit cr

/* collapse to the household level */
gen N_cars = 1
collapse (sum) N_cars mileage (max) enginecapacity odometer vehicleage, by(HHid)

/* HHid */
egen NewHHid = group(HHid)
tostring NewHHid, replace
replace NewHHid = "2015-"+NewHHid

save Data2/HouseholdVKT/ProcessData3_Vehicles2015.dta, replace


use Data2/HouseholdVKT/ProcessData2_Vehicles2010.dta, clear
append using Data2/HouseholdVKT/ProcessData3_Vehicles2015.dta
isid NewHHid
save Data2/HouseholdVKT/ProcessData6_Vehicles20102015.dta, replace

/*** I.4 Hhd info 2010 ***/
use "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Household Data.dta", clear

/* trim sample and variables */
	/* income bracket */
drop if income == 99
rename income income_bracket
gen income = .
replace income = 25000 if income_bracket == 1
replace income = 75000 if income_bracket == 2
replace income = 125000 if income_bracket == 3
replace income = 175000 if income_bracket == 4
replace income = 225000 if income_bracket == 5
replace income = 275000 if income_bracket == 6
replace income = 325000 if income_bracket == 7
replace income = 600000 if income_bracket == 8
replace income = 25000 if income_bracket == 99

	/* household side and # of workers*/
rename residents hhd_size
rename employee N_workers 
	/* having kids */
rename kids havekid
	/* taz */
rename TAZid_home taz2010
	
/* keep variables */
# delimit ;
keep HHid 
	/* location */
	taz2010
	/* Hhd chars */
	income_bracket income
	hhd_size N_workers
	houseownership buildingtype floorarea housingtype
	havekid
	/* interview dates */
	day1 day2
;
# delimit cr

gen Day1 = dofc(day1)
format %td Day1
gen Day2 = dofc(day2)
format %td Day2
drop day1 day2
rename Day1 day1
rename Day2 day2

	/*
		houseownership: 住房所有权
		1.家庭自有产权房; 2.单位自管房/直管房; 3.借住房屋; 4.租住房屋; 5.廉租房; 6.其他 
		buildingtype: 住房类型
		1.正规楼房; 2.中式楼房; 3.简易楼房; 4.别墅; 5.公寓; 6.平房; 7.其他
		housingtype: 住房性质
		1.商品房; 2.房改房; 3.经济适用房; 4.其他
	*/
	

/* merge with personal information */
merge 1:m HHid using "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Person Data.dta", keepusing(gender role age hukou education persontype job industry)
drop if _merge == 2
drop _merge

/* verify household size */
bysort HHid: gen hhsize = _N
count if hhsize == hhd_size

gen children = (inrange(age,6,12))
bysort HHid: egen Children = max(children)
drop children
tab Children havekid

drop Children hhsize

/* keep only the man of household */
	/* verify # of HHD == # of heads */
bysort HHid: gen n = _n
count if role == 0
local Nhead = `r(N)'
count if n == 1
local Nhhd = `r(N)'
assert `Nhead' == `Nhhd'
drop n 

	/* keep head */
keep if inlist(role,0,1)
gsort HHid gender age
by HHid: gen n = _n
keep if n == 1
drop n role

/* head's characteristics */
	/*
		education: 1.学龄前儿童; 2.小学; 3.初中; 4.高中; 5.中专; 6.大专; 7.本科; 8.研究生; 9.未受教育;
	*/
rename education head_edu
	/*
		persontype: 1.全职工作; 2.兼职工作; 3.全日制学习; 4.非全日制学习; 5.学龄前儿童; 6.退休人员; 7.照料家庭; 8.无职业; 9.其他; 
	*/
rename persontype head_persontype	
	/*
		occ: 1.工人 2.企业公司员工 3.商业服务业人员 4.公务员 5.事业单位员工 6.农林牧渔业人员 
			7.社区工作人员 8.个体业主或经营者 9.专职司机 10.教职工 11.医护人员 12.军人/警察 
			13.自由职业 14.其他
	*/
rename job head_occ
replace head_occ = 99 if head_occ == .
	/*
		industry: 1.农林牧渔 2.采矿业 3.制造业 4.电燃气水 5.建筑 6.交通仓储邮政 7.信息计算机软件
				8.批发零售 9.餐饮住宿 10.金融 11.房地产 12.租赁和商务服务 13.科研技术地质 14.水利环境公共设施
				15.居民服务 16.教育 17.卫生社会保障福利 18.文化体育娱乐 19.公共管理和社会组织 20.国际组织
	*/
rename industry head_ind

rename gender head_gender
rename age head_age
	/*
		hukou: 1.京籍本区 2.京籍外区 3.外地户口 4.外国籍 5.港澳台 6.其他
	*/
rename hukou head_hukou

/* HHid */
egen NewHHid = group(HHid)
tostring NewHHid, replace
replace NewHHid = "2010-"+NewHHid

gsort HHid -head_age
by HHid: keep if _n == 1
isid NewHHid

save Data2/HouseholdVKT/ProcessData4_HHd2010.dta, replace


/*** I.5 Hhd info 2015  ***/
use "$datapath/2015/Cleaned_Dta/household_2015.dta", clear

gen day1_str = substr(firstvisit_date,7,4)+substr(firstvisit_date,4,2)+substr(firstvisit_date,1,2)
gen day2_str = substr(secondvisit_date,7,4)+substr(secondvisit_date,4,2)+substr(secondvisit_date,1,2)
gen day1 = date(day1_str,"YMD")
format %td day1
gen day2 = date(day2_str,"YMD")
format %td day2

/* trim sample and variables */
	/* income bracket */
rename lastyearincome income_bracket
gen income = .
replace income = 25000 if income_bracket == 1
replace income = 75000 if income_bracket == 2
replace income = 125000 if income_bracket == 3
replace income = 175000 if income_bracket == 4
replace income = 225000 if income_bracket == 5
replace income = 275000 if income_bracket == 6
replace income = 325000 if income_bracket == 7
replace income = 600000 if income_bracket == 8
replace income = 25000 if income_bracket == 99

	/* move */
gen moved = (changeaddress == 2) 
gen moved_year = startyear_address
gen PreAdd_taz = previous_address

rename PreAdd_taz taz2015
merge m:1 taz2015 using Data2/HouseholdVKT/TAZ2015_2010_crosswalk.dta, keepusing(taz2010)
drop if _merge == 2
drop _merge
rename taz2010 PreAdd_taz2010
drop taz2015

	/* taz */
rename address_home  taz2015
merge m:1 taz2015 using Data2/HouseholdVKT/TAZ2015_2010_crosswalk.dta, keepusing(taz2010)
drop if _merge == 2
drop _merge

	/*
		houseownership: 住房所有权
		1.家庭自有产权房; 2.单位自管房/直管房; 3.借住房屋; 4.租住房屋; 5.廉租房; 6.其他 
	*/
rename housetype houseownership
replace houseownership = 6 if houseownership >= 6

/* keep variables */
# delimit ;
keep HHid 
	/* location */
	taz2010
	/* Hhd chars */
	income_bracket income
	floorarea houseownership
	/* move */
	moved moved_year PreAdd_taz2010 
	/* interview dates */
	day1 day2
;
# delimit cr

/* merge with personal information */
# delimit ;
merge 1:m HHid using "$datapath/2015/Cleaned_Dta/person_2015.dta", 
	keepusing(gender role age hukou edu persontype job industry)
;
# delimit cr
drop if _merge == 2
drop _merge

/* size of household */
bysort HHid: gen hhd_size = _N
gen worker = (inlist(persontype,1,2))
bysort HHid: egen N_workers = total(worker)
drop worker

gen havekids = (inrange(age,6,12))
bysort HHid: egen havekid = max(havekids)
drop havekids

/* keep only head of household */
	/* verify # of HHD == # of heads */
bysort HHid: gen n = _n
count if role == 0
local Nhead = `r(N)'
count if n == 1
local Nhhd = `r(N)'
assert `Nhead' == `Nhhd'
drop n 

	/* keep head */
keep if inlist(role,0,1)
gsort HHid gender age
by HHid: gen n = _n
keep if n == 1
drop n role

/* head's characteristics */
rename edu head_edu
rename persontype head_persontype	
rename job head_occ
replace head_occ = 99 if head_occ == .
rename industry head_ind
rename gender head_gender
rename age head_age
rename hukou head_hukou

/* HHid */
egen NewHHid = group(HHid)
tostring NewHHid, replace
replace NewHHid = "2015-"+NewHHid

gsort HHid -head_age
by HHid: keep if _n == 1
isid NewHHid

save Data2/HouseholdVKT/ProcessData5_HHd2015.dta, replace

/*** I.6 Trips 2010 ***/
use "$datapath/2010/Data Cleaning_2nd round/2010 BJHTS Trip.dta", clear

/* drop trips with walking and cycling*/
drop if inlist(mode,1,12,13,14)

/* code modes */
gen mode_sub = (mode == 6)
gen mode_bus = (mode == 7)
gen mode_car = (inlist(mode,2,3,4,5,8,9,10,11))

/* collapse to person level: ever use? */
collapse (max) mode_sub mode_bus mode_car (first) HHid, by(Pid)

/* collapse to household level: share use */
collapse (mean) mode_sub mode_bus mode_car, by(HHid)

/* merge to get NewHHid */
merge 1:1 HHid using Data2/HouseholdVKT/ProcessData4_HHd2010.dta, keepusing(NewHHid)
drop if _merge == 1
drop _merge
/*** If not merged, it means that no one in the household took a trip that uses the following modes of transportation ***/
/*** Can leave it out of the sample***/
/***
replace mode_sub = 0 if mode_sub == .
replace mode_bus = 0 if mode_bus == .
replace mode_car = 0 if mode_car == .
***/

save Data2/HouseholdVKT/ProcessData7_Trips2010.dta, replace


/*** I.7 Trips 2015 ***/
use "$datapath/2015/Cleaned_Dta/trip_location_2015.dta", clear

/* drop trips with walking and cycling*/
drop if inlist(mode,1,12,13,14)

/* code modes */
gen mode_sub = (mode == 6)
gen mode_bus = (mode == 7)
gen mode_car = (inlist(mode,21,22,23,3,4,5,8,9,10,11))

/* collapse to person level: ever use? */
collapse (max) mode_sub mode_bus mode_car (first) HHid, by(Pid)

/* collapse to household level: share use */
collapse (mean) mode_sub mode_bus mode_car, by(HHid)

/* merge to get NewHHid */
merge 1:1 HHid using Data2/HouseholdVKT/ProcessData5_HHd2015.dta, keepusing(NewHHid)
drop _merge
/*** If not merged, it means that no one in the household took a trip that uses the following modes of transportation ***/
/*** Can leave it out of the sample***/
/***
replace mode_sub = 0 if mode_sub == .
replace mode_bus = 0 if mode_bus == .
replace mode_car = 0 if mode_car == .
***/

save Data2/HouseholdVKT/ProcessData8_Trips2015.dta, replace


/*** I.8 Trips 2010 and 2015 ***/
clear
use Data2/HouseholdVKT/ProcessData7_Trips2010.dta
append using Data2/HouseholdVKT/ProcessData8_Trips2015.dta
save Data2/HouseholdVKT/ProcessData9_Trips20102015.dta, replace

/*** I.9 Merge and append  ***/
/* Households info */
clear 
use Data2/HouseholdVKT/ProcessData5_HHd2015.dta
gen year = 2015
append using Data2/HouseholdVKT/ProcessData4_HHd2010.dta
replace year = 2010 if year == .
isid NewHHid

/* Vehicle info */
merge 1:1 NewHHid using Data2/HouseholdVKT/ProcessData6_Vehicles20102015
drop if _merge == 2
drop _merge

replace N_cars = 0 if N_cars == .
replace mileage = 0 if mileage == .
replace enginecapacity = 0 if enginecapacity == .
replace odometer = 0 if odometer == .
replace vehicleage = 0 if vehicleage == .
replace income_bracket = 0 if income_bracket == .

/* Trip modes */
merge m:1 NewHHid using Data2/HouseholdVKT/ProcessData9_Trips20102015.dta
drop _merge 

/* TAZ info */
merge m:1 taz2010 year using Data2/HouseholdVKT/ProcessData1_SubwayExtension.dta
drop if _merge == 2
drop _merge


/*** I.10 Erase process data ***/
erase Data2/HouseholdVKT/ProcessData1_SubwayExtension.dta
erase Data2/HouseholdVKT/ProcessData2_Vehicles2010.dta
erase Data2/HouseholdVKT/ProcessData3_Vehicles2015.dta
*erase Data2/HouseholdVKT/ProcessData4_HHd2010.dta
*erase Data2/HouseholdVKT/ProcessData5_HHd2015.dta
erase Data2/HouseholdVKT/ProcessData6_Vehicles20102015.dta
erase Data2/HouseholdVKT/ProcessData7_Trips2010.dta
erase Data2/HouseholdVKT/ProcessData8_Trips2015.dta
erase Data2/HouseholdVKT/ProcessData9_Trips20102015.dta

/*** I.11 Change in TAZ distance to subway station ***/
gen code = string(taz2010)
gen l = length(code)
replace code = "0" + code if l == 5
drop l
merge m:1 code using Data2/HouseholdVKT/TAZDist2StnGrid/distance_2010_2014.dta
assert _merge != 1
keep if _merge == 3
drop _merge

gen dln_dist2stn_1015 = ln(distance_2014/1000) - ln(distance_2010/1000)
gen ln_dist2stn = ln(distance_2014/1000)  if year == 2015
replace ln_dist2stn = ln(distance_2010/1000)  if year == 2010

/*** I.12 Label variables ***/		                                                  
label var day1 "interview day 1: day of dropping off the questionnaire"
label var day2 "interview day 2: day of collecting the questionnaire"
label var income "household income, generated from income brackets"
label var moved "whether the household had moved"
label var moved_year "year last moved"
label var PreAdd_taz2010 "TAZ (2010 code) of the previous residence"
label var taz2010 "TAZ (2010 code) of the current residence"
label var head_gender "gender of household head: 1 male 2 female"
label var head_age "age of household head"
label var head_edu "education of household head"
label var head_persontype "employment status of household head"
label var NewHHid "new Household ID"
label var head_occ "occupation of household head"
label var head_ind "industry of household head"
label var hhd_size "household size"
label var N_workers "# of workers in the household "
label var havekid "=1 if have kid between 0 and 18"
label var enginecapacity "motor vehicle engine capacity (litre), = 0 if no motor vehicle"
label var year "survey year, 2010 or 2015"
label var buildingtype "1.正规楼房; 2.中式楼房; 3.简易楼房; 4.别墅; 5.公寓; 6.平房; 7.其他"
label var housingtype "1.商品房; 2.房改房; 3.经济适用房; 4.其他"
label var N_cars "# of cars in the household"
label var mileage "total mileage from all cars in the last 12 months"
label var subway_numli "# of subway lines in the TAZ"
label var odometer "odometer reading of the oldest vehicle"
label var vehicleage "age of the oldest vehicle"
label var mode_sub "avg prob of using subway among household members"
label var mode_bus "avg prob of using bus among household members"
label var mode_car "avg prob of using car among household members"
label var distance_2010 "TAZ distance to subway in 2010"
label var distance_2014 "TAZ distance to subway in 2014"
label var subway_numst "# of subway stations in the TAZ"
label var subway_leng "subway line length (km) in the TAZ"
label var subway_lden "subway line density (km/sqkm) in the TAZ"
label var ln_dist2stn "log distance to subway station (in the corresponding year)"
label var dln_dist2stn_1015 "change in log distance to the subway station between 2010 and 2015"
label var code "county code"
label var taz "TAZ (2010 code)"

save Data2/HouseholdVKT/HhdVKTSample.dta, replace

* end

