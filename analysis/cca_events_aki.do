sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_aki.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_aki.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("COVID-19 cohort") _tab ("General population cohort") _tab ("COVID-19 cohort") _tab ("General population cohort") _n

*Calculate denominator for each cohort (i.e. 100000 person-years)
/*local cohort "2017 2020 hospitalised"
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear, clear
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip = 100000 / r(mean)
}*/

local cohort "2017 2020"

*Total
file write tablecontent ("Total") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n

*Age
file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if agegroup==`age' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if agegroup==`age' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if sex==`sex' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if sex==`sex' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if imd==`imd' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if imd==`imd' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if ethnicity==`ethnicity' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if ethnicity==. & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==. & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if region==`region' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if region==`region' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*Baseline eGFR
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if egfr_group==`group' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if egfr_group==`group' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*Previous AKI
file write tablecontent ("Previous AKI") _n
forvalues aki=0/1 {
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
label values aki_baseline aki_baseline
local label_`aki': label aki_baseline `aki'
file write tablecontent ("`label_`aki''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if aki_baseline==`aki' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if aki_baseline==`aki' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*Diabetes
file write tablecontent ("Diabetes") _n
forvalues diabetes=0/1 {
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
local label_`diabetes': label diabetes `diabetes'
file write tablecontent ("`label_`diabetes''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if diabetes==`diabetes' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if diabetes==`diabetes' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*COVID-19 vaccination status
file write tablecontent ("COVID-19 vaccination status") _n
forvalues group=1/5 {
local label_`group': label covid_vax `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if covid_vax==`group' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if covid_vax==`group' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

*COVID-19 wave
file write tablecontent ("COVID-19 wave") _n
forvalues group=1/4 {
local label_`group': label wave `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
qui safecount if wave==`group' & case==1 & aki==1
local cases_events = round(r(N),5)
qui safecount if wave==`group' & case==0 & aki==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
}
file write tablecontent _n
}

file close tablecontent