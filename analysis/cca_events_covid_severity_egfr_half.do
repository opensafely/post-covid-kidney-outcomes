sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_covid_severity_egfr_half.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_covid_severity_egfr_half.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("COVID-19 non-hospitalised") _tab ("COVID-19 hospitalised") _tab ("COVID-19 critical care") _tab ("General population cohort") _tab ("COVID-19 non-hospitalised") _tab ("COVID-19 hospitalised") _tab ("COVID-19 critical care") _tab ("General population cohort") _n

local cohort "2017 2020"

*Total
file write tablecontent ("Total")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n

*Age
file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if agegroup==`age' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if agegroup==`age' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if sex==`sex' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if sex==`sex' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if imd==`imd' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if imd==`imd' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if ethnicity==`ethnicity' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if ethnicity==`ethnicity' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}
file write tablecontent ("Missing")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if ethnicity==. & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if ethnicity==. & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n

*Baseline eGFR
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if egfr_group==`group' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if egfr_group==`group' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*Previous AKI
file write tablecontent ("Previous AKI") _n
forvalues aki=0/1 {
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
label values aki_baseline aki_baseline
local label_`aki': label aki_baseline `aki'
file write tablecontent ("`label_`aki''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if aki_baseline==`aki' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if aki_baseline==`aki' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*Diabetes
file write tablecontent ("Diabetes") _n
forvalues diabetes=0/1 {
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
local label_`diabetes': label diabetes `diabetes'
file write tablecontent ("`label_`diabetes''")
foreach x of local cohort {
use ./output/analysis_complete_`x'.dta, clear
forvalues i=1/3 {
qui safecount if diabetes==`diabetes' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if diabetes==`diabetes' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events')
}
file write tablecontent _n
}

*COVID-19 vaccination status
file write tablecontent ("COVID-19 vaccination status") _n
forvalues group=1/5 {
use ./output/analysis_complete_2020.dta, clear
local label_`group': label covid_vax `group'
file write tablecontent ("`label_`group''")
forvalues i=1/3 {
qui safecount if covid_vax==`group' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if covid_vax==`group' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab _tab _tab _tab _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events') _n
}

*COVID-19 wave
file write tablecontent ("COVID-19 wave") _n
forvalues group=1/4 {
use ./output/analysis_complete_2020.dta, clear
local label_`group': label wave `group'
file write tablecontent ("`label_`group''")
forvalues i=1/3 {
qui safecount if wave==`group' & covid_severity==`i' & egfr_half==1
local cases_events_`i' = round(r(N),5)
}
qui safecount if wave==`group' & covid_severity==0 & egfr_half==1
local controls_events = round(r(N),5)
file write tablecontent _tab _tab _tab _tab _tab (`cases_events_1') _tab (`cases_events_2') _tab (`cases_events_3') _tab (`controls_events') _n
}

file close tablecontent