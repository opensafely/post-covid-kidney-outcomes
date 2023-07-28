sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models_hospitalised_death.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_models_hospitalised_death.csv, write text replace
file write tablecontent _tab ("Crude rate (/100000py) (95% CI)") _n
file write tablecontent _tab ("COVID-19") _tab ("Pneumonia (pre-pandemic)") _tab ("Crude HR (95% CI)") _tab ("Age and sex adjusted HR (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _n
file write tablecontent ("COVID-19 overall") _n
file write tablecontent ("Overall") _tab
use ./output/analysis_hospitalised.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
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

qui stcox i.case, vce(cluster practice_id)
matrix table = r(table)
local crude_overall_b: display %4.2f table[1,2]
local crude_overall_ll: display %4.2f table[5,2]
local crude_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_overall_b: display %4.2f table[1,2]
local minimal_overall_ll: display %4.2f table[5,2]
local minimal_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id) 
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`crude_overall_b') (" (") %4.2f (`crude_overall_ll') ("-") %4.2f (`crude_overall_ul') (")") _tab %4.2f (`minimal_overall_b') (" (") %4.2f (`minimal_overall_ll') ("-") %4.2f (`minimal_overall_ul') (")") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _n

local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach x of local period {
file write tablecontent ("`lab`x''") _tab
stset exit_date`x'_death, fail(death_date`x') origin(index_date`x'_death) id(unique) scale(365.25)
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

qui stcox i.case, vce(cluster practice_id)
matrix table = r(table)
local crude_overall_b: display %4.2f table[1,2]
local crude_overall_ll: display %4.2f table[5,2]
local crude_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_overall_b: display %4.2f table[1,2]
local minimal_overall_ll: display %4.2f table[5,2]
local minimal_overall_ul: display %4.2f table[6,2]

qui stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id) 
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]	

file write tablecontent  %4.2f (`crude_overall_b') (" (") %4.2f (`crude_overall_ll') ("-") %4.2f (`crude_overall_ul') (")") _tab %4.2f (`minimal_overall_b') (" (") %4.2f (`minimal_overall_ll') ("-") %4.2f (`minimal_overall_ul') (")") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 wave") _n
file write tablecontent ("Overall") _n
use ./output/analysis_hospitalised.dta, clear

local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)

qui stcox i.wave, vce(cluster practice_id)
matrix table = r(table)
local crude_wave_1b: display %4.2f table[1,2]
local crude_wave_1ll: display %4.2f table[5,2]
local crude_wave_1ul: display %4.2f table[6,2]
local crude_wave_2b: display %4.2f table[1,3]
local crude_wave_2ll: display %4.2f table[5,3]
local crude_wave_2ul: display %4.2f table[6,3]
local crude_wave_3b: display %4.2f table[1,4]
local crude_wave_3ll: display %4.2f table[5,4]
local crude_wave_3ul: display %4.2f table[6,4]
local crude_wave_4b: display %4.2f table[1,5]
local crude_wave_4ll: display %4.2f table[5,5]
local crude_wave_4ul: display %4.2f table[6,5]

qui stcox i.wave i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_wave_1b: display %4.2f table[1,2]
local minimal_wave_1ll: display %4.2f table[5,2]
local minimal_wave_1ul: display %4.2f table[6,2]
local minimal_wave_2b: display %4.2f table[1,3]
local minimal_wave_2ll: display %4.2f table[5,3]
local minimal_wave_2ul: display %4.2f table[6,3]
local minimal_wave_3b: display %4.2f table[1,4]
local minimal_wave_3ll: display %4.2f table[5,4]
local minimal_wave_3ul: display %4.2f table[6,4]
local minimal_wave_4b: display %4.2f table[1,5]
local minimal_wave_4ll: display %4.2f table[5,5]
local minimal_wave_4ul: display %4.2f table[6,5]

qui stcox i.wave i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)	
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
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
file write tablecontent ("`wave`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`crude_wave_`i'b') (" (") %4.2f (`crude_wave_`i'll') ("-") %4.2f (`crude_wave_`i'ul') (")") _tab %4.2f (`minimal_wave_`i'b') (" (") %4.2f (`minimal_wave_`i'll') ("-") %4.2f (`minimal_wave_`i'ul') (")") _tab %4.2f (`full_wave_`i'b') (" (") %4.2f (`full_wave_`i'll') ("-") %4.2f (`full_wave_`i'ul') (")") _n
}

foreach x of local period {
file write tablecontent ("`lab`x''") _n
stset exit_date`x'_death, fail(death_date`x') origin(index_date`x'_death) id(unique) scale(365.25)
qui stcox i.wave, vce(cluster practice_id)
matrix table = r(table)
local crude_wave_1b: display %4.2f table[1,2]
local crude_wave_1ll: display %4.2f table[5,2]
local crude_wave_1ul: display %4.2f table[6,2]
local crude_wave_2b: display %4.2f table[1,3]
local crude_wave_2ll: display %4.2f table[5,3]
local crude_wave_2ul: display %4.2f table[6,3]
local crude_wave_3b: display %4.2f table[1,4]
local crude_wave_3ll: display %4.2f table[5,4]
local crude_wave_3ul: display %4.2f table[6,4]
local crude_wave_4b: display %4.2f table[1,5]
local crude_wave_4ll: display %4.2f table[5,5]
local crude_wave_4ul: display %4.2f table[6,5]

qui stcox i.wave i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_wave_1b: display %4.2f table[1,2]
local minimal_wave_1ll: display %4.2f table[5,2]
local minimal_wave_1ul: display %4.2f table[6,2]
local minimal_wave_2b: display %4.2f table[1,3]
local minimal_wave_2ll: display %4.2f table[5,3]
local minimal_wave_2ul: display %4.2f table[6,3]
local minimal_wave_3b: display %4.2f table[1,4]
local minimal_wave_3ll: display %4.2f table[5,4]
local minimal_wave_3ul: display %4.2f table[6,4]
local minimal_wave_4b: display %4.2f table[1,5]
local minimal_wave_4ll: display %4.2f table[5,5]
local minimal_wave_4ul: display %4.2f table[6,5]

qui stcox i.wave i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)	
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

bysort wave: egen total_follow_up`x' = total(_t)
forvalues i=1/4 {
qui su total_follow_up`x' if wave==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
file write tablecontent ("`wave`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`crude_wave_`i'b') (" (") %4.2f (`crude_wave_`i'll') ("-") %4.2f (`crude_wave_`i'ul') (")") _tab %4.2f (`minimal_wave_`i'b') (" (") %4.2f (`minimal_wave_`i'll') ("-") %4.2f (`minimal_wave_`i'ul') (")") _tab %4.2f (`full_wave_`i'b') (" (") %4.2f (`full_wave_`i'll') ("-") %4.2f (`full_wave_`i'ul') (")") _n
}
}

file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n
file write tablecontent ("Overall") _n
use ./output/analysis_hospitalised.dta, clear

local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)

qui stcox i.covid_vax, vce(cluster practice_id)
matrix table = r(table)
local crude_vax_1b: display %4.2f table[1,2]
local crude_vax_1ll: display %4.2f table[5,2]
local crude_vax_1ul: display %4.2f table[6,2]
local crude_vax_2b: display %4.2f table[1,3]
local crude_vax_2ll: display %4.2f table[5,3]
local crude_vax_2ul: display %4.2f table[6,3]
local crude_vax_3b: display %4.2f table[1,4]
local crude_vax_3ll: display %4.2f table[5,4]
local crude_vax_3ul: display %4.2f table[6,4]
local crude_vax_4b: display %4.2f table[1,5]
local crude_vax_4ll: display %4.2f table[5,5]
local crude_vax_4ul: display %4.2f table[6,5]
local crude_vax_5b: display %4.2f table[1,6]
local crude_vax_5ll: display %4.2f table[5,6]
local crude_vax_5ul: display %4.2f table[6,6]

qui stcox i.covid_vax i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_vax_1b: display %4.2f table[1,2]
local minimal_vax_1ll: display %4.2f table[5,2]
local minimal_vax_1ul: display %4.2f table[6,2]
local minimal_vax_2b: display %4.2f table[1,3]
local minimal_vax_2ll: display %4.2f table[5,3]
local minimal_vax_2ul: display %4.2f table[6,3]
local minimal_vax_3b: display %4.2f table[1,4]
local minimal_vax_3ll: display %4.2f table[5,4]
local minimal_vax_3ul: display %4.2f table[6,4]
local minimal_vax_4b: display %4.2f table[1,5]
local minimal_vax_4ll: display %4.2f table[5,5]
local minimal_vax_4ul: display %4.2f table[6,5]
local minimal_vax_5b: display %4.2f table[1,6]
local minimal_vax_5ll: display %4.2f table[5,6]
local minimal_vax_5ul: display %4.2f table[6,6]

qui stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)	
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
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
file write tablecontent ("`vax`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`crude_vax_`i'b') (" (") %4.2f (`crude_vax_`i'll') ("-") %4.2f (`crude_vax_`i'ul') (")") _tab %4.2f (`minimal_vax_`i'b') (" (") %4.2f (`minimal_vax_`i'll') ("-") %4.2f (`minimal_vax_`i'ul') (")") _tab %4.2f (`full_vax_`i'b') (" (") %4.2f (`full_vax_`i'll') ("-") %4.2f (`full_vax_`i'ul') (")") _n
}

foreach x of local period {
file write tablecontent ("`lab`x''") _n
stset exit_date`x'_death, fail(death_date`x') origin(index_date`x'_death) id(unique) scale(365.25)
qui stcox i.covid_vax, vce(cluster practice_id)
matrix table = r(table)
local crude_vax_1b: display %4.2f table[1,2]
local crude_vax_1ll: display %4.2f table[5,2]
local crude_vax_1ul: display %4.2f table[6,2]
local crude_vax_2b: display %4.2f table[1,3]
local crude_vax_2ll: display %4.2f table[5,3]
local crude_vax_2ul: display %4.2f table[6,3]
local crude_vax_3b: display %4.2f table[1,4]
local crude_vax_3ll: display %4.2f table[5,4]
local crude_vax_3ul: display %4.2f table[6,4]
local crude_vax_4b: display %4.2f table[1,5]
local crude_vax_4ll: display %4.2f table[5,5]
local crude_vax_4ul: display %4.2f table[6,5]
local crude_vax_5b: display %4.2f table[1,6]
local crude_vax_5ll: display %4.2f table[5,6]
local crude_vax_5ul: display %4.2f table[6,6]

qui stcox i.covid_vax i.sex age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local minimal_vax_1b: display %4.2f table[1,2]
local minimal_vax_1ll: display %4.2f table[5,2]
local minimal_vax_1ul: display %4.2f table[6,2]
local minimal_vax_2b: display %4.2f table[1,3]
local minimal_vax_2ll: display %4.2f table[5,3]
local minimal_vax_2ul: display %4.2f table[6,3]
local minimal_vax_3b: display %4.2f table[1,4]
local minimal_vax_3ll: display %4.2f table[5,4]
local minimal_vax_3ul: display %4.2f table[6,4]
local minimal_vax_4b: display %4.2f table[1,5]
local minimal_vax_4ll: display %4.2f table[5,5]
local minimal_vax_4ul: display %4.2f table[6,5]
local minimal_vax_5b: display %4.2f table[1,6]
local minimal_vax_5ll: display %4.2f table[5,6]
local minimal_vax_5ul: display %4.2f table[6,6]

qui stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)	
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

bysort covid_vax: egen total_follow_up`x' = total(_t)
forvalues i=1/5 {
qui su total_follow_up`x' if covid_vax==`i'
local cases`i'_py = r(mean)
local cases`i'_multip = 100000 / r(mean)
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ul = `cases`i'_rate' + (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
local cases`i'_ll = `cases`i'_rate' - (1.96*sqrt(`cases`i'_rate' / `cases`i'_multip'))
file write tablecontent ("`vax`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab _tab  %4.2f (`crude_vax_`i'b') (" (") %4.2f (`crude_vax_`i'll') ("-") %4.2f (`crude_vax_`i'ul') (")") _tab %4.2f (`minimal_vax_`i'b') (" (") %4.2f (`minimal_vax_`i'll') ("-") %4.2f (`minimal_vax_`i'ul') (")") _tab %4.2f (`full_vax_`i'b') (" (") %4.2f (`full_vax_`i'll') ("-") %4.2f (`full_vax_`i'ul') (")") _n
}
}