sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/selection_hospitalised.log, replace t

cap file close tablecontent

file open tablecontent using ./output/selection_hospitalised.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Contemporary comparator") _n

local lab1 "Extracted from OpenSAFELY"
local lab2 "Invalid IMD"
local lab3 "Baseline eGFR <15"
local lab4 "Final analysis dataset"


**Extracted from OpenSAFELY
capture noisily import delimited ./output/input_covid_hospitalised.csv, clear
tempfile covid_hospitalised
save `covid_hospitalised', replace
safecount
local covid_1 = round(r(N),5)

capture noisily import delimited ./output/input_pneumonia_hospitalised.csv, clear
tempfile pneumonia_hospitalised
save `pneumonia_hospitalised', replace
safecount
local pneumonia_1 = round(r(N),5)

append using `covid_hospitalised', force
gen case = covid
replace case = 0 if covid==.

*IMD invalid
safecount if case==1 & imd==0
local covid_2 = round(r(N),5)
safecount if case==0 & imd==0
local pneumonia_2 = round(r(N),5)
drop if imd==0

* Create new index date variable 28 days after case_index_date (i.e. to exclude anyone who does not survive to start follow-up)
gen index_date = date(patient_index_date, "YMD")
format index_date %td
gen index_date_28 = index_date + 28
format index_date_28 %td

* eGFR <15 before index_date
gen sex1 = 1 if sex=="M"
replace sex1 = 0 if sex=="F"
drop sex
rename sex1 sex
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
local covid_3 = round(r(N),5)
safecount if baseline_esrd==1 & case==0
local pneumonia_3 = round(r(N),5)
drop if baseline_esrd==1

use ./output/analysis_hospitalised.dta, clear

safecount if case==1
local covid_4 = round(r(N),5)

safecount if case==0
local pneumonia_4 = round(r(N),5)

forvalues i=1/4 {
file write tablecontent ("`lab`i''") _tab (`covid_`i'') _tab (`pneumonia_`i'') _n
}

file close tablecontent