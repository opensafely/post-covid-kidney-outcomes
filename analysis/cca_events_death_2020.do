sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_death_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_death_2020.csv, write text replace
file write tablecontent _tab ("COVID-19 cohort") _tab ("Matched cohort") _n

use ./output/analysis_complete_2020.dta, clear

*COVID-19 wave
forvalues group=1/4 {
local label_`group': label wave `group'
file write tablecontent ("`label_`group''") _tab
qui safecount if wave==`group' & case==1 & death==1
local cases_events = round(r(N),5)
qui safecount if wave==`group' & case==0 & death==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}

*Cases up to March 2022
file write tablecontent ("Excluding COVID-19 from April 2022 onwards") _n
drop if index_date_death > 22735
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

*COVID-19 wave
forvalues group=1/4 {
local label_`group': label wave `group'
file write tablecontent ("`label_`group''") _tab
qui safecount if wave==`group' & case==1 & death==1
local cases_events = round(r(N),5)
qui safecount if wave==`group' & case==0 & death==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}


file close tablecontent