sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_2017_sens1.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_cca_2017_sens1.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Matched historical cohort") _n
file write tablecontent ("COVID-19 overall")
use ./output/analysis_complete_2017.dta, clear

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
gen krt = 0
replace krt = 1 if krt_date!=.

stset exit_date_krt, fail(krt_date) origin(index_date_krt) id(unique) scale(365.25)
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