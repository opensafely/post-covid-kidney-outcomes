sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020.csv, write text replace
file write tablecontent ("outcome") _tab ("stratum") _tab ("period") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("rate_text") _tab ("rate") _tab ("rate_ll") _tab ("rate_ul") _tab ("ard_text") _tab ("ard") _tab ("ard_ll") _tab ("ard_ul") _n
use ./output/analysis_complete_2020.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"

*Time to event
local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

local outcomes "esrd egfr_half aki death"

local esrd_lab "Kidney failure"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

foreach out of local outcomes {

stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

**COVID overall

*Rates
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

*Adjusted rate difference - confidence intervals based on crude rate in exposed with uncertainty expressed by confidence intervals for HRs
local ard_b: di %3.2f `cases_rate' - ((1/`full_overall_b') * `cases_rate')
local ard_ll: di %3.2f `cases_rate' - ((1/`full_overall_ll') * `cases_rate')
local ard_ul: di %3.2f `cases_rate' - ((1/`full_overall_ul') * `cases_rate')

**By COVID severity

*Rates
drop total_follow_up
forvalues i=1/2 {
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`i'
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}

*HR
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_severity_1b: display %4.2f table[1,2]
local full_severity_1ll: display %4.2f table[5,2]
local full_severity_1ul: display %4.2f table[6,2]
local full_severity_2b: display %4.2f table[1,3]
local full_severity_2ll: display %4.2f table[5,3]
local full_severity_2ul: display %4.2f table[6,3]

*Adjusted rate difference
forvalues i=1/2 {
local ard`i'_b: di %3.2f `cases`i'_rate' - ((1/`full_severity_`i'b') * `cases`i'_rate')
local ard`i'_ll: di %3.2f `cases`i'_rate' - ((1/`full_severity_`i'll') * `cases`i'_rate')
local ard`i'_ul: di %3.2f `cases`i'_rate' - ((1/`full_severity_`i'ul') * `cases`i'_rate')
}

*Stratified by time to event
foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)

**COVID overall

*Rate
bysort case: egen total_follow_up`x' = total(_t)
qui su total_follow_up`x' if case==1
local cases_multip = 100000 / r(mean)
drop total_follow_up`x'
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate`x' : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`x' = `cases_rate`x'' * `cases_ef'
local cases_ll`x' = `cases_rate`x'' / `cases_ef'

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b`x': display %4.2f table[1,2]
local full_overall_ll`x': display %4.2f table[5,2]
local full_overall_ul`x': display %4.2f table[6,2]

*Adjusted rate difference
local ard_b`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_b`x'') * `cases_rate`x'')
local ard_ll`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_ll`x'') * `cases_rate`x'')
local ard_ul`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_ul`x'') * `cases_rate`x'')

**BY COVID severity

*Rate
forvalues i=1/2 {
bysort covid_severity: egen total_follow_up`x' = total(_t)
qui su total_follow_up`x' if covid_severity==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up`x'
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate`x' : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul`x' = `cases`i'_rate`x'' * `cases`i'_ef'
local cases`i'_ll`x' = `cases`i'_rate`x'' / `cases`i'_ef'
}

*HR
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id)	strata(set_id)
matrix table = r(table)
local full_severity_1b`x': display %4.2f table[1,2]
local full_severity_1ll`x': display %4.2f table[5,2]
local full_severity_1ul`x': display %4.2f table[6,2]
local full_severity_2b`x': display %4.2f table[1,3]
local full_severity_2ll`x': display %4.2f table[5,3]
local full_severity_2ul`x': display %4.2f table[6,3]

*Adjusted rate difference
forvalues i=1/2 {
local ard`i'_b`x': di %3.2f `cases`i'_rate`x'' - ((1/`full_severity_`i'b`x'') * `cases`i'_rate`x'')
local ard`i'_ll`x': di %3.2f `cases`i'_rate`x'' - ((1/`full_severity_`i'll`x'') * `cases`i'_rate`x'')
local ard`i'_ul`x': di %3.2f `cases`i'_rate`x'' - ((1/`full_severity_`i'ul`x'') * `cases`i'_rate`x'')
}
}

file write tablecontent ("``out'_lab'") _tab ("COVID-19 overall") _tab ("Overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab ("`cases_ll'") _tab ("`cases_ul'") _tab ("`ard_b'") (" (") %3.2f (`ard_ll')  ("-") %3.2f (`ard_ul') (")") _tab ("`ard_b'") _tab ("`ard_ll'") _tab ("`ard_ul'") _n

foreach x of local period {
file write tablecontent ("``out'_lab'") _tab ("COVID-19 overall") _tab ("`lab`x''") _tab %4.2f (`full_overall_b`x'') (" (") %4.2f (`full_overall_ll`x'') ("-") %4.2f (`full_overall_ul`x'') (")") _tab %4.2f (`full_overall_b`x'') _tab %4.2f (`full_overall_ll`x'') _tab (`full_overall_ul`x'') _tab ("`cases_rate`x''") (" (") %3.2f (`cases_ll`x'')  ("-") %3.2f (`cases_ul`x'') (")")  _tab ("`cases_rate`x''") _tab ("`cases_ll`x''") _tab ("`cases_ul`x''") _tab ("`ard_b`x''") (" (") %3.2f (`ard_ll`x'')  ("-") %3.2f (`ard_ul`x'') (")") _tab ("`ard_b`x''") _tab ("`ard_ll`x''") _tab ("`ard_ul`x''") _n
}

forvalues i=1/2 {
file write tablecontent ("``out'_lab'") _tab ("`severity`i''") _tab ("Overall") _tab %4.2f (`full_severity_`i'b') (" (") %4.2f (`full_severity_`i'll') ("-") %4.2f (`full_severity_`i'ul') (")") _tab %4.2f (`full_severity_`i'b') _tab %4.2f (`full_severity_`i'll') _tab (`full_severity_`i'ul') _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab ("`cases`i'_rate'") _tab ("`cases`i'_ll'") _tab ("`cases`i'_ul'") _tab ("`ard`i'_b'") (" (") %3.2f (`ard`i'_ll')  ("-") %3.2f (`ard`i'_ul') (")") _tab ("`ard`i'_b'") _tab ("`ard`i'_ll'") _tab ("`ard`i'_ul'") _n
foreach x of local period {
file write tablecontent ("``out'_lab'") _tab ("`severity`i''") _tab ("`lab`x''") _tab %4.2f (`full_severity_`i'b`x'') (" (") %4.2f (`full_severity_`i'll`x'') ("-") %4.2f (`full_severity_`i'ul`x'') (")") _tab %4.2f (`full_severity_`i'b`x'') _tab %4.2f (`full_severity_`i'll`x'') _tab (`full_severity_`i'ul`x'') _tab ("`cases`i'_rate`x''") (" (") %3.2f (`cases`i'_ll`x'')  ("-") %3.2f (`cases`i'_ul`x'') (")")  _tab ("`cases`i'_rate`x''") _tab ("`cases`i'_ll`x''") _tab ("`cases`i'_ul`x''") _tab ("`ard`i'_b`x''") (" (") %3.2f (`ard`i'_ll`x'')  ("-") %3.2f (`ard`i'_ul`x'') (")") _tab ("`ard`i'_b`x''") _tab ("`ard`i'_ll`x''") _tab ("`ard`i'_ul`x''") _n
}
}
}


file close tablecontent