sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/selection_2017.log, replace t

cap file close tablecontent

file open tablecontent using ./output/selection_2017.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Contemporary comparator") _n

local lab1 "Extracted from OpenSAFELY"
local lab2 "In COVID-19 cohort"
local lab3 "Baseline eGFR <15"
local lab4 "Unmatched"
local lab5 "Invalid IMD"
local lab6 "Invalid region"
local lab7 "Deregistered from primary care before index date"
local lab8 "Deceased before index date"
local lab9 "Baseline eGFR <15"
local lab10 "Remaining in valid matched sets"
local lab11 "Final analysis dataset"


**Extracted from OpenSAFELY
capture noisily import delimited ./output/input_covid_matching.csv, clear
safecount
local covid_1 = round(r(N),5)
capture noisily import delimited ./output/input_2017_matching.csv, clear
safecount
local 2017_1 = round(r(N),5)

**Excluded as baseline eGFR <15
**COVID
clear
import delimited ./output/input_covid_matching.csv, delimiter(comma) varnames(1) case(preserve) 
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

safecount if egfr_baseline_creatinine_feb2020 <15
local ckd5_feb2020 = r(N)

drop if egfr_baseline_creatinine_feb2020 <15
drop baseline_creatinine_feb2020
drop mgdl_baseline_creatinine_feb2020
drop min_baseline_creatinine_feb2020
drop max_baseline_creatinine_feb2020

* Baseline eGFR <15 at time of COVID diagnosis using baseline creatinine updated monthly
gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
drop if covid_date ==.
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date
drop sars_cov_2

foreach baseline_creatinine_monthly of varlist 	baseline_creatinine_mar2020 ///
												baseline_creatinine_apr2020 ///
												baseline_creatinine_may2020 ///
												baseline_creatinine_jun2020 ///
												baseline_creatinine_jul2020 ///
												baseline_creatinine_aug2020 ///
												baseline_creatinine_sep2020 ///
												baseline_creatinine_oct2020 ///
												baseline_creatinine_nov2020 ///
												baseline_creatinine_dec2020 ///
												baseline_creatinine_jan2021 ///
												baseline_creatinine_feb2021 ///
												baseline_creatinine_mar2021 ///
												baseline_creatinine_apr2021 ///
												baseline_creatinine_may2021 ///
												baseline_creatinine_jun2021 ///
												baseline_creatinine_jul2021 ///
												baseline_creatinine_aug2021 ///
												baseline_creatinine_sep2021 ///
												baseline_creatinine_oct2021 ///
												baseline_creatinine_nov2021 ///
												baseline_creatinine_dec2021 ///
												baseline_creatinine_jan2022 ///
												baseline_creatinine_feb2022 ///
												baseline_creatinine_mar2022 ///
												baseline_creatinine_apr2022 ///
												baseline_creatinine_may2022 ///
												baseline_creatinine_jun2022 ///
												baseline_creatinine_jul2022 ///
												baseline_creatinine_aug2022 ///
												baseline_creatinine_sep2022 ///
												baseline_creatinine_oct2022	///
												baseline_creatinine_nov2022 ///
												baseline_creatinine_dec2022	{
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
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022"
foreach x of  local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if covid_month=="`x'"
drop egfr_baseline_creatinine_`x'
}
safecount if baseline_egfr <15
local covid_3 = round((r(N) + `ckd5_feb2020'),5)

**2017

capture noisily import delimited ./output/covid_matching_2017.csv, clear
keep patient_id covid_date
gen case=1
tempfile covid_list_2017
save `covid_list_2017', replace

capture noisily import delimited ./output/input_2017_matching.csv, delimiter(comma) varnames(1) case(preserve) clear
append using `covid_list_2017', force
replace case=0 if case==.
gen duplicates=.
bysort patient_id: replace duplicates=_N
safecount if duplicates==2 & case==0
local 2017_2 = round(r(N),5)
local covid_2 = 0

duplicates drop patient_id, force
drop if covid_date!=""

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

safecount if egfr_baseline_creatinine_feb2017 <15
local 2017_3 = round(r(N),5)

*Unmatched
capture noisily import delimited ./output/input_combined_stps_covid_2017.csv, clear
keep patient_id death_date date_deregistered stp krt_outcome_date male covid_date covid_month set_id case match_counts
tempfile covid_2017_matched
save `covid_2017_matched', replace

capture noisily import delimited ./output/input_combined_stps_matches_2017.csv, clear
keep patient_id death_date date_deregistered stp krt_outcome_date male set_id case covid_date
tempfile 2017_matched
save `2017_matched', replace

capture noisily import delimited ./output/input_covid_2017_additional.csv, clear
merge 1:1 patient_id using `covid_2017_matched'
keep if _merge==3
drop _merge
tempfile covid_2017_complete
save `covid_2017_complete', replace

capture noisily import delimited ./output/input_2017_additional.csv, clear
merge 1:1 patient_id using `2017_matched'
keep if _merge==3
drop _merge
tempfile 2017_complete
save `2017_complete', replace

append using `covid_2017_complete', force
order patient_id set_id match_count case
gsort set_id -case

*Calculate unmatched
safecount if case==1
local covid_4 = round(((`covid_1' - `covid_3') - r(N)),5)
safecount if case==0
local 2017_4 = round(((`2017_1' - `2017_2' - `2017_3') - r(N)),5)

*IMD invalid
safecount if case==1 & imd==0
local covid_5 = round(r(N),5)
safecount if case==0 & imd==0
local 2017_5 = round(r(N),5)

drop if imd==0

* Region missing
rename region region_string
gen region = 1 if region_string=="East Midlands"
replace region = 2 if region_string=="East"
replace region = 3 if region_string=="London"
replace region = 4 if region_string=="North East"
replace region = 5 if region_string=="North West"
replace region = 6 if region_string=="South East"
replace region = 7 if region_string=="South West"
replace region = 8 if region_string=="West Midlands"
replace region = 9 if region_string=="Yorkshire and The Humber"
replace region = 10 if region_string==""

safecount if case==1 & region==10
local covid_6 = round(r(N),5)
safecount if case==0 & region==10
local 2017_6 = round(r(N),5)
drop if region==10

* Create new index date variable 28 days after case_index_date (i.e. to exclude anyone who does not survive to start follow-up)
gen index_date = date(case_index_date, "YMD")
format index_date %td
gen index_date_28 = index_date + 28
format index_date_28 %td

** Deregistered before index_date
gen deregistered_date = date(date_deregistered, "YMD")
format deregistered_date %td
drop date_deregistered 
safecount if deregistered_date < index_date_28 + 1 & case==1
local covid_7 = round(r(N),5)
safecount if deregistered_date < index_date_28 + 1 & case==0
local 2017_7 = round(r(N),5)
drop if deregistered_date < index_date_28 + 1

**Deceased before index date
gen death_date1 = date(death_date, "YMD")
format death_date1 %td
drop death_date
rename death_date1 death_date
gen deceased = 0
replace deceased = 1 if death_date < index_date_28 + 1
safecount if deceased==1 & case==1
local covid_8 = round(r(N),5)
safecount if deceased==1 & case==0
local 2017_8 = round(r(N),5)
drop if deceased==1

**Baseline eGFR <15
gen index_year = yofd(index_date)
gen age = index_year - year_of_birth
gen sex = 1 if male == "Male"
label var sex "Sex"
replace sex = 0 if male == "Female"
label define sex 0"Female" 1"Male"
label values sex sex
foreach baseline_creatinine_monthly of varlist 	baseline_creatinine_feb2017 ///
												baseline_creatinine_mar2017 ///
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
												baseline_creatinine_feb2020 ///
												baseline_creatinine_mar2020 ///
												baseline_creatinine_apr2020 ///
												baseline_creatinine_may2020 ///
												baseline_creatinine_jun2020 ///
												baseline_creatinine_jul2020 ///
												baseline_creatinine_aug2020 ///
												baseline_creatinine_sep2020 ///
												baseline_creatinine_oct2020 ///
												baseline_creatinine_nov2020 ///
												baseline_creatinine_dec2020 ///
												baseline_creatinine_jan2021 ///
												baseline_creatinine_feb2021 ///
												baseline_creatinine_mar2021 ///
												baseline_creatinine_apr2021 ///
												baseline_creatinine_may2021 ///
												baseline_creatinine_jun2021 ///
												baseline_creatinine_jul2021 ///
												baseline_creatinine_aug2021 ///
												baseline_creatinine_sep2021 ///
												baseline_creatinine_oct2021 ///
												baseline_creatinine_nov2021 ///
												baseline_creatinine_dec2021 ///
												baseline_creatinine_jan2022 ///
												baseline_creatinine_feb2022 ///
												baseline_creatinine_mar2022 ///
												baseline_creatinine_apr2022 ///
												baseline_creatinine_may2022 ///
												baseline_creatinine_jun2022 ///
												baseline_creatinine_jul2022 ///
												baseline_creatinine_aug2022 ///
												baseline_creatinine_sep2022 ///
												baseline_creatinine_oct2022 ///
												baseline_creatinine_nov2022 ///
												baseline_creatinine_dec2022 {
replace `baseline_creatinine_monthly' = . if !inrange(`baseline_creatinine_monthly', 20, 3000)
gen mgdl_`baseline_creatinine_monthly' = `baseline_creatinine_monthly'/88.4
gen min_`baseline_creatinine_monthly'=.
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if sex==0
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if sex==1
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.329 if sex==0
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.411 if sex==1
replace min_`baseline_creatinine_monthly' = 1 if min_`baseline_creatinine_monthly'<1
gen max_`baseline_creatinine_monthly'=.
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if sex==0
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if sex==1
replace max_`baseline_creatinine_monthly' = max_`baseline_creatinine_monthly'^-1.209
replace max_`baseline_creatinine_monthly' = 1 if max_`baseline_creatinine_monthly'>1
gen egfr_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'*max_`baseline_creatinine_monthly'*141
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*(0.993^age)
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*1.018 if sex==0
drop `baseline_creatinine_monthly'
drop mgdl_`baseline_creatinine_monthly'
drop min_`baseline_creatinine_monthly'
drop max_`baseline_creatinine_monthly'
}
gen index_date_string=string(index_date, "%td") 
gen index_month=substr(index_date_string ,3,7)
gen baseline_egfr=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022"
foreach x of local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if index_month=="`x'"
drop egfr_baseline_creatinine_`x'
}
gen baseline_esrd = 0
replace baseline_esrd = 1 if baseline_egfr <15
safecount if baseline_esrd==1 & case==1
local covid_9 = round(r(N),5)
safecount if baseline_esrd==1 & case==0
local 2017_9 = round(r(N),5)
drop if baseline_esrd==1

* Exclude unmatched after application of exclusions
generate match_counts1=.
order patient_id set_id match_counts match_counts1
bysort set_id: replace match_counts1=_N-1
replace match_counts1=. if case==0
drop match_counts
rename match_counts1 match_counts
drop if match_counts==0
* Keep valid sets
bysort set_id: egen set_case_mean = mean(case) // if mean of exposure var is 0 then only uncase in set, if 1 then only case in set
gen valid_set = (set_case_mean>0 & set_case_mean<1) // ==1 is valid set containing both case and uncase
keep if valid_set==1
safecount if case==1
local covid_10 = round(r(N),5)
safecount if case==0
local 2017_10 = round(r(N),5)


use ./output/analysis_2017.dta, clear

safecount if case==1
local covid_11 = round(r(N),5)

safecount if case==0
local 2017_11 = round(r(N),5)

forvalues i=1/11 {
file write tablecontent ("`lab`i''") _tab (`covid_`i'') _tab (`2017_`i'') _n
}

file close tablecontent