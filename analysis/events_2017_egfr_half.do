sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_crude_2017_egfr_half.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_crude_2017_egfr_half.csv, write text replace
file write tablecontent _tab ("Events") _n
file write tablecontent _tab ("COVID-19") _tab ("General population (pre-pandemic)") _n
file write tablecontent ("COVID-19 overall") _n
file write tablecontent ("Overall") _tab
use ./output/analysis_2017.dta, clear
stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)


qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n

local period "29 89 179 max"

local lab29 "0-29 days"
local lab89 "30-89 days"
local lab179 "90-179 days"
local labmax "180+ days"

foreach x of local period {
file write tablecontent ("`lab`x''") _tab
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n

}

file write tablecontent _n

file write tablecontent ("By COVID-19 severity") _n

use ./output/analysis_2017.dta, clear

local severity1: label covid_severity 1
local severity2: label covid_severity 2
local severity3: label covid_severity 3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

bysort covid_severity: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/3 {
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events`x' = round(r(N),5)
}
}

forvalues i=1/3 {
file write tablecontent ("`severity`i''") _n
file write tablecontent ("Overall") _tab (`cases`i'_events') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab (`cases`i'_events`x'') _n
}
}
file write tablecontent _n


file write tablecontent ("By COVID-19 AKI") _n

use ./output/analysis_2017.dta, clear

local aki1: label covid_aki 1
local aki2: label covid_aki 2
local aki3: label covid_aki 3

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/3 {
qui safecount if covid_aki==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/3 {
qui safecount if covid_aki==`i' & _d==1 & _st==1
local cases`i'_events`x' = round(r(N),5)
}
}

forvalues i=1/3 {
file write tablecontent ("`aki`i''") _n
file write tablecontent ("Overall") _tab (`cases`i'_events') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab (`cases`i'_events`x'') _n
}
}
file write tablecontent _n


file write tablecontent ("By COVID-19 wave") _n

use ./output/analysis_2017.dta, clear

local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events`x' = round(r(N),5)
}
}

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _n
file write tablecontent ("Overall") _tab (`cases`i'_events') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab (`cases`i'_events`x'') _n
}
}
file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n

use ./output/analysis_2017.dta, clear

local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/5 {
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

foreach x of local period {
stset exit_date`x'_egfr_half, fail(egfr_half_date`x') origin(index_date`x'_egfr_half) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)

forvalues i=1/5 {
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events`x' = round(r(N),5)
}
}

forvalues i=1/5 {
file write tablecontent ("`vax`i''") _n
file write tablecontent ("Overall") _tab (`cases`i'_events') _n
foreach x of local period {
file write tablecontent ("`lab`x''") _tab (`cases`i'_events`x'') _n
}
}
file close tablecontent