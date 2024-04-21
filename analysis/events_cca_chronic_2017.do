sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_cca_chronic_2020.log, replace t

cap file close tablecontent
use ./output/analysis_complete_2017.dta, clear

file open tablecontent using ./output/events_cca_chronic_2020.csv, write text replace
file write tablecontent ("outcome") _tab ("stratum") _tab ("period") _tab ("events_covid") _tab ("events_control") _n


*ESRD redefined by not including KRT codes 28 days before COVID
gen chronic_krt_date = date(krt_outcome2_date, "YMD")
format chronic_krt_date %td
drop krt_outcome2_date
replace esrd_date=. if covid_krt==3
replace esrd_date=egfr15_date if esrd_date==.
replace esrd_date = chronic_krt_date if esrd_date==.
drop exit_date_esrd
gen exit_date_esrd = esrd_date
format exit_date_esrd %td
replace exit_date_esrd = min(deregistered_date, death_date, end_date) if esrd_date==.

*50% reduction in eGFR redefined by not including KRT codes 28 days before COVID
drop egfr_half_date
gen egfr_half_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year {
  replace egfr_half_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_half_date==.& egfr_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>index_date
  format egfr_half_date %td
}
replace egfr_half_date=esrd_date if egfr_half_date==.
drop exit_date_egfr_half
gen exit_date_egfr_half = egfr_half_date
format exit_date_egfr_half %td
replace exit_date_egfr_half = min(deregistered_date,death_date,end_date) if egfr_half_date==. & index_date_egfr_half!=.

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3
local severity1 "COVID-19 non-hospitalised"
local severity2 "COVID-19 hospitalised"

local outcomes "esrd egfr_half aki death"

local esrd_lab "Kidney failure"
local egfr_half_lab "50% reduction in eGFR"
local aki_lab "AKI"
local death_lab "Death"

local period "29 89 179 max"
local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach out of local outcomes {

stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("Overall") _tab ("Overall") _tab (`cases_events') _tab (`controls_events') _n

foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("Overall") _tab ("`lab`x''") _tab (`cases_events') _tab (`controls_events') _n
}


forvalues i=1/2 {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("`severity`i''") _tab ("Overall") _tab (`cases_events') _tab ("N/A") _n
foreach x of local period {
stset exit_date`x'_`out', fail(`out'_date`x') origin(index_date`x'_`out') id(unique) scale(365.25)
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases_events = round(r(N),5)
file write tablecontent ("``out'_lab'") _tab ("`severity`i''") _tab ("`lab`x''") _tab (`cases_events') _tab ("N/A") _n
}
}
}

file close tablecontent