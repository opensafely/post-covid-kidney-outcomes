sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_ethnicity_severity_2020_wave.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_ethnicity_severity_2020_wave.csv, write text replace
file write tablecontent ("ethnicity") _tab ("outcome") _tab ("wave") _tab ("severity") _tab ("COVID-19 cohort") _tab ("Matched cohort (contemporary)") _n

use ./output/analysis_complete_2020.dta, clear
replace covid_severity=2 if covid_severity==3

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

local outcomes "esrd krt chronic_krt egfr_half aki death"

local esrd_lab "Kidney failure"
local chronic_krt_lab "Kidney failure (excluding acute KRT)"
local krt_lab "Kidney replacement therapy"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

foreach out of local outcomes {
*Ethnicity
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
forvalues i=1/4 {
local wave_`i': label wave `i'
qui safecount if ethnicity==`ethnicity' & wave==`i' & _d==1 & _st==1 & covid_severity==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & wave==`i' & _d==1 & _st==1 & covid_severity==0
local controls_events = round(r(N),5)
file write tablecontent ("`label_`ethnicity''") _tab ("``out'_lab'") _tab ("`wave_`i''") _tab ("COVID-19 non-hospitalised") _tab (`cases_events') _tab (`controls_events') _n
qui safecount if ethnicity==`ethnicity' & wave==`i' & _d==1 & _st==1 & covid_severity==2
local cases_events = round(r(N),5)
file write tablecontent ("`label_`ethnicity''") _tab ("``out'_lab'") _tab ("`wave_`i''") _tab ("COVID-19 hospitalised") _tab (`cases_events') _tab ("N/A") _n
}
}
}

file close tablecontent