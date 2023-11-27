clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2017_covid_severity_esrd.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2017_covid_severity_esrd.csv, write text replace
file write tablecontent _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n

use ./output/analysis_complete_2017.dta, clear
replace covid_severity=2 if covid_severity==3

*Age group
forvalues j=1/2 {
local label`j': label covid_severity `j'
forvalues i=1/6 {
local label_`i': label agegroup `i'
}
}
*Obtain p-values for interaction
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/6 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.agegroup, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}

file write tablecontent ("Age") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/6 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

*Sex
forvalues i=0/1 {
local label_`i': label sex `i'
}
*Obtain p-values for interaction
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=0/1 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.sex, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}

file write tablecontent ("Sex") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_0'") _tab %4.2f (`int_`j'0b') (" (") %4.2f (`int_`j'0ll') ("-") %4.2f (`int_`j'0ul') (")") _tab %4.2f (`int_`j'0b') _tab %4.2f (`int_`j'0ll') _tab %4.2f (`int_`j'0ul') _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
}


*Ethnicity
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
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
file write tablecontent ("Ethnicity") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

*IMD
forvalues i=1/5 {
local label_`i': label imd `i'
}
*Obtain p-values for interaction
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.imd, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}

file write tablecontent ("Index of multiple deprivation") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

*Diabetes
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
forvalues i=0/1 {
local label_`i': label diabetes `i'
}
*Obtain p-values for interaction
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=0/1 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.diabetes, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}

file write tablecontent ("Diabetes") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_0'") _tab %4.2f (`int_`j'0b') (" (") %4.2f (`int_`j'0ll') ("-") %4.2f (`int_`j'0ul') (")") _tab %4.2f (`int_`j'0b') _tab %4.2f (`int_`j'0ll') _tab %4.2f (`int_`j'0ul') _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
}



*Baseline eGFR
forvalues i=1/7 {
local label_`i': label egfr_group `i'
}
*Obtain p-values for interaction
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.egfr_group i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.egfr_group i.imd i.ethnicity i.urban i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/2 {
forvalues i=1/7 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.egfr_group, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}


file write tablecontent ("Baseline eGFR") _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/2 {
file write tablecontent ("`label`j''") _n
file write tablecontent ("`label_1'") _tab %4.2f (`int_`j'1b') (" (") %4.2f (`int_`j'1ll') ("-") %4.2f (`int_`j'1ul') (")") _tab %4.2f (`int_`j'1b') _tab %4.2f (`int_`j'1ll') _tab %4.2f (`int_`j'1ul') _n
forvalues i=2/7 {
file write tablecontent ("`label_`i''") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _tab %4.2f (`int_`j'`i'b') _tab %4.2f (`int_`j'`i'll') _tab %4.2f (`int_`j'`i'ul') _n
}
}

file close tablecontent
