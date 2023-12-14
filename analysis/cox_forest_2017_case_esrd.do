clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2017_case_esrd.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2017_case_esrd.csv, write text replace
file write tablecontent _tab ("Fully-adjusted HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _tab ("p-value for interaction") _n

use ./output/analysis_complete_2017.dta, clear

*Age group
file write tablecontent ("Age") _n
forvalues i=1/6 {
local label_`i': label agegroup `i'
}
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.case i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
*return list
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/6 {
lincom 1.case + 1.case#`i'.agegroup, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}

file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _tab %5.4f (`p') _n
forvalues i=2/6 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues i=0/1 {
local label_`i': label sex `i'
}
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_0b = r(estimate)
local int_0ll = r(lb)
local int_0ul = r(ub)
lincom 1.case + 1.case#1.sex, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
file write tablecontent ("`label_0'")
file write tablecontent _tab %4.2f (`int_0b') (" (") %4.2f (`int_0ll') ("-") %4.2f (`int_0ul') (")") _tab %4.2f (`int_0b') _tab %4.2f (`int_0ll') _tab %4.2f (`int_0ul') _tab %5.4f (`p') _n
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _n


*Ethnicity
file write tablecontent ("Ethnicity") _n
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

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues i=1/5 {
local label_`i': label imd `i'
}
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
lincom 1.case + 1.case#`i'.imd, eform
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

*Region
file write tablecontent ("Region") _n
forvalues i=1/9 {
local label_`i': label region `i'
}
qui stcox i.case i.region i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.region i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/9 {
lincom 1.case + 1.case#`i'.region, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _tab %5.4f (`p') _n
forvalues i=2/9 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}


*Diabetes
file write tablecontent ("Diabetes") _n
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
forvalues i=0/1 {
local label_`i': label diabetes `i'
}
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_0b = r(estimate)
local int_0ll = r(lb)
local int_0ul = r(ub)
lincom 1.case + 1.case#1.diabetes, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
file write tablecontent ("`label_0'")
file write tablecontent _tab %4.2f (`int_0b') (" (") %4.2f (`int_0ll') ("-") %4.2f (`int_0ul') (")") _tab %4.2f (`int_0b') _tab %4.2f (`int_0ll') _tab %4.2f (`int_0ul') _tab %5.4f (`p') _n
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _n

*Baseline eGFR
file write tablecontent ("Baseline eGFR") _n
forvalues i=1/7 {
local label_`i': label egfr_group `i'
}
file write tablecontent ("`label_1'")
qui stcox i.case i.egfr_group i.ethnicity i.imd i.urban i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.case##i.egfr_group i.imd i.ethnicity i.urban i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/7 {
lincom 1.case + 1.case#`i'.egfr_group, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _tab %5.4f (`p') _n
forvalues i=2/7 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}
file close tablecontent