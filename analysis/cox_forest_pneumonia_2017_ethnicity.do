clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_pneumonia_2017_ethnicity.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_pneumonia_2017_ethnicity.csv, write text replace
file write tablecontent _tab ("HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n


local outcomes "esrd krt chronic_krt egfr_half aki death"

local esrd_lab "Kidney failure"
local chronic_krt_lab "Kidney failure (excluding acute KRT)"
local krt_lab "Kidney replacement therapy"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

use ./output/analysis_pneumonia_2017.dta, clear

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

file write tablecontent ("Fully-adjusted (non-stratified)") _n

foreach out of local outcomes {

qui stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

file write tablecontent ("``out'_lab'") _n

forvalues i=1/5 {
local label_`i': label ethnicity `i'
}

qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
est store a
qui stcox i.case##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
lincom 1.case + 1.case#`i'.ethnicity, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _tab %5.4f (`p') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}
}

use ./output/analysis_pneumonia_2017_complete.dta, clear

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


file write tablecontent ("Fully-adjusted (stratified)") _n

foreach out of local outcomes {

qui stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

file write tablecontent ("``out'_lab'") _n

forvalues i=1/5 {
local label_`i': label ethnicity `i'
}

qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
lincom 1.case + 1.case#`i'.ethnicity, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _tab %5.4f (`p') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}
}

file close tablecontent