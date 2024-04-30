sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_pneumonia_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_pneumonia_2017.csv, write text replace
file write tablecontent _tab ("Pneumonia cohort (pre-pandemic)") _tab ("Matched cohort (pre-pandemic)") _n

use ./output/analysis_pneumonia_2017_complete.dta, clear

*ESRD = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.

gen krt_date29 = krt_date if krt_date < (index_date_krt + 30) 
gen exit_date29_krt = krt_date29
gen index_date29_krt = index_date_krt
format exit_date29_krt %td
replace exit_date29_krt = min(deregistered_date, death_date, end_date, (index_date_krt + 29)) if krt_date29==.

*30-89 days
gen krt_date89 = krt_date if krt_date < (index_date_krt + 90) 
gen exit_date89_krt = krt_date89
gen index_date89_krt = index_date_krt + 30
format exit_date89_krt %td
replace exit_date89_krt = min(deregistered_date, death_date, end_date, (index_date_krt + 89)) if krt_date89==.

*90-179 days
gen krt_date179 = krt_date if krt_date < (index_date_krt + 180) 
gen exit_date179_krt = krt_date179
gen index_date179_krt = index_date_krt + 90
format exit_date179_krt %td
replace exit_date179_krt = min(deregistered_date, death_date, end_date, (index_date_krt + 179)) if krt_date179==.

*180+ days
gen index_datemax_krt = index_date_krt + 180
gen exit_datemax_krt = exit_date_krt
gen krt_datemax = krt_date


local outcomes "esrd krt egfr_half aki death"

local esrd_lab "Kidney failure"
local krt_lab "Kidney replacement therapy"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

local period "29 89 179 max"
local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach out of local outcomes {
	
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

file write tablecontent ("``out'_lab'") _n

*Total
file write tablecontent ("Denominator") _tab
qui safecount if case==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n

file write tablecontent ("Overall events") _tab
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n

foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)
file write tablecontent ("`lab`x''") _tab
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}

*Ethnicity
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'

file write tablecontent ("`label_`ethnicity'' denominator") _tab
qui safecount if ethnicity==`ethnicity' & case==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n

file write tablecontent ("`label_`ethnicity'' events") _tab
qui safecount if ethnicity==`ethnicity' & case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}
}

file close tablecontent