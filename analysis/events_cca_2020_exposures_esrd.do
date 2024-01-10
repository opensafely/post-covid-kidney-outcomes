sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_2020_exposures_esrd.log, replace t

cap file close tablecontent
use ./output/analysis_complete_2020.dta, clear

file open tablecontent using ./output/events_cca_2020_exposures_esrd.csv, write text replace
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

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

qui safecount if covsev==0 & _d==1 & _st==1
local events = round(r(N),5)
file write tablecontent ("Matched population (contemporary)") _tab (`events') _n

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

file close tablecontent