/************************************/
/*** Appendix Figure A.5		  ***/
/*** Seasonality in traffic in control cities ***/
/************************************/
clear
set more off
timer clear
timer on 1
cap log close
log using "LogFiles/AppA_FigA4", replace

	/* use data on sample segments in control cities */
use "Data/HourlySample.dta", clear

*/Este codigo permite inspeccionar a estacionalidad en la velocidad del tráfico en las ciudades de control*/


/************************************/
/*** I. Residual speed			  ***/
/************************************/

keep if treat == 0
gen timestr = string(time,"%10.0f")
gen datestr = substr(timestr,1,8)
gen date = date(datestr,"YMD")
format %td date

areg lnspd, a(link_dow_hour)
local const = _b[_cons]
predict lnspd_res, res

/************************************/
/*** II. Average log residual speed at the day level ***/
/************************************/

collapse (first) dow datestr (mean) lnspd_res, by(linkid date)

/*** Collapse to date ***/
*/Speed is adjusted for a complete set of road segment per day of week per hour of day fixed effects. Weekends and national holidays
They are excluded.*
/*To get the adjusted logging rate on each day, the hourly logging rate on each road segment is first rolled back into a full set of indicators with segment, time of day, and day of week indicators fully interacting
/*Add the average log speed over the sample period.*/

replace lnspd_res = lnspd_res + `const'
collapse (mean) lnspd_res, by(date)


# delimit ;
label def ldate
	20667 "Aug '16"
	20698 "Sep"
	20728 "Oct"
	20759 "Nov"
	20789 "Dec"
	20820 "Jan '17"
	20851 "Feb"
	20879 "Mar"
	20910 "Apr"
	20940 "May"
	20971 "Jun"
	21001 "Jul"
	21032 "Aug"
	21063 "Sep"
	21093 "Oct"
	21124 "Nov"
	21154 "Dec"
	21185 "Jan '18"
;
# delimit cr
label val date ldate

/************************************/
/*** III. Prepare for graph		  ***/
/************************************/
count
local NewN = `r(N)' + 1
set obs `NewN'
replace date = 20715 if date == .

count
local NewN = `r(N)' + 1
set obs `NewN'
replace date = 20735 if date == .

count
local NewN = `r(N)' + 1
set obs `NewN'
replace date = 20821 if date == .

count
local NewN = `r(N)' + 1
set obs `NewN'
replace date = 21186 if date == .

gen h = 3.55 if inlist(date,20715,20735,20821,20853,20914,20941,20970,21101,21186)

gen holiday = ""
replace holiday = "Mid Autumn" if date == 20715
replace holiday = "National Day" if date == 20735 
replace holiday = "New Year" if date == 20821 
replace holiday = "Chinese New Year" if date == 20853 
replace holiday = "Qingming" if date == 20914
replace holiday = "Labor Day" if date == 20941
replace holiday = "Duanwu" if date == 20970
replace holiday = "National Day" if date == 21101
replace holiday = "New Year" if date == 21186

/************************************/
/*** IV. Graph		  			  ***/
/************************************/
# delimit ;
twoway  (scatter lnspd_res date, msize(small) msymbol(X) mcolor(dknavy))
		(scatter h date, mcolor(none) mlabel(holiday) mlabsize(vsmall) mlabcolor(maroon) mlabposition(6) mlabangle(forty_five))
		, title("seasonality") 
		xtitle("  ") ytitle("adj. log speed")
		xlabel(20667 20698 20728 20759 20789 20820 20851 20879 20910 20940 20971 21001 21032 21063 21093 21124 21154 21185
			, valuelabel labsize(vsmall) angle(45))
		ylabel(3.2(0.2)3.6, labsize(vsmall) angle(45))
		xline(20712 20714 20728 20734 20820 20846 20852 20911 20913 20940 20967 20969 21093 21100 21185, lcolor(gs8))
		legend(off)
		graphregion(color(white))
		xsize(10) ysize(7)
;
# delimit cr
graph export "TablesFigures/AppA_FigA5.pdf", replace

* end
timer off 1
timer list 1
cap log close
