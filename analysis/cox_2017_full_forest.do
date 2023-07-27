sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_2017_full_forest.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_2017_full_forest.csv, write text replace
file write tablecontent ("exposure") _tab ("mean") _tab ("lower") _tab ("upper") _tab ("hr") _n

use ./output/analysis_2017.dta, clear

label var esrd "Kidney failure"
label var egfr_half "50% reduction in eGFR"
label var aki "Acute kidney injury"
label var death "Death"

*Fully-adjusted Cox regression models
foreach outcome of varlist esrd egfr_half aki death {
local label_`outcome': variable label `outcome'
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique) scale(365.25)

*Exposure = case
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)	
matrix table = r(table)
local case_`outcome'_b: display %4.2f table[1,2]
local case_`outcome'_ll: display %4.2f table[5,2]
local case_`outcome'_ul: display %4.2f table[6,2]

*Exposure = covid_severity
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)	
matrix table = r(table)
local sev_`outcome'_1b: display %4.2f table[1,2]
local sev_`outcome'_1ll: display %4.2f table[5,2]
local sev_`outcome'_1ul: display %4.2f table[6,2]
local sev_`outcome'_2b: display %4.2f table[1,3]
local sev_`outcome'_2ll: display %4.2f table[5,3]
local sev_`outcome'_2ul: display %4.2f table[6,3]
local sev_`outcome'_3b: display %4.2f table[1,4]
local sev_`outcome'_3ll: display %4.2f table[5,4]
local sev_`outcome'_3ul: display %4.2f table[6,4]

*Exposure = covid_aki
qui stcox i.covid_aki i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local aki_`outcome'_1b: display %4.2f table[1,2]
local aki_`outcome'_1ll: display %4.2f table[5,2]
local aki_`outcome'_1ul: display %4.2f table[6,2]
local aki_`outcome'_2b: display %4.2f table[1,3]
local aki_`outcome'_2ll: display %4.2f table[5,3]
local aki_`outcome'_2ul: display %4.2f table[6,3]
local aki_`outcome'_3b: display %4.2f table[1,4]
local aki_`outcome'_3ll: display %4.2f table[5,4]
local aki_`outcome'_3ul: display %4.2f table[6,4]

local case_lab1: label case 1
local sev_lab1: label covid_severity 1
local sev_lab2: label covid_severity 2
local sev_lab3: label covid_severity 3
local aki_lab1: label covid_aki 1
local aki_lab2: label covid_aki 2
local aki_lab3: label covid_aki 3

file write tablecontent ("`label_`outcome''") _n
file write tablecontent ("`case_lab1'") _tab (`case_`outcome'_b') _tab (`case_`outcome'_ll') _tab (`case_`outcome'_ul') _tab %4.2f (`case_`outcome'_b') (" (") %4.2f (`case_`outcome'_ll') ("-") %4.2f (`case_`outcome'_ul') (")") _tab _n
file write tablecontent _n
forvalues sev=1/3 {
file write tablecontent ("`sev_lab`sev''") _tab (`sev_`outcome'_`sev'b') _tab (`sev_`outcome'_`sev'll') _tab (`sev_`outcome'_`sev'ul') _tab %4.2f (`sev_`outcome'_`sev'b') (" (") %4.2f (`sev_`outcome'_`sev'll') ("-") %4.2f (`sev_`outcome'_`sev'ul') (")") _tab _n
}
file write tablecontent _n
forvalues aki=1/3 {
file write tablecontent ("`aki_lab`aki''") _tab (`aki_`outcome'_`aki'b') _tab (`aki_`outcome'_`aki'll') _tab (`aki_`outcome'_`aki'ul') _tab %4.2f (`aki_`outcome'_`aki'b') (" (") %4.2f (`aki_`outcome'_`aki'll') ("-") %4.2f (`aki_`outcome'_`aki'ul') (")") _tab _n
}
file write tablecontent _n
}

