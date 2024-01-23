clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_ethnicity_esrd_wave.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_ethnicity_esrd_wave.csv, write text replace
file write tablecontent ("Ethnicity") _tab ("Wave") _tab ("HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _n

use ./output/analysis_complete_2020.dta, clear

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

file write tablecontent ("Minimally-adjusted") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
forvalues j=1/4 {
local wave_`j': label wave `j'
}
qui stcox i.case##i.ethnicity##i.wave, strata(set_id)
forvalues j=1/4 {
forvalues i=1/5 {
lincom 1.case + 1.case#`i'.ethnicity#`j'.wave, eform
local int_`i'`j'b = r(estimate)
local int_`i'`j'll = r(lb)
local int_`i'`j'ul = r(ub)
}
}
forvalues j = 1/4 {
forvalues i=1/5 {
file write tablecontent ("`label_`i''") _tab ("`wave_`j''") _tab %4.2f (`int_`i'`j'b') (" (") %4.2f (`int_`i'`j'll') ("-") %4.2f (`int_`i'`j'ul') (")") _tab %4.2f (`int_`i'`j'b') _tab %4.2f (`int_`i'`j'll') _tab %4.2f (`int_`i'`j'ul') _n
}
}


file write tablecontent ("Fully-adjusted") _n

forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
forvalues j=1/4 {
local wave_`j': label wave `j'
}
qui stcox i.case##i.ethnicity##i.wave i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
forvalues j=1/4 {
forvalues i=1/5 {
lincom 1.case + 1.case#`i'.ethnicity#`j'.wave, eform
local int_`i'`j'b = r(estimate)
local int_`i'`j'll = r(lb)
local int_`i'`j'ul = r(ub)
}
}
forvalues j = 1/4 {
forvalues i=1/5 {
file write tablecontent ("`label_`i''") _tab ("`wave_`j''") _tab %4.2f (`int_`i'`j'b') (" (") %4.2f (`int_`i'`j'll') ("-") %4.2f (`int_`i'`j'ul') (")") _tab %4.2f (`int_`i'`j'b') _tab %4.2f (`int_`i'`j'll') _tab %4.2f (`int_`i'`j'ul') _n
}
}

file close tablecontent