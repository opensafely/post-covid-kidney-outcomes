clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2017_ethnicity_severity.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2017_ethnicity_severity.csv, write text replace
file write tablecontent _tab ("model") _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n

use ./output/analysis_complete_2017.dta, clear
replace covid_severity=2 if covid_severity==3

local outcomes "esrd krt chronic_krt egfr_half aki death"

local esrd_lab "Kidney failure"
local chronic_krt_lab "Kidney failure (excluding acute KRT)"
local krt_lab "Kidney replacement therapy"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

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
replace exit_date_chronic_krt = min(deregistered_date, death_date, end_date) if chronic_krt_date==.
gen index_date_chronic_krt = index_date

forvalues i=1/5 {
local label_`i': label ethnicity `i'
}

foreach out of local outcomes {

qui stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)

*Obtain p-values for interaction
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.ethnicity, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}
file write tablecontent ("``out'_lab'") _tab _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab ("Conditional") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''") _tab ("Conditional") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&bmi!=.&smoking!=., cubic nknots(4)


*Obtain p-values for interaction
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp
est store a
qui stcox i.covid_severity##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3 i.sex i.stp
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.ethnicity, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}
file write tablecontent ("``out'_lab'") _tab _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab ("Frequency") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''") _tab ("Frequency") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}
}

file close tablecontent