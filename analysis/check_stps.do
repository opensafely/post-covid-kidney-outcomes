sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/check_stps.log, replace t


*(1)=========Cases============
import delimited ./output/input_covid_matching.csv, clear
safetab stp


*(2)=========Controls============
import delimited ./output/input_contemporary_matching.csv, clear
safetab stp


log close