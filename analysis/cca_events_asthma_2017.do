sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_asthma_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_asthma_2017.csv, write text replace
file write tablecontent _tab ("Asthma cohort (pre-pandemic)") _tab ("Matched cohort (pre-pandemic)") _n

use ./output/analysis_asthma_2017_complete.dta, clear

local outcomes "esrd krt egfr_half aki death"

local esrd_lab "Kidney failure"
local krt_lab "Kidney replacement therapy"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

foreach out of local outcomes {
	
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

file write tablecontent ("``out'_lab'") _n

*Total
file write tablecontent ("Overall") _tab
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n


*Ethnicity
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
qui safecount if ethnicity==`ethnicity' & case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}
file write tablecontent ("Missing") _tab
qui safecount if ethnicity==. & case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==. & case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}

file close tablecontent