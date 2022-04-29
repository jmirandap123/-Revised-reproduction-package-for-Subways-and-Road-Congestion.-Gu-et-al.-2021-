/*********************************************************************/
/*** Fig 3: Wald Stats from Placebo Tests						   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Fig3", replace
use Data/BaseSamp.dta, replace

/**********************************************/
/*** I. Variables							***/
/**********************************************/
gen TP = treat * (wk2open >= 0)
gen post = (wk2open >= 0)

/**********************************************/
/*** II. Varying Post						***/
/**********************************************/

/*se amplian la muestra hasta 48 semanas antes y después de la apertura de la línea del metro cada una con una semana de apertura del metro placebo entre 48 semanas antes y 48 semanas después de la semana de apertura actual*/
/*El siguiente loop permite encontrar las estadìsticas de Wald asociadas con la variable tratamientoxpost. se representan frente a la semana de apertura placebo en relaciòn a la semana real de apertura*/
/*Lo anterior lo hacen con el objetivo de que aliviar la preocupación de que los resultados están impulsados por algunas tendencias temporales confusas, 
por esto prueban si el momento del efecto coincide con el momento de la apertura de las líneas de metro. Los resultados sugieren que esto no sucede.*/


summ wk2open
local min = `r(min)'
local max = `r(max)'
local N = `=`max'-`min'-1'
mat B = J(`N',1,.)

local n = 1
qui forvalues i = `=`min'+1'/`=`max'-1' {
	cap drop Dp
	gen Dp = treat * (wk2open >= `i')
	
	# delimit ;
	qui xi: reghdfe lnspd_res Dp post treat
		, a(linkid case_wk2open yrwk##c.(lnpop lngdppc)) cluster(case)
	;	
	# delimit cr
	mat B[`n',1] = _b[Dp]/_se[Dp]
	
	noisily dis "`n' out of `N' is done!"
	
	local n = `n' + 1
}

/*** Save results ***/
clear
svmat B
gen wk2open = _n - 55
save TablesFigures/Fig3_PlaceboWald.dta, replace

/**********************************************/
/*** III. Graph								***/
/**********************************************/
use TablesFigures/Fig3_PlaceboWald.dta, clear

# delimit ;
twoway (scatter B1 wk2open, msize(large) msymbol(x) mcolor(teal))
	if inrange(wk2open,-47,47)
	, ytitle("Wald statistic") xtitle("week relative to opening") 
	xlabel(-48(4)48, labsize(small) angle(45))
	xline(0)
	title("")
	graphregion(color(white))
;
# delimit cr
graph export TablesFigures/Fig3.pdf, replace

* end
timer off 1
timer list 1
cap log close
