sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_2020_sens2.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_cca_2020_sens2.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Matched contemporary cohort") _n
file write tablecontent ("COVID-19 overall")
use ./output/analysis_complete_2020.dta, clear

*Sensivity analysis 2 = 30% reduction in eGFR
* 3% eGFR reduction (earliest month) (or ESRD)
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
gen egfr_30pc=0
replace egfr_30pc=1 if egfr_30pc_date!=.

stset exit_date_egfr_30pc, fail(egfr_30pc_date) origin(index_date_egfr_30pc) id(unique) scale(365.25)
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

file close tablecontent