/*********************************************************************/
/*** Tab 2: Summary Statistics									   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Tab2", replace


*********************************************************************
* PANEL A: CITY LEVEL
* Note: Foshan is treated as part of Guangzhou
*********************************************************************
use Data/CityChars.dta, replace

mat B0A = J(2,4,0)
mat B0B = J(2,4,0)

gen popxmil = popx10k/100

summ popxmil if treat == 1, de
mat B0A[1,1] = round(`r(mean)',0.01)
mat B0A[1,2] = round(`r(p25)',0.01)
mat B0A[1,3] = round(`r(p50)',0.01)
mat B0A[1,4] = round(`r(p75)',0.01)

summ gdppc if treat == 1, de
mat B0A[2,1] = round(`r(mean)',1)
mat B0A[2,2] = round(`r(p25)',1)
mat B0A[2,3] = round(`r(p50)',1)
mat B0A[2,4] = round(`r(p75)',1)
 
summ popxmil if treat == 0, de
mat B0B[1,1] = round(`r(mean)',0.01)
mat B0B[1,2] = round(`r(p25)',0.01)
mat B0B[1,3] = round(`r(p50)',0.01)
mat B0B[1,4] = round(`r(p75)',0.01)

summ gdppc if treat == 0, de
mat B0B[2,1] = round(`r(mean)',1)
mat B0B[2,2] = round(`r(p25)',1)
mat B0B[2,3] = round(`r(p50)',1)
mat B0B[2,4] = round(`r(p75)',1)

mat B0 = [B0A, B0B]
mat colnames B0 = Treated_mean p25 p50 p75 Control_mean p25 p50 p75 
matlist B0


*********************************************************************
* PANEL B: ROAD SEGMENT LEVEL
*********************************************************************

/*********************************************************************/
/*** I. Sample and additional variables							   ***/
/*********************************************************************/
use Data/BaseSamp.dta, replace

/*** Baseline sample, week-to-open between [-6,47] ***/
keep if inrange(wk2open,-6,47)

/**********************************************/
/*** II. Mats								***/
/**********************************************/
/* Treated Lines */
mat B1 = J(5,4,.)
mat colnames B1 = N NLink spd CI
mat rownames B1 = Treated_all highway express arterial subarterial

/* Control Lines */
mat B2 = J(5,4,.)
mat colnames B1 = N NLink spd CI
mat rownames B2 = Control_all highway express arterial subarterial

/**********************************************/
/*** II. Stats								***/
/**********************************************/
bysort linkid: gen n = _n

local if1 = ""
local if2 = "& roadtype == 1"
local if3 = "& roadtype == 2"
local if4 = "& roadtype == 3"
local if5 = "& roadtype == 4"

qui forvalues i = 1/5 {
	/*** Treated ***/
		/* Col 1: N */
	count if treat == 1 `if`i''
	mat B1[`i',1] = `r(N)'
		/* Col 2: NLink*/
	preserve
		collapse (max) treat roadtype, by(linkid)
		count if treat == 1 `if`i''
		mat B1[`i',2] = `r(N)'
	restore
		/* Col 3: average speed */
	summ speed if treat == 1 `if`i''
	mat B1[`i',3] = round(`r(mean)',0.01)
		/* Col 4-7: CI */
	summ CI if treat == 1 `if`i'', de
	mat B1[`i',4] = round(`r(mean)',0.01)


	/*** Control ***/
		/* Col 1: N */
	count if treat == 0 `if`i''
	mat B2[`i',1] = `r(N)'
		/* Col 2: NLink*/
	preserve
		collapse (max) treat roadtype, by(linkid)
		count if treat == 0 `if`i''
		mat B2[`i',2] = `r(N)'
	restore		
		/* Col 3: average speed */
	summ speed if treat == 0 `if`i''
	mat B2[`i',3] = round(`r(mean)',0.01)
		/* Col 4-7: CI */
	summ CI if treat == 0 `if`i'', de
	mat B2[`i',4] = round(`r(mean)',0.01)

}

/**********************************************/
/*** III. Save mat							***/
/**********************************************/
matlist B0
outtable using "TablesFigures/Tab2A", mat(B0) cap("Summ Stat, Panel A") replace

mat B = [B1 \ B2]
matlist B
outtable using "TablesFigures/Tab2B", mat(B) cap("Summ Stat, Panel B") replace

* end
timer off 1
timer list 1
cap log close
