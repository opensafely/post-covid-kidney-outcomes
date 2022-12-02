sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/combine_stps_matches_20174.log, replace t

*(1)=========Change source files to stata format============
foreach i of numlist 5/10 12/17 20/27 29 33 35/37 40/44 49 {
	capture noisily import delimited ./output/matched_matches_20174_stp`i'.csv, clear
	capture noisily tempfile matched_matches_20174_stp`i'
	capture noisily save `matched_matches_20174_stp`i'', replace
}

*(2)=========Append separate cases files==========
use `matched_matches_20174_stp5', clear
foreach i of numlist 6/10 12/17 20/27 29 33 35/37 40/44 49 {
	capture noisily append using `matched_matches_20174_stp`i'', force
}

*save as .csv file for input into study definitions that add further variables, erase dta version
capture noisily export delimited using "./output/input_combined_stps_matches_20174.csv", replace

log close