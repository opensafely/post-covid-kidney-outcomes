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
sts graph, failure by(case) adjustfor(ethnicity imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) title("") ytitle("Cumulative incidence") xtitle("Analysis time (days)")
graph export ./output/failure_curve.svg, as(svg) replace
*survival curve*
stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) 
stcurve, survival at1(case=0) at2(case=1) title("") xtitle("Analysis time (days)")
graph export ./output/survival_curve.svg, as(svg) replace
clear

log close
