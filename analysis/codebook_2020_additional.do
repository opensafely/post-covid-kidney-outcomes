sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/codebook_2020_additional.log, replace t

capture noisily import delimited ./output/input_covid_2020_additional.csv, clear
codebook

capture noisily import delimited ./output/input_2020_additional.csv, clear
codebook

log close