sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_covid_severity_egfr_half_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_covid_severity_egfr_half_2020.csv, write text replace
file write tablecontent _tab ("COVID-19 non-hospitalised") _tab ("COVID-19 hospitalised") _tab ("Matched contemporary cohort") _n

use ./output/analysis_complete_2020.dta, clear
replace covid_severity=2 if covid_severity==3

*COVID-19 wave
forvalues group=1/4 {
local label_`group': label wave `group'
file write tablecontent ("`label_`group''")

forvalues i=1/2 {
qui safecount if wave==`group' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if wave==`group' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`controls_events') _n
}



*Cases up to March 2022)

drop if index_date_egfr_half > 22735
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

file write tablecontent ("Excluding COVID-19 from April 2022 onwards") _n

*COVID-19 wave
forvalues group=1/4 {
local label_`group': label wave `group'
file write tablecontent ("`label_`group''")

replace covid_severity=2 if covid_severity==3
forvalues i=1/2 {
qui safecount if wave==`group' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if wave==`group' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`controls_events') _n
}

file close tablecontent