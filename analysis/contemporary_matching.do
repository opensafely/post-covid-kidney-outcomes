cap log close
log using ./logs/contemporary_matching, replace t
clear

import delimited ./output/input_contemporary_matching.csv, delimiter(comma) varnames(1) case(preserve) 

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

replace baseline_creatinine_feb2020 = . if !inrange(baseline_creatinine_feb2020, 20, 3000)
gen mgdl_baseline_creatinine_feb2020 = baseline_creatinine_feb2020/88.4
gen min_baseline_creatinine_feb2020=.
replace min_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.7 if male==0
replace min_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.9 if male==1
replace min_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020^-0.329  if male==0
replace min_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020^-0.411  if male==1
replace min_baseline_creatinine_feb2020 = 1 if min_baseline_creatinine_feb2020<1
gen max_baseline_creatinine_feb2020=.
replace max_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.7 if male==0
replace max_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.9 if male==1
replace max_baseline_creatinine_feb2020 = max_baseline_creatinine_feb2020^-1.209
replace max_baseline_creatinine_feb2020 = 1 if max_baseline_creatinine_feb2020>1
gen egfr_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020*max_baseline_creatinine_feb2020*141
replace egfr_baseline_creatinine_feb2020 = egfr_baseline_creatinine_feb2020*(0.993^age)
replace egfr_baseline_creatinine_feb2020 = egfr_baseline_creatinine_feb2020*1.018 if male==0
drop if egfr_baseline_creatinine_feb2020 <15
drop baseline_creatinine_feb2020
drop mgdl_baseline_creatinine_feb2020
drop min_baseline_creatinine_feb2020
drop max_baseline_creatinine_feb2020
drop egfr_baseline_creatinine_feb2020
drop age

* Deceased
drop if deceased==1
drop deceased

**Covariates
* IMD
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
drop imd_o
recode imd 5=1 4=2 3=3 2=4 1=5 .=.
label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" 
label values imd imd
label var imd "Index of Multiple Deprivation"
noi di "DROPPING IF NO IMD" 
drop if imd>=.

export delimited using "./output/contemporary_matching.csv", replace
log close
