sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/analysis_complete_hospitalised.log, replace t

use ./output/analysis_hospitalised.dta, clear
foreach var of varlist bmi smoking ethnicity {
drop if `var'==.
}
save ./output/analysis_complete_hospitalised.dta, replace

log close