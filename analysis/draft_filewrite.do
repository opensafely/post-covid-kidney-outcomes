sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles

capture log close
log using ./logs/table_descriptive_2017.log, replace t

*list for use below
global table1Vars follow_up_time age agegroup sex imd ethnicity1 region stp urban smoking bmi baseline_egfr egfr_group ckd_stage diabetes hypertension cardiovascular immunosuppressed


use ./output/analysis_2017.dta, clear

/* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	cou
	local overalldenom=r(N)
	
	sum `variable' if `variable' `condition'
	**K Wing additional code to output variable category labels**
	local level=substr("`condition'",3,.)
	local lab: label `variable' `level'
	file write tablecontent (" `lab'") _tab
	
	/*this is the overall column - had to edit this so that the row totals are the SUM OF THE ROUNDED COUNTS FOR EXPOSED AND UNEXPOSED, not the rounded total (as these may not match)*/
	/*old code
	cou if `variable' `condition'
	local rowdenom = round(r(N),5)
	local colpct = 100*(r(N)/`overalldenom')
	*/
	*updated code where the row totals (i.e. the "Total" column) is the sum of the two rounded values for the exposed (COVID case) and unexposed (comparator) columns
	/*this is the overall column - had to edit this so that the row totals are the SUM OF THE ROUNDED COUNTS FOR EXPOSED AND UNEXPOSED, not the rounded total (as these may not match)*/
	forvalues i=0/1{
		cou if covid == `i' & `variable' `condition'
		local subTotal_`i'=round(r(N),5)
	}
	local rowdenom = `subTotal_0' + `subTotal_1'
	local colpct = 100*(`rowdenom'/`overalldenom')
	file write tablecontent %9.0f (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	/*this loops through groups*/
	forvalues i=0/1{
		safecount if covid==`i'
		local coldenom=r(N)
		cou if case == `i' & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		*file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
		file write tablecontent %9.0f (round(r(N),5)) (" (") %3.1f (`pct') (")") _tab
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


	qui summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	forvalues i=0/1{							
		qui summarize `variable' if case == `i', d
		file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}

file write tablecontent _n

	
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
file open tablecontent using ./output/table1_longCovidSymp_`1'.txt, write text replace

file write tablecontent ("Table 1: Demographic and clinical characteristics for exposed to COVID-19 and `1' matched unexposed") _n




* eth5 labelled columns *THESE WOULD BE HOUSEHOLD LABELS, eth5 is the equivalent of the hh size variable
*these are NOT ROUNDED - will do this manually in excel, am keeping them unrounded as a sanity check

local lab0: label case 0
local lab1: label case 1   
*for display n values
safecount if case==0
local comparator=r(N)
safecount if case==1
local case=r(N)
safecount
local total=r(N)

file write tablecontent _tab ("Total")	_tab ///			 
							 ("Unexposed (`1')")	_tab ///
							 ("Exposed")  			_n 	

							 
file write tablecontent _tab ("n=`total'")				  		  _tab ///
							 ("n=`comparator'")				  	_tab ///
							 ("n=`case'")  			  	  _n
							 


**DEMOGRAPHICS AND PREVIOUS COMRBIDITIES (more than one level, potentially missing)**
*Age
* Open Stata dataset
tab ageCat case, col
tabulatevariable, variable(ageCat) min(0) max(9)
file write tablecontent _n

*continous
sum age, detail
qui summarizevariable, variable(age) 
file write tablecontent _n

*Sex
tab sex case, col
tabulatevariable, variable(sex) min(0) max(1) 
file write tablecontent _n 

*IMD
tab imd case, col
tabulatevariable, variable(imd) min(1) max(5) 
file write tablecontent _n 

*Ethnicity
tab ethnicity case, col
tabulatevariable, variable(eth5Table1) min(1) max(6) 
file write tablecontent _n 

*Rural urban (binary)
tab rural_urban case, col
tabulatevariable, variable(rural_urbanBroad) min(0) max(1) 
file write tablecontent _n 

*Comorbidities (3 categories)
tab preExistComorbCat case, col
tabulatevariable, variable(preExistComorbCat) min(0) max(2) 
file write tablecontent _n 

*Previous consultations (3 categories)
tab gpCountCat case, col
tabulatevariable, variable(gpCountCat) min(0) max(2) 
file write tablecontent _n 


file write tablecontent _n _n


file close tablecontent


* Close log file 
log close
