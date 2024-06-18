sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/covariate_events_2020.log, replace t

use ./output/analysis_complete_2020.dta, clear

cap file close tablecontent
file open tablecontent using ./output/covariate_events_2020.csv, write text replace

file write tablecontent _tab ("Matched") _tab _tab _tab ("Non-hospitalised COVID-19") _tab _tab _tab ("Hospitalised_COVID-19") _n
file write tablecontent _tab ("0-29 days") _tab ("30-89 days") _tab ("90-179 days") _tab ("180 days+") _tab ("0-29 days") _tab ("30-89 days") _tab ("90-179 days") _tab ("180 days+") _tab ("0-29 days") _tab ("30-89 days") _tab ("90-179 days") _tab ("180 days+") _n

gen follow_up_esrd = follow_up_time_esrd
recode follow_up_esrd	min/29=1 	///
						30/89=2 	///
						90/179=3			///
						180/max=4 
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

*COVID severity

file write tablecontent ("Overall") _n
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}
file write tablecontent _n



*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if imd==`imd' & covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if ethnicity==`ethnicity' & covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}
file write tablecontent _n
}

*CKD stage
file write tablecontent ("CKD stage") _n
forvalues ckd_stage =1/6 {
local label_`ckd_stage': label ckd_stage `ckd_stage'
file write tablecontent ("`label_`ckd_stage''") _tab
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if ckd_stage==`ckd_stage' & covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}
file write tablecontent _n
}

*AKI
file write tablecontent ("Previous acute kidney injury") _tab
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if aki_baseline==1 & covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}
file write tablecontent _n

*Diabetes
file write tablecontent ("Diabetes") _tab
forvalues i=0/2 {
forvalues j=1/4 {
qui safecount if diabetes==1 & covid_severity==`i' & _d==1 & follow_up_esrd==`j'
local followup_`j' = round(r(N),5)
}
file write tablecontent %9.0f (`followup_1') _tab %9.0f (`followup_2') _tab %9.0f (`followup_3') _tab %9.0f (`followup_4') _tab
}

