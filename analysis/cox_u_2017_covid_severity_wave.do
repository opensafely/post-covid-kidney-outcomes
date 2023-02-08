sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_u_2017_covid_severity_wave.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_u_2017_covid_severity_wave.txt, write text replace
file write tablecontent ("Kidney outcomes by SARS-CoV-2 severity compared to matched historical general population comparator for each COVID-19 wave") _n
file write tablecontent _n
file write tablecontent ("Historical general population matched on age, sex and STP") _n
file write tablecontent ("Restricted to those who survived 28 days after first recorded SARS-CoV-2 or equivalent date of matching") _n
file write tablecontent ("All models stratified by matched set and clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions) and sex") _n
file write tablecontent ("3. Additionally adjusted: additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: additionally adjusted for CKD stage, cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n
file write tablecontent ("By SARS-CoV-2 severity") _n

use ./output/analysis_2017.dta, clear
foreach outcome of varlist esrd egfr_half aki death {
forvalues wave=1/4 {
use ./output/analysis_2017.dta, clear
drop if case!=0 & wave!=`wave'
bysort set_id: egen set_case_mean = mean(case) // if mean of exposure var is 0 then only uncase in set, if 1 then only case in set
gen valid_set = (set_case_mean>0 & set_case_mean<1) // ==1 is valid set containing both case and uncase
tab valid_set, miss
tab valid_set case, col
keep if valid_set==1
drop valid_set set_case_mean
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up_`outcome' = total(_t)

stcox i.covid_severity, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local crude_`outcome'_1b: display %4.2f table[1,2]
local crude_`outcome'_1ll: display %4.2f table[5,2]
local crude_`outcome'_1ul: display %4.2f table[6,2]
local crude_`outcome'_2b: display %4.2f table[1,3]
local crude_`outcome'_2ll: display %4.2f table[5,3]
local crude_`outcome'_2ul: display %4.2f table[6,3]
local crude_`outcome'_3b: display %4.2f table[1,4]
local crude_`outcome'_3ll: display %4.2f table[5,4]
local crude_`outcome'_3ul: display %4.2f table[6,4]

stcox i.covid_severity i.sex age1 age2 age3, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_`outcome'_1b: display %4.2f table[1,2]
local minimal_`outcome'_1ll: display %4.2f table[5,2]
local minimal_`outcome'_1ul: display %4.2f table[6,2]
local minimal_`outcome'_2b: display %4.2f table[1,3]
local minimal_`outcome'_2ll: display %4.2f table[5,3]
local minimal_`outcome'_2ul: display %4.2f table[6,3]
local minimal_`outcome'_3b: display %4.2f table[1,4]
local minimal_`outcome'_3ll: display %4.2f table[5,4]
local minimal_`outcome'_3ul: display %4.2f table[6,4]

stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local additional_`outcome'_1b: display %4.2f table[1,2]
local additional_`outcome'_1ll: display %4.2f table[5,2]
local additional_`outcome'_1ul: display %4.2f table[6,2]
local additional_`outcome'_2b: display %4.2f table[1,3]
local additional_`outcome'_2ll: display %4.2f table[5,3]
local additional_`outcome'_2ul: display %4.2f table[6,3]
local additional_`outcome'_3b: display %4.2f table[1,4]
local additional_`outcome'_3ll: display %4.2f table[5,4]
local additional_`outcome'_3ul: display %4.2f table[6,4]

stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)		
matrix table = r(table)
local full_`outcome'_1b: display %4.2f table[1,2]
local full_`outcome'_1ll: display %4.2f table[5,2]
local full_`outcome'_1ul: display %4.2f table[6,2]
local full_`outcome'_2b: display %4.2f table[1,3]
local full_`outcome'_2ll: display %4.2f table[5,3]
local full_`outcome'_2ul: display %4.2f table[6,3]
local full_`outcome'_3b: display %4.2f table[1,4]
local full_`outcome'_3ll: display %4.2f table[5,4]
local full_`outcome'_3ul: display %4.2f table[6,4]
															
local lab0: label covid_severity 0
local lab1: label covid_severity 1
local lab2: label covid_severity 2
local lab3: label covid_severity 3

	qui safecount if covid_severity==0 & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if covid_severity== 0 & `outcome'==1 & _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if covid_severity==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("Wave `wave' `outcome'") _n
	file write tablecontent _tab ("`lab0'") _tab _tab (`denominator') _tab _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
forvalues severity=1/3 {
	qui safecount if covid_severity==`severity' & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if covid_severity==`severity' & `outcome'==1 &  _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if covid_severity==`severity'
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab`severity''") _tab _tab (`denominator') _tab _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab
	file write tablecontent  _tab %4.2f (`crude_`outcome'_`severity'b') _tab ("(") %4.2f (`crude_`outcome'_`severity'll') (" - ") %4.2f (`crude_`outcome'_`severity'ul') (")")
	file write tablecontent  _tab %4.2f (`minimal_`outcome'_`severity'b') _tab ("(") %4.2f (`minimal_`outcome'_`severity'll') (" - ") %4.2f (`minimal_`outcome'_`severity'ul') (")")
	file write tablecontent  _tab %4.2f (`additional_`outcome'_`severity'b') _tab ("(") %4.2f (`additional_`outcome'_`severity'll') (" - ") %4.2f (`additional_`outcome'_`severity'ul') (")")
	file write tablecontent  _tab %4.2f (`full_`outcome'_`severity'b') _tab ("(") %4.2f (`full_`outcome'_`severity'll') (" - ") %4.2f (`full_`outcome'_`severity'ul') (")") _tab _n
	}
	}
}
file close tablecontent