sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_ethnicity_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_ethnicity_2017.csv, write text replace
file write tablecontent _tab ("COVID-19 cohort") _tab ("Matched cohort (pre-pandemic)") _n

use ./output/analysis_complete_2017.dta, clear

*ESRD = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.

*ESRD redefined by not including KRT codes 28 days before index date
gen chronic_krt_date = date(krt_outcome2_date, "YMD")
format chronic_krt_date %td
drop krt_outcome2_date
replace chronic_krt_date = egfr15_date if egfr15_date < chronic_krt_date
replace chronic_krt_date=egfr15_date if chronic_krt_date==.
gen exit_date_chronic_krt = chronic_krt_date
format exit_date_chronic_krt %td
replace exit_date_chronic_krt = min(deregistered_date, death_date, end_date) if chronic_krt_date==.
gen index_date_chronic_krt = index_date

local outcomes "krt chronic_krt"

foreach out of local outcomes {

gen `out'_date29 = `out'_date if `out'_date < (index_date_`out' + 30) 
gen exit_date29_`out' = `out'_date29
gen index_date29_`out' = index_date_`out'
format exit_date29_`out' %td
replace exit_date29_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 29)) if `out'_date29==.

*30-89 days
gen `out'_date89 = `out'_date if `out'_date < (index_date_`out' + 90) 
gen exit_date89_`out' = `out'_date89
gen index_date89_`out' = index_date_`out' + 30
format exit_date89_`out' %td
replace exit_date89_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 89)) if `out'_date89==.

*90-179 days
gen `out'_date179 = `out'_date if `out'_date < (index_date_`out' + 180) 
gen exit_date179_`out' = `out'_date179
gen index_date179_`out' = index_date_`out' + 90
format exit_date179_`out' %td
replace exit_date179_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 179)) if `out'_date179==.

*180+ days
gen index_datemax_`out' = index_date_`out' + 180
gen exit_datemax_`out' = exit_date_`out'
gen `out'_datemax = `out'_date
}

local outcomes "esrd krt chronic_krt egfr_half aki death"

local esrd_lab "Kidney failure"
local chronic_krt_lab "Kidney failure (excluding acute KRT)"
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