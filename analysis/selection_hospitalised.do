sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/selection_hospitalised.log, replace t

cap file close tablecontent

file open tablecontent using ./output/selection_hospitalised.csv, write text replace
file write tablecontent _tab ("Hospitalised COVID-19") _tab ("Hospitalised pneumonia (pre-pandemic)") _n

local lab1 "Selected from OpenSAFELY"
local lab2 "After application of exclusion criteria"

capture noisily import delimited ./output/input_covid_hospitalised.csv, clear
tempfile covid_hospitalised
save `covid_hospitalised', replace
qui safecount
local covid_1 = round(r(N),5)

capture noisily import delimited ./output/input_pneumonia_hospitalised.csv, clear
tempfile pneumonia_hospitalised
save `pneumonia_hospitalised', replace
qui safecount
local pneumonia_1 = round(r(N),5)

use ./output/analysis_hospitalised.dta, clear

qui safecount if case==1
local covid_2 = round(r(N),5)

qui safecount if case==0
local pneumonia_2 = round(r(N),5)

forvalues i=1/2 {
file write tablecontent ("`lab`i''") _tab (`covid_`i'') _tab (`pneumonia_`i'') _n
}

file close tablecontent