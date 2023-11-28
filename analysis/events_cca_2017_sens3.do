sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_2017_sens3.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_cca_2017_sens3.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Matched historical cohort") _n
file write tablecontent ("COVID-19 overall")
use ./output/analysis_complete_2017.dta, clear

*Sensivity analysis 3 - outcome = ESRD + eGFR <30
gen egfr30_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
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
gen ckd4 = 0
replace ckd4 = 1 if ckd4_date!=.

stset exit_date_ckd4, fail(ckd4_date) origin(index_date_ckd4) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)


qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events') _tab (`controls_events') _n

file write tablecontent _n

file write tablecontent ("By COVID-19 severity") _n

local severity1: label covid_severity 1
local severity2: label covid_severity 2
local severity3: label covid_severity 3

bysort covid_severity: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/3 {
file write tablecontent ("`severity`i''") _tab (`cases`i'_events') _n
}
file write tablecontent _n


file write tablecontent ("By COVID-19 AKI") _n


local aki1: label covid_aki 1
local aki2: label covid_aki 2
local aki3: label covid_aki 3

forvalues i=1/3 {
qui safecount if covid_aki==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/3 {
file write tablecontent ("`aki`i''") _tab (`cases`i'_events') _n
}
file write tablecontent _n


file write tablecontent ("By COVID-19 wave") _n


local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _tab (`cases`i'_events') _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n


local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

forvalues i=1/5 {
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/5 {
file write tablecontent ("`vax`i''") _tab (`cases`i'_events') _n
}
file close tablecontent