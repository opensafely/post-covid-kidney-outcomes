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
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.02"
local yscale_death "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_egfr_half "0.003"
local yscale_egfr_half "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
local yrange_esrd "0.003"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(case) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Historical comparator") label(2 "SARS-CoV-2"))
graph export ./output/failure_curve_case_`outcome'_2017.svg, as(svg) replace
}

*covid_severity*
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.05"
local yscale_death "0 0.01 "1" 0.02 "2" 0.03 "3" 0.04 "4" 0.05 "5""
local yrange_egfr_half "0.01"
local yscale_egfr_half "0 0.002 "0.2" 0.004 "0.4" 0.006 "0.6" 0.008 "0.8" 0.01 "1""
local yrange_esrd "0.005"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3" 0.004 "0.4" 0.005 "0.5""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_severity) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Historical comparator") label(2 "Non-hospitalised COVID") label(3 "Hospitalised COVID") label(4 "Critical care COVID") )
graph export ./output/failure_curve_covid_severity_`outcome'_2017.svg, as(svg) replace
}

*covid_aki*
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.05"
local yscale_death "0 0.01 "1" 0.02 "2" 0.03 "3" 0.04 "4" 0.05 "5""
local yrange_egfr_half "0.005"
local yscale_egfr_half "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3" 0.004 "0.4" 0.005 "0.5""
local yrange_esrd "0.003"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_aki) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Historical comparator") label(2 "Non-hospitalised COVID") label(3 "Hospitalised COVID") label(4 "Hospitalised COVID-AKI") )
graph export ./output/failure_curve_covid_aki_`outcome'_2017.svg, as(svg) replace
}

*covid_vax*
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.02"
local yscale_death "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_egfr_half "0.003"
local yscale_egfr_half "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
local yrange_esrd "0.003"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(covid_vax) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Historical comparator") label(2 "Pre-vaccination") label(3 "1 vaccine dose") label(4 "2 vaccine doses") label(5 "3 vaccine doses") label(6 ">=4 vaccine doses") )
graph export ./output/failure_curve_covid_vax_`outcome'_2017.svg, as(svg) replace
}

*wave*
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.02"
local yscale_death "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_egfr_half "0.003"
local yscale_egfr_half "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
local yrange_esrd "0.003"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
foreach outcome of varlist esrd egfr_half aki death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*
sts graph, failure strata(wave) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Historical comparator") label(2 "Febuary20-August20") label(3 "September20-June21") label(4 "July21-November21") label(5 "December21-December22"))
graph export ./output/failure_curve_wave_`outcome'_2017.svg, as(svg) replace
}
