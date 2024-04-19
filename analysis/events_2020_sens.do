sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_2020_sens.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_2020_sens.csv, write text replace
file write tablecontent ("sens") _tab ("outcome") _tab ("stratum") _tab ("denominator") _tab ("controls") _tab ("Events (COVID-19)") _tab ("Events (matched contemporary cohort)") _n
use ./output/analysis_complete_2020.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"


*Sensivity analysis 1 = eGFR = RRT only
gen index_date_krt = index_date
gen exit_date_krt = krt_date
format exit_date_krt %td
replace exit_date_krt = min(deregistered_date, death_date, end_date) if krt_date==.
gen follow_up_time_krt = (exit_date_krt - index_date_krt)
label var follow_up_time_krt "Follow-up time (Days)"
gen follow_up_cat_krt = follow_up_time_krt
recode follow_up_cat_krt	min/-29=1 	///
						-28/-1=2 	///
						0=3			///
						1/365=4 	///
						366/730=5	///
						731/1040=6	///					
						1041/max=7
label define follow_up_cat_krt 	1 "<-29 days" 	///
							2 "-28 to -1 days" 		///
							3 "0 days"				///
							4 "1 to 365 days"		///
							5 "366 to 730 days" 	///
							6 "731 to 1040 days"	///
							7 ">1040 days"
label values follow_up_cat_krt follow_up_cat_krt
label var follow_up_cat_krt "Follow_up time"
tab case follow_up_cat_krt
tab covid_krt follow_up_cat_krt
drop if follow_up_time_krt<1
drop if follow_up_time_krt>1040
tab case follow_up_cat_krt
tab covid_krt follow_up_cat_krt
gen follow_up_years_krt = follow_up_time_krt/365.25


*Sensivity analysis 2 = 30% reduction in eGFR
* 30% eGFR reduction (earliest month) (or ESRD)
gen egfr_30pc_date=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year {
  replace egfr_30pc_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_30pc_date==.& egfr_creatinine_`x'<0.7*baseline_egfr & date("01`x'", "DMY")>index_date
  format egfr_30pc_date %td
}
replace egfr_30pc_date=esrd_date if egfr_30pc_date==.
* Index date (50% eGFR reduction)
gen index_date_egfr_30pc = index_date
replace index_date_egfr_30pc =. if baseline_egfr==.
* Exit date (50% eGFR reduction)
gen exit_date_egfr_30pc = egfr_30pc_date
format exit_date_egfr_30pc %td
replace exit_date_egfr_30pc = min(deregistered_date,death_date,end_date) if egfr_30pc_date==. & index_date_egfr_30pc!=.
gen follow_up_time_egfr_30pc = (exit_date_egfr_30pc - index_date_egfr_30pc)

*Sensivity analysis 3 - outcome = ESRD + eGFR <30
drop if baseline_egfr <30
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n
gen egfr30_date=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year  {
  replace egfr30_date=date("15`x'", "DMY") if egfr30_date==.& egfr_creatinine_`x'<30 & date("01`x'", "DMY")>index_date
}
format egfr30_date %td
* CKD4 date
gen index_date_ckd4 = index_date
gen ckd4_date = egfr30_date
format ckd4_date %td
replace ckd4_date = krt_date if ckd4_date==.
gen exit_date_ckd4 = ckd4_date
format exit_date_ckd4 %td
replace exit_date_ckd4 = min(deregistered_date, death_date, end_date) if ckd4_date==.
gen follow_up_time_ckd4 = (exit_date_ckd4 - index_date_ckd4)
label var follow_up_time_ckd4 "Follow-up time (Days)"
gen follow_up_cat_ckd4 = follow_up_time_ckd4
recode follow_up_cat_ckd4	min/-29=1 	///
						-28/-1=2 	///
						0=3			///
						1/365=4 	///
						366/730=5	///
						731/1040=6	///					
						1041/max=7
label define follow_up_cat_ckd4 	1 "<-29 days" 	///
							2 "-28 to -1 days" 		///
							3 "0 days"				///
							4 "1 to 365 days"		///
							5 "366 to 730 days" 	///
							6 "731 to 1040 days"	///
							7 ">1040 days"
label values follow_up_cat_ckd4 follow_up_cat_ckd4
label var follow_up_cat_ckd4 "Follow_up time"
tab case follow_up_cat_ckd4
tab covid_krt follow_up_cat_ckd4
drop if follow_up_time_ckd4<1
drop if follow_up_time_ckd4>1040
tab case follow_up_cat_ckd4
tab covid_krt follow_up_cat_ckd4
gen follow_up_years_ckd4 = follow_up_time_ckd4/365.25


local sensitivity "krt egfr_30pc ckd4"

local krt_lab "Kidney replacement therapy"
local egfr_30pc_lab "30% reduction in eGFR"
local ckd4_lab "eGFR <30ml/min/1.73m2"

local krt_sens "Sensitivity analysis 1"
local egfr_30pc_sens "Sensitivity analysis 2"
local ckd4_sens "Sensitivity analysis 3"

foreach sens of local sensitivity {

stset exit_date_`sens', fail(`sens'_date) origin(index_date_`sens') id(unique) scale(365.25)

qui safecount if case==1 & _st==1
local cases_denom = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_denom = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("``sens'_sens'") _tab ("``sens'_lab'") _tab ("Overall") _tab (`cases_denom') _tab (`controls_denom') _tab (`cases_events') _tab (`controls_events') _n

forvalues i=1/2 {
qui safecount if covid_severity==`i' & _st==1
local denom`i' = round(r(N),5)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("``sens'_sens'") _tab ("``sens'_lab'") _tab ("`severity`i''") _tab ("`denom`i''") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}
}

*Sensivity analysis 4 - multiple imputation for missing ethnicity
use ./output/analysis_2020.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3

*Remove invalid sets with missing smoking/BMI data
foreach var of varlist bmi smoking {
gen `var'_recorded = 0
replace `var'_recorded = 1 if case==1 & `var'!=.
replace `var'_recorded = 1 if case==0
bysort set_id: egen set_mean = mean(`var'_recorded)
drop if set_mean < 1
drop set_mean `var'_recorded
drop if case==0 & `var'==.
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n
}

*mi set the data
mi set mlong

*mi register 
mi register imputed ethnicity

noisily mi impute mlogit ethnicity esrd i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.agegroup i.sex i.stp i.covid_vax, add(10) rseed(70548) augment force // can maybe remove the force option in the server

mi stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

qui safecount if case==1 & _st==1
local cases_denom = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_denom = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("Sensitivity analysis 4") _tab ("Kidney failure (after multiple imputation for missing ethnicity)") _tab ("Overall") _tab (`cases_denom') _tab (`controls_denom') _tab (`cases_events') _tab (`controls_events') _n

forvalues i=1/2 {
qui safecount if covid_severity==`i' & _st==1
local denom`i' = round(r(N),5)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 4") _tab ("Kidney failure (after multiple imputation for missing ethnicity)") _tab ("`severity`i''") _tab ("`denom`i''") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}

*Sensitivity analysis 5 - restricting cases up to March 2023 (end of mass testing)
use ./output/analysis_2020.dta, clear
drop if index_date_esrd > 22735
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

qui safecount if case==1 & _st==1
local cases_denom = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_denom = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("Sensitivity analysis 5") _tab ("Kidney failure (COVID-19 up to March 2022)") _tab ("Overall") _tab (`cases_denom') _tab (`controls_denom') _tab (`cases_events') _tab (`controls_events') _n


forvalues i=1/2 {
qui safecount if covid_severity==`i' & _st==1
local denom`i' = round(r(N),5)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 5") _tab ("Kidney failure (COVID-19 up to March 2022)") _tab ("`severity`i''") _tab ("`denom`i''") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}

*Sensitivity analysis 6 - kidney failure excluding individuals with KRT during initial COVID illness
use ./output/analysis_2020.dta, clear
drop if covid_krt==3
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"

stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

qui safecount if case==1 & _st==1
local cases_denom = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_denom = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("Sensitivity analysis 6") _tab ("Kidney failure (excluding COVID-KRT)") _tab ("Overall") _tab (`cases_denom') _tab (`controls_denom') _tab (`cases_events') _tab (`controls_events') _n


forvalues i=1/2 {
qui safecount if covid_severity==`i' & _st==1
local denom`i' = round(r(N),5)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 6") _tab ("Kidney failure (excluding COVID-KRT)") _tab ("`severity`i''") _tab ("`denom`i''") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}

*Sensitivity analysis 7 - 50% reduction in eGFR excluding individuals with KRT during initial COVID illness
use ./output/analysis_2020.dta, clear
drop if covid_krt==3
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)

qui safecount if case==1 & _st==1
local cases_denom = round(r(N),5)
qui safecount if case==0 & _st==1
local controls_denom = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("Sensitivity analysis 7") _tab ("50% reduction in eGFR (excluding COVID-KRT)") _tab ("Overall") _tab (`cases_denom') _tab (`controls_denom') _tab (`cases_events') _tab (`controls_events') _n


forvalues i=1/2 {
qui safecount if covid_severity==`i' & _st==1
local denom`i' = round(r(N),5)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 7") _tab ("50% reduction in eGFR (excluding COVID-KRT)") _tab ("`severity`i''") _tab ("`denom`i''") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}

*ESRD vs 50% reduction in eGFR

qui safecount if case==1 & _d==1 & _st==1 & esrd_date==.
local cases_events = round(r(N),5)
file write tablecontent ("Sensitivity analysis 7") _tab ("50% reduction in eGFR only (without ESRD)") _tab ("Overall") _tab ("N/A") _tab ("N/A") _tab (`cases_events') _tab ("N/A") _n


forvalues i=1/2 {
qui safecount if covid_severity==`i' & _d==1 & _st==1 & esrd_date==.
local cases`i'_events = round(r(N),5)
}

forvalues i=1/2 {
file write tablecontent ("Sensitivity analysis 7") _tab ("50% reduction in eGFR only (without ESRD)") _tab ("`severity`i''") _tab ("N/A") _tab ("N/A") _tab (`cases`i'_events') _tab ("N/A") _n
}



file close tablecontent