/*********************************************************************/
/*** Fig 1: Subway Construction									   ***/
/*********************************************************************/
clear all
set more off
set matsize 11000
timer clear
timer on 1
cap log close
log using "LogFiles/Fig1", replace

/**************************************/
/*** I. Use data and clean 			***/
/**************************************/
/*** 1. From Urban Transit Reports ***/
use Data/UrbanTransitReports.dta, clear

drop year
rename 年份 year
label var year "年份 year"
rename 城市 city
label var city "城市 city"
rename 轨道交通运营线路总长度公里  subway_length
label var subway_length "轨道交通运营线路总长度（公里） Total subway track length (km)"
rename 轨道交通客运量万人次  subway_ridership
label var subway_ridership "轨道交通客运量（万人次） Subway ridership (x 10k)"

/***
	/* Translation from Chinese */
rename year yearn
rename 城市 city
label var city "城市 city"
rename 年份 year
label var year "年份 year"
rename 年末总人口万 pop
label var pop "年末总人口万 pop (x 10k)"
rename 市辖区年末总人口万 CityPop
label var CityPop "市辖区年末总人口万 city district population (x 10k)"
rename 年末实有公共汽电车营运车辆数辆 N_Bus
label var N_Bus "年末实有公共汽电车营运车辆数辆 # of buses in operation"
rename 公共汽电车运营里程万公里  Bus_mileage
label var Bus_mileage "公共汽电车运营里程万公里 Bus mileage (x 10k km)"
rename 公共汽电车客运量万人次		Bus_ridership
label var Bus_ridership "公共汽电车客运量万人次 Bus ridership (x 10k)"
rename 出租汽车车辆数运营车数合计辆 N_Taxi
label var N_Taxi "出租汽车车辆数运营车数合计辆 # of taxis"
rename 出租汽车运营里程万公里			Taxi_mileage
label var Taxi_mileage "出租汽车运营里程万公里 Taxi mileage (x 10k km)"
rename 出租汽车载客车次总数万车次		Taxi_trips
label var Taxi_trips "出租汽车载客车次总数万车次 # of taxi trips (x 10k)"
rename 出租汽车客运量万人次 			Taxi_ridership
label var Taxi_ridership "出租汽车客运量万人次 Taxi ridership (x 10k)"
rename 轨道交通运营车数辆  			N_subway_vehicle
label var N_subway_vehicle "轨道交通运营车数辆 # of subway vehicles"
rename 轨道交通运营线路条数合计条		N_subway_lines
label var N_subway_lines "轨道交通运营线路条数合计条 # of subway lines"
rename 轨道交通运营线路总长度公里 subway_length
label var subway_length "轨道交通运营线路总长度（公里） Total subway track length (km)"
rename 轨道交通运营线路长度公里	subway_length2
label var subway_length2 "轨道交通运营线路长度（公里） Subway track length (km)"
rename 轨道交通运营里程万列公里	subway_mileage
label var subway_mileage "轨道交通运营里程(万列公里) subway mileage (x 10k trains x km)"
rename 轨道交通客运量万人次		subway_ridership	
label var subway_ridership "轨道交通客运量（万人次） Subway ridership (x 10k)"
rename 年末实有城市道路面积万平方米	RoadSurface
label var RoadSurface "年末实有城市道路面积(万平方米) Area of urban road surface (x 10k sqm)"
rename 人均城市道路面积平方米	RoadSurface_pc
label var RoadSurface_pc "人均城市道路面积(平方米) per capita urban road surface (sqm)"
rename 民用汽车拥有量万辆	N_CivilCar
label var N_CivilCar "民用汽车拥有量(万辆) # of civilian-use cars (x 10k)"
rename 私人汽车拥有量万辆	N_PrivateCar
label var N_PrivateCar "私人汽车拥有量万辆 # of private cars (x 10k)"
rename 人均地区生产总值元	DistrGDP_pc
label var DistrGDP_pc "人均地区生产总值(元) per capita district GDP (yuan)"
rename 城镇居民人均可支配收入元	inc_pc
label var inc_pc "城镇居民人均可支配收入(元) per capita urban resident expendible income (yuan)"
rename 城镇居民人均生活消费性支出元 expend_pc
label var expend_pc "城镇居民人均生活消费性支出(元) per capita urban resident consumption expenditure (yuan)"
rename 地铁开通年份 year_has_subway
label var year_has_subway "地铁开通年份 year subway was launched"
rename 是否开通地铁 has_subway
label var has_subway "是否开通地铁 whether has subway"
rename GDP GDP
label var GDP "GDP"
rename 城市人均GDP CityGDP_pc 
label var CityGDP_pc "城市人均GDP (x10k yuan) Per capita city GDP (x10k yuan)"
rename year year
label var year "year"
rename id id
label var id "City ID"
***/

/*** subway length: 2010-2016 ***/
tab year if subway_length != .

/*** subway ridership: 1993-2016 ***/
tab year if subway_ridership != .

/*** collapse to year ***/
collapse (sum) subway_length subway_ridership, by(year)
replace subway_ridership = subway_ridership/100

/*** 2009 a little strange ***/
drop if year == 2009

save Data/Annual_temp.dta, replace

/*** 1. From Urban Transit Reports ***/
use Data/SubwayLines.dta, clear
drop if city == "Hong Kong"

collapse (sum) lengthkm, by(openyear)
rename openyear year
gen subway_length2 = sum(lengthkm)
drop lengthkm

merge 1:1 year using Data/Annual_temp.dta
drop _merge
sort year

replace subway_ridership = . if subway_ridership == 0
replace subway_length = . if subway_length == 0

erase Data/Annual_temp.dta

gen NCities = ""
replace NCities = "4 cities" if year == 2000 
replace NCities = "30 cities" if year == 2017
gen mark = int(subway_length2)
labmask mark, values(NCities)

/**************************************/
/*** II. Graph			 			***/
/**************************************/
# delimit ;
twoway  (line subway_ridership year if inrange(year,2002,2017), lpattern(solid) lcolor(teal) lwidth(thick))
		(line subway_length2 year if inrange(year,2002,2017), yaxis(2) lpattern(dash) lcolor(maroon) lwidth(thick))
		(scatter mark year if inrange(year,2000,2017), yaxis(2) mcolor(none) mlabel(NCities) mlabposition(2) mlabcolor(black))
		, 
		/*title("Subway construction in China")*/
		title("")
		xtitle("year") ytitle("total ridership (million)") ytitle("total length (km)", axis(2))
		ylabel(0(1000)5000, axis(2))
		legend(on order(1 "ridership" 2 "length"))
		graphregion(color(white))
;
# delimit cr
graph export TablesFigures/Fig1.pdf, replace

* end
timer off 1
timer list 1
cap log close



