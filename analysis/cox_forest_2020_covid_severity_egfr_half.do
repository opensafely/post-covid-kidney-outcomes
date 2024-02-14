clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_covid_severity_egfr_half.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_covid_severity_egfr_half.csv, write text replace
file write tablecontent _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n

use ./output/analysis_complete_2020.dta, clear
replace covid_severity=2 if covid_severity==3


*COVID-19 wave

use ./output/analysis_complete_2020.dta, clear

replace covid_severity=2 if covid_severity==3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)

file write tablecontent ("COVID-19 wave") _n
forvalues i=1/4 {
local label_`i': label wave `i'
}
qui stcox i.covid_severity i.wave i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.wave i.covid_vax i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/4 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.wave, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}


file write tablecontent ("COVID-19 wave") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
forvalues i=1/4 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

*COVID-19 wave (cases up to March 2022)
file write tablecontent ("COVID-19 wave (cases up to March 2022)") _n
use ./output/analysis_complete_2020.dta, clear
drop if index_date_egfr_half > 22735
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

replace covid_severity=2 if covid_severity==3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)

forvalues i=1/4 {
local label_`i': label wave `i'
}
qui stcox i.covid_severity i.wave i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.wave i.covid_vax i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/4 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.wave, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}


file write tablecontent ("COVID-19 wave (cases up to March 2022)") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
forvalues i=1/4 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

file close tablecontent
