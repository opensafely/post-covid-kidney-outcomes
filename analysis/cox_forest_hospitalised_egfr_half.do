sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_hospitalised_egfr_half.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_hospitalised_egfr_half.csv, write text replace
file write tablecontent _tab ("Rate (/100000 person years) (95% CI)") _tab ("rate") _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _n
file write tablecontent ("Hospitalised COVID-19 overall") _n
file write tablecontent ("Overall") _tab
use ./output/analysis_hospitalised.dta, clear
*50% reduction in eGFR outcome
drop if baseline_egfr==.

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
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
drop total_follow_up
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n

local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach x of local period {
file write tablecontent ("`lab`x''") _tab
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort case: egen total_follow_up`x' = total(_t)
qui su total_follow_up`x' if case==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up`x' if case==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
drop total_follow_up`x'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab

qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 wave") _n

local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.wave i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_wave_1b: display %4.2f table[1,2]
local full_wave_1ll: display %4.2f table[5,2]
local full_wave_1ul: display %4.2f table[6,2]
local full_wave_2b: display %4.2f table[1,3]
local full_wave_2ll: display %4.2f table[5,3]
local full_wave_2ul: display %4.2f table[6,3]
local full_wave_3b: display %4.2f table[1,4]
local full_wave_3ll: display %4.2f table[5,4]
local full_wave_3ul: display %4.2f table[6,4]
local full_wave_4b: display %4.2f table[1,5]
local full_wave_4ll: display %4.2f table[5,5]
local full_wave_4ul: display %4.2f table[6,5]	

bysort wave: egen total_follow_up = total(_t)
forvalues i=1/4 {
qui su total_follow_up if wave==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}
drop total_follow_up

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.wave i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)	
matrix table = r(table)
local full_wave_1b`x': display %4.2f table[1,2]
local full_wave_1ll`x': display %4.2f table[5,2]
local full_wave_1ul`x': display %4.2f table[6,2]
local full_wave_2b`x': display %4.2f table[1,3]
local full_wave_2ll`x': display %4.2f table[5,3]
local full_wave_2ul`x': display %4.2f table[6,3]
local full_wave_3b`x': display %4.2f table[1,4]
local full_wave_3ll`x': display %4.2f table[5,4]
local full_wave_3ul`x': display %4.2f table[6,4]
local full_wave_4b`x': display %4.2f table[1,5]
local full_wave_4ll`x': display %4.2f table[5,5]
local full_wave_4ul`x': display %4.2f table[6,5]

bysort wave: egen total_follow_up`x' = total(_t)
forvalues i=1/4 {
qui su total_follow_up`x' if wave==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate`x' : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul`x' = `cases`i'_rate`x'' * `cases`i'_ef'
local cases`i'_ll`x' = `cases`i'_rate`x'' / `cases`i'_ef'
}
drop total_follow_up`x'
}

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _n
file write tablecontent ("Overall") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_wave_`i'b') (" (") %4.2f (`full_wave_`i'll') ("-") %4.2f (`full_wave_`i'ul') (")") _tab %4.2f (`full_wave_`i'b') _tab %4.2f (`full_wave_`i'll') _tab (`full_wave_`i'ul') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab ("`cases`i'_rate`x''") (" (") %3.2f (`cases`i'_ll`x'')  ("-") %3.2f (`cases`i'_ul`x'') (")")  _tab ("`cases`i'_rate`x''") _tab %4.2f (`full_wave_`i'b`x'') (" (") %4.2f (`full_wave_`i'll`x'') ("-") %4.2f (`full_wave_`i'ul`x'') (")") _tab %4.2f (`full_wave_`i'b`x'') _tab %4.2f (`full_wave_`i'll`x'') _tab %4.2f (`full_wave_`i'ul`x'') _n
}
}
file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n

local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_vax_1b: display %4.2f table[1,2]
local full_vax_1ll: display %4.2f table[5,2]
local full_vax_1ul: display %4.2f table[6,2]
local full_vax_2b: display %4.2f table[1,3]
local full_vax_2ll: display %4.2f table[5,3]
local full_vax_2ul: display %4.2f table[6,3]
local full_vax_3b: display %4.2f table[1,4]
local full_vax_3ll: display %4.2f table[5,4]
local full_vax_3ul: display %4.2f table[6,4]
local full_vax_4b: display %4.2f table[1,5]
local full_vax_4ll: display %4.2f table[5,5]
local full_vax_4ul: display %4.2f table[6,5]
local full_vax_5b: display %4.2f table[1,6]
local full_vax_5ll: display %4.2f table[5,6]
local full_vax_5ul: display %4.2f table[6,6]

bysort covid_vax: egen total_follow_up = total(_t)
forvalues i=1/5 {
qui su total_follow_up if covid_vax==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}
drop total_follow_up

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_vax_1b`x': display %4.2f table[1,2]
local full_vax_1ll`x': display %4.2f table[5,2]
local full_vax_1ul`x': display %4.2f table[6,2]
local full_vax_2b`x': display %4.2f table[1,3]
local full_vax_2ll`x': display %4.2f table[5,3]
local full_vax_2ul`x': display %4.2f table[6,3]
local full_vax_3b`x': display %4.2f table[1,4]
local full_vax_3ll`x': display %4.2f table[5,4]
local full_vax_3ul`x': display %4.2f table[6,4]
local full_vax_4b`x': display %4.2f table[1,5]
local full_vax_4ll`x': display %4.2f table[5,5]
local full_vax_4ul`x': display %4.2f table[6,5]
local full_vax_5b`x': display %4.2f table[1,6]
local full_vax_5ll`x': display %4.2f table[5,6]
local full_vax_5ul`x': display %4.2f table[6,6]

bysort covid_vax: egen total_follow_up`x' = total(_t)
forvalues i=1/5 {
qui su total_follow_up`x' if covid_vax==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate`x' : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul`x' = `cases`i'_rate`x'' * `cases`i'_ef'
local cases`i'_ll`x' = `cases`i'_rate`x'' / `cases`i'_ef'
}
drop total_follow_up`x'
}

forvalues i=1/5 {
file write tablecontent ("`vax`i''") _n
file write tablecontent ("Overall") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_vax_`i'b') (" (") %4.2f (`full_vax_`i'll') ("-") %4.2f (`full_vax_`i'ul') (")") _tab %4.2f (`full_vax_`i'b') _tab %4.2f (`full_vax_`i'll') _tab (`full_vax_`i'ul') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab ("`cases`i'_rate`x''") (" (") %3.2f (`cases`i'_ll`x'')  ("-") %3.2f (`cases`i'_ul`x'') (")")  _tab ("`cases`i'_rate`x''") _tab %4.2f (`full_vax_`i'b`x'') (" (") %4.2f (`full_vax_`i'll`x'') ("-") %4.2f (`full_vax_`i'ul`x'') (")") _tab %4.2f (`full_vax_`i'b`x'') _tab %4.2f (`full_vax_`i'll`x'') _tab %4.2f (`full_vax_`i'ul`x'') _n
}
}
file close tablecontent