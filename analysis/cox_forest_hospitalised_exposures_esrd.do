sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_hospitalised_exposures_esrd.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_hospitalised_exposures_esrd.csv, write text replace
file write tablecontent ("stratum") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("rate_text") _tab ("rate") _tab ("rate_ll") _tab ("rate_ul") _tab ("ard_text") _tab ("ard") _tab ("ard_ll") _tab ("ard_ul") _n
use ./output/analysis_hospitalised.dta, clear

rename covid_vax covvax

local wave1 "COVID-19 Feb20-Aug20"
local wave2 "COVID-19 Sep20-Jun21"
local wave3 "COVID-19 Jul21-Nov21"
local wave4 "COVID-19 Dec21-Dec22"

local covvax1 "COVID-19 pre-vaccination"
local covvax2 "COVID-19 1 vaccination dose"
local covvax3 "COVID-19 2 vaccination doses"
local covvax4 "COVID-19 3 vaccination doses"
local covvax5 "COVID-19 4 vaccination doses"

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

**By COVID wave
*Rates
forvalues i=1/4 {
bysort wave: egen total_follow_up = total(_t)
qui su total_follow_up if wave==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'wave_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'wave_ul = `cases`i'wave_rate' * `cases`i'_ef'
local cases`i'wave_ll = `cases`i'wave_rate' / `cases`i'_ef'
}

*HR
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

*Adjusted rate difference
forvalues i=1/4 {
local ard`i'wave_b: di %3.2f `cases`i'wave_rate' - ((1/`full_wave_`i'b') * `cases`i'wave_rate')
local ard`i'wave_ll: di %3.2f `cases`i'wave_rate' - ((1/`full_wave_`i'll') * `cases`i'wave_rate')
local ard`i'wave_ul: di %3.2f `cases`i'wave_rate' - ((1/`full_wave_`i'ul') * `cases`i'wave_rate')
}


**By COVID vaccination status
*Rates
forvalues i=1/5 {
bysort covvax: egen total_follow_up = total(_t)
qui su total_follow_up if covvax==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if covvax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'covvax_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'covvax_ul = `cases`i'covvax_rate' * `cases`i'_ef'
local cases`i'covvax_ll = `cases`i'covvax_rate' / `cases`i'_ef'
}

*HR
qui stcox i.covvax i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_covvax_1b: display %4.2f table[1,2]
local full_covvax_1ll: display %4.2f table[5,2]
local full_covvax_1ul: display %4.2f table[6,2]
local full_covvax_2b: display %4.2f table[1,3]
local full_covvax_2ll: display %4.2f table[5,3]
local full_covvax_2ul: display %4.2f table[6,3]
local full_covvax_3b: display %4.2f table[1,4]
local full_covvax_3ll: display %4.2f table[5,4]
local full_covvax_3ul: display %4.2f table[6,4]
local full_covvax_4b: display %4.2f table[1,5]
local full_covvax_4ll: display %4.2f table[5,5]
local full_covvax_4ul: display %4.2f table[6,5]
local full_covvax_5b: display %4.2f table[1,6]
local full_covvax_5ll: display %4.2f table[5,6]
local full_covvax_5ul: display %4.2f table[6,6]

*Adjusted rate difference
forvalues i=1/5 {
local ard`i'covvax_b: di %3.2f `cases`i'covvax_rate' - ((1/`full_covvax_`i'b') * `cases`i'covvax_rate')
local ard`i'covvax_ll: di %3.2f `cases`i'covvax_rate' - ((1/`full_covvax_`i'll') * `cases`i'covvax_rate')
local ard`i'covvax_ul: di %3.2f `cases`i'covvax_rate' - ((1/`full_covvax_`i'ul') * `cases`i'covvax_rate')
}

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _tab %4.2f (`full_wave_`i'b') (" (") %4.2f (`full_wave_`i'll') ("-") %4.2f (`full_wave_`i'ul') (")") _tab %4.2f (`full_wave_`i'b') _tab %4.2f (`full_wave_`i'll') _tab (`full_wave_`i'ul') _tab ("`cases`i'wave_rate'") (" (") %3.2f (`cases`i'wave_ll')  ("-") %3.2f (`cases`i'wave_ul') (")")  _tab ("`cases`i'wave_rate'") _tab ("`cases`i'wave_ll'") _tab ("`cases`i'wave_ul'") _tab ("`ard`i'wave_b'") (" (") %3.2f (`ard`i'wave_ll')  ("-") %3.2f (`ard`i'wave_ul') (")") _tab ("`ard`i'wave_b'") _tab ("`ard`i'wave_ll'") _tab ("`ard`i'wave_ul'") _n
}
forvalues i=1/5 {
file write tablecontent ("`covvax`i''") _tab %4.2f (`full_covvax_`i'b') (" (") %4.2f (`full_covvax_`i'll') ("-") %4.2f (`full_covvax_`i'ul') (")") _tab %4.2f (`full_covvax_`i'b') _tab %4.2f (`full_covvax_`i'll') _tab (`full_covvax_`i'ul') _tab ("`cases`i'covvax_rate'") (" (") %3.2f (`cases`i'covvax_ll')  ("-") %3.2f (`cases`i'covvax_ul') (")")  _tab ("`cases`i'covvax_rate'") _tab ("`cases`i'covvax_ll'") _tab ("`cases`i'covvax_ul'") _tab ("`ard`i'covvax_b'") (" (") %3.2f (`ard`i'covvax_ll')  ("-") %3.2f (`ard`i'covvax_ul') (")") _tab ("`ard`i'covvax_b'") _tab ("`ard`i'covvax_ll'") _tab ("`ard`i'covvax_ul'") _n
}

file close tablecontent