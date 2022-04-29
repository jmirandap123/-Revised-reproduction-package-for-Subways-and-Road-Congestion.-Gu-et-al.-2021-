1. Data

Raw data are proprietary to Baidu Maps and are NOT included in the replication packet.

The raw data include two component: (1) a dataset on hourly road speed data at the road segment level; (2) a dataset on road segment characteristics.

SpeedDataExample.dta provides an example of what the dataset on road speed looks like.
	v1 citycode 
	v2 polygon id
	v3 linkid
	v4 date
	v5 time 
	v6 speed
	v7 congestindex

LinkInfoExample.dta is provides an example of what the dataset on road segment characteristics looks like.


2. Cleaning Codes

Note: all codes needs additional dataset that are not provided in the replication packet.

ExtractTreatedLines.do extracts treated road segments
	- Keep road segments in the 2.5-km buffer zones of treated lines
	- Drop road segments without road name
	- Drop local streets
	- Keep only observations in rush hours
	- Drop weekends and holidays
	- Drop duplicate observations
	- Keep only "directly-affected" road segments

ExtractControlCities.do extracts road segments in control cities
	- Keep road segments in the 2.5-km buffer zones of control lines
	- Drop road segments without road name
	- Drop local streets
	- Keep only observations in rush hours
	- Drop weekends and holidays
	- Drop duplicate observations

CrossCity_AllCasesWkly_ExclTestRides.do
	- Randomly breaking control segments into 45 cases
	- For each case
		- append with its randomly assigned control segments
		- create the week relative to line opening
		- exclude test-ride period, if any
		- keep week-to-opening between 55 weeks prior and 55 weeks posterior
		- keep only fully-balanced panel between 6 weeks prior and 47 weeks posterior to line opening
		- first step regression: regress log speed on segment-day of the week-week of the day fixed effects
		- winsorizing residual log speed within each road segment to be between 1st and 99th percentile
		- collapse to the road segment-week to opening level
	
Gen_BaseSamp.do
	- Additional clean up based on CrossCity_AllCasesWkly_ExclTestRides.do
	- Additional variables
	- Keep necessary variables
	- Label variables
	- Generate baseline regression sample
	
Gen_ExtendSamp.do
	- Incorporate all road segments in treated cities (note that the extraction code is different from ExtractTreatedLines.do)
	- Generate road segment characteristics, geographic relation variables
	- Generate additional variables
	- Keep necessary variables
	- Label variables
	- Generate extended regression sample (used mainly for Fig 6)

Gen_HourlySamp.do
	- Incorporate all road segments in treated and control cities
	- Clean up speed data
	- Create a sample of balanced panel
	- Create treated groups
	- Generate hourly sample (HourlySample.dta), used to generate Appendix Table B5.

Gen_IndModeSample.do
	- Combine data from 2010 and 2015 Beijing Household Travel Survey
	- Extract information on individual and household characteristics
	- Generate information on TAZ's distance to subway
	- Generate information on individual's mode choice for travel
	- Generate a sample of individual transportation choices (IndModeSample.dta), used to generate Table 5.

Gen_HhdVKTSample.do
	- Combine data from 2010 and 2015 Beijing Household Travel Survey
	- Generate information on TAZ's distance to subway
	- Extract information on car ownership, usage, and household characteristics
	- Generate a sample of household vehicle uses (HhdVKTSample.dta), used to generate Table 5.