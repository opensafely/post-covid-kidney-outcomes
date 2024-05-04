sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_asthma_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_forest_asthma_2017.csv, write text replace
file write tablecontent ("model") _tab ("outcome") _tab ("stratum") _tab ("period") _tab ("hr_text") _tab ("hr") _tab ("ll") _tab ("ul") _n
use ./output/analysis_asthma_2017_complete.dta, clear

*ESRD = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.

*ESRD redefined by not including KRT codes 28 days before index date
gen chronic_krt_date = date(krt_outcome2_date, "YMD")
format chronic_krt_date %td
drop krt_outcome2_date
replace chronic_krt_date = egfr15_date if egfr15_date < chronic_krt_date
replace chronic_krt_date=egfr15_date if chronic_krt_date==.
gen exit_date_chronic_krt = chronic_krt_date
format exit_date_chronic_krt %td
replace exit_date_chronic_krt = min(deregistered_date, death_date, end_date, covid_exit) if chronic_krt_date==.
replace exit_date_chronic_krt = covid_exit if covid_exit < chronic_krt_date
replace chronic_krt_date=. if covid_exit<chronic_krt_date&case==0
gen index_date_chronic_krt = index_date

local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

local outcomes "krt chronic_krt"

foreach out of local outcomes {

gen `out'_date29 = `out'_date if `out'_date < (index_date_`out' + 30) 
gen exit_date29_`out' = `out'_date29
gen index_date29_`out' = index_date_`out'
format exit_date29_`out' %td
replace exit_date29_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 29)) if `out'_date29==.

*30-89 days
gen `out'_date89 = `out'_date if `out'_date < (index_date_`out' + 90) 
gen exit_date89_`out' = `out'_date89
gen index_date89_`out' = index_date_`out' + 30
format exit_date89_`out' %td
replace exit_date89_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 89)) if `out'_date89==.

*90-179 days
gen `out'_date179 = `out'_date if `out'_date < (index_date_`out' + 180) 
gen exit_date179_`out' = `out'_date179
gen index_date179_`out' = index_date_`out' + 90
format exit_date179_`out' %td
replace exit_date179_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 179)) if `out'_date179==.

*180+ days
gen index_datemax_`out' = index_date_`out' + 180
gen exit_datemax_`out' = exit_date_`out'
gen `out'_datemax = `out'_date
}

local outcomes "esrd krt chronic_krt egfr_half aki death"

local esrd_lab "Kidney failure"
local chronic_krt_lab "Kidney failure (excluding acute KRT)"
local krt_lab "Kidney replacement therapy"
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

file write tablecontent ("Conditional") _tab ("``out'_lab'") _tab ("COVID-19 overall") _tab ("Overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n

*Stratified by time to event
foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)

**COVID overall

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

file write tablecontent ("Conditional") _tab ("``out'_lab'") _tab ("COVID-19 overall") _tab ("`lab`x''") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n
}

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&bmi!=.&smoking!=., cubic nknots(4)

**Frequency matched analysis (i.e. not stratified by matched set)

**COVID overall

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

file write tablecontent ("Frequency") _tab ("``out'_lab'") _tab ("COVID-19 overall") _tab ("Overall") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n

*Stratified by time to event
foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)

**COVID overall

*HR
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,2]
local full_overall_ll: display %4.2f table[5,2]
local full_overall_ul: display %4.2f table[6,2]

file write tablecontent ("Frequency") _tab ("``out'_lab'") _tab ("COVID-19 overall") _tab ("`lab`x''") _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %4.2f (`full_overall_b') _tab %4.2f (`full_overall_ll') _tab (`full_overall_ul') _n
}
}



file close tablecontent