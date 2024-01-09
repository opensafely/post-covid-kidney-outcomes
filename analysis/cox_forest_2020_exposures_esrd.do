sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_exposures_esrd.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_exposures_esrd.csv, write text replace
file write tablecontent ("stratum") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("rate_text") _tab ("rate") _tab ("rate_ll") _tab ("rate_ul") _tab ("ard_text") _tab ("ard") _tab ("ard_ll") _tab ("ard_ul") _n
use ./output/analysis_complete_2020.dta, clear

rename covid_severity covsev
rename covid_aki covaki
rename covid_vax covvax

local exposure "covsev covaki"

local covsev1 "COVID-19 non-hospitalised"
local covsev2 "COVID-19 hospitalised ward-based"
local covsev3 "COVID-19 hospitalised ICU"
local covaki1 "COVID-19 non-hospitalised"
local covaki2 "COVID-19 hospitalised without AKI"
local covaki3 "COVID-19 hospitalised with AKI"


stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

**By COVID severity
*Rates
foreach exp of local exposure {
forvalues i=1/3 {
bysort `exp': egen total_follow_up = total(_t)
qui su total_follow_up if `exp'==`i'
local cases`i'_multip = 100000 / r(mean)
drop total_follow_up
qui safecount if `exp'==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
local cases`i'`exp'_rate : di %3.2f (`cases`i'_events' * `cases`i'_multip')
local cases`i'_ef = exp(1.96/(sqrt(`cases`i'_events')))
local cases`i'`exp'_ul = `cases`i'`exp'_rate' * `cases`i'_ef'
local cases`i'`exp'_ll = `cases`i'`exp'_rate' / `cases`i'_ef'
}

*HR
qui stcox i.`exp' i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_`exp'_1b: display %4.2f table[1,2]
local full_`exp'_1ll: display %4.2f table[5,2]
local full_`exp'_1ul: display %4.2f table[6,2]
local full_`exp'_2b: display %4.2f table[1,3]
local full_`exp'_2ll: display %4.2f table[5,3]
local full_`exp'_2ul: display %4.2f table[6,3]
local full_`exp'_3b: display %4.2f table[1,4]
local full_`exp'_3ll: display %4.2f table[5,4]
local full_`exp'_3ul: display %4.2f table[6,4]

*Adjusted rate difference
forvalues i=1/3 {
local ard`i'`exp'_b: di %3.2f `cases`i'`exp'_rate' - ((1/`full_`exp'_`i'b') * `cases`i'`exp'_rate')
local ard`i'`exp'_ll: di %3.2f `cases`i'`exp'_rate' - ((1/`full_`exp'_`i'll') * `cases`i'`exp'_rate')
local ard`i'`exp'_ul: di %3.2f `cases`i'`exp'_rate' - ((1/`full_`exp'_`i'ul') * `cases`i'`exp'_rate')
}
}


forvalues i=1/3 {
file write tablecontent ("`covsev`i''") _tab %4.2f (`full_covsev_`i'b') (" (") %4.2f (`full_covsev_`i'll') ("-") %4.2f (`full_covsev_`i'ul') (")") _tab %4.2f (`full_covsev_`i'b') _tab %4.2f (`full_covsev_`i'll') _tab (`full_covsev_`i'ul') _tab ("`cases`i'covsev_rate'") (" (") %3.2f (`cases`i'covsev_ll')  ("-") %3.2f (`cases`i'covsev_ul') (")")  _tab ("`cases`i'covsev_rate'") _tab ("`cases`i'covsev_ll'") _tab ("`cases`i'covsev_ul'") _tab ("`ard`i'covsev_b'") (" (") %3.2f (`ard`i'covsev_ll')  ("-") %3.2f (`ard`i'covsev_ul') (")") _tab ("`ard`i'covsev_b'") _tab ("`ard`i'covsev_ll'") _tab ("`ard`i'covsev_ul'") _n
}
forvalues i=2/3 {
file write tablecontent ("`covaki`i''") _tab %4.2f (`full_covaki_`i'b') (" (") %4.2f (`full_covaki_`i'll') ("-") %4.2f (`full_covaki_`i'ul') (")") _tab %4.2f (`full_covaki_`i'b') _tab %4.2f (`full_covaki_`i'll') _tab (`full_covaki_`i'ul') _tab ("`cases`i'covaki_rate'") (" (") %3.2f (`cases`i'covaki_ll')  ("-") %3.2f (`cases`i'covaki_ul') (")")  _tab ("`cases`i'covaki_rate'") _tab ("`cases`i'covaki_ll'") _tab ("`cases`i'covaki_ul'") _tab ("`ard`i'covaki_b'") (" (") %3.2f (`ard`i'covaki_ll')  ("-") %3.2f (`ard`i'covaki_ul') (")") _tab ("`ard`i'covaki_b'") _tab ("`ard`i'covaki_ll'") _tab ("`ard`i'covaki_ul'") _n
}



file close tablecontent