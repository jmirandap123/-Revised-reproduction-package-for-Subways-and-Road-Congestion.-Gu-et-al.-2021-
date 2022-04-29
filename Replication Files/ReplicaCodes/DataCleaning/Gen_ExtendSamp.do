/*********************************************************************/
/*** Gen_ExtendSamp.do											   ***/
/*** Generate extended sample									   ***/
/*********************************************************************/
clear
set more off
timer clear
set matsize 11000
timer clear
timer on 1

if "`c(username)'" == "bzou" {
	cd "/Users/bzou/research/Speed/"
	global ldir "/Users/bzou/Dropbox/Congestion Law/Replica"
}

if "`c(username)'" == "benzou" {
	cd "I:/Speed/"
	global ldir "I:\Dropbox\Congestion Law\Replica"
}

cap log close

/**********************************************/
/*** 0.A With Traffic vs. Against Traffic	***/
/**********************************************/
use Data2/AllCasesWkly/CrossCityPolybyHour_ExclTestRides_AllCasesWkly.dta, clear
gen morning = (inlist(hour,7,8))
gen morning_CI = CI if morning == 1
gen evening_CI = CI if morning == 0

bysort linkid: egen AMRush_CI = mean(morning_CI)
bysort linkid: egen PMRush_CI = mean(evening_CI)
drop morning_CI evening_CI

gen AMRushLine = (AMRush_CI > PMRush_CI * 1.425393/1.581865)
gen PMRushLine = (AMRushLine == 0)

collapse (mean) AMRushLine PMRushLine treat speed CI lnspd_res, by(linkid case wk2open morning)
gen WithTraffic = .
replace WithTraffic = 1 if (morning == 1 & AMRushLine == 1) | (morning == 0 & AMRushLine == 0)
replace WithTraffic = 0 if (morning == 1 & AMRushLine == 0) | (morning == 0 & AMRushLine == 1)

rename CI CI_WithAgainstTraffic
rename lnspd_res lnspd_res_WithAgainstTraffic 

keep linkid case wk2open WithTraffic lnspd_res_WithAgainstTraffic morning CI_WithAgainstTraffic

save "$ldir/Data/WithAgainstTraffic.dta", replace


/**********************************************/
/*** I. Control segment to subway line relation***/
/**********************************************/
set more off
use Data2/AllCasesWkly/CrossCityPoly_ExclTestRides_AllCasesWkly.dta, clear
keep if treat == 0
merge m:m linkid using Data2/LinkGeo/Link2Line_bd.dta, keepusing(link2line_km roadtype direct_link direct_line)
keep if _merge == 3
drop _merge

bysort linkid: egen double link2line_km_min = min(link2line_km)
keep if link2line_km_min == link2line_km

collapse (first) link2line_km roadtype direct_link direct_line, by(linkid case)
replace direct_link  = "东西" if inlist(direct_link,"东向西","西向东")
replace direct_link  = "南北" if inlist(direct_link,"南向北","北向南")
gen same_direct = (direct_link == direct_line)
drop direct_link direct_line

rename link2line_km dist2line_control
rename roadtype roadtype_control
rename same_direct same_direct_control

gen mostaffected_control = (same_direct_control == 1 &  dist2line_control<=0.5)

save Output_May2019/ControlLineDist_temp.dta, replace

/**********************************************/
/*** II. Treated segment to subway line relation ***/
/**********************************************/
use Data2/AllCasesWkly/CrossCityPoly_ExclTestRides_AllCasesWkly.dta, clear

/*** Link's shortest distance to the opening line ***/
split treatlines, parse(,)
rename treatlines1	lineid1
rename treatlines2	lineid2
rename treatlines3	lineid3
destring lineid1, replace
destring lineid2, replace
destring lineid3, replace

rename lineid1 lineid
merge m:1 linkid lineid using Data2/LinkGeo/Link2Line_bd.dta, keepusing(link2line_km roadtype direct_link direct_line)
drop if _merge == 2
drop _merge
rename link2line_km link2line_km1
rename direct_line direct_line1 
rename lineid lineid1

rename lineid2 lineid
merge m:1 linkid lineid using Data2/LinkGeo/Link2Line_bd.dta, keepusing(link2line_km roadtype direct_link direct_line) update
drop if _merge == 2
drop _merge
rename link2line_km link2line_km2
rename direct_line direct_line2
rename lineid lineid2

rename lineid3 lineid
merge m:1 linkid lineid using Data2/LinkGeo/Link2Line_bd.dta, keepusing(link2line_km roadtype direct_link direct_line) update
drop if _merge == 2
drop _merge
rename link2line_km link2line_km3
rename direct_line direct_line3
rename lineid lineid3

/*** Drop distance information cannot be matched, about 13%, all in control lines ***/ 
drop if link2line_km1 == . & link2line_km2 == . & link2line_km3 == .

/*** Identify the nearest line ***/
gen link2line_km = link2line_km1
gen nearest_treatline_id = lineid1
gen nearest_treatline_direct = direct_line1

replace nearest_treatline_id = lineid2 if link2line_km2 < link2line_km
replace nearest_treatline_direct = direct_line2 if link2line_km2 < link2line_km 
replace link2line_km = link2line_km2 if link2line_km2 < link2line_km

replace nearest_treatline_id = lineid3 if link2line_km3 < link2line_km
replace nearest_treatline_direct = direct_line3 if link2line_km3 < link2line_km
replace link2line_km = link2line_km3 if link2line_km3 < link2line_km

drop link2line_km1 link2line_km2 link2line_km3
drop direct_line1 direct_line2 direct_line3
rename link2line_km link2_nearest_treat_line_km

/*** Distance to the nearest subway line (including existing) ***/
cap rename direct_link  direct_link0 
cap rename direct_line direct_line0
merge m:1 linkid using Data2/LinkGeo/Link2NearestLine_bd.dta, keepusing(link2line_km direct_link direct_line)
keep if _merge == 3
drop _merge
rename link2line_km link2_nearest_line_km
replace direct_link  = "东西" if inlist(direct_link,"东向西","西向东")
replace direct_link  = "南北" if inlist(direct_link,"南向北","北向南")
gen same_direct_nearest_line = (direct_link == direct_line)
drop direct_link direct_line
cap rename direct_link0 direct_link  
cap rename direct_line0 direct_line

/*** Direction from treated lines ***/
rename nearest_treatline_id lineid
merge m:1 lineid using Data2/LinkGeo/Line_City.dta, keepusing(direction)
rename direction NearestTreatedLineDirect
keep if _merge == 3
drop _merge
	/* Same direction */
replace direct_link  = "东西" if inlist(direct_link,"东向西","西向东")
replace direct_link  = "南北" if inlist(direct_link,"南向北","北向南")
gen same_direct = (direct_link == NearestTreatedLineDirect)

/*** merge back to get controls ***/
merge 1:1  case linkid wk2open using Data2/AllCasesWkly/CrossCityPoly_ExclTestRides_AllCasesWkly.dta
tab treat if _merge == 2
assert treat == 0 if _merge == 2
drop _merge

replace link2_nearest_line_km = 0 if link2_nearest_line_km == .
gen ln_link2_nearest_line_km = ln(link2_nearest_line_km + 1)

replace link2_nearest_treat_line_km = 0 if link2_nearest_treat_line_km == .
replace roadtype  = 0 if roadtype  == .

replace same_direct = 0 if same_direct == .

/*** Most affected links ***/
preserve
	use Data2/AllCasesWkly/CrossCity_AllCasesWkly.dta, clear
	keep if treat == 1
	gen treatlineid = .
	replace treatlineid = 2 if case == 1
	replace treatlineid = 3 if case == 2
	replace treatlineid = 6 if case == 3
	replace treatlineid = 8 if case == 4
	replace treatlineid = 9 if case == 5
	replace treatlineid = 11 if case == 6
	replace treatlineid = 12 if case == 7
	replace treatlineid = 14 if case == 8
	replace treatlineid = 15 if case == 9
	replace treatlineid = 17 if case == 10
	replace treatlineid = 19 if case == 11
	replace treatlineid = 21 if case == 12
	replace treatlineid = 22 if case == 13
	replace treatlineid = 25 if case == 14
	replace treatlineid = 32 if case == 15
	replace treatlineid = 33 if case == 16
	replace treatlineid = 38 if case == 17
	replace treatlineid = 39 if case == 18
	replace treatlineid = 41 if case == 19
	replace treatlineid = 42 if case == 20
	replace treatlineid = 44 if case == 21
	replace treatlineid = 45 if case == 22
	replace treatlineid = 49 if case == 23
	replace treatlineid = 50 if case == 24
	replace treatlineid = 51 if case == 25
	replace treatlineid = 54 if case == 26
	replace treatlineid = 56 if case == 27
	replace treatlineid = 57 if case == 28
	replace treatlineid = 58 if case == 29
	replace treatlineid = 59 if case == 30
	replace treatlineid = 61 if case == 31
	replace treatlineid = 66 if case == 32
	replace treatlineid = 69 if case == 33
	replace treatlineid = 71 if case == 34
	replace treatlineid = 73 if case == 35
	replace treatlineid = 74 if case == 36
	replace treatlineid = 76 if case == 37
	replace treatlineid = 79 if case == 38
	replace treatlineid = 80 if case == 39
	replace treatlineid = 81 if case == 40
	replace treatlineid = 82 if case == 41
	replace treatlineid = 84 if case == 42
	replace treatlineid = 85 if case == 43
	replace treatlineid = 86 if case == 44
	replace treatlineid = 93 if case == 45	
	
	collapse (count) case, by(treatlineid linkid)
	drop case
	save Data2/AllCasesWkly/MostAffectedLinks_temp.dta, replace
restore

gen MostAffectedLinks = .

rename lineid1 treatlineid
merge m:1 treatlineid linkid using Data2/AllCasesWkly/MostAffectedLinks_temp.dta
drop if _merge == 2
replace MostAffectedLinks =  1 if _merge == 3
drop _merge
drop treatlineid

rename lineid2 treatlineid
merge m:1 treatlineid linkid using Data2/AllCasesWkly/MostAffectedLinks_temp.dta
drop if _merge == 2
replace MostAffectedLinks =  1 if _merge == 3
drop _merge
drop treatlineid

rename lineid3 treatlineid
merge m:1 treatlineid linkid using Data2/AllCasesWkly/MostAffectedLinks_temp.dta
drop if _merge == 2
replace MostAffectedLinks =  1 if _merge == 3
drop _merge
drop treatlineid

replace MostAffectedLinks = 0 if treat == 0
replace MostAffectedLinks = 0 if MostAffectedLinks == .

erase Data2/AllCasesWkly/MostAffectedLinks_temp.dta

/*** control lines, geo info missing ***/
drop ln_link2_nearest_line_km 
replace link2_nearest_treat_line_km = . if treat == 0
replace link2_nearest_line_km = . if treat == 0
replace same_direct =. if treat == 0 
replace MostAffectedLinks = . if treat == 0
replace roadtype = . if treat == 0


/**********************************************/
/*** III. Merge back control link to line relation***/
/**********************************************/
merge m:1 linkid using Output_May2019/ControlLineDist_temp
drop _merge

replace roadtype = roadtype_control if treat == 0
replace link2_nearest_treat_line_km = dist2line_control if treat == 0
replace link2_nearest_line_km = dist2line_control if treat == 0
replace same_direct = same_direct_control if treat == 0 
replace MostAffectedLinks = mostaffected_control if treat == 0

drop *_control

	/*** Pre-treatment average CI ***/
gen CI_pre = CI if inrange(wk2open,-6,-1)
sort case linkid wk2open
by case linkid: egen CI_Pre = mean(CI_pre)
drop CI_pre
summ CI_Pre if inrange(wk2open,-6,-1)
local CI_Pre_mean = `r(mean)'
gen MoreCongested = (CI_Pre >= `CI_Pre_mean')


	/*** Link to station distance ***/
merge m:1 linkid using Data2/LinkGeo/Link2StnDist.dta
drop if _merge == 2
replace dist2stn = 5 if dist2stn == .
drop _merge
	/*** Link to line (real) distance ***/
merge m:1 linkid using Data2/LinkGeo/Link2LineDist2.dta
drop if _merge == 2
replace link2linedist2 = 5 if link2linedist2 == .
drop _merge
rename link2linedist2 dist2line2

/**********************************************/
/*** IV. City-level hetero					***/
/**********************************************/
gen opendate = . 
replace opendate = date("20161218","YMD") if case == 1
replace opendate = date("20171210","YMD") if case == 2
replace opendate = date("20170625","YMD") if case == 3
replace opendate = date("20161228","YMD") if case == 4
replace opendate = date("20171228","YMD") if case == 5
replace opendate = date("20160819","YMD") if case == 6
replace opendate = date("20170112","YMD") if case == 7
replace opendate = date("20161228","YMD") if case == 8
replace opendate = date("20161108","YMD") if case == 9
replace opendate = date("20160924","YMD") if case == 10
replace opendate = date("20170415","YMD") if case == 11
replace opendate = date("20170106","YMD") if case == 12
replace opendate = date("20161028","YMD") if case == 13
replace opendate = date("20161228","YMD") if case == 14
replace opendate = date("20171226","YMD") if case == 15
replace opendate = date("20170703","YMD") if case == 16
replace opendate = date("20170829","YMD") if case == 17
replace opendate = date("20170602","YMD") if case == 18
replace opendate = date("20170906","YMD") if case == 19
replace opendate = date("20161228","YMD") if case == 20
replace opendate = date("20171228","YMD") if case == 21
replace opendate = date("20160806","YMD") if case == 22
replace opendate = date("20170608","YMD") if case == 23
replace opendate = date("20170126","YMD") if case == 24
replace opendate = date("20161226","YMD") if case == 25
replace opendate = date("20171226","YMD") if case == 26
replace opendate = date("20171231","YMD") if case == 27
replace opendate = date("20170818","YMD") if case == 28
replace opendate = date("20161228","YMD") if case == 29
replace opendate = date("20171228","YMD") if case == 30
replace opendate = date("20170118","YMD") if case == 31
replace opendate = date("20171206","YMD") if case == 32
replace opendate = date("20161231","YMD") if case == 33
replace opendate = date("20171230","YMD") if case == 34
replace opendate = date("20171230","YMD") if case == 35
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


/**********************************************/
/*** V. Variables							***/
/**********************************************/
/*** BASELINE: wk2open within -6 and 47 ***/
keep if inrange(wk2open,-6,47)

/*** treat_post ***/
gen post = (wk2open >= 0)
gen Dp = treat * (wk2open >= 0)


/*** ADDITIONAL FES ***/
egen case_wk2open = group(case wk2open)
egen case_linkid = group(case linkid)

/*** Drop vars ***/
# delimit ;
drop CI_res lnspd speed treatline direct_link 
	lineid nearest_treatline_direct
	dist2stn dist2line2 
	opendate id 
	popx10k gdpx10k gdppc avgwage
	date NearestTreatedLineDirect
	lnavgwage*
	
;
# delimit cr

/*** Label vars ***/
label var linkid  "road segment id"    
label var wk2open "week relative to line opening"
label var lnspd_res "average weekly residual log speed (dep var)"    
label var CI "average weekly congestion index"
label var treat "=1 if treated"
label var case "group of segments, 1-35, corresponding to each treated line and its assigned controls"          
label var yrwk "calendar year-week"
label var roadtype "road type: 1-highway, 2-expressway, 3-arterial, 4-subarterial, 5-local"
label var link2_nearest_treat_line_km "segment distance to the nearest treated (or control) line (km)"
label var link2_nearest_line_km "segment distance to the nearest (new or existing) line (km)"
label var same_direct_nearest_line "=1 if segment is roughly the same direction to the nearest line"
label var same_direct "=1 if segment is roughly the same direction to the nearest treated (or control) line"
label var MostAffectedLinks "=1 if segment is directly affected by the new line"
label var CI_Pre "average congestion index in the pre-period"
label var MoreCongested "=1 if CI_Pre above median"
label var lnpop "log population (x 10k)"        
label var lnpop2 "log population (x 10k), squared"
label var lnpop3 "log population (x 10k), cubic"
label var lngdppc "log GDP per capita"        
label var lngdppc2 "log GDP per capita, squared"
label var lngdppc3  "log GDP per capita, cubic"
label var post "=1 if in post-period"
label var Dp "treatedXpost"
label var case_wk2open "=1 if group=g and week-to-open=w"
label var case_linkid "=1 if group=g and linkid=l"

save "$ldir/Data/ExtendSample.dta", replace

* end
timer off 1
timer list 1
cap log close
