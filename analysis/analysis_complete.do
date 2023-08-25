sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/analysis_complete.log, replace t

/*
Complete case analysis (BMI/smoking/ethnicity)
1. Drop whole set if case has missing data
2. Drop comparators with missing data
3. Drop whole set if all comparators have missing data
*/
local cohort "2017 2020"
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
foreach var of varlist bmi smoking ethnicity {
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
save ./output/analysis_complete_`x'.dta, replace
}
}

log close