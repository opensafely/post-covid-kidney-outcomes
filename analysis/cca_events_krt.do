sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_krt.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_krt.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("COVID-19 cohort") _tab ("Matched population cohort") _tab ("COVID-19 cohort") _tab ("Matched population cohort") _n

local cohort "2017 2020"



*Total
file write tablecontent ("Total") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear

*eGFR = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.

qui safecount if case==1 & krt==1
local cases_events = round(r(N),5)
qui safecount if case==0 & krt==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n


*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear

*eGFR = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.


qui safecount if ethnicity==`ethnicity' & case==1 & krt==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & krt==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear

*eGFR = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.

qui safecount if ethnicity==. & case==1 & krt==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==. & case==0 & krt==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n



file close tablecontent