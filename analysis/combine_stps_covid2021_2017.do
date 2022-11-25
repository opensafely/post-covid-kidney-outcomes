sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/combine_stps_2017B.log, replace t

*(1)=========Change source files to stata format============
foreach i of numlist 10 12 {
	capture noisily import delimited ./output/matched_cases_2017B_stp`i'.csv, clear
	capture noisily tempfile matched_cases_2017B_stp`i'
	capture noisily save `matched_cases_2017B_stp`i'', replace
}

*(2)=========Append separate cases files==========
use `matched_cases_2017B_stp10', clear
foreach i of numlist 10 12 {
	capture noisily append using `matched_cases_2017B_stp`i'', force
}

*save as .csv file for input into study definitions that add further variables, erase dta version
capture noisily export delimited using "./output/input_combined_stps_2017B.csv", replace

log close