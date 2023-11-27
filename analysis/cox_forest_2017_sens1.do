sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2017_sens1.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_2017_sens1.csv, write text replace
file write tablecontent _tab ("Rate (/100000 person years) (95% CI)") _tab ("rate") _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _n
file write tablecontent ("COVID-19 overall") _tab
use ./output/analysis_complete_2017.dta, clear

*Sensivity analysis 1 = eGFR = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.
gen follow_up_time_krt = (exit_date_krt - index_date_krt)
label var follow_up_time_krt "Follow-up time (Days)"
gen follow_up_cat_krt = follow_up_time_krt
recode follow_up_cat_krt	min/-29=1 	///
						-28/-1=2 	///
						0=3			///
						1/365=4 	///
						366/730=5	///
						731/1040=6	///					
						1041/max=7
label define follow_up_cat_krt 	1 "<-29 days" 	///
							2 "-28 to -1 days" 		///
							3 "0 days"				///
							4 "1 to 365 days"		///
							5 "366 to 730 days" 	///
							6 "731 to 1040 days"	///
							7 ">1040 days"
label values follow_up_cat_krt follow_up_cat_krt
label var follow_up_cat_krt "Follow_up time"
tab case follow_up_cat_krt
tab covid_krt follow_up_cat_krt
drop if follow_up_time_krt<1
drop if follow_up_time_krt>1040
tab case follow_up_cat_krt
tab covid_krt follow_up_cat_krt
gen follow_up_years_krt = follow_up_time_krt/365.25

stset exit_date_krt, fail(krt_date) origin(index_date_krt) id(unique) scale(365.25)
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
file write tablecontent _n


file write tablecontent ("By COVID-19 wave") _n

local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

qui stcox i.wave i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)	
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

drop total_follow_up
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

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_wave_`i'b') (" (") %4.2f (`full_wave_`i'll') ("-") %4.2f (`full_wave_`i'ul') (")") _tab %4.2f (`full_wave_`i'b') _tab %4.2f (`full_wave_`i'll') _tab (`full_wave_`i'ul') _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n

local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

qui stcox i.covid_vax i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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

drop total_follow_up
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

forvalues i=1/5 {
file write tablecontent ("`vax`i''") _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")") _tab ("`cases`i'_rate'")  _tab %4.2f (`full_vax_`i'b') (" (") %4.2f (`full_vax_`i'll') ("-") %4.2f (`full_vax_`i'ul') (")") _tab %4.2f (`full_vax_`i'b') _tab %4.2f (`full_vax_`i'll') _tab (`full_vax_`i'ul') _n
}
file close tablecontent