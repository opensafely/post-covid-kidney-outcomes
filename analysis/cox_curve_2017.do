cap log close
macro drop hr
log using ./logs/cox_curve_2017.log, replace t

*2017*
use ./output/analysis_complete_2017.dta, clear
label var esrd "Kidney failure"
label var egfr_half "50% reduction in eGFR"
label var aki "Acute kidney injury"
label var death "Death"
*create dummy variable for categorical covariates*
foreach var of varlist ethnicity imd urban bmi smoking ckd_stage aki_baseline cardiovascular diabetes hypertension immunosuppressed non_haem_cancer gp_consults admissions {
 tabulate `var', generate(`var'_n)
}
drop ethnicity_n1 imd_n1 urban_n2 bmi_n2 smoking_n1 ckd_stage_n1 aki_baseline_n1 cardiovascular_n1 diabetes_n1 hypertension_n1 immunosuppressed_n1 non_haem_cancer_n1 gp_consults_n1 admissions_n1

*case*
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(case) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02, format(%5.3f)) title(`label_`outcome'') ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve_case_`outcome'_2017.svg, as(svg) replace
}

*covid_severity*
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_severity) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02, format(%5.3f)) title(`label_`outcome'') ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve_covid_severity_`outcome'_2017.svg, as(svg) replace
}

*covid_aki*
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_aki) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02, format(%5.3f)) title(`label_`outcome'') ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve_covid_aki_`outcome'_2017.svg, as(svg) replace
}

*covid_vax*
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_vax) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02, format(%5.3f)) title(`label_`outcome'') ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve_covid_vax_`outcome'_2017.svg, as(svg) replace
}

*wave*
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(wave) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02, format(%5.3f)) title(`label_`outcome'') ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve_wave_`outcome'_2017.svg, as(svg) replace
}
