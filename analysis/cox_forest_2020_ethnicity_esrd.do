clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_ethnicity_esrd.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_ethnicity_esrd.csv, write text replace
file write tablecontent _tab ("HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n

use ./output/analysis_complete_2020.dta, clear

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

file write tablecontent ("Minimally-adjusted") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
qui stcox i.case i.ethnicity, strata(set_id)
est store a
qui stcox i.case##i.ethnicity, strata(set_id)
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


file write tablecontent ("After adjustment for potential mediators") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}

qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
est store a
qui stcox i.case##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
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


file close tablecontent