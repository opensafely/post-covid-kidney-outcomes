sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_hospitalised.log, replace t

cap file close tablecontent
use ./output/analysis_hospitalised.dta, clear

file open tablecontent using ./output/events_cca_hospitalised.csv, write text replace
file write tablecontent ("outcome") _tab ("period") _tab ("events_covid") _tab ("events_control") _n

local outcomes "esrd egfr_half aki death"

local esrd_lab "Kidney failure"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

local period "29 89 179 max"
local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach out of local outcomes {

qui stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("Overall") _tab (`cases_events') _tab (`controls_events') _n

foreach x of local period {
qui stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("`lab`x''") _tab (`cases_events') _tab (`controls_events') _n
}
}

file close tablecontent