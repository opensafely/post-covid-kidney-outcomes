sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_hospitalised.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_hospitalised.csv, write text replace
file write tablecontent ("outcome") _tab ("period") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("rate_text") _tab ("rate") _tab ("rate_ll") _tab ("rate_ul") _tab ("ard_text") _tab ("ard") _tab ("ard_ll") _tab ("ard_ul") _n
use ./output/analysis_hospitalised.dta, clear

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

qui stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

**COVID overall

*Rates
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'

*HR
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

*Adjusted rate difference - confidence intervals based on crude rate in exposed with uncertainty expressed by confidence intervals for HRs
local ard_b: di %3.2f `cases_rate' - ((1/`full_overall_b') * `cases_rate')
local ard_ll: di %3.2f `cases_rate' - ((1/`full_overall_ll') * `cases_rate')
local ard_ul: di %3.2f `cases_rate' - ((1/`full_overall_ul') * `cases_rate')

*Stratified by time to event
foreach x of local period {
qui stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)

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
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b`x': display %4.2f table[1,2]
local full_overall_ll`x': display %4.2f table[5,2]
local full_overall_ul`x': display %4.2f table[6,2]

*Adjusted rate difference
local ard_b`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_b`x'') * `cases_rate`x'')
local ard_ll`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_ll`x'') * `cases_rate`x'')
local ard_ul`x': di %3.2f `cases_rate`x'' - ((1/`full_overall_ul`x'') * `cases_rate`x'')
}


file write tablecontent ("``out'_lab'") _tab ("Overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab ("`cases_ll'") _tab ("`cases_ul'") _tab ("`ard_b'") (" (") %3.2f (`ard_ll')  ("-") %3.2f (`ard_ul') (")") _tab ("`ard_b'") _tab ("`ard_ll'") _tab ("`ard_ul'") _n

foreach x of local period {
file write tablecontent ("``out'_lab'") _tab ("`lab`x''") _tab %4.2f (`full_overall_b`x'') (" (") %4.2f (`full_overall_ll`x'') ("-") %4.2f (`full_overall_ul`x'') (")") _tab %4.2f (`full_overall_b`x'') _tab %4.2f (`full_overall_ll`x'') _tab (`full_overall_ul`x'') _tab ("`cases_rate`x''") (" (") %3.2f (`cases_ll`x'')  ("-") %3.2f (`cases_ul`x'') (")")  _tab ("`cases_rate`x''") _tab ("`cases_ll`x''") _tab ("`cases_ul`x''") _tab ("`ard_b`x''") (" (") %3.2f (`ard_ll`x'')  ("-") %3.2f (`ard_ul`x'') (")") _tab ("`ard_b`x''") _tab ("`ard_ll`x''") _tab ("`ard_ul`x''") _n
}
}


file close tablecontent