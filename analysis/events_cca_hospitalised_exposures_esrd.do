sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_hospitalised_exposures_esrd.log, replace t

cap file close tablecontent
use ./output/analysis_hospitalised.dta, clear

file open tablecontent using ./output/events_cca_hospitalised_exposures_esrd.csv, write text replace
file write tablecontent ("stratum") _tab ("events") _n

rename covid_vax covvax

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
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

qui safecount if case==0 & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("Pneumonia (pre-pandemic)") _tab (`events') _n

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