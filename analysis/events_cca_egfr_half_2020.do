sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_egfr_half_2020.log, replace t

cap file close tablecontent
use ./output/analysis_complete_2020.dta, clear

file open tablecontent using ./output/events_cca_egfr_half_2020.csv, write text replace
file write tablecontent ("outcome") _tab ("stratum") _tab ("period") _tab ("events_covid") _tab ("events_control") _n


*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"

local period "29 89 179 max"
local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1 & esrd_date==.
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1 & esrd_date==.
local controls_events = round(r(N),5)
file write tablecontent ("50% reduction in eGFR (no ESRD)") _tab ("Overall") _tab ("Overall") _tab (`cases_events') _tab (`controls_events') _n

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1 & esrd_date==.
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1 & esrd_date==.
local controls_events = round(r(N),5)
file write tablecontent ("50% reduction in eGFR (no ESRD)") _tab ("Overall") _tab ("`lab`x''") _tab (`cases_events') _tab (`controls_events') _n
}


forvalues i=1/2 {
stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
qui safecount if covid_severity==`i' & _d==1 & _st==1 & esrd_date==.
local cases_events = round(r(N),5)
file write tablecontent ("50% reduction in eGFR (no ESRD)") _tab ("`severity`i''") _tab ("Overall") _tab (`cases_events') _tab ("N/A") _n
foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
qui safecount if covid_severity==`i' & _d==1 & _st==1 & esrd_date==.
local cases_events = round(r(N),5)
file write tablecontent ("50% reduction in eGFR (no ESRD)") _tab ("`severity`i''") _tab ("`lab`x''") _tab (`cases_events') _tab ("N/A") _n
}
}


file close tablecontent