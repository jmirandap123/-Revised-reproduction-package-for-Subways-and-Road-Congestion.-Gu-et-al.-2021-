/************************************/
/*** Appendix Figure A.4: Congestion Index by Hour ***/
/************************************/
clear
set more off
timer clear
timer on 1
cap log close
log using "LogFiles/AppA_FigA4", replace

/*** Use the raw data that roughly corresponds to the third week of November, 2017***/
use "Data/2017_part18.dta", clear

/************************************/
/*** I. Clean up				  ***/
/************************************/
rename v3 linkid
rename v4 date
rename v5 time
rename v6 speed
rename v7 CI
merge m:1 linkid using "Data/linkInfo_new.dta"
keep if _merge == 3
drop _merge
drop if roadtype == 5

gen datestr = string(date,"%8.0f")
rename date date_num
gen date = date(datestr,"YMD")
format %td date
gen dow = dow(date)
gen timestr = string(time,"%10.0f")
gen hour = real(substr(timestr,-2,2))

	/* Drop weekends */
drop if inlist(dow,0,6)

cap label drop lhour
# delimit ;
label def lhour 
		0 "0-1"
		1 "1-2"
		2 "2-3"
		3 "3-4"
		4 "4-5"
		5 "5-6"
		6 "6-7"
		7 "7-8"
		8 "8-9"
		9 "9-10"
		10 "10-11"
		11 "11-12"
		12 "12-13"
		13 "13-14"
		14 "14-15"
		15 "15-16"
		16 "16-17"
		17 "17-18"
		18 "18-19"
		19 "19-20"
		20 "20-21"
		21 "21-22"
		22 "22-23"
		23 "23-0"
;
# delimit cr


/************************************/
/*** II. Collapse to hour level	  ***/
/************************************/
collapse (mean) CI, by(hour)
label val hour lhour


/************************************/
/*** III. Graph					  ***/
/************************************/
# delimit ;
twoway (connect CI hour, mcolor(teal) lpattern(solid) lcolor(teal) lwidth(thick))
	, title("", size(medium))
	ytitle(average congestion index)
	xlabel(0(1)23, labsize(small) angle(45) valuelabel)
	xline(7 8 17 18, lcolor(red))
	legend(off order(1 "Sample"))
	graphregion(color(white))
	/* note("Note: weekdays of the third week of November, 2017") */
;
# delimit cr
graph export "TablesFigures/AppA_FigA4.pdf", replace

* end
timer off 1
timer list 1
cap log close
