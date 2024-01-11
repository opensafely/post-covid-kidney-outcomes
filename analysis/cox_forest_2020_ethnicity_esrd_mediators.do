clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_forest_2020_ethnicity_esrd_mediators.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_forest_2020_ethnicity_esrd_mediators.csv, write text replace
file write tablecontent _tab ("HR (95% CI)") _tab ("hr") _tab ("ll") _tab ("ul") _n

use ./output/analysis_complete_2020.dta, clear

qui stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

file write tablecontent ("Minimally-adjusted") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
qui stcox i.case##i.ethnicity, strata(set_id)
qui lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
qui lincom 1.case + 1.case#`i'.ethnicity, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}

local mediators "imd urban bmi smoking ckd_stage aki_baseline cardiovascular diabetes hypertension immunosuppressed non_haem_cancer gp_consults admissions covid_vax"

local imd_lab "IMD"
local urban_lab "rural/urban"
local bmi_lab "BMI"
local smoking_lab "smoking"
local ckd_stage_lab "CKD stage"
local aki_baseline_lab "previous AKI"
local cardiovascular_lab "cardiovascular diseases"
local diabetes_lab "diabetes"
local hypertension_lab "hypertension"
local immunosuppressed_lab "immunosuppressed"
local non_haem_cancer_lab "non-haematological cancer"
local gp_consults_lab "GP consultations"
local admissions_lab "previous hospital admissions"
local covid_vax_lab "COVID-19 vaccination"

foreach med of local mediators {

file write tablecontent ("After adjustment for ``med'_lab'") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}

qui stcox i.case##i.ethnicity i.`med', strata(set_id)
qui lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
qui lincom 1.case + 1.case#`i'.ethnicity, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
file write tablecontent ("`label_1'")
file write tablecontent _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %4.2f (`int_1b') _tab %4.2f (`int_1ll') _tab %4.2f (`int_1ul') _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
file write tablecontent _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _tab %4.2f (`int_`i'b') _tab %4.2f (`int_`i'll') _tab %4.2f (`int_`i'ul') _n
}
}

file close tablecontent