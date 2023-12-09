cap log close
macro drop hr
log using ./logs/cox_curve_hosp.log, replace t

*hospitalised*
use ./output/analysis_complete_hospitalised.dta, clear
label var esrd "Kidney failure"
label var egfr_half "50% reduction in eGFR"
label var aki "Acute kidney injury"
label var death "Death"
*create dummy variable for categorical covariates*
foreach var of varlist sex ethnicity imd urban bmi smoking ckd_stage aki_baseline cardiovascular diabetes hypertension immunosuppressed non_haem_cancer gp_consults admissions month {
 tabulate `var', generate(`var'_n)
}
drop sex_n1 ethnicity_n1 imd_n1 urban_n2 bmi_n2 smoking_n1 ckd_stage_n1 aki_baseline_n1 cardiovascular_n1 diabetes_n1 hypertension_n1 immunosuppressed_n1 non_haem_cancer_n1 gp_consults_n1 admissions_n1 month_n1
*center age*
sum age
gen age_c=age-r(mean)

*case*
local yrange_aki "0.1"
local yscale_aki "0 0.05 "5" 0.1 "10""
local yrange_death "0.2"
local yscale_death "0 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20""
local yrange_egfr_half "0.02"
local yscale_egfr_half "0 0.01 "1" 0.02 "2""
local yrange_esrd "0.01"
local yscale_esrd "0 0.005 "0.5" 0.01 "1""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(case) adjustfor(sex_n* ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n* month_n* age_c) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Pneumonia (pre-pandemic)") label(2 "COVID-19"))
graph export ./output/failure_curve_case_`outcome'_hosp.svg, as(svg) replace
}


*covid_vax*
local yrange_aki "0.1"
local yscale_aki "0 0.05 "5" 0.1 "10""
local yrange_death "0.2"
local yscale_death "0 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20""
local yrange_egfr_half "0.02"
local yscale_egfr_half "0 0.01 "1" 0.02 "2""
local yrange_esrd "0.01"
local yscale_esrd "0 0.005 "0.5" 0.01 "1""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_vax) adjustfor(sex_n* ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* month_n* age_c) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Pneumonia (pre-pandemic)") label(2 "COVID pre-vaccination") label(3 "COVID 1 vaccine dose") label(4 "COVID 2 vaccine doses") label(5 "COVID 3 vaccine doses") label(6 "COVID >=4 vaccine doses") )
graph export ./output/failure_curve_covid_vax_`outcome'_hosp.svg, as(svg) replace
}

*wave*
local yrange_aki "0.1"
local yscale_aki "0 0.05 "5" 0.1 "10""
local yrange_death "0.2"
local yscale_death "0 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20""
local yrange_egfr_half "0.02"
local yscale_egfr_half "0 0.01 "1" 0.02 "2""
local yrange_esrd "0.01"
local yscale_esrd "0 0.005 "0.5" 0.01 "1""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(wave) adjustfor(sex_n* ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* month_n* age_c) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Pneumonia (pre-pandemic)") label(2 "COVID Feb20-Aug20") label(3 "COVID Sep20-Jun21") label(4 "COVID Jul21-Nov21") label(5 "COVID Dec21-Dec22"))
graph export ./output/failure_curve_wave_`outcome'_hosp.svg, as(svg) replace
}




