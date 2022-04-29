/***********************/
/*** ExtractControlCities.do ***/
/*** Roads in cities with no line openings ***/
/***********************/
clear
set more off
timer clear
timer on 1
cd "/Users/bzou/Downloads/Speed/"
 
/***********************/
/*** Extract	 	 ***/
/***********************/
local data1 = "2016_part1.dta"
local data2 = "2016_part2.dta"
local data3 = "2016_part3.dta"
local data4 = "2016_part4.dta"
local data5 = "2016_part5.dta"
local data6 = "2016_part6.dta"
local data7 = "2016_part7.dta"
local data8 = "2016_part8.dta"
local data9 = "2016_part9.dta"
local data10 = "2016_part10.dta"

local data11 = "2017_part1.dta"
local data12 = "2017_part2.dta"
local data13 = "2017_part3.dta"
local data14 = "2017_part4.dta"
local data15 = "2017_part5.dta"
local data16 = "2017_part6.dta"
local data17 = "2017_part7.dta"
local data18 = "2017_part8.dta"
local data19 = "2017_part9.dta"
local data20 = "2017_part10.dta"
local data21 = "2017_part11.dta"
local data22 = "2017_part12.dta"
local data23 = "2017_part13.dta"
local data24 = "2017_part14.dta"
local data25 = "2017_part15.dta"
local data26 = "2017_part16.dta"
local data27 = "2017_part17.dta"
local data28 = "2017_part18.dta"
local data29 = "2017_part19.dta"
local data30 = "2017_part20.dta"

local data31 = "2018_part1.dta"
local data32 = "2018_part2.dta"
local data33 = "2018_part3.dta"
local data34 = "2018_part4.dta"
local data35 = "2018_part5.dta"

qui forvalues i = 1/35 {
	/* use */
	use "/Volumes/easystore/Speed/DataTransferred/`data`i''", clear
	
	/* rename */
	rename v1 citycode 
	rename v2 id
	rename v3 linkid
	rename v4 date
	rename v5 time 
	rename v6 speed
	rename v7 congestindex
	drop citycode
	
	/* in cities with no subway line opening during the sample period */
	gen tokeep = .
	replace tokeep = 1 if inlist(id,21,41,26,60,58,52,68,55,6)
	replace tokeep = 1 if inlist(id,42,48,43,25,74,59,72,46,69)
	keep if tokeep == 1
	drop tokeep
	
	/* No links with roadname == "" or roadtype == 5 */
	merge m:1 linkid using DataTransferred/linkInfo.dta, keepusing(roadname roadtype)
	keep if _merge == 3
	drop _merge
	drop if roadtype == 5
	drop if roadname == ""
	drop roadname roadtype

	/* keep only rush hours */
	gen timestr = string(time,"%10.0f")
	gen hour = substr(timestr,9,2)
	destring hour, replace
	keep if inlist(hour,7,8,17,18)
	drop timestr hour
	
	/* drop weekends and holidays */
	gen datestr = string(date,"%16.0f")
	rename date datenum
	gen date = date(datestr,"YMD")
	gen dow = dow(date)
	drop if dow == 0 | dow == 6
	drop date datestr dow 

	qui do Codes/SelectedLinks/_Holidays.do
	drop if holiday != 0
	drop holiday

	/* drop duplicates */
	duplicates drop linkid time, force
	
	/* save */
	save Data2/Extract/Sample_ControlCities_part`i'.dta, replace
	
	noisily dis "Part `i' out of 35 is done."
}


/***********************/
/*** Combine	 	 ***/
/***********************/
clear
set more off
forvalues i = 1/35 {
	append using Data2/Extract/Sample_ControlCities_part`i'.dta
	erase Data2/Extract/Sample_ControlCities_part`i'.dta
	
	noisily dis "Part `i' out of 35 is done."
}

duplicates drop id linkid time, force

save Data2/Extract/Sample_ControlCities.dta, replace


/***********************/
/*** Random case match, by linkid	 	 ***/
/***********************/
sort linkid time
by linkid: gen n = _n
gen r = runiform() if n == 1

bysort linkid: gen R = sum(r)
gen pseudo_case = int(R/0.02222222) + 1

drop n r R

save Data2/Extract/Sample_ControlCities.dta, replace

timer off 1
timer list 1

* end
