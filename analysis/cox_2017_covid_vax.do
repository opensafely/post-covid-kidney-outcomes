sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_2017_covid_vax.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_2017_covid_vax.txt, write text replace
file write tablecontent ("Kidney outcomes after SARS-CoV-2 by COVID-19 vaccination status compared to matched historical general population") _n
file write tablecontent _n
file write tablecontent ("Historical general population matched on age, sex and STP") _n
file write tablecontent ("All models stratified by matched set and clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions) and sex") _n
file write tablecontent ("3. Additionally adjusted: additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: additionally adjusted for cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n
file write tablecontent ("By COVID-19 AKI") _n

use ./output/analysis_2017.dta, clear
foreach outcome of varlist esrd egfr_half aki death {
stset exit_date, fail(`outcome'_date) origin(index_date) id(patient_id) scale(365.25)

stcox i.covid_vax, vce(cluster practice_id) strata(set_id)
estimates save "crude_covid_vax_`outcome'", replace 
eststo model1
parmest, label eform format(estimate p lb ub) saving("crude_covid_vax_`outcome'", replace) idstr("crude_covid_vax_`outcome'") 
local hr "`hr' "crude_covid_vax_`outcome'" "

stcox i.covid_vax i.sex age1 age2 age3, vce(cluster practice_id) strata(set_id)
estimates save "minimal_covid_vax_`outcome'", replace 
eststo model2
parmest, label eform format(estimate p lb ub) saving("minimal_covid_vax_`outcome'", replace) idstr("minimal_covid_vax_`outcome'")
local hr "`hr' "minimal_covid_vax_`outcome'" "

stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.bmi i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
if _rc==0{
estimates
estimates save "additional_covid_vax_`outcome'", replace 
eststo model3
parmest, label eform format(estimate p lb ub) saving("additional_covid_vax_`outcome'", replace) idstr("additional_covid_vax_`outcome'") 
local hr "`hr' "additional_covid_vax_`outcome'" "
}
else di "WARNING MODEL1 DID NOT FIT (`outcome')"

stcox i.covid_vax i.sex i.ethnicity i.imd i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)		
if _rc==0{
estimates
estimates save "full_covid_vax_`outcome'", replace 
eststo model4
parmest, label eform format(estimate p lb ub) saving("full_covid_vax_`outcome'", replace) idstr("full_covid_vax_`outcome'") 
local hr "`hr' "full_covid_vax_`outcome'" "
}
else di "WARNING MODEL2 DID NOT FIT (`outcome')"
															
local lab0: label covid_vax 0
local lab1: label covid_vax 1
local lab2: label covid_vax 2
local lab3: label covid_vax 3
local lab4: label covid_vax 4
local lab5: label covid_vax 5

	qui safecount if covid_vax==0
	local denominator = r(N)
	qui safecount if covid_vax== 1 & `outcome'==1
	local event = r(N)
    bysort covid_vax: egen total_follow_up_`outcome' = total(_t)
	qui su total_follow_up_`outcome' if covid_vax==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	file write tablecontent _tab ("`lab0'") _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
forvalues vax=1/5 {
	qui safecount if covid_vax==`vax'
	local denominator = r(N)
	qui safecount if covid_vax == `vax' & `outcome'==1
	local event = r(N)
	qui su total_follow_up_`outcome' if covid_vax==`vax'
	local person_year = r(mean)/365.25
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab`vax''") _tab _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate ') _tab  
	cap estimates use "crude_covid_vax_`outcome'" 
	 cap lincom `vax'.covid_vax, eform
	file write tablecontent  _tab %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "minimal_covid_vax_`outcome'" 
	 cap lincom `vax'.covid_vax, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "additional_covid_vax_`outcome'" 
	 cap lincom `vax'.covid_vax, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "full_covid_vax_`outcome'" 
	 cap lincom `vax'.covid_vax, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab _n 
	}
}

file close tablecontent