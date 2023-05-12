sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/deaths_2017_check.log, replace t
use ./output/analysis_2017.dta, clear
rename case expStatus
keep unique expStatus index_date deregistered_date set_id death_date 
*keep only comparators who have a death_date populated
keep if expStatus==0 & death_date!=.
*number of comparators who died
safecount
*number who died before start of follow_up
safecount if death_date<index_date
*number who died during follow-up, and eyeball case_index_date and index_date for these
safecount if death_date>=index_date & death_date<index_date+1095
preserve
	keep if death_date>=index_date & death_date<index_date+1095
	list index_date death_date 
restore
*number who died after end of follow-up
safecount if death_date>=case_index_date+1095
*eyeball random sample of 500 of these
keep if death_date>=case_index_date+1095
set seed 74925
generate random = runiform()
sort random
keep if _n<500
list index_date death_date
log close