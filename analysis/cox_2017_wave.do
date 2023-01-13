sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_2017_wave.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_2017_wave.txt, write text replace
file write tablecontent ("Kidney outcomes after SARS-CoV-2 by COVID-19 pandemic period compared to matched historical general population") _n
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

stcox i.wave, vce(cluster practice_id) strata(set_id)
estimates save "crude_wave_`outcome'", replace 
eststo model1
parmest, label eform format(estimate p lb ub) saving("crude_wave_`outcome'", replace) idstr("crude_wave_`outcome'") 
local hr "`hr' "crude_wave_`outcome'" "

stcox i.wave i.sex age1 age2 age3, vce(cluster practice_id) strata(set_id)
estimates save "minimal_wave_`outcome'", replace 
eststo model2
parmest, label eform format(estimate p lb ub) saving("minimal_wave_`outcome'", replace) idstr("minimal_wave_`outcome'")
local hr "`hr' "minimal_wave_`outcome'" "

stcox i.wave i.sex i.ethnicity i.imd i.urban i.bmi i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
if _rc==0{
estimates
estimates save "additional_wave_`outcome'", replace 
eststo model3
parmest, label eform format(estimate p lb ub) saving("additional_wave_`outcome'", replace) idstr("additional_wave_`outcome'") 
local hr "`hr' "additional_wave_`outcome'" "
}
else di "WARNING MODEL1 DID NOT FIT (`outcome')"

stcox i.wave i.sex i.ethnicity i.imd i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)		
if _rc==0{
estimates
estimates save "full_wave_`outcome'", replace 
eststo model4
parmest, label eform format(estimate p lb ub) saving("full_wave_`outcome'", replace) idstr("full_wave_`outcome'") 
local hr "`hr' "full_wave_`outcome'" "
}
else di "WARNING MODEL2 DID NOT FIT (`outcome')"					
							
local lab0: label wave 0
local lab1: label wave 1
local lab2: label wave 2
local lab3: label wave 3
local lab4: label wave 4
local lab5: label wave 5

	qui safecount if wave==0
	local denominator = r(N)
	qui safecount if wave== 1 & `outcome'==1
	local event = r(N)
    bysort wave: egen total_follow_up_`outcome' = total(_t)
	qui su total_follow_up_`outcome' if wave==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	file write tablecontent _tab ("`lab0'") _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	
forvalues wave=1/4 {
	qui safecount if wave==`wave'
	local denominator = r(N)
	qui safecount if wave == `wave' & `outcome'==1
	local event = r(N)
	qui su total_follow_up_`outcome' if wave==`wave'
	local person_year = r(mean)/365.25
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab`wave''") _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate ') _tab  
	cap estimates use "crude_wave_`outcome'" 
	 cap lincom `wave'.wave, eform
	file write tablecontent  _tab %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "minimal_wave_`outcome'" 
	 cap lincom `wave'.wave, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "additional_wave_`outcome'" 
	 cap lincom `wave'.wave, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "full_wave_`outcome'" 
	 cap lincom `wave'.wave, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab _n 
	}
}

file close tablecontent