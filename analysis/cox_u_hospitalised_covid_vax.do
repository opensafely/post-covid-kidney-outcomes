sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_u_hospitalised_covid_vax.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_u_hospitalised_covid_vax.txt, write text replace
file write tablecontent ("Kidney outcomes after COVID-19 hospitalisation by vaccination status compared to a pre-pandemic population hospitalised for pneumonia") _n
file write tablecontent _n
file write tablecontent ("Populations restricted to those who survived 28 days after hospital admission") _n
file write tablecontent ("Clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions), sex and calendar month") _n
file write tablecontent ("3. Additionally adjusted: additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: additionally adjusted for cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n

use ./output/analysis_hospitalised.dta, clear
foreach outcome of varlist esrd egfr_half aki death {
stset time_end_`outcome', fail(time_`outcome') origin(time_zero_`outcome') id(unique) scale(365.25)
bysort covid_vax: egen total_follow_up_`outcome' = total(_t)

stcox i.covid_vax, vce(cluster practice_id)
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
local crude_`outcome'_4b: display %4.2f table[1,5]
local crude_`outcome'_4ll: display %4.2f table[5,5]
local crude_`outcome'_4ul: display %4.2f table[6,5]
local crude_`outcome'_5b: display %4.2f table[1,6]
local crude_`outcome'_5ll: display %4.2f table[5,6]
local crude_`outcome'_5ul: display %4.2f table[6,6]

stcox i.covid_vax i.sex age1 age2 age3 i.month, vce(cluster practice_id)
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
local minimal_`outcome'_4b: display %4.2f table[1,5]
local minimal_`outcome'_4ll: display %4.2f table[5,5]
local minimal_`outcome'_4ul: display %4.2f table[6,5]
local minimal_`outcome'_5b: display %4.2f table[1,6]
local minimal_`outcome'_5ll: display %4.2f table[5,6]
local minimal_`outcome'_5ul: display %4.2f table[6,6]

stcox i.covid_vax i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
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
local additional_`outcome'_4b: display %4.2f table[1,5]
local additional_`outcome'_4ll: display %4.2f table[5,5]
local additional_`outcome'_4ul: display %4.2f table[6,5]
local additional_`outcome'_5b: display %4.2f table[1,6]
local additional_`outcome'_5ll: display %4.2f table[5,6]
local additional_`outcome'_5ul: display %4.2f table[6,6]

stcox i.covid_vax i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)		
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
local full_`outcome'_4b: display %4.2f table[1,5]
local full_`outcome'_4ll: display %4.2f table[5,5]
local full_`outcome'_4ul: display %4.2f table[6,5]
local full_`outcome'_5b: display %4.2f table[1,6]
local full_`outcome'_5ll: display %4.2f table[5,6]
local full_`outcome'_5ul: display %4.2f table[6,6]
										
local lab0: label covid_vax 0
local lab1: label covid_vax 1
local lab2: label covid_vax 2
local lab3: label covid_vax 3
local lab4: label covid_vax 4
local lab5: label covid_vax 5

	qui safecount if covid_vax==0 & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if covid_vax== 0 & `outcome'==1 & _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if covid_vax==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	file write tablecontent _tab ("`lab0'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
forvalues vax=1/5 {
	qui safecount if covid_vax==`vax'  & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if covid_vax==`vax' & `outcome'==1 &  _st==1
	local event = round(r(N),5)
	qui su total_follow_up_`outcome' if covid_vax==`vax'
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab`vax''") _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab
	file write tablecontent  _tab %4.2f (`crude_`outcome'_`vax'b') _tab ("(") %4.2f (`crude_`outcome'_`vax'll') (" - ") %4.2f (`crude_`outcome'_`vax'ul') (")")
	file write tablecontent  _tab %4.2f (`minimal_`outcome'_`vax'b') _tab ("(") %4.2f (`minimal_`outcome'_`vax'll') (" - ") %4.2f (`minimal_`outcome'_`vax'ul') (")")
	file write tablecontent  _tab %4.2f (`additional_`outcome'_`vax'b') _tab ("(") %4.2f (`additional_`outcome'_`vax'll') (" - ") %4.2f (`additional_`outcome'_`vax'ul') (")")
	file write tablecontent  _tab %4.2f (`full_`outcome'_`vax'b') _tab ("(") %4.2f (`full_`outcome'_`vax'll') (" - ") %4.2f (`full_`outcome'_`vax'ul') (")") _tab _n
	}
}

file close tablecontent