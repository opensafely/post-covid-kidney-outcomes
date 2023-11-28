*Original code by Rohini Mathur, Angel Wong, Anna Schultze
*https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/08b_eth_cr_imputed_eth5.do

sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_sens4.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_sens4.csv, write text replace
file write tablecontent _tab ("Rate (/100000 person years) (95% CI)") _tab ("rate") _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _n
file write tablecontent ("COVID-19 overall") _tab
use ./output/analysis_2020.dta, clear

*Sensivity analysis 4 - multiple imputation for missing ethnicity

*Remove invalid sets with missing smoking/BMI data
foreach var of varlist bmi smoking {
gen `var'_recorded = 0
replace `var'_recorded = 1 if case==1 & `var'!=.
replace `var'_recorded = 1 if case==0
bysort set_id: egen set_mean = mean(`var'_recorded)
drop if set_mean < 1
drop set_mean `var'_recorded
drop if case==0 & `var'==.
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n
}

*mi set the data
mi set mlong

*mi register 
mi register imputed ethnicity

noisily mi impute mlogit ethnicity esrd i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.agegroup i.sex i.stp, add(10) rseed(70548) augment force // can maybe remove the force option in the server

mi stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n
file write tablecontent _n

file write tablecontent ("By COVID-19 severity") _n

local severity1: label covid_severity 1
local severity2: label covid_severity 2
local severity3: label covid_severity 3

qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_severity_1b: display %4.2f table[1,2]
local full_severity_1ll: display %4.2f table[5,2]
local full_severity_1ul: display %4.2f table[6,2]
local full_severity_2b: display %4.2f table[1,3]
local full_severity_2ll: display %4.2f table[5,3]
local full_severity_2ul: display %4.2f table[6,3]
local full_severity_3b: display %4.2f table[1,4]
local full_severity_3ll: display %4.2f table[5,4]
local full_severity_3ul: display %4.2f table[6,4]

drop total_follow_up
bysort covid_severity: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui su total_follow_up if covid_severity==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}

forvalues i=1/3 {
file write tablecontent ("`severity`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_severity_`i'b') (" (") %4.2f (`full_severity_`i'll') ("-") %4.2f (`full_severity_`i'ul') (")") _tab %4.2f (`full_severity_`i'b') _tab %4.2f (`full_severity_`i'll') _tab (`full_severity_`i'ul') _n
}
file write tablecontent _n


file write tablecontent ("By COVID-19 AKI") _n

local aki1: label covid_aki 1
local aki2: label covid_aki 2
local aki3: label covid_aki 3

qui stcox i.covid_aki i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_aki_1b: display %4.2f table[1,2]
local full_aki_1ll: display %4.2f table[5,2]
local full_aki_1ul: display %4.2f table[6,2]
local full_aki_2b: display %4.2f table[1,3]
local full_aki_2ll: display %4.2f table[5,3]
local full_aki_2ul: display %4.2f table[6,3]
local full_aki_3b: display %4.2f table[1,4]
local full_aki_3ll: display %4.2f table[5,4]
local full_aki_3ul: display %4.2f table[6,4]

drop total_follow_up
bysort covid_aki: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui su total_follow_up if covid_aki==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_aki==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}

forvalues i=1/3 {
file write tablecontent ("`aki`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_aki_`i'b') (" (") %4.2f (`full_aki_`i'll') ("-") %4.2f (`full_aki_`i'ul') (")") _tab %4.2f (`full_aki_`i'b') _tab %4.2f (`full_aki_`i'll') _tab (`full_aki_`i'ul') _n
}
file close tablecontent