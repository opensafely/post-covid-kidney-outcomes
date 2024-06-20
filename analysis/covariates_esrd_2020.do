sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/covariates_esrd_2020.log, replace t

use ./output/analysis_complete_2020.dta, clear

cap file close tablecontent
file open tablecontent using ./output/covariates_esrd_2020.csv, write text replace

file write tablecontent _tab ("Matched") _tab ("COVID-19") _n


stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

*Age group
file write tablecontent ("Age") _n
forvalues j=1/6 {
local label_`j': label agegroup `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if agegroup==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues j=0/1 {
local label_`j': label sex `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if sex==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}


*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues j=1/5 {
local label_`j': label imd `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if imd==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues j=1/5 {
local label_`j': label ethnicity `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if ethnicity==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*Rural/urban
file write tablecontent ("Rural/urban") _n
forvalues j=0/1{
local label_`j': label urban `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if urban==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*BMI
file write tablecontent ("BMI") _n
forvalues j=1/6 {
local label_`j': label bmi `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if bmi==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*Smoking
file write tablecontent ("Smoking") _n
forvalues j=0/1 {
local label_`j': label smoking `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if smoking==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*CKD stage
file write tablecontent ("CKD stage") _n
forvalues j=1/6 {
local label_`j': label ckd_stage `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if ckd_stage==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*Previous AKI
file write tablecontent ("Previous AKI")
forvalues i=0/1 {
qui safecount if aki_baseline==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*Cardiovascular
file write tablecontent ("Cardiovascular")
forvalues i=0/1 {
qui safecount if cardiovascular==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*Diabetes
file write tablecontent ("Diabetes")
forvalues i=0/1 {
qui safecount if diabetes==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*Hypertension
file write tablecontent ("Hypertension")
forvalues i=0/1 {
qui safecount if hypertension==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*Immunosuppressed
file write tablecontent ("Immunosuppressed")
forvalues i=0/1 {
qui safecount if immunosuppressed==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*Cancer
file write tablecontent ("Cancer")
forvalues i=0/1 {
qui safecount if non_haem_cancer==1 & case==`i' & _d==1
local events_1_`i' = round(r(N),5)
if `events_1_`i''>5 & `events_1_`i''!=. {
file write tablecontent _tab %9.0f (`events_1_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n

*GP interactions
file write tablecontent ("GP interactions (1 year)") _n
forvalues j=0/3 {
local label_`j': label gp_consults `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if gp_consults==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*GP interactions
file write tablecontent ("Admissions (5 years)") _n
forvalues j=0/2 {
local label_`j': label admissions `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if admissions==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}

*COVID vaccination
file write tablecontent ("COVID-19 vaccination") _n
forvalues j=1/5 {
local label_`j': label covid_vax `j'
file write tablecontent ("`label_`j''")
forvalues i=0/1 {
qui safecount if covid_vax==`j' & case==`i' & _d==1
local events_`j'_`i' = round(r(N),5)
}
forvalues i=0/1{
if `events_`j'_`i''>5 & `events_`j'_`i''!=. {
file write tablecontent _tab %9.0f (`events_`j'_`i'')
}
else {
file write tablecontent _tab ("REDACTED")
}
}
file write tablecontent _n
}
file close tablecontent


