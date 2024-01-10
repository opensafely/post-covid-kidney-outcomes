sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/selection_2020.log, replace t

cap file close tablecontent

file open tablecontent using ./output/selection_2020.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Contemporary comparator") _n


local lab1 "Extracted from OpenSAFELY"
local lab2 "After applying exclusion criteria"
local lab3 "After matching"
local lab4 "After merging"
local lab5 "After further application of exclusion criteria"


capture noisily import delimited ./output/input_covid_matching.csv, clear
qui safecount
local covid_1 = round(r(N),5)
capture noisily import delimited ./output/input_2020_matching.csv, clear
qui safecount
local 2020_1 = round(r(N),5)
capture noisily import delimited ./output/covid_matching_2020.csv, clear
qui safecount
local covid_2 = round(r(N),5)
capture noisily import delimited ./output/2020_matching.csv, clear
qui safecount
local 2020_2 = round(r(N),5)
* Import COVID-19 dataset comprising individuals matched with historical comparators (limited matching variables only)	
capture noisily import delimited ./output/input_combined_stps_covid_2020.csv, clear
* Drop age & covid_diagnosis_date
keep patient_id death_date date_deregistered stp krt_outcome_date male covid_date covid_month set_id case match_counts
tempfile covid_2020_matched
* For dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `covid_2020_matched', replace
* Number of matched COVID-19 cases
qui safecount
local covid_3 = round(r(N),5)
* Import matched historical comparators (limited matching variables only)
capture noisily import delimited ./output/input_combined_stps_matches_2020.csv, clear
* Drop age
keep patient_id death_date date_deregistered stp krt_outcome_date male set_id case covid_date
tempfile 2020_matched
* For dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `2020_matched', replace
* Number of matched historical comparators
qui safecount
local 2020_3 = round(r(N),5)
* Merge limited COVID-19 dataset with additional variables
capture noisily import delimited ./output/input_covid_2020_additional.csv, clear
qui merge 1:1 patient_id using `covid_2020_matched'
keep if _merge==3
drop _merge
tempfile covid_2020_complete
save `covid_2020_complete', replace
qui safecount
local covid_4 = round(r(N),5)
* Merge limited historical comparator dataset with additional variables
capture noisily import delimited ./output/input_2020_additional.csv, clear
qui merge 1:1 patient_id using `2020_matched'
keep if _merge==3
drop _merge
tempfile 2020_complete
save `2020_complete', replace
qui safecount
local 2020_4 = round(r(N),5)

use ./output/analysis_2020.dta, clear

qui safecount if case==1
local covid_5 = round(r(N),5)

qui safecount if case==0
local 2020_5 = round(r(N),5)

forvalues i=1/5 {
file write tablecontent ("`lab`i''") _tab (`covid_`i'') _tab (`2020_`i'') _n
}

file close tablecontent