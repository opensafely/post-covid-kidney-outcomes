sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_asthma_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_asthma_2017.csv, write text replace
file write tablecontent ("outcome") _tab ("stratum") _tab ("period") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _n
use ./output/analysis_complete_2017.dta, clear

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

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

*Stratified by time to event
foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)

**COVID overall

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b`x': display %4.2f table[1,2]
local full_overall_ll`x': display %4.2f table[5,2]
local full_overall_ul`x': display %4.2f table[6,2]

file write tablecontent ("``out'_lab'") _tab ("COVID-19 overall") _tab ("Overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _n

foreach x of local period {
file write tablecontent ("``out'_lab'") _tab ("COVID-19 overall") _tab ("`lab`x''") _tab %4.2f (`full_overall_b`x'') (" (") %4.2f (`full_overall_ll`x'') ("-") %4.2f (`full_overall_ul`x'') (")") _tab %4.2f (`full_overall_b`x'') _tab %4.2f (`full_overall_ll`x'') _tab (`full_overall_ul`x'') _tab ("`cases_rate`x''") (" (") %3.2f (`cases_ll`x'')  ("-") %3.2f (`cases_ul`x'') (")") _n
}

}
}


file close tablecontent