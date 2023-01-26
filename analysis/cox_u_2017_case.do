sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_u_2017_case.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_u_2017_case.txt, write text replace
file write tablecontent ("Kidney outcomes after SARS-CoV-2 infection compared to matched historical general population") _n
file write tablecontent _n
file write tablecontent ("Historical general population matched on age, sex and STP") _n
file write tablecontent ("Restricted to those who survived 28 days after first recorded SARS-CoV-2 or equivalent date of matching") _n
file write tablecontent ("All models stratified by matched set and clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions) and sex") _n
file write tablecontent ("3. Additionally adjusted: additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: additionally adjusted for cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n
file write tablecontent ("By SARS-CoV-2 infection") _n

use ./output/analysis_2017.dta, clear
foreach outcome of varlist esrd egfr_half aki death {
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique) scale(365.25)
bysort case: egen total_follow_up_`outcome' = total(_t)

stcox i.case, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local crude_`outcome'_b: display %4.2f table[1,2]
local crude_`outcome'_ll: display %4.2f table[5,2]
local crude_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local minimal_`outcome'_b: display %4.2f table[1,2]
local minimal_`outcome'_ll: display %4.2f table[5,2]
local minimal_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3, vce(cluster set_id) strata(practice_id)
matrix table = r(table)
local additional_`outcome'_b: display %4.2f table[1,2]
local additional_`outcome'_ll: display %4.2f table[5,2]
local additional_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster set_id) strata(practice_id)		
matrix table = r(table)
local full_`outcome'_b: display %4.2f table[1,2]
local full_`outcome'_ll: display %4.2f table[5,2]
local full_`outcome'_ul: display %4.2f table[6,2]			
								
local lab0: label case 0
local lab1: label case 1

	qui safecount if case==0 & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case== 0 & `outcome'==1 & _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if case==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	file write tablecontent _tab ("`lab0'") _tab _tab (`denominator') _tab _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
	qui safecount if case==1  & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case == 1 & `outcome'==1 &  _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if case==1
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab1'") _tab _tab _tab (`denominator') _tab _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab  
	file write tablecontent  _tab %4.2f (`crude_`outcome'_b') _tab ("(") %4.2f (`crude_`outcome'_ll') (" - ") %4.2f (`crude_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`minimal_`outcome'_b') _tab ("(") %4.2f (`minimal_`outcome'_ll') (" - ") %4.2f (`minimal_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`additional_`outcome'_b') _tab ("(") %4.2f (`additional_`outcome'_ll') (" - ") %4.2f (`additional_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`full_`outcome'_b') _tab ("(") %4.2f (`full_`outcome'_ll') (" - ") %4.2f (`full_`outcome'_ul') (")") _tab _n
}

file close tablecontent