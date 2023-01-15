* Adapted from Rohini Mathur

capture log close
log using "logs/descriptive_2017.log", replace t

* Open Stata dataset
use ./output/analysis_2017, clear

 /* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	qui cou
	local overalldenom=r(N)
	local r_overalldenom = round(`overalldenom',5)
	
	qui sum `variable' if `variable' `condition'
	file write tablecontent (r(max)) _tab
	
	qui cou   if `variable' `condition'
	local rowdenom = r(N)
	local r_rowdenom = round(`rowdenom',5)
	local colpct = 100*(`r_rowdenom'/`r_overalldenom')
	file write tablecontent %9.0gc (`r_rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=0/1{
	qui cou if case == `i'
	local rowdenom = r(N)
	local r_rowdenom = round(`rowdenom',5)
	qui cou if case == `i' & `variable' `condition'
	local numerator = r(N)
	local r_numerator = round(`numerator',5)
	local pct = 100*(`r_numerator'/`rowdenom') 
	file write tablecontent %9.0gc (`r_numerator') (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end


* Output one row of table for co-morbidities and meds

cap prog drop generaterow2
program define generaterow2
syntax, variable(varname) condition(string) 
	
	qui cou
	local overalldenom=r(N)
	local r_overalldenom = round(`overalldenom',5)
	
	qui cou if `variable' `condition'
	local rowdenom = r(N)
	local r_rowdenom = round(`rowdenom',5)
	local colpct = 100*(`r_rowdenom'/`r_overalldenom')
	file write tablecontent %9.0gc (`r_rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=0/1{
	qui cou if case == `i'
	local rowdenom = r(N)
	local r_rowdenom = round(`rowdenom',5)
	qui cou if case == `i' & `variable' `condition'
	local numerator = r(N)
	local r_numerator = round(`numerator',5)
	local pct = 100*(`r_numerator'/`rowdenom') 
	file write tablecontent %9.0gc (`r_numerator') (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end



/* Explanatory Notes 
defines a program (SAS macro/R function equivalent), generate row
the syntax row specifies two inputs for the program: 
	a VARNAME which is your variable 
	a CONDITION which is a string of some condition you impose 
	
the program counts if variable and condition and returns the counts
column percentages are then automatically generated
this is then written to the text file 'tablecontent' 
the number followed by space, brackets, formatted pct, end bracket and then tab
the format %3.1f specifies length of 3, followed by 1 dp. 
*/ 

********************************************************************************
* Generic code to output one section (varible) within table (calls above)

cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) min(real) max(real) [missing]

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	forvalues varlevel = `min'/`max'{ 
		generaterow, variable(`variable') condition("==`varlevel'")
	}
	
	if "`missing'"!="" generaterow, variable(`variable') condition("== 12")
	


end

********************************************************************************

/* Explanatory Notes 
defines program tabulate variable 
syntax is : 
	- a VARNAME which you stick in variable 
	- a numeric minimum 
	- a numeric maximum 
	- optional missing option, default value is . 
forvalues lowest to highest of the variable, manually set for each var
run the generate row program for the level of the variable 
if there is a missing specified, then run the generate row for missing vals
*/ 

********************************************************************************
* Generic code to qui summarize a continous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 


	* Means for continuous variables
	/*qui summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	forvalues i=0/1{							
	qui summarize `variable' if case == `i', d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}*/

file write tablecontent

	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	
	forvalues i=0/1{
	qui summarize `variable' if case == `i', d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	}
	
file write tablecontent _n
	
end

/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using ./output/descriptive_2017_RM.csv, write text replace

file write tablecontent ("Table 1: Demographic and Clinical Characteristics") _n

local lab0: label case 0
local lab1: label case 1


file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab0'")  						  _tab ///
							 ("`lab1'")  						  _n 							 
							 


* DEMOGRAPHICS (more than one level, potentially missing) 

format age baseline_egfr follow_up_time %9.2f

gen byte Denominator=1
qui tabulatevariable, variable(Denominator) min(1) max(1) 
file write tablecontent _n 

qui summarizevariable, variable(follow_up_time) 
file write tablecontent _n

qui summarizevariable, variable(age) 
file write tablecontent _n

qui tabulatevariable, variable(sex) min(0) max(1) 
file write tablecontent _n 

qui tabulatevariable, variable(imd) min(1) max(5) 
file write tablecontent _n 

qui tabulatevariable, variable(ethnicity1) min(1) max(6)
file write tablecontent _n 

qui tabulatevariable, variable(region) min(1) max(9)
file write tablecontent _n 

qui tabulatevariable, variable(stp) min(1) max(35)
file write tablecontent _n 

qui tabulatevariable, variable(urban) min(0) max(1)
file write tablecontent _n 

qui tabulatevariable, variable(bmi) min(1) max(6)
file write tablecontent _n 

qui tabulatevariable, variable(smoking) min(0) max(1)
file write tablecontent _n 

qui summarizevariable, variable(baseline_egfr) 
file write tablecontent _n 

qui tabulatevariable, variable(egfr_group) min(1) max(7)  
file write tablecontent _n 

qui tabulatevariable, variable(ckd_stage) min(1) max(6)  
file write tablecontent _n 

* COMORBIDITIES (binary)
foreach comorb of varlist 		///
	cardiovascular		///
	diabetes			///
	hypertension		///
	immunosuppressed	///
	non_haem_cancer { 
	local comorb: subinstr local comorb "i." ""
	local lab: variable label `comorb'
	file write tablecontent ("`lab'") _tab
								
	generaterow2, variable(`comorb') condition("==1")
	file write tablecontent _n _n
}

file close tablecontent

* Close log file 
log close

*clear
*insheet using "$Tabfigdir/table1_eth5_nocarehomes.txt", clear