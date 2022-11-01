cap log close
log using ./logs/covid_matching_2020, replace t
clear

import delimited ./output/input_covid_matching.csv, delimiter(comma) varnames(1) case(preserve) 

**Exclusions
* Age <18
drop if age <18

* Anyone not registered at one practice for 3 months before COVID-19 diagnosis
drop if has_follow_up==0
drop has_follow_up

* Pre-existing kidney replacement therapy
drop if baseline_krt_primary_care==1
drop baseline_krt_primary_care
drop if baseline_krt_icd_10==1
drop baseline_krt_icd_10
drop if baseline_krt_opcs_4==1
drop baseline_krt_opcs_4

* Baseline eGFR <15 as at February 2020
assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
label define sexLab 1 "Male" 0 "Female"
label values male sexLab
label var male "Sex (0=F 1=M)"

replace creatinine_feb2020 = . if !inrange(creatinine_feb2020, 20, 3000)
gen mgdl_creatinine_feb2020 = creatinine_feb2020/88.4
gen min_creatinine_feb2020=.
replace min_creatinine_feb2020 = mgdl_creatinine_feb2020/0.7 if male==0
replace min_creatinine_feb2020 = mgdl_creatinine_feb2020/0.9 if male==1
replace min_creatinine_feb2020 = min_creatinine_feb2020^-0.329  if male==0
replace min_creatinine_feb2020 = min_creatinine_feb2020^-0.411  if male==1
replace min_creatinine_feb2020 = 1 if min_creatinine_feb2020<1
gen max_creatinine_feb2020=.
replace max_creatinine_feb2020 = mgdl_creatinine_feb2020/0.7 if male==0
replace max_creatinine_feb2020 = mgdl_creatinine_feb2020/0.9 if male==1
replace max_creatinine_feb2020 = max_creatinine_feb2020^-1.209
replace max_creatinine_feb2020 = 1 if max_creatinine_feb2020>1
gen egfr_creatinine_feb2020 = min_creatinine_feb2020*max_creatinine_feb2020*141
replace egfr_creatinine_feb2020 = egfr_creatinine_feb2020*(0.993^age)
replace egfr_creatinine_feb2020 = egfr_creatinine_feb2020*1.018 if male==0
drop if egfr_creatinine_feb2020 <15
drop creatinine_feb2020
drop mgdl_creatinine_feb2020
drop min_creatinine_feb2020
drop max_creatinine_feb2020

* Baseline eGFR <15 at time of COVID diagnosis using baseline creatinine updated monthly
gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
drop if covid_date ==.
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date
drop sars_cov_2

foreach creatinine_monthly of varlist 	creatinine_mar2020 ///
												creatinine_apr2020 ///
												creatinine_may2020 ///
												creatinine_jun2020 ///
												creatinine_jul2020 ///
												creatinine_aug2020 ///
												creatinine_sep2020 ///
												creatinine_oct2020 ///
												creatinine_nov2020 ///
												creatinine_dec2020 ///
												creatinine_jan2021 ///
												creatinine_feb2021 ///
												creatinine_mar2021 ///
												creatinine_apr2021 ///
												creatinine_may2021 ///
												creatinine_jun2021 ///
												creatinine_jul2021 ///
												creatinine_aug2021 ///
												creatinine_sep2021 ///
												creatinine_oct2021 ///
												creatinine_nov2021 ///
												creatinine_dec2021 ///
												creatinine_jan2022 ///
												creatinine_feb2022 ///
												creatinine_mar2022 ///
												creatinine_apr2022 ///
												creatinine_may2022 ///
												creatinine_jun2022 ///
												creatinine_jul2022 ///
												creatinine_aug2022 ///
												creatinine_sep2022 {
replace `creatinine_monthly' = . if !inrange(`creatinine_monthly', 20, 3000)
gen mgdl_`creatinine_monthly' = `creatinine_monthly'/88.4
gen min_`creatinine_monthly'=.
replace min_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.7 if male==0
replace min_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.9 if male==1
replace min_`creatinine_monthly' = min_`creatinine_monthly'^-0.329 if male==0
replace min_`creatinine_monthly' = min_`creatinine_monthly'^-0.411 if male==1
replace min_`creatinine_monthly' = 1 if min_`creatinine_monthly'<1
gen max_`creatinine_monthly'=.
replace max_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.7 if male==0
replace max_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.9 if male==1
replace max_`creatinine_monthly' = max_`creatinine_monthly'^-1.209
replace max_`creatinine_monthly' = 1 if max_`creatinine_monthly'>1
gen egfr_`creatinine_monthly' = min_`creatinine_monthly'*max_`creatinine_monthly'*141
replace egfr_`creatinine_monthly' = egfr_`creatinine_monthly'*(0.993^age)
replace egfr_`creatinine_monthly' = egfr_`creatinine_monthly'*1.018 if male==0
drop `creatinine_monthly'
drop mgdl_`creatinine_monthly'
drop min_`creatinine_monthly'
drop max_`creatinine_monthly'
}

gen covid_date_string=string(covid_date, "%td") 
gen covid_month=substr( covid_date_string ,3,7)

gen baseline_egfr=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022"
foreach x of  local month_year  {
replace baseline_egfr=egfr_creatinine_`x' if  covid_month=="`x'"
drop if baseline_egfr <15
drop egfr_creatinine_`x'
}
drop baseline_egfr
drop covid_date_string

* COVID-19 death
drop if deceased==1
drop deceased

**Covariates
* IMD
drop if imd>=.

**Drop disaggregated krt_outcome variables
drop krt_outcome_primary_care
drop krt_outcome_icd_10
drop krt_outcome_opcs_4

*Tabulate variables
tab age
tab imd
tab male
tab covid_month

export delimited using "./output/covid_matching_2020.csv", replace

log close
