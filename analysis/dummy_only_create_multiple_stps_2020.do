sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd


* Open a log file
cap log close
log using ./logs/dummy_only_create_multiple_stps_2020.log, replace t

*program for replacing stps that is called below
program drop _all
program replaceSTPs
	local low=0
	*divide total dataset by number of stps (=31)
	local increase=int(_N/31)
	*replace stps 5-9
	foreach i of numlist 5/9 {
		local high=`low'+`increase'
		replace stp="E5400000`i'" if _n>`low'& _n<`high'
		local low=`low'+ `increase'
	}
	count
	*replace all other stps
	*reset lower limit to take account that 5/9 have been done already
	local low=`increase'*5 
	foreach i of numlist 10 12/17 20/27 29 33 35/37 40/44 49 {
		local high=`low'+`increase'
		replace stp="E540000`i'" if _n>`low'& _n<`high'
		local low=`low'+ `increase'
	}
	count
	*tidy up remainder
	replace stp="E54000005" if stp=="STP1"
end


*(1)=========Create separate stps for cases============
import delimited ./output/covid_matching.csv, clear
*tabulate before changes
tab stp
*call program
replaceSTPs
*tabulate after changes
tab stp, miss
*export output
export delimited using "./output/covid_matching.csv", replace




*(2)=========Create separate stps for comparators============
import delimited ./output/2020_matching.csv, clear
*tabulate before changes
tab stp
*call program
replaceSTPs
*tabulate after changes
tab stp
*export output
export delimited using "./output/2020_matching.csv", replace


log close