sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models3_2020_egfr_half.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_models3_2020_egfr_half.csv, write text replace
file write tablecontent _tab ("Crude rate (/100000py) (95% CI)") _n
file write tablecontent _tab ("COVID-19") _tab ("General population (contemporary)") _tab ("Minimally-adjusted HR (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _n
file write tablecontent ("COVID-19 overall") _n
file write tablecontent ("Overall") _tab
use ./output/analysis_complete_2020.dta, clear
stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ul = `cases_rate' + (1.96*sqrt(`cases_rate' / `cases_multip'))
local cases_ll = `cases_rate' - (1.96*sqrt(`cases_rate' / `cases_multip'))
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ul = `controls_rate' + (1.96*sqrt(`controls_rate' / `controls_multip'))
local controls_ll = `controls_rate' - (1.96*sqrt(`controls_rate' / `controls_multip'))
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab

qui stcox i.case, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_overall_b: display %4.2f table[1,2]
local minimal_overall_ll: display %4.2f table[5,2]
local minimal_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`minimal_overall_b') (" (") %4.2f (`minimal_overall_ll') ("-") %4.2f (`minimal_overall_ul') (")") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _n

local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach x of local period {
file write tablecontent ("`lab`x''") _tab
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
bysort case: egen total_follow_up`x' = total(_t)
qui su total_follow_up`x' if case==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up`x' if case==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ul = `cases_rate' + (1.96*sqrt(`cases_rate' / `cases_multip'))
local cases_ll = `cases_rate' - (1.96*sqrt(`cases_rate' / `cases_multip'))
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ul = `controls_rate' + (1.96*sqrt(`controls_rate' / `controls_multip'))
local controls_ll = `controls_rate' - (1.96*sqrt(`controls_rate' / `controls_multip'))
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab

qui stcox i.case, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_overall_b: display %4.2f table[1,2]
local minimal_overall_ll: display %4.2f table[5,2]
local minimal_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`minimal_overall_b') (" (") %4.2f (`minimal_overall_ll') ("-") %4.2f (`minimal_overall_ul') (")") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 severity") _n

use ./output/analysis_complete_2020.dta, clear

local severity1: label covid_severity 1
local severity2: label covid_severity 2
local severity3: label covid_severity 3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)

qui stcox i.covid_severity, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_severity_1b: display %4.2f table[1,2]
local minimal_severity_1ll: display %4.2f table[5,2]
local minimal_severity_1ul: display %4.2f table[6,2]
local minimal_severity_2b: display %4.2f table[1,3]
local minimal_severity_2ll: display %4.2f table[5,3]
local minimal_severity_2ul: display %4.2f table[6,3]
local minimal_severity_3b: display %4.2f table[1,4]
local minimal_severity_3ll: display %4.2f table[5,4]
local minimal_severity_3ul: display %4.2f table[6,4]

qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
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

bysort covid_severity: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui su total_follow_up if covid_severity==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)

qui stcox i.covid_severity, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_severity_1b`x': display %4.2f table[1,2]
local minimal_severity_1ll`x': display %4.2f table[5,2]
local minimal_severity_1ul`x': display %4.2f table[6,2]
local minimal_severity_2b`x': display %4.2f table[1,3]
local minimal_severity_2ll`x': display %4.2f table[5,3]
local minimal_severity_2ul`x': display %4.2f table[6,3]
local minimal_severity_3b`x': display %4.2f table[1,4]
local minimal_severity_3ll`x': display %4.2f table[5,4]
local minimal_severity_3ul`x': display %4.2f table[6,4]

qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id)	strata(set_id)
matrix table = r(table)
local full_severity_1b`x': display %4.2f table[1,2]
local full_severity_1ll`x': display %4.2f table[5,2]
local full_severity_1ul`x': display %4.2f table[6,2]
local full_severity_2b`x': display %4.2f table[1,3]
local full_severity_2ll`x': display %4.2f table[5,3]
local full_severity_2ul`x': display %4.2f table[6,3]
local full_severity_3b`x': display %4.2f table[1,4]
local full_severity_3ll`x': display %4.2f table[5,4]
local full_severity_3ul`x': display %4.2f table[6,4]

bysort covid_severity: egen total_follow_up`x' = total(_t)
forvalues i=1/3 {
qui su total_follow_up`x' if covid_severity==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate`x' : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul`x' = `cases`i'_rate`x'' + (1.96*sqrt(`cases`i'_rate`x'' / `cases`i'_multip'))
local cases`i'_ll`x' = `cases`i'_rate`x'' - (1.96*sqrt(`cases`i'_rate`x'' / `cases`i'_multip'))
}
}

forvalues i=1/3 {
file write tablecontent ("`severity`i''") _n
file write tablecontent ("Overall") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`minimal_severity_`i'b') (" (") %4.2f (`minimal_severity_`i'll') ("-") %4.2f (`minimal_severity_`i'ul') (")") _tab %4.2f (`full_severity_`i'b') (" (") %4.2f (`full_severity_`i'll') ("-") %4.2f (`full_severity_`i'ul') (")") _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab ("`cases`i'_rate`x''") (" (") %3.2f (`cases`i'_ll`x'')  ("-") %3.2f (`cases`i'_ul`x'') (")")  _tab _tab %4.2f (`minimal_severity_`i'b`x'') (" (") %4.2f (`minimal_severity_`i'll`x'') ("-") %4.2f (`minimal_severity_`i'ul`x'') (")") _tab %4.2f (`full_severity_`i'b`x'') (" (") %4.2f (`full_severity_`i'll`x'') ("-") %4.2f (`full_severity_`i'ul`x'') (")") _n
}
}
file write tablecontent _n


file write tablecontent ("By COVID-19 egfr_half") _n

use ./output/analysis_complete_2020.dta, clear

local egfr_half1: label covid_egfr_half 1
local egfr_half2: label covid_egfr_half 2
local egfr_half3: label covid_egfr_half 3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)

qui stcox i.covid_egfr_half, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_egfr_half_1b: display %4.2f table[1,2]
local minimal_egfr_half_1ll: display %4.2f table[5,2]
local minimal_egfr_half_1ul: display %4.2f table[6,2]
local minimal_egfr_half_2b: display %4.2f table[1,3]
local minimal_egfr_half_2ll: display %4.2f table[5,3]
local minimal_egfr_half_2ul: display %4.2f table[6,3]
local minimal_egfr_half_3b: display %4.2f table[1,4]
local minimal_egfr_half_3ll: display %4.2f table[5,4]
local minimal_egfr_half_3ul: display %4.2f table[6,4]

qui stcox i.covid_egfr_half i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_egfr_half_1b: display %4.2f table[1,2]
local full_egfr_half_1ll: display %4.2f table[5,2]
local full_egfr_half_1ul: display %4.2f table[6,2]
local full_egfr_half_2b: display %4.2f table[1,3]
local full_egfr_half_2ll: display %4.2f table[5,3]
local full_egfr_half_2ul: display %4.2f table[6,3]
local full_egfr_half_3b: display %4.2f table[1,4]
local full_egfr_half_3ll: display %4.2f table[5,4]
local full_egfr_half_3ul: display %4.2f table[6,4]

bysort covid_egfr_half: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui su total_follow_up if covid_egfr_half==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_egfr_half==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)

qui stcox i.covid_egfr_half, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_egfr_half_1b`x': display %4.2f table[1,2]
local minimal_egfr_half_1ll`x': display %4.2f table[5,2]
local minimal_egfr_half_1ul`x': display %4.2f table[6,2]
local minimal_egfr_half_2b`x': display %4.2f table[1,3]
local minimal_egfr_half_2ll`x': display %4.2f table[5,3]
local minimal_egfr_half_2ul`x': display %4.2f table[6,3]
local minimal_egfr_half_3b`x': display %4.2f table[1,4]
local minimal_egfr_half_3ll`x': display %4.2f table[5,4]
local minimal_egfr_half_3ul`x': display %4.2f table[6,4]

qui stcox i.covid_egfr_half i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)	
matrix table = r(table)
local full_egfr_half_1b`x': display %4.2f table[1,2]
local full_egfr_half_1ll`x': display %4.2f table[5,2]
local full_egfr_half_1ul`x': display %4.2f table[6,2]
local full_egfr_half_2b`x': display %4.2f table[1,3]
local full_egfr_half_2ll`x': display %4.2f table[5,3]
local full_egfr_half_2ul`x': display %4.2f table[6,3]
local full_egfr_half_3b`x': display %4.2f table[1,4]
local full_egfr_half_3ll`x': display %4.2f table[5,4]
local full_egfr_half_3ul`x': display %4.2f table[6,4]

bysort covid_egfr_half: egen total_follow_up`x' = total(_t)
forvalues i=1/3 {
qui su total_follow_up`x' if covid_egfr_half==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_egfr_half==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate`x' : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul`x' = `cases`i'_rate`x'' + (1.96*sqrt(`cases`i'_rate`x'' / `cases`i'_multip'))
local cases`i'_ll`x' = `cases`i'_rate`x'' - (1.96*sqrt(`cases`i'_rate`x'' / `cases`i'_multip'))
}
}

forvalues i=1/3 {
file write tablecontent ("`egfr_half`i''") _n
file write tablecontent ("Overall") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`minimal_egfr_half_`i'b') (" (") %4.2f (`minimal_egfr_half_`i'll') ("-") %4.2f (`minimal_egfr_half_`i'ul') (")") _tab %4.2f (`full_egfr_half_`i'b') (" (") %4.2f (`full_egfr_half_`i'll') ("-") %4.2f (`full_egfr_half_`i'ul') (")") _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab ("`cases`i'_rate`x''") (" (") %3.2f (`cases`i'_ll`x'')  ("-") %3.2f (`cases`i'_ul`x'') (")")  _tab _tab %4.2f (`minimal_egfr_half_`i'b`x'') (" (") %4.2f (`minimal_egfr_half_`i'll`x'') ("-") %4.2f (`minimal_egfr_half_`i'ul`x'') (")") _tab %4.2f (`full_egfr_half_`i'b`x'') (" (") %4.2f (`full_egfr_half_`i'll`x'') ("-") %4.2f (`full_egfr_half_`i'ul`x'') (")") _n
}
}