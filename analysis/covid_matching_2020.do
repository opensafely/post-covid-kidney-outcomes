cap log close
log using ./logs/covid_matching_2020, replace t
clear

*import delimited ./output/input_covid_matching.csv, delimiter(comma) varnames(1) case(preserve) 
import delimited ./output/input_asthma_matching_2020.csv, delimiter(comma) varnames(1) case(preserve) 

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

* Baseline eGFR <15 at time of COVID diagnosis using baseline creatinine updated monthly
gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
drop if covid_date ==.
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date
drop sars_cov_2

foreach baseline_creatinine_monthly of varlist 	baseline_creatinine_mar2017 ///
												baseline_creatinine_apr2017 ///
												baseline_creatinine_may2017 ///
												baseline_creatinine_jun2017 ///
												baseline_creatinine_jul2017 ///
												baseline_creatinine_aug2017 ///
												baseline_creatinine_sep2017 ///
												baseline_creatinine_oct2017 ///
												baseline_creatinine_nov2017 ///
												baseline_creatinine_dec2017 ///
												baseline_creatinine_jan2018 ///
												baseline_creatinine_feb2018 ///
												baseline_creatinine_mar2018 ///
												baseline_creatinine_apr2018 ///
												baseline_creatinine_may2018 ///
												baseline_creatinine_jun2018 ///
												baseline_creatinine_jul2018 ///
												baseline_creatinine_aug2018 ///
												baseline_creatinine_sep2018 ///
												baseline_creatinine_oct2018 ///
												baseline_creatinine_nov2018 ///
												baseline_creatinine_dec2018 ///
												baseline_creatinine_jan2019 ///
												baseline_creatinine_feb2019 ///
												baseline_creatinine_mar2019 ///
												baseline_creatinine_apr2019 ///
												baseline_creatinine_may2019 ///
												baseline_creatinine_jun2019 ///
												baseline_creatinine_jul2019 ///
												baseline_creatinine_aug2019 ///
												baseline_creatinine_sep2019 ///
												baseline_creatinine_oct2019	///
												baseline_creatinine_nov2019 ///
												baseline_creatinine_dec2019	{
replace `baseline_creatinine_monthly' = . if !inrange(`baseline_creatinine_monthly', 20, 3000)
gen mgdl_`baseline_creatinine_monthly' = `baseline_creatinine_monthly'/88.4
gen min_`baseline_creatinine_monthly'=.
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if male==0
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if male==1
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.329 if male==0
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.411 if male==1
replace min_`baseline_creatinine_monthly' = 1 if min_`baseline_creatinine_monthly'<1
gen max_`baseline_creatinine_monthly'=.
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if male==0
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if male==1
replace max_`baseline_creatinine_monthly' = max_`baseline_creatinine_monthly'^-1.209
replace max_`baseline_creatinine_monthly' = 1 if max_`baseline_creatinine_monthly'>1
gen egfr_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'*max_`baseline_creatinine_monthly'*141
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*(0.993^age)
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*1.018 if male==0
drop `baseline_creatinine_monthly'
drop mgdl_`baseline_creatinine_monthly'
drop min_`baseline_creatinine_monthly'
drop max_`baseline_creatinine_monthly'
}

gen covid_date_string=string(covid_date, "%td") 
gen covid_month=substr( covid_date_string ,3,7)

gen baseline_egfr=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 oct2019 nov2019 dec2019"
foreach x of  local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if covid_month=="`x'"
drop egfr_baseline_creatinine_`x'
}
drop if baseline_egfr <15
drop baseline_egfr
drop covid_date_string

* COVID-19 death
drop if deceased==1
drop deceased

**Drop disaggregated krt_outcome variables
drop krt_outcome_primary_care
drop krt_outcome_icd_10
drop krt_outcome_opcs_4

export delimited using "./output/covid_matching_2020.csv", replace

log close
