sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr

use ./output/analysis_complete_2020.dta, clear

replace covid_severity = 2 if covid_severity==3


label var esrd "Kidney failure"
label var egfr_half "50% reduction in eGFR"
label var death "Death"
*create dummy variable for categorical covariates*
foreach var of varlist sex stp ethnicity imd urban bmi smoking ckd_stage aki_baseline cardiovascular diabetes hypertension immunosuppressed non_haem_cancer gp_consults admissions covid_vax {
 tabulate `var', generate(`var'_n)
}
drop sex_n1 stp_n1 ethnicity_n1 imd_n1 urban_n2 bmi_n2 smoking_n1 ckd_stage_n1 aki_baseline_n1 cardiovascular_n1 diabetes_n1 hypertension_n1 immunosuppressed_n1 non_haem_cancer_n1 gp_consults_n1 admissions_n1 covid_vax_n1



*case*
local yrange_aki "0.02"
local yscale_aki "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_death "0.02"
local yscale_death "0 0.005 "0.5" 0.010 "1" 0.015 "1.5" 0.020 "2""
local yrange_egfr_half "0.003"
local yscale_egfr_half "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
local yrange_esrd "0.003"
local yscale_esrd "0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3""
foreach outcome of varlist esrd egfr_half death { 

stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&bmi!=.&smoking!=., cubic nknots(4)

local label_`outcome': variable label `outcome'
*failure curve*

sts graph, failure strata(case) adjustfor(age1 age2 age3 sex_n* stp_n* ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n* covid_vax_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Contemporary comparator") label(2 "SARS-CoV-2"))
graph export ./output/failure_curve_case_`outcome'_2020.svg, as(svg) replace
sts list, by(case) saving(./output/sts_list_output_case_`outcome')
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

foreach outcome of varlist esrd egfr_half  death { 
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique)
local label_`outcome': variable label `outcome'
*failure curve*

sts graph, failure strata(covid_severity) adjustfor(ethnicity_n* imd_n* urban_n* bmi_n* smoking_n* ckd_stage_n* aki_baseline_n* cardiovascular_n* diabetes_n* hypertension_n* immunosuppressed_n* non_haem_cancer_n* gp_consults_n* admissions_n* covid_vax_n*) tmax(600) ysc(r(`yrange_`outcome'')) ylabel(`yscale_`outcome'', format(%5.1f)) title(`label_`outcome'') ytitle("Cumulative incidence, %") xtitle("Follow-up time (days)") legend(label(1 "Contemporary comparator") label(2 "Non-hospitalised COVID") label(3 "Hospitalised COVID") label(4 "Critical care COVID") )
graph export ./output/failure_curve_covid_severity_`outcome'_2020.svg, as(svg) replace
sts list, by(covid_severity) saving(./output/sts_list_output_covid_severity_`outcome')

}
foreach outcome of varlist esrd egfr_half  death { 
use ./output/sts_list_output_case_`outcome', clear
export delimited using "./output/sts_list_output_case_`outcome'.csv", replace
use ./output/sts_list_output_covid_severity_`outcome', clear
export delimited using "./output/sts_list_output_covid_severity_`outcome'.csv", replace
}
/* - Already outputted:
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
sts graph, by(case) title("esrd") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2020_case_esrd.svg, as(svg) replace
sts graph, by(covid_severity) title("esrd") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2020_severity_esrd.svg, as(svg) replace

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
sts graph, by(case) title("egfr_half") graphregion(fcolor(white)) ylabel(.90(.1)1)
graph export ./output/km_2020_case_egfr_half.svg, as(svg) replace
sts graph, by(covid_severity) title("egfr_half") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2020_severity_egfr_half.svg, as(svg) replace

stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
sts graph, by(case) title("death") graphregion(fcolor(white)) ylabel(.90(.1)1)
graph export ./output/km_2020_case_death.svg, as(svg) replace
sts graph, by(covid_severity) title("death") graphregion(fcolor(white)) ylabel(.65(.1)1)
graph export ./output/km_2020_severity_death.svg, as(svg) replace


gen covid_severity1 = 0
replace covid_severity1 = 1 if covid_severity==1
gen covid_severity2 = 0
replace covid_severity2 = 1 if covid_severity==2

forvalues i = 1/2 {
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox covid_severity`i' i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
estat phtest, detail
* Plot schoenfeld residuals 
estat phtest, plot(covid_severity`i') ///
graphregion(fcolor(white)) ///
ylabel(, nogrid labsize(small)) ///
xlabel(, labsize(small)) ///
xtitle("Time", size(small)) ///
ytitle("Scaled Schoenfeld Residuals", size(small)) ///
msize(small) ///
mcolor(gs6) ///
msymbol(circle_hollow) ///
scheme(s1mono) ///
title ("esrd", position(11) size(medsmall)) ///
note("")
graph export ./output/schoenplot_2020_severity`i'_esrd.svg, as(svg) replace
}

qui stcox case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
estat phtest, detail
* Plot schoenfeld residuals 
estat phtest, plot(case) ///
graphregion(fcolor(white)) ///
ylabel(, nogrid labsize(small)) ///
xlabel(, labsize(small)) ///
xtitle("Time", size(small)) ///
ytitle("Scaled Schoenfeld Residuals", size(small)) ///
msize(small) ///
mcolor(gs6) ///
msymbol(circle_hollow) ///
scheme(s1mono) ///
title ("esrd", position(11) size(medsmall)) ///
note("")
graph export ./output/schoenplot_2020_case_esrd.svg, as(svg) replace
}
*/