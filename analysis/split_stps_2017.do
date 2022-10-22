sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/split_stps_2017.log, replace t


*(1)=========Split cases into separate stp files============
import delimited ./output/covid_matching.csv, clear

*stps are coded E54000005-9, 10, 12-17, 20-27, 29, 33, 35-37, 40-44, 49
*files need to be .csv format as this is what the matching program needs as input
foreach i of numlist 5/9 {
	preserve
		capture noisily keep if stp=="E5400000`i'"
		capture noisily export delimited using "./output/input_covid_matching_stp`i'.csv", replace
		count
	restore
}

foreach i of numlist 10 12/17 20/27 29 33 35/37 40/44 49 {
	preserve
		capture noisily keep if stp=="E540000`i'"
		capture noisily export delimited using "./output/input_covid_matching_stp`i'.csv", replace
		count
	restore
}

*(2)=========Split controls into separate stp files============
import delimited ./output/2017_matching.csv, clear

	*stps are coded E54000005-9, 10, 12-17, 20-27, 29, 33, 35-37, 40-44, 49
foreach i of numlist 5/9  {
	preserve
		capture noisily keep if stp=="E5400000`i'"
		capture noisily export delimited using "./output/input_2017_matching_stp`i'.csv", replace
		count
	restore
}

foreach i of numlist 10 12/17 20/27 29 33 35/37 40/44 49 {
	preserve
		capture noisily keep if stp=="E540000`i'"
		capture noisily export delimited using "./output/input_2017_matching_stp`i'.csv", replace
		count
	restore
}


log close
