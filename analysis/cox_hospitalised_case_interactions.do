sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_hospitalised_case_interactions.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_hospitalised_case_interactions.txt, write text replace
file write tablecontent ("Kidney outcomes after COVID-19 hospitalisation compared to a pre-pandemic population hospitalised for pneumonia by critical care admission and acute kidney injury") _n
file write tablecontent _n
file write tablecontent ("Populations restricted to those who survived 28 days after hospital admission") _n
file write tablecontent ("Clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions), sex and calendar month") _n
file write tablecontent ("3. Additionally adjusted: Additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: Additionally adjusted for cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n

use ./output/analysis_hospitalised.dta, clear

foreach interaction of varlist critical_care adm_aki {
gen pneumonia_`interaction' = 0 if case==0 & `interaction'==0
replace pneumonia_`interaction' = 1 if case==0 & `interaction'==1
gen covid_`interaction' = 0 if case==1 & `interaction'==0
replace covid_`interaction' = 1 if case==1 & `interaction'==1

foreach outcome of varlist esrd egfr_half aki death {
stset time_end_`outcome', fail(time_`outcome') origin(time_zero_`outcome') id(patient_id) scale(365.25)

forvalues i=0/1 {
stcox `i'.case##i.`interaction', vce(cluster practice_id)
matrix table = r(table)
local m1`i'`interaction'_`outcome'_b: display %4.2f table[1,5]
local m1`i'`interaction'_`outcome'_ll: display %4.2f table[5,5]
local m1`i'`interaction'_`outcome'_ul: display %4.2f table[6,5]

stcox `i'.case##i.`interaction' i.sex age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m2`i'`interaction'_`outcome'_b: display %4.2f table[1,5]
local m2`i'`interaction'_`outcome'_ll: display %4.2f table[5,5]
local m2`i'`interaction'_`outcome'_ul: display %4.2f table[6,5]

stcox `i'.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m3`i'`interaction'_`outcome'_b: display %4.2f table[1,5]
local m3`i'`interaction'_`outcome'_ll: display %4.2f table[5,5]
local m3`i'`interaction'_`outcome'_ul: display %4.2f table[6,5]

stcox `i'.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)		
matrix table = r(table)
local m4`i'`interaction'_`outcome'_b: display %4.2f table[1,5]
local m4`i'`interaction'_`outcome'_ll: display %4.2f table[5,5]
local m4`i'`interaction'_`outcome'_ul: display %4.2f table[6,5]


}										
local lab0: label `interaction' 0
local lab1: label `interaction' 1


	
	qui safecount if pneumonia_`interaction'==0 & `outcome'_denominator==1
	local denominator = r(N)
	local r_denominator = round(`denominator',5)
	qui safecount if pneumonia_`interaction'==0 & `outcome'==1
	local event = r(N)
	local r_event = round(`event',5)
    bysort pneumonia_`interaction': egen tfu0_`interaction'_`outcome' = total(_t)
	qui su tfu0_`interaction'_`outcome' if pneumonia_`interaction'==0
	local person_year = r(mean)
	local rate = 100000*(`r_event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	file write tablecontent _tab ("Pneumonia `lab0'") _tab _tab (`r_denominator') _tab (`r_event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	

	qui safecount if pneumonia_`interaction'==1 & `outcome'_denominator==1
	local denominator = r(N)
	local r_denominator = round(`denominator',5)
	qui safecount if pneumonia_`interaction'==1 & `outcome'==1
	local event = r(N)
	local r_event = round(`event',5)
	qui su tfu0_`interaction'_`outcome' if pneumonia_`interaction'==1
	local person_year = r(mean)
	local rate = 100000*(`r_event'/`person_year')
	file write tablecontent _tab ("Pneumonia `lab1'") _tab _tab (`r_denominator') _tab (`r_event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate ') _tab _tab
	file write tablecontent  _tab %4.2f (`m10`interaction'_`outcome'_b') _tab ("(") %4.2f (`m10`interaction'_`outcome'_ll') (" - ") %4.2f (`m10`interaction'_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`m20`interaction'_`outcome'_b') _tab ("(") %4.2f (`m20`interaction'_`outcome'_ll') (" - ") %4.2f (`m20`interaction'_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`m30`interaction'_`outcome'_b') _tab ("(") %4.2f (`m30`interaction'_`outcome'_ll') (" - ") %4.2f (`m30`interaction'_`outcome'_ul') (")")
	file write tablecontent  _tab %4.2f (`m40`interaction'_`outcome'_b') _tab ("(") %4.2f (`m40`interaction'_`outcome'_ll') (" - ") %4.2f (`m40`interaction'_`outcome'_ul') (")") _tab  _n
	
	
	qui safecount if covid_`interaction'==0 & `outcome'_denominator==1
	local denominator = r(N)
	local r_denominator = round(`denominator',5)
	qui safecount if covid_`interaction'==0 & `outcome'==1
	local event = r(N)
	local r_event = round(`event',5)
    bysort covid_`interaction': egen tfu1_`interaction'_`outcome' = total(_t)
	qui su tfu1_`interaction'_`outcome' if covid_`interaction'==0
	local person_year = r(mean)
	local rate = 100000*(`r_event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent _tab ("COVID-19 `lab0'") _tab _tab (`r_denominator') _tab (`r_event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
	qui safecount if covid_`interaction'==1 & `outcome'_denominator==1
	local denominator = r(N)
	local r_denominator = round(`denominator',5)
	qui safecount if covid_`interaction'==1 & `outcome'==1
	local event = r(N)
	local r_event = round(`event',5)
	qui su tfu1_`interaction'_`outcome' if covid_`interaction'==1
	local person_year = r(mean)
	local rate = 100000*(`r_event'/`person_year')
	file write tablecontent _tab ("COVID-19 `lab1'") _tab _tab (`r_denominator') _tab (`r_event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate ') _tab _tab
	file write tablecontent  _tab %4.2f (`m11`interaction'_`outcome'_b') _tab ("(") %4.2f (`m11`interaction'_`outcome'_ll') (" - ") %4.2f (`m11`interaction'_`outcome'_ul') (")") 
	file write tablecontent  _tab %4.2f (`m21`interaction'_`outcome'_b') _tab ("(") %4.2f (`m21`interaction'_`outcome'_ll') (" - ") %4.2f (`m21`interaction'_`outcome'_ul') (")") 
	file write tablecontent  _tab %4.2f (`m31`interaction'_`outcome'_b') _tab ("(") %4.2f (`m31`interaction'_`outcome'_ll') (" - ") %4.2f (`m31`interaction'_`outcome'_ul') (")") 
	file write tablecontent  _tab %4.2f (`m41`interaction'_`outcome'_b') _tab ("(") %4.2f (`m41`interaction'_`outcome'_ll') (" - ") %4.2f (`m41`interaction'_`outcome'_ul') (")") _tab  _n
}
}

file close tablecontent