sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2017_sens.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_2017_sens.csv, write text replace
file write tablecontent ("sens") _tab ("outcome") _tab ("stratum") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("rate_text") _tab ("rate") _tab ("rate_ll") _tab ("rate_ul") _tab ("ard_text") _tab ("ard") _tab ("ard_ll") _tab ("ard_ul") _n
use ./output/analysis_complete_2017.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"


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


*Sensivity analysis 2 = 30% reduction in eGFR
* 30% eGFR reduction (earliest month) (or ESRD)
gen egfr_30pc_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year {
  replace egfr_30pc_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_30pc_date==.& egfr_creatinine_`x'<0.7*baseline_egfr & date("01`x'", "DMY")>index_date
  format egfr_30pc_date %td
}
replace egfr_30pc_date=esrd_date if egfr_30pc_date==.
* Index date (50% eGFR reduction)
gen index_date_egfr_30pc = index_date
replace index_date_egfr_30pc =. if baseline_egfr==.
* Exit date (50% eGFR reduction)
gen exit_date_egfr_30pc = egfr_30pc_date
format exit_date_egfr_30pc %td
replace exit_date_egfr_30pc = min(deregistered_date,death_date,end_date) if egfr_30pc_date==. & index_date_egfr_30pc!=.
gen follow_up_time_egfr_30pc = (exit_date_egfr_30pc - index_date_egfr_30pc)

*Sensivity analysis 3 - outcome = ESRD + eGFR <30
drop if baseline_egfr <30
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n
gen egfr30_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year  {
  replace egfr30_date=date("15`x'", "DMY") if egfr30_date==.& egfr_creatinine_`x'<30 & date("01`x'", "DMY")>index_date
}
format egfr30_date %td
* CKD4 date
gen index_date_ckd4 = index_date
gen ckd4_date = egfr30_date
format ckd4_date %td
replace ckd4_date = krt_date if ckd4_date==.
gen exit_date_ckd4 = ckd4_date
format exit_date_ckd4 %td
replace exit_date_ckd4 = min(deregistered_date, death_date, end_date) if ckd4_date==.
gen follow_up_time_ckd4 = (exit_date_ckd4 - index_date_ckd4)
label var follow_up_time_ckd4 "Follow-up time (Days)"
gen follow_up_cat_ckd4 = follow_up_time_ckd4
recode follow_up_cat_ckd4	min/-29=1 	///
						-28/-1=2 	///
						0=3			///
						1/365=4 	///
						366/730=5	///
						731/1040=6	///					
						1041/max=7
label define follow_up_cat_ckd4 	1 "<-29 days" 	///
							2 "-28 to -1 days" 		///
							3 "0 days"				///
							4 "1 to 365 days"		///
							5 "366 to 730 days" 	///
							6 "731 to 1040 days"	///
							7 ">1040 days"
label values follow_up_cat_ckd4 follow_up_cat_ckd4
label var follow_up_cat_ckd4 "Follow_up time"
tab case follow_up_cat_ckd4
tab covid_krt follow_up_cat_ckd4
drop if follow_up_time_ckd4<1
drop if follow_up_time_ckd4>1040
tab case follow_up_cat_ckd4
tab covid_krt follow_up_cat_ckd4
gen follow_up_years_ckd4 = follow_up_time_ckd4/365.25


local sensitivity "krt egfr_30pc ckd4"

local krt_lab "Kidney replacement therapy"
local egfr_30pc_lab "30% reduction in eGFR"
local ckd4_lab "eGFR <30ml/min/1.73m2"

local krt_sens "Sensitivity analysis 1"
local egfr_30pc_sens "Sensitivity analysis 2"
local ckd4_sens "Sensitivity analysis 3"

foreach sens of local sensitivity {

stset exit_date_`sens', fail(`sens'_date) origin(index_date_`sens') id(unique) scale(365.25)

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
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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
forvalues i=1/2 {
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}

*HR
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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

file write tablecontent ("``sens'_sens'") _tab ("``sens'_lab'") _tab ("COVID-19 overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab %4.2f (`full_overall_ul') _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab ("`cases_ll'") _tab ("`cases_ul'") _tab ("`ard_b'") (" (") %3.2f (`ard_ll')  ("-") %3.2f (`ard_ul') (")") _tab ("`ard_b'") _tab ("`ard_ll'") _tab ("`ard_ul'") _n

forvalues i=1/2 {
file write tablecontent ("``sens'_sens'") _tab ("``sens'_lab'") _tab ("`severity`i''") _tab %4.2f (`full_severity_`i'b') (" (") %4.2f (`full_severity_`i'll') ("-") %4.2f (`full_severity_`i'ul') (")") _tab %4.2f (`full_severity_`i'b') _tab %4.2f (`full_severity_`i'll') _tab %4.2f (`full_severity_`i'ul') _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab ("`cases`i'_rate'") _tab ("`cases`i'_ll'") _tab ("`cases`i'_ll'") _tab ("`ard`i'_b'") (" (") %3.2f (`ard`i'_ll')  ("-") %3.2f (`ard`i'_ul') (")") _tab ("`ard`i'_b'") _tab ("`ard`i'_ll'") _tab ("`ard`i'_ul'") _n
}
}

*Sensivity analysis 4 - multiple imputation for missing ethnicity
use ./output/analysis_2017.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3

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
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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
forvalues i=1/2 {
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'_ul = `cases`i'_rate' * `cases`i'_ef'
local cases`i'_ll = `cases`i'_rate' / `cases`i'_ef'
}

*HR
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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

file write tablecontent ("Sensitivity analysis 4") _tab ("Kidney failure (after multiple imputation for missing ethnicity)") _tab ("COVID-19 overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab %4.2f (`full_overall_ul') _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`cases_rate'") _tab ("`cases_ll'") _tab ("`cases_ul'") _tab ("`ard_b'") (" (") %3.2f (`ard_ll')  ("-") %3.2f (`ard_ul') (")") _tab ("`ard_b'") _tab ("`ard_ll'") _tab ("`ard_ul'") _n

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 4") _tab ("Kidney failure (after multiple imputation for missing ethnicity)") _tab ("`severity`i''") _tab %4.2f (`full_severity_`i'b') (" (") %4.2f (`full_severity_`i'll') ("-") %4.2f (`full_severity_`i'ul') (")") _tab %4.2f (`full_severity_`i'b') _tab %4.2f (`full_severity_`i'll') _tab %4.2f (`full_severity_`i'ul') _tab ("`cases`i'_rate'") (" (") %3.2f (`cases`i'_ll')  ("-") %3.2f (`cases`i'_ul') (")")  _tab ("`cases`i'_rate'") _tab ("`cases`i'_ll'") _tab ("`cases`i'_ll'") _tab ("`ard`i'_b'") (" (") %3.2f (`ard`i'_ll')  ("-") %3.2f (`ard`i'_ul') (")") _tab ("`ard`i'_b'") _tab ("`ard`i'_ll'") _tab ("`ard`i'_ul'") _n
}

file close tablecontent