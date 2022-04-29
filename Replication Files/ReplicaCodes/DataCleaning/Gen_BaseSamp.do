/*********************************************************************/
/*** Gen_BaseSamp.do											   ***/
/*** Generate baseline sample									   ***/
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

/********************************************************************************************/
/*** Generate																			  ***/
/********************************************************************************************/
use Data2/AllCasesWkly/CrossCity_AllCasesWkly_ExclTestRides.dta, clear

/*** Open Dates					***/
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

/*** City-level Hetero			***/
merge m:1 linkid using Data2/LinkGeo/CityIDLink.dta
assert _merge != 1
keep if _merge == 3
drop _merge

merge m:1 cityname using Data2/CityLevel/CityChars.dta
assert _merge != 1
keep if _merge == 3
drop _merge
drop cityname citycode

/*** Calendar Date ***/
gen date = (opendate + 7 * wk2open)

gen yr = year(date)
gen wk = week(date)
gen yrwk = yr*100 + wk
drop yr wk

/*** Hetero 	***/
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

/*** Additional FEs 			***/
egen case_wk2open = group(case wk2open)

/*** Drop vars ***/
# delimit ;
drop CI_res lnspd id popx10k gdpx10k gdppc avgwage lnavgwage*
;
# delimit cr

/*** Label vars ***/
label var linkid  "road segment id"    
label var opendate "line opening date"
label var wk2open "week relative to line opening"
label var yrwk "calendar year-week"
label var treat "=1 if treated"
label var CI "congestion index"    
label var speed "speed (km/h)"
label var lnspd_res "average weekly residual log speed (dep var)"    
label var case		"group of segments, 1-45, corresponding to each treated line and its assigned controls"          
label var date      "first calendar day of the week"    
label var lnpop "log population (x 10k)"        
label var lnpop2 "log population (x 10k), squared"
label var lnpop3 "log population (x 10k), cubic"
label var lngdppc "log GDP per capita"        
label var lngdppc2 "log GDP per capita, squared"        
label var lngdppc3 "log GDP per capita, cubic"        
label var case_wk2open "=1 if group = g and week-to-open = w"

save "$ldir/Data/BaseSamp.dta", replace

* end
timer off 1
timer list 1
cap log close
