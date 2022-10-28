cap log close
log using ./logs/2020_matching, replace t
clear

import delimited ./output/input_2020_matching.csv, delimiter(comma) varnames(1) case(preserve) 

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
drop egfr_creatinine_feb2020

* Deceased
drop if deceased==1
drop deceased

**Covariates
* IMD
drop if imd>=.

**Drop excess variables
drop krt_outcome_primary_care
drop krt_outcome_icd_10
drop krt_outcome_opcs_4
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date

*Tabulate variables
tab age
tab imd
tab male

gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
gen covid_date_string=string(covid_date, "%td") 
gen covid_month=substr( covid_date_string ,3,7)
tab covid_month


gen death_date1 = date(death_date, "YMD")
format death_date1 %td
gen death_date_string=string(death_date1, "%td")
gen death_month=substr( death_date_string ,3,7)
tab death_month


export delimited using "./output/2020_matching.csv", replace
log close
