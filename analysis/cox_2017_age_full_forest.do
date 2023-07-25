sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_2017_age_full_forest.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_2017_age_full_forest.csv, write text replace
file write tablecontent ("subgroup") _tab ("mean") _tab ("lower") _tab ("upper") _tab ("hr") _n

use ./output/analysis_2017.dta, clear

label var esrd "Kidney failure"
label var egfr_half "50% reduction in eGFR"
label var aki "Acute kidney injury"
label var death "Death"

*Fully-adjusted Cox regression models
foreach outcome of varlist esrd egfr_half aki death {
local label_`outcome': variable label `outcome'
forvalues age = 1/5 {
use ./output/analysis_2017.dta, clear
drop if agegroup !=`age'
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique) scale(365.25)

*Exposure = case
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)	
matrix table = r(table)
local case_`outcome'age`age'_b: display %4.2f table[1,2]
local case_`outcome'age`age'_ll: display %4.2f table[5,2]
local case_`outcome'age`age'_ul: display %4.2f table[6,2]

*Exposure = covid_severity
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)	
matrix table = r(table)
local sev_`outcome'age`age'_1b: display %4.2f table[1,2]
local sev_`outcome'age`age'_1ll: display %4.2f table[5,2]
local sev_`outcome'age`age'_1ul: display %4.2f table[6,2]
local sev_`outcome'age`age'_2b: display %4.2f table[1,3]
local sev_`outcome'age`age'_2ll: display %4.2f table[5,3]
local sev_`outcome'age`age'_2ul: display %4.2f table[6,3]
local sev_`outcome'age`age'_3b: display %4.2f table[1,4]
local sev_`outcome'age`age'_3ll: display %4.2f table[5,4]
local sev_`outcome'age`age'_3ul: display %4.2f table[6,4]

*Exposure = covid_aki
qui stcox i.covid_aki i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local aki_`outcome'age`age'_1b: display %4.2f table[1,2]
local aki_`outcome'age`age'_1ll: display %4.2f table[5,2]
local aki_`outcome'age`age'_1ul: display %4.2f table[6,2]
local aki_`outcome'age`age'_2b: display %4.2f table[1,3]
local aki_`outcome'age`age'_2ll: display %4.2f table[5,3]
local aki_`outcome'age`age'_2ul: display %4.2f table[6,3]
local aki_`outcome'age`age'_3b: display %4.2f table[1,4]
local aki_`outcome'age`age'_3ll: display %4.2f table[5,4]
local aki_`outcome'age`age'_3ul: display %4.2f table[6,4]

*Exposure = wave
qui stcox i.wave i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local wave_`outcome'age`age'_1b: display %4.2f table[1,2]
local wave_`outcome'age`age'_1ll: display %4.2f table[5,2]
local wave_`outcome'age`age'_1ul: display %4.2f table[6,2]
local wave_`outcome'age`age'_2b: display %4.2f table[1,3]
local wave_`outcome'age`age'_2ll: display %4.2f table[5,3]
local wave_`outcome'age`age'_2ul: display %4.2f table[6,3]
local wave_`outcome'age`age'_3b: display %4.2f table[1,4]
local wave_`outcome'age`age'_3ll: display %4.2f table[5,4]
local wave_`outcome'age`age'_3ul: display %4.2f table[6,4]
local wave_`outcome'age`age'_4b: display %4.2f table[1,5]
local wave_`outcome'age`age'_4ll: display %4.2f table[5,5]
local wave_`outcome'age`age'_4ul: display %4.2f table[6,5]

*Exposure = covid_vax
qui stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local vax_`outcome'age`age'_1b: display %4.2f table[1,2]
local vax_`outcome'age`age'_1ll: display %4.2f table[5,2]
local vax_`outcome'age`age'_1ul: display %4.2f table[6,2]
local vax_`outcome'age`age'_2b: display %4.2f table[1,3]
local vax_`outcome'age`age'_2ll: display %4.2f table[5,3]
local vax_`outcome'age`age'_2ul: display %4.2f table[6,3]
local vax_`outcome'age`age'_3b: display %4.2f table[1,4]
local vax_`outcome'age`age'_3ll: display %4.2f table[5,4]
local vax_`outcome'age`age'_3ul: display %4.2f table[6,4]
local vax_`outcome'age`age'_4b: display %4.2f table[1,5]
local vax_`outcome'age`age'_4ll: display %4.2f table[5,5]
local vax_`outcome'age`age'_4ul: display %4.2f table[6,5]
local vax_`outcome'age`age'_5b: display %4.2f table[1,6]
local vax_`outcome'age`age'_5ll: display %4.2f table[5,6]
local vax_`outcome'age`age'_5ul: display %4.2f table[6,6]
}

local case_lab1: label case 1
local sev_lab1: label covid_severity 1
local sev_lab2: label covid_severity 2
local sev_lab3: label covid_severity 3
local aki_lab1: label covid_aki 1
local aki_lab2: label covid_aki 2
local aki_lab3: label covid_aki 3
local wave_lab1: label wave 1
local wave_lab2: label wave 2
local wave_lab3: label wave 3
local wave_lab4: label wave 4
local vax_lab1: label covid_vax 1
local vax_lab2: label covid_vax 2
local vax_lab3: label covid_vax 3
local vax_lab4: label covid_vax 4
local vax_lab5: label covid_vax 5
local age_lab1: label agegroup 1
local age_lab2: label agegroup 2
local age_lab3: label agegroup 3
local age_lab4: label agegroup 4
local age_lab5: label agegroup 5
local age_lab6: label agegroup 6

file write tablecontent ("`case_lab1'") _n
forvalues age = 1/5 {
file write tablecontent ("`age_lab`age''") _tab (`case_`outcome'age`age'_b') _tab (`case_`outcome'age`age'_ll') _tab (`case_`outcome'age`age'_ul') _tab %4.2f (`case_`outcome'age`age'_b') (" (") %4.2f (`case_`outcome'age`age'_ll') ("-") %4.2f (`case_`outcome'age`age'_ul') (")") _tab _n
}
file write tablecontent _n
forvalues sev=1/3 {
file write tablecontent ("`sev_lab`sev''") _n
forvalues age = 1/5 {
file write tablecontent ("`age_lab`age''") _tab (`sev_`outcome'age`age'_`sev'b') _tab (`sev_`outcome'age`age'_`sev'll') _tab (`sev_`outcome'age`age'_`sev'ul') _tab %4.2f (`sev_`outcome'age`age'_`sev'b') (" (") %4.2f (`sev_`outcome'age`age'_`sev'll') ("-") %4.2f (`sev_`outcome'age`age'_`sev'ul') (")") _tab _n
}
}
file write tablecontent _n
forvalues aki=1/3 {
file write tablecontent ("`aki_lab`aki''") _n
forvalues age = 1/5 {
file write tablecontent ("`age_lab`age''") _tab (`aki_`outcome'age`age'_`aki'b') _tab (`aki_`outcome'age`age'_`aki'll') _tab (`aki_`outcome'age`age'_`aki'ul') _tab %4.2f (`aki_`outcome'age`age'_`aki'b') (" (") %4.2f (`aki_`outcome'age`age'_`aki'll') ("-") %4.2f (`aki_`outcome'age`age'_`aki'ul') (")") _tab _n
}
}
file write tablecontent _n
forvalues wave=1/4 {
file write tablecontent ("`wave_lab`wave''") _n
forvalues age = 1/5 {
file write tablecontent ("`age_lab`age''") _tab (`wave_`outcome'age`age'_`wave'b') _tab (`wave_`outcome'age`age'_`wave'll') _tab (`wave_`outcome'age`age'_`wave'ul') _tab %4.2f (`wave_`outcome'age`age'_`wave'b') (" (") %4.2f (`wave_`outcome'age`age'_`wave'll') ("-") %4.2f (`wave_`outcome'age`age'_`wave'ul') (")") _tab _n
}
}
file write tablecontent _n
file write tablecontent 
forvalues vax=1/5 {
file write tablecontent ("`vax_lab`vax''") _n
forvalues age = 1/5 {
file write tablecontent ("`age_lab`age''") _tab (`vax_`outcome'age`age'_`vax'b') _tab (`vax_`outcome'age`age'_`vax'll') _tab (`vax_`outcome'age`age'_`vax'ul') _tab %4.2f (`vax_`outcome'age`age'_`vax'b') (" (") %4.2f (`vax_`outcome'age`age'_`vax'll') ("-") %4.2f (`vax_`outcome'age`age'_`vax'ul') (")") _tab _n
}
}
file write tablecontent _n
}


