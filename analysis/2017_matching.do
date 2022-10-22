cap log close
log using ./logs/2017_matching, replace t
clear

import delimited ./output/input_2017_matching.csv, delimiter(comma) varnames(1) case(preserve) 

**Exclusions
* Age <18
drop if age <18

* Anyone not registered at one practice for 3 months before
drop if has_follow_up==0
drop has_follow_up

* Pre-existing kidney replacement therapy
drop if baseline_krt_primary_care==1
drop baseline_krt_primary_care
drop if baseline_krt_icd_10==1
drop baseline_krt_icd_10
drop if baseline_krt_opcs_4==1
drop baseline_krt_opcs_4

* Baseline eGFR <15 as at February 2017
assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
label define sexLab 1 "Male" 0 "Female"
label values male sexLab
label var male "Sex (0=F 1=M)"

replace baseline_creatinine_feb2017 = . if !inrange(baseline_creatinine_feb2017, 20, 3000)
gen mgdl_baseline_creatinine_feb2017 = baseline_creatinine_feb2017/88.4
gen min_baseline_creatinine_feb2017=.
replace min_baseline_creatinine_feb2017 = mgdl_baseline_creatinine_feb2017/0.7 if male==0
replace min_baseline_creatinine_feb2017 = mgdl_baseline_creatinine_feb2017/0.9 if male==1
replace min_baseline_creatinine_feb2017 = min_baseline_creatinine_feb2017^-0.329  if male==0
replace min_baseline_creatinine_feb2017 = min_baseline_creatinine_feb2017^-0.411  if male==1
replace min_baseline_creatinine_feb2017 = 1 if min_baseline_creatinine_feb2017<1
gen max_baseline_creatinine_feb2017=.
replace max_baseline_creatinine_feb2017 = mgdl_baseline_creatinine_feb2017/0.7 if male==0
replace max_baseline_creatinine_feb2017 = mgdl_baseline_creatinine_feb2017/0.9 if male==1
replace max_baseline_creatinine_feb2017 = max_baseline_creatinine_feb2017^-1.209
replace max_baseline_creatinine_feb2017 = 1 if max_baseline_creatinine_feb2017>1
gen egfr_baseline_creatinine_feb2017 = min_baseline_creatinine_feb2017*max_baseline_creatinine_feb2017*141
replace egfr_baseline_creatinine_feb2017 = egfr_baseline_creatinine_feb2017*(0.993^age)
replace egfr_baseline_creatinine_feb2017 = egfr_baseline_creatinine_feb2017*1.018 if male==0
drop if egfr_baseline_creatinine_feb2017 <15
drop baseline_creatinine_feb2017
drop mgdl_baseline_creatinine_feb2017
drop min_baseline_creatinine_feb2017
drop max_baseline_creatinine_feb2017
drop egfr_baseline_creatinine_feb2017
drop age

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

*Tabulate variables
tab year_of_birth
tab imd
tab male

export delimited using "./output/2017_matching.csv", replace
log close
