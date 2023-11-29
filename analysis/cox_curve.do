cap log close
macro drop hr
log using ./logs/cox_curve.log, replace t

use ./output/analysis_complete_2017.dta, clear
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique)
*failure curve-need to create dummy variable for categorical covariates*
foreach var of varlist ethnicity imd urban bmi smoking ckd_stage aki_baseline cardiovascular diabetes hypertension immunosuppressed non_haem_cancer gp_consults admissions {
 tabulate `var', generate(`var'_n)
}
drop ethnicity_n1 imd_n1 urban_n2 bmi_n2 smoking_n1 ckd_stage_n1 aki_baseline_n1 cardiovascular_n1 diabetes_n1 hypertension_n1 immunosuppressed_n1 non_haem_cancer_n1 gp_consults_n1 admissions_n1
sts graph, failure by(case) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(700) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02) title("Acute kidney injury") ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve.svg, as(svg) replace
sts graph, failure strata(case) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(700) ysc(r(0.02)) ylabel(0 0.005 0.01 0.015 0.02) title("Acute kidney injury") ytitle("Cumulative incidence") xtitle("Follow-up time (days)")
graph export ./output/failure_curve2.svg, as(svg) replace
clear

log close
