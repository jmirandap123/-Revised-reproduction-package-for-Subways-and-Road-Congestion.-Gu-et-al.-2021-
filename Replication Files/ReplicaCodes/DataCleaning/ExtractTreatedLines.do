/***********************/
/*** ExtractTreatedLines.do ***/
/*** Selected roads and links near treated lines ***/
/***********************/
clear
set more off
timer clear
timer on 1
cd "/Users/bzou/Downloads/Speed/"

/***********************/
/*** id-roadname-linkid***/
/***********************/
use Data2/Extract/TreatedLines_SelectedRoads.dta, clear

rename polygon_id id
duplicates drop id roadname, force

save Data2/Extract/TreatedLines_SelectedRoads_temp.dta, replace
 
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
	
	/* merge */
	merge m:1 linkid using DataTransferred/linkInfo.dta, keepusing(roadname)
	drop if _merge == 2
	drop _merge
	
	drop if roadname == ""
	
	merge m:1 id roadname using Data2/Extract/TreatedLines_SelectedRoads_temp.dta, keepusing(roadname)
	keep if _merge == 3
	drop _merge
	
	/* rush hours */
	gen timestr = string(time,"%10.0f")
	gen hour = substr(timestr,9,2)
	destring hour, replace
	keep if inlist(hour,7,8,17,18)
	drop timestr hour
	
	/* drop duplicates */
	duplicates drop linkid time, force
	
	save Data2/Extract/Sample_TreatedLines_part`i'.dta, replace
	
	noisily dis "Part `i' out of 36 is done."
}



/*** Append ***/
clear
set more off
forvalues i = 1/35 {
	append using Data2/Extract/Sample_TreatedLines_part`i'.dta
	erase  Data2/Extract/Sample_TreatedLines_part`i'.dta
}


duplicates drop linkid time, force
save Data2/Extract/Sample_TreatedLines.dta, replace
erase Data2/Extract/TreatedLines_SelectedRoads_temp.dta

timer off 1 
timer list 1


/***********************/
/*** Delete weekend and holidays ***/
/***********************/
use Data2/Extract/Sample_TreatedLines.dta, clear

gen datestr = string(date,"%16.0f")
rename date datenum
gen date = date(datestr,"YMD")
gen dow = dow(date)
drop if dow == 0 | dow == 6
drop date datestr dow 

qui do Codes/SelectedLinks/_Holidays.do
drop if holiday != 0
drop holiday

save Data2/Extract/Sample_TreatedLines.dta, replace

/***********************/
/*** Merge with treated lines	 	 ***/
/***********************/
set more off
timer on 2

qui forvalues seq = 1/45 {
	use Data2/Extract/TreatedLines_SelectedRoads.dta, clear
	egen seqid = group(line_id)
	rename polygon_id id 

	keep if seqid == `seq'
	summ line_id if seqid == `seq'
	local line = `r(mean)'
	
	duplicates drop roadname, force
	
	merge 1:m id roadname using Data2/Extract/Sample_TreatedLines.dta
	keep if _merge == 3
	drop _merge
	
		/* line ID, road name, */
	preserve
		keep line_id id city line treat roadname linkid
		cap duplicates drop linkid, force
		save Data2/Extract/TreatedLines_SelectedLinks_Line`seq'.dta, replace
	restore
	
		/* line ID, speed*/
	keep line_id id treat linkid datenum time speed congestindex
	save Data2/Extract/Sample_TreatedLines_Line`seq'.dta, replace

	noisily dis "`seq' out of 45 is done."
}

	/* Combine */
clear
qui forvalues seq = 1/45 {
	append using Data2/Extract/TreatedLines_SelectedLinks_Line`seq'.dta
	erase Data2/Extract/TreatedLines_SelectedLinks_Line`seq'.dta
}
save Data2/Extract/TreatedLines_SelectedLinks.dta, replace

clear
qui forvalues seq = 1/45 {
	append using Data2/Extract/Sample_TreatedLines_Line`seq'.dta
	erase Data2/Extract/Sample_TreatedLines_Line`seq'.dta
}
save Data2/Extract/Sample_TreatedLines.dta, replace


timer off 2
timer list 2

* end
