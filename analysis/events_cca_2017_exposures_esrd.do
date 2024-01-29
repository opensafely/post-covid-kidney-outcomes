sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_2017_exposures_esrd.log, replace t

cap file close tablecontent
use ./output/analysis_complete_2017.dta, clear

file open tablecontent using ./output/events_cca_2017_exposures_esrd.csv, write text replace
file write tablecontent ("stratum") _tab ("events") _n

rename covid_severity covsev
rename covid_aki covaki
rename covid_vax covvax

local exposure "covsev covaki"

local covsev1 "COVID-19 non-hospitalised"
local covsev2 "COVID-19 hospitalised ward-based"
local covsev3 "COVID-19 hospitalised ICU"
local covaki1 "COVID-19 non-hospitalised"
local covaki2 "COVID-19 hospitalised without AKI"
local covaki3 "COVID-19 hospitalised with AKI"

local wave1 "COVID-19 Feb20-Aug20"
local wave2 "COVID-19 Sep20-Jun21"
local wave3 "COVID-19 Jul21-Nov21"
local wave4 "COVID-19 Dec21-Dec22"

local covvax1 "COVID-19 pre-vaccination"
local covvax2 "COVID-19 1 vaccination dose"
local covvax3 "COVID-19 2 vaccination doses"
local covvax4 "COVID-19 3 vaccination doses"
local covvax5 "COVID-19 4 vaccination doses"

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

qui safecount if covsev==0 & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("Matched population (pre-pandemic)") _tab (`events') _n

forvalues i=1/3 {
qui safecount if covsev==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`covsev`i''") _tab (`events') _n
}

forvalues i=2/3 {
qui safecount if covaki==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`covaki`i''") _tab (`events') _n
}

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`wave`i''") _tab (`events') _n
}

forvalues i=1/5 {
qui safecount if covvax==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`covvax`i''") _tab (`events') _n
}

*Cases up to March 2022)
file write tablecontent ("Cases up to March 2022") _n
drop if index_date_esrd > 22735
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`wave`i''") _tab (`events') _n
}

forvalues i=1/5 {
qui safecount if covvax==`i' & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("`covvax`i''") _tab (`events') _n
}

file close tablecontent