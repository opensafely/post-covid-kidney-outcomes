sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_split_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_split_2020.csv, write text replace
file write tablecontent ("outcome") _tab ("split") _tab ("events") _n
use ./output/analysis_complete_2020.dta, clear

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1
local overall = round(r(N),5)

qui safecount if case==1 & _d==1 & _st==1 & esrd_date==.
local no_esrd = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1 & esrd_date!=.
local esrd = round(r(N),5)

file write tablecontent ("50% reduction in eGFR") _tab ("Overall") _tab (`overall') _n
file write tablecontent ("50% reduction in eGFR") _tab ("50% reduction in eGFR") _tab (`no_esrd') _n
file write tablecontent ("50% reduction in eGFR") _tab ("Kidney failure") _tab (`esrd') _n

stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
qui safecount if case==1 & _d==1 & _st==1
local overall = round(r(N),5)

qui safecount if case==1 & _d==1 & _st==1 & esrd_date==.
local no_esrd = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1 & esrd_date!=.
local esrd = round(r(N),5)

qui safecount if case==1 & _d==1 & _st==1 & egfr15_date==. & esrd_date==.
local no_egfr15 = round(r(N),5)
qui safecount if case==1 & _d==1 & _st==1 & egfr15_date!=.
local egfr15 = round(r(N),5)

file write tablecontent ("Death") _tab ("Overall") _tab (`overall') _n
file write tablecontent ("Death") _tab ("Without kidney failure") _tab (`no_esrd') _n
file write tablecontent ("Death") _tab ("With kidney failure") _tab (`esrd') _n
file write tablecontent ("Death") _tab ("eGFR >15") _tab (`no_egfr15') _n
file write tablecontent ("Death") _tab ("eGFR <15") _tab (`egfr15') _n

file close tablecontent