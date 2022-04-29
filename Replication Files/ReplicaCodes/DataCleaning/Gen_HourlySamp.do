/************************************/
/*** Generate baseline hourly sample***/
/*** For one-step estimation in Table B.5 ***/
/************************************/
clear
cap log close
set more off
timer clear
timer on 1
cd "I:/Speed/"

/**********************************************/
/*** 0. Case by Case set up					***/
/**********************************************/
set more off
/*** 
Case 1: 青岛	3号线二期		12/18/16	12/19/16
Treated: line id 2	
Control: polygon id = 57
		 line id = 3
***/
local OpenDate1 = date("20161218","YMD")
local TreatLine1 = 2 
local ControlLine1 = "3"
local ControlPolygon1 = "57"
local DropDates1 = "inrange(datenum,20161207,20161209)"

/***
Case 2: 青岛2号线 12/10/17	12/11/17
Treated: line id 3
Control: polygon id = 57
		 line id = 2
***/
local OpenDate2 = date("20171210","YMD")
local TreatLine2 = 3
local ControlLine2 = "2"
local ControlPolygon2 = "57"
local DropDates2 = "inrange(datenum,20171203,20171205)"

/***
Case 3: 长春地铁1号线 6/30/17	6/30/17
Treated: line id = 6
Control: polygon id = 70
***/
local OpenDate3 = date("20170625","YMD")
local TreatLine3 = 6
local ControlLine3 = "."
local ControlPolygon3 = "70"
local DropDates3 = "inrange(datenum,0,0)"

/***
Case 4: 重庆地铁空港线 12/28/16	12/28/16
Treated: line id = 8
Control: polygon id = 22,23
***/
local OpenDate4 = date("20161228","YMD")
local TreatLine4 = 8
local ControlLine4 = "."
local ControlPolygon4 = "22 23"
local DropDates4 = "inrange(datenum,0,0)"

/***
Case 5: 重庆地铁5号线 12/28/17	12/28/17
Treated: line id = 9
Control: polygon id = 22,24
***/
local OpenDate5 = date("20171228","YMD")
local TreatLine5 = 9
local ControlLine5 = "."
local ControlPolygon5 = "22 24"
local DropDates5 = "inrange(datenum,20170930,20171110)"

/***
Case 6: 重庆地铁10号线 12/28/17	12/28/17
Treated: line id = 11
Control: polygon id = 24
		 line id = 10
***/
local OpenDate6 = date("20171228","YMD")
local TreatLine6 = 11
local ControlLine6 = "10"
local ControlPolygon6 = "24"
local DropDates6 = "inrange(datenum,20170930,20171110)"

/***
Case 7: 郑州城郊地铁 1/12/17	1/12/17
Treated: line id = 12
Control: polygon id = 54
***/
local OpenDate7 = date("20170112","YMD")
local TreatLine7 = 12
local ControlLine7 = "."
local ControlPolygon7 = "54"
local DropDates7 = "inrange(datenum,20160810,20160819)"

/***
Case 8: 郑州地铁2号线 8/19/16	8/19/16
Treated: line id = 14
Control: polygon id = 54
***/
local OpenDate8 = date("20160819","YMD")
local TreatLine8 = 14
local ControlLine8 = "."
local ControlPolygon8 = "54"
local DropDates8 = "inrange(datenum,0,0)"

/***
Case 9: 郑州地铁1号线二期 1/12/17	1/12/17
Treated: line id = 15
Control: polygon id = 54
***/
local OpenDate9 = date("20170112","YMD")
local TreatLine9 = 15
local ControlLine9 = "."
local ControlPolygon9 = "54"
local DropDates9 = "inrange(datenum,0,0)"

/***
Case 10: 贵阳地铁1号线 12/28/17	12/28/17
Treated: line id = 17
Control: polygon id = 19
***/
local OpenDate10 = date("20171228","YMD")
local TreatLine10 = 17
local ControlLine10 = "."
local ControlPolygon10 = "19"
local DropDates10 = "inrange(datenum,0,0)"

/***
Case 11: 西安地铁3号线 11/8/16	12/1/16
Treated: line id = 19
Control: polygon id = 50
***/
local OpenDate11 = date("20161108","YMD")
local TreatLine11 = 19
local ControlLine11 = "."
local ControlPolygon11 = "50"
local DropDates11 = "inrange(datenum,0,0)"

/***
Case 12: 苏州地铁4号线 4/15/17	4/17/17
Treated: line id = 21
Control: line id = 20
***/
local OpenDate12 = date("20170415","YMD")
local TreatLine12 = 21
local ControlLine12 = "20"
local ControlPolygon12 = ""
local DropDates12 = "inrange(datenum,20170325,20170327)"

/***
Case 13: 苏州地铁2号线二期 9/24/16	9/26/16
Treated: line id = 22
Control: polygon id = 40
***/
local OpenDate13 = date("20160924","YMD")
local TreatLine13 = 22
local ControlLine13 = "."
local ControlPolygon13 = "40"
local DropDates13 = "inrange(datenum,0,0)"

/***
Case 14: 福州地铁1号线二期北段 1/6/17	1/6/17
Treated: line id = 18
Control: line id = 26
		 polygon id = 17
***/
local OpenDate14 = date("20161225","YMD")
local TreatLine14 = 25
local ControlLine14 = "26"
local ControlPolygon14 = "17"
local DropDates14 = "inrange(datenum,0,0)"

/***
Case 15: 深圳地铁7号线 10/28/16 12/1/16
Treated: line id = 32
Control: polygon id = 2
***/
local OpenDate15 = date("20161028","YMD")
local TreatLine15 = 32
local ControlLine15 = "."
local ControlPolygon15 = "2"
local DropDates15 = "inrange(datenum,0,0)"

/***
Case 16: 深圳地铁9号线 10/28/16 12/1/16
Treated: line id = 33
Control: polygon id = 2
***/
local OpenDate16 = date("20161028","YMD")
local TreatLine16 = 33
local ControlLine16 = "."
local ControlPolygon16 = "2"
local DropDates16 = "inrange(datenum,0,0)"

/***
Case 17: 武汉地铁6号线 12/28/16	12/28/16
Treated: line id = 38
Control: line id = 39 
		 polygon id = 28,34
***/
local OpenDate17 = date("20161228","YMD")
local TreatLine17 = 38
local ControlLine17 = "39"
local ControlPolygon17 = "28 34"
local DropDates17 = "inrange(datenum,0,0)"

/***
Case 18: 武汉地铁8号线 12/26/17	12/26/17
Treated: line id = 39
Control: line id = 38 
		 polygon id = 28,33
***/
local OpenDate18 = date("20171226","YMD")
local TreatLine18 = 39
local ControlLine18 = "38"
local ControlPolygon18 = "28 33"
local DropDates18 = "inrange(datenum,0,0)"

/***
Case 19: 武汉地铁阳逻线 12/26/17	12/26/17
Treated: line id = 41
Control: line id = . 
		 polygon id = 31,28,33
***/
local OpenDate19 = date("20171226","YMD")
local TreatLine19 = 41
local ControlLine19 = "."
local ControlPolygon19 = "28 31 33"
local DropDates19 = "inrange(datenum,0,0)"

/***
Case 20: 武汉地铁机场线 12/28/16	12/28/16
Treated: line id = 42
Control: line id = . 
		 polygon id = 28,31,34
***/
local OpenDate20 = date("20161228","YMD")
local TreatLine20 = 42
local ControlLine20 = "."
local ControlPolygon20 = "28 31 34"
local DropDates20 = "inrange(datenum,0,0)"

/***
Case 21: 杭州地铁2号线一期西北段 7/3/17	7/3/17
Treated: line id = 44
Control: line id = 43 
		 polygon id = .
***/
local OpenDate21 = date("20170703","YMD")
local TreatLine21 = 44
local ControlLine21 = "43"
local ControlPolygon21 = ""
local DropDates21 = "inrange(datenum,0,0)"

/***
Case 22: 昆明地铁3号线 8/29/17	8/29/17
Treated: line id = 45
Control: line id = . 
		 polygon id = 14 15
***/
local OpenDate22 = date("20170829","YMD")
local TreatLine22 = 45
local ControlLine22 = "."
local ControlPolygon22 = "14 15"
local DropDates22 = "inrange(datenum,0,0)"

/***
Case 23: 成都地铁7号线 12/6/17	12/6/17
Treated: line id = 49
Control: line id = . 
		 polygon id = 32
***/
local OpenDate23 = date("20171206","YMD")
local TreatLine23 = 49
local ControlLine23 = "."
local ControlPolygon23 = "32"
local DropDates23 = "inrange(datenum,0,0)"

/***
Case 24: 成都地铁10号线 9/6/17	9/6/17
Treated: line id = 50
Control: line id = . 
		 polygon id = 32
***/
local OpenDate24 = date("20170906","YMD")
local TreatLine24 = 50
local ControlLine24 = "."
local ControlPolygon24 = "32"
local DropDates24 = "inrange(datenum,0,0)"

/***
Case 25: 成都地铁4号线二期西延 6/2/17	6/2/17
Treated: line id = 51
Control: line id = . 
		 polygon id = 32
***/
local OpenDate25 = date("20170602","YMD")
local TreatLine25 = 51
local ControlLine25 = "."
local ControlPolygon25 = "32"
local DropDates25 = "inrange(datenum,0,0)"

/***
Case 26: 成都地铁4号线二期东延 6/2/17	6/2/17
Treated: line id = 54
Control: line id = . 
		 polygon id = 32
***/
local OpenDate26 = date("20170602","YMD")
local TreatLine26 = 54
local ControlLine26 = "."
local ControlPolygon26 = "32"
local DropDates26 = "inrange(datenum,0,0)"

/***
Case 27: 广州地铁7号线首期 12/28/16	12/28/16
Treated: line id = 56
Control: line id = . 
		 polygon id = 8,9,11
***/
local OpenDate27 = date("20161228","YMD")
local TreatLine27 = 56
local ControlLine27 = "."
local ControlPolygon27 = "8 9 11"
local DropDates27 = "inrange(datenum,0,0)"

/***
Case 28: 广州地铁广佛线 12/28/16	12/28/16
Treated: line id = 57
Control: line id = . 
		 polygon id = 8,9,11
***/
local OpenDate28 = date("20161228","YMD")
local TreatLine28 = 57
local ControlLine28 = "."
local ControlPolygon28 = "8 9 11"
local DropDates28 = "inrange(datenum,0,0)"

/***
Case 29: 广州地铁9号线 12/28/17	12/28/17
Treated: line id = 58
Control: line id = . 
		 polygon id = 5,7,9,10
***/
local OpenDate29 = date("20171228","YMD")
local TreatLine29 = 58
local ControlLine29 = "."
local ControlPolygon29 = "7 9 10"
local DropDates29 = "inrange(datenum,0,0)"

/***
Case 30: 广州地铁6号线二期 12/28/16	12/28/16
Treated: line id = 59
Control: line id = . 
		 polygon id = 8,9,11
***/
local OpenDate30 = date("20161228","YMD")
local TreatLine30 = 59
local ControlLine30 = "."
local ControlPolygon30 = "8 9 11"
local DropDates30 = "inrange(datenum,0,0)"

/***
Case 31: 广州地铁13号线 12/28/17	12/28/17
Treated: line id = 61
Control: line id = . 
		 polygon id = 5,7,9,10
***/
local OpenDate31 = date("20171228","YMD")
local TreatLine31 = 61
local ControlLine31 = "."
local ControlPolygon31 = "7 9 10"
local DropDates31 = "inrange(datenum,0,0)"

/***
Case 32: 天津地铁6号线 8/6/16	8/8/16
Treated: line id = 66
Control: line id = . 
		 polygon id = 64
***/
local OpenDate32 = date("20160806","YMD")
local TreatLine32 = 66
local ControlLine32 = "."
local ControlPolygon32 = "64"
local DropDates32 = "inrange(datenum,20160704,20160719)"

/***
Case 33: 大连地铁1号线 6/8/17	6/8/17
Treated: line id = 69
Control: line id = . 
		 polygon id = 62
***/
local OpenDate33 = date("20170607","YMD")
local TreatLine33 = 69
local ControlLine33 = "."
local ControlPolygon33 = "62"
local DropDates33 = "inrange(datenum,0,0)"

/***
Case 34: 哈尔滨地铁3号线 1/26/17	2/6/17
Treated: line id = 71
Control: line id = . 
		 polygon id = 73
***/
local OpenDate34 = date("20170126","YMD")
local TreatLine34 = 71
local ControlLine34 = "."
local ControlPolygon34 = "73"
local DropDates34 = "inrange(datenum,0,0)"

/***
Case 35: 合肥地铁1号线 12/26/16	12/26/16
Treated: line id = 73
Control: line id = 74
		 polygon id = .
***/
local OpenDate35 = date("20161226","YMD")
local TreatLine35 = 73
local ControlLine35 = "74"
local ControlPolygon35 = ""
local DropDates35 = "inrange(datenum,0,0)"

/***
Case 36: 合肥地铁2号线 12/26/17	12/26/17
Treated: line id = 74
Control: line id = 73
		 polygon id = .
***/
local OpenDate36 = date("20171226","YMD")
local TreatLine36 = 74
local ControlLine36 = "73"
local ControlPolygon36 = ""
local DropDates36 = "inrange(datenum,20171206,20171210)"

/***
Case 37: 厦门地铁1号线一期 12/31/17	12/31/17
Treated: line id = 76
Control: line id = .
		 polygon id = 13
***/
local OpenDate37 = date("20171231","YMD")
local TreatLine37 = 76
local ControlLine37 = "."
local ControlPolygon37 = "13"
local DropDates37 = "inrange(datenum,20171006,20171011)"

/***
Case 38: 南昌地铁2号线 	8/18/17	8/18/17
Treated: line id = 79
Control: line id = .
		 polygon id = 75
***/
local OpenDate38 = date("20170818","YMD")
local TreatLine38 = 79
local ControlLine38 = "."
local ControlPolygon38 = "75"
local DropDates38 = "inrange(datenum,0,0)"

/***
Case 39: 南宁地铁2号线 	12/28/17	12/28/17
Treated: line id = 80
Control: line id = .
		 polygon id = 4
***/
local OpenDate39 = date("20171228","YMD")
local TreatLine39 = 80
local ControlLine39 = "."
local ControlPolygon39 = "4"
local DropDates39 = "inrange(datenum,0,0)"

/***
Case 40: 南宁地铁1号线 	12/28/16	12/28/16
Treated: line id = 81
Control: line id = .
		 polygon id = 3
***/
local OpenDate40 = date("20161228","YMD")
local TreatLine40 = 81
local ControlLine40 = "."
local ControlPolygon40 = "3"
local DropDates40 = "inrange(datenum,0,0)"

/***
Case 41: 南京地铁4号线 	1/8/17	1/8/17
Treated: line id = 82
Control: line id = 83
		 polygon id = 45
***/
local OpenDate41 = date("20170108","YMD")
local TreatLine41 = 82
local ControlLine41 = "83"
local ControlPolygon41 = "45"
local DropDates41 = "inrange(datenum,0,0)"

/***
Case 42: 南京地铁S3号线 	12/6/17	12/6/17
Treated: line id = 84
Control: line id = .
		 polygon id = 47
***/
local OpenDate42 = date("20171206","YMD")
local TreatLine42 = 84
local ControlLine42 = "."
local ControlPolygon42 = "47"
local DropDates42 = "inrange(datenum,0,0)"

/***
Case 43: 北京地铁16号线 	12/31/16	12/31/16
Treated: line id = 85
Control: line id = .
		 polygon id = 65
***/
local OpenDate43 = date("20161231","YMD")
local TreatLine43 = 85
local ControlLine43 = "."
local ControlPolygon43 = "65"
local DropDates43 = "inrange(datenum,0,0)"

/***
Case 44: 北京地铁西郊线 	12/30/17	1/2/18
Treated: line id = 86
Control: line id = .
		 polygon id = 65
***/
local OpenDate44 = date("20180228","YMD")
local TreatLine44 = 86
local ControlLine44 = "."
local ControlPolygon44 = "65"
local DropDates44 = "inrange(datenum,0,0)"

/***
Case 45: 上海地铁9号线 	12/30/17	1/2/18
Treated: line id = 93
Control: line id = .
		 polygon id = 36,39
***/
local OpenDate45 = date("20171230","YMD")
local TreatLine45 = 93
local ControlLine45 = "."
local ControlPolygon45 = "36 39"
local DropDates45 = "inrange(datenum,0,0)"


/************************************/
/*** I. Combine treated and control segments***/
/************************************/
use "Data2/Extract/Sample_TreatedLines.dta", clear
gen case = .
forvalues i = 1/45 {
		replace case = `i' if line_id == `TreatLine`i''
}

append using "Data2/Extract/Sample_ControlCities.dta"
replace treat = 0 if treat == .
replace case = pseudo_case if case == .

drop congestindex
drop pseudo_case line_id


/************************************/
/*** II. Week relative to opening ***/
/************************************/
gen OpenDate = .
forvalues i = 1/45 {
	replace OpenDate = `OpenDate`i'' if case == `i'
}
gen datestr = string(datenum,"%16.0f")
gen date = date(datestr,"YMD")
drop datestr

gen wk2open = int((date - OpenDate)/7)
replace wk2open = wk2open - 1 if date < OpenDate
	
	/*Drop test ride dates*/
forvalues i = 1/45 {
	drop if `DropDates`i'' == 1 & case == `i'
}

	/*keep wk2open between -6 and 47*/
keep if inrange(wk2open,-6,47)

	/*keep fully balanced sample, between -6 and 47 */
	/* extract from CrossCity_AllCasesWkly_ExclTestRides.dta*/
preserve
	use Data2/AllCasesWkly/CrossCity_AllCasesWkly_ExclTestRides.dta, clear
	gen n = 1
	collapse (first) n, by(case linkid treat)
	save Data2/AllCasesWkly/Case_Linkid_45CaseSample_temp.dta, replace
restore

merge m:1 case linkid treat using Data2/AllCasesWkly/Case_Linkid_45CaseSample_temp.dta
assert _merge != 2
keep if _merge == 3
drop _merge 

erase Data2/AllCasesWkly/Case_Linkid_45CaseSample_temp.dta

/************************************/
/*** III. Residuals from linkid-dow-hour ***/
/************************************/
gen dow = dow(date)
gen timestr = string(time,"%16.0f")
gen hour = substr(timestr,-2,2)
destring hour, replace
egen link_dow_hour = group(linkid dow hour)

gen lnspd = ln(speed)
areg lnspd, a(link_dow_hour)
	/* adjusted R-sqaured is 0.67 */
predict lnspd_res, res
summ lnspd_res
	/* sd = 0.24*/

	/* Winsorize */
bysort link_dow_hour: egen p99 = pctile(lnspd), p(99)
bysort link_dow_hour: egen p1 = pctile(lnspd), p(1)
bysort linkid: egen pres99 = pctile(lnspd_res), p(99)
bysort linkid: egen pres1 = pctile(lnspd_res), p(1)
replace lnspd = p99 if lnspd_res >= pres99
replace lnspd = p1 if lnspd_res <= pres1
drop p1 p99 pres1 pres99


/************************************/
/*** IV. Variables	 			  ***/
/************************************/
egen case_wk2open = group(case wk2open)
gen post = (wk2open >= 0)
gen treat_post = treat * (wk2open >= 0)


/**********************************************/
/*** V. City-level hetero					***/
/**********************************************/
gen opendate = . 
replace opendate = date("20161218","YMD") if case == 1
replace opendate = date("20171210","YMD") if case == 2
replace opendate = date("20170625","YMD") if case == 3
replace opendate = date("20161228","YMD") if case == 4
replace opendate = date("20171228","YMD") if case == 5
replace opendate = date("20171228","YMD") if case == 6
replace opendate = date("20170112","YMD") if case == 7
replace opendate = date("20160819","YMD") if case == 8
replace opendate = date("20170112","YMD") if case == 9
replace opendate = date("20171228","YMD") if case == 10
replace opendate = date("20161108","YMD") if case == 11
replace opendate = date("20170415","YMD") if case == 12
replace opendate = date("20160924","YMD") if case == 13
replace opendate = date("20161225","YMD") if case == 14
replace opendate = date("20161028","YMD") if case == 15
replace opendate = date("20161028","YMD") if case == 16
replace opendate = date("20161228","YMD") if case == 17
replace opendate = date("20171226","YMD") if case == 18
replace opendate = date("20171226","YMD") if case == 19
replace opendate = date("20161228","YMD") if case == 20
replace opendate = date("20170703","YMD") if case == 21
replace opendate = date("20170829","YMD") if case == 22
replace opendate = date("20171206","YMD") if case == 23
replace opendate = date("20170906","YMD") if case == 24
replace opendate = date("20170602","YMD") if case == 25
replace opendate = date("20170602","YMD") if case == 26
replace opendate = date("20161228","YMD") if case == 27
replace opendate = date("20161228","YMD") if case == 28
replace opendate = date("20171228","YMD") if case == 29
replace opendate = date("20161228","YMD") if case == 30
replace opendate = date("20171228","YMD") if case == 31
replace opendate = date("20160806","YMD") if case == 32
replace opendate = date("20170607","YMD") if case == 33
replace opendate = date("20170126","YMD") if case == 34
replace opendate = date("20161226","YMD") if case == 35
replace opendate = date("20171226","YMD") if case == 36
replace opendate = date("20171231","YMD") if case == 37
replace opendate = date("20170818","YMD") if case == 38
replace opendate = date("20171228","YMD") if case == 39
replace opendate = date("20161228","YMD") if case == 40
replace opendate = date("20170108","YMD") if case == 41
replace opendate = date("20171206","YMD") if case == 42
replace opendate = date("20161231","YMD") if case == 43
replace opendate = date("20180228","YMD") if case == 44
replace opendate = date("20171230","YMD") if case == 45
assert opendate != .
format %td opendate

merge m:1 linkid using Data2/LinkGeo/CityIDLink.dta
assert _merge != 1
keep if _merge == 3
drop _merge

merge m:1 cityname using Data2/CityLevel/CityChars.dta
assert _merge != 1
keep if _merge == 3
drop _merge
drop cityname citycode

/*** Calendar date ***/
cap drop date
gen date = (opendate + 7 * wk2open)

gen yr = year(date)
gen wk = week(date)
gen yrwk = yr*100 + wk
drop yr wk

/*** hetero ***/
ds popx10k gdppc avgwage
gen lnpop = ln(popx10k)
gen lnpop2 = ln(popx10k)^2
gen lnpop3 = ln(popx10k)^3
gen lngdppc = ln(gdppc)
gen lngdppc2 = ln(gdppc)^2
gen lngdppc3 = ln(gdppc)^3
gen lnavgwage = ln(avgwage)
gen lnavgwage2 = ln(avgwage)^2
gen lnavgwage3 = ln(avgwage)^3

save Data2/Extract/HourlySample.dta

* ending
timer off 1
timer list 1
* end
