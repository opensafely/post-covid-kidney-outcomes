sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_2020_wave.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_2020_wave.txt, write text replace
file write tablecontent ("Kidney outcomes after SARS-CoV-2 by COVID-19 pandemic period compared to matched contemporary controls") _n
file write tablecontent _n
file write tablecontent ("contemporary controls matched on age, sex and STP") _n
file write tablecontent ("Restricted to those who survived 28 days after first recorded SARS-CoV-2 or equivalent date of matching") _n
file write tablecontent ("All models stratified by general practice and clustering by matched set accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions) and sex") _n
file write tablecontent ("3. Additionally adjusted: additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: additionally adjusted for CKD stage, cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab ("Number") _tab _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab ("Minimally adjusted") _tab ("Additionally adjusted") _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("HR") _tab ("95% CI") _tab _tab _n
file write tablecontent ("By COVID-19 pandemic period") _n

use ./output/analysis_2020.dta, clear
foreach outcome of varlist esrd egfr_half aki death {
stset exit_date_`outcome', fail(`outcome'_date) origin(index_date_`outcome') id(unique) scale(365.25)
bysort wave case: egen total_follow_up_`outcome' = total(_t)

stcox i.case if wave==1, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local crude_`outcome'_1b: display %4.2f table[1,2]
local crude_`outcome'_1ll: display %4.2f table[5,2]
local crude_`outcome'_1ul: display %4.2f table[6,2]
stcox i.case if wave==2, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local crude_`outcome'_2b: display %4.2f table[1,2]
local crude_`outcome'_2ll: display %4.2f table[5,2]
local crude_`outcome'_2ul: display %4.2f table[6,2]
stcox i.case if wave==3, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local crude_`outcome'_3b: display %4.2f table[1,2]
local crude_`outcome'_3ll: display %4.2f table[5,2]
local crude_`outcome'_3ul: display %4.2f table[6,2]
stcox i.case if wave==4, vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local crude_`outcome'_4b: display %4.2f table[1,2]
local crude_`outcome'_4ll: display %4.2f table[5,2]
local crude_`outcome'_4ul: display %4.2f table[6,2]

stcox i.case##i.wave, vce(cluster practice_id) strata(set_id)
contrast i.case#i.wave

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&wave==1, cubic nknots(4)
stcox i.case i.sex age1 age2 age3 if wave==1,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_`outcome'_1b: display %4.2f table[1,2]
local minimal_`outcome'_1ll: display %4.2f table[5,2]
local minimal_`outcome'_1ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&wave==2, cubic nknots(4)
stcox i.case i.sex age1 age2 age3 if wave==2,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_`outcome'_2b: display %4.2f table[1,2]
local minimal_`outcome'_2ll: display %4.2f table[5,2]
local minimal_`outcome'_2ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&wave==3, cubic nknots(4)
stcox i.case i.sex age1 age2 age3 if wave==3,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_`outcome'_3b: display %4.2f table[1,2]
local minimal_`outcome'_3ll: display %4.2f table[5,2]
local minimal_`outcome'_3ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&wave==4, cubic nknots(4)
stcox i.case i.sex age1 age2 age3 if wave==4,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local minimal_`outcome'_4b: display %4.2f table[1,2]
local minimal_`outcome'_4ll: display %4.2f table[5,2]
local minimal_`outcome'_4ul: display %4.2f table[6,2]

drop age1 age2 age3
mkspline age = age if _st==1&sex!=., cubic nknots(4)
stcox i.case##i.wave i.sex age1 age2 age3,  vce(cluster practice_id) strata(set_id)
contrast i.case#i.wave

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&wave==1, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3 if wave==1,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local additional_`outcome'_1b: display %4.2f table[1,2]
local additional_`outcome'_1ll: display %4.2f table[5,2]
local additional_`outcome'_1ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&wave==2, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3 if wave==2,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local additional_`outcome'_2b: display %4.2f table[1,2]
local additional_`outcome'_2ll: display %4.2f table[5,2]
local additional_`outcome'_2ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&wave==3, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3 if wave==3,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local additional_`outcome'_3b: display %4.2f table[1,2]
local additional_`outcome'_3ll: display %4.2f table[5,2]
local additional_`outcome'_3ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&wave==4, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3 if wave==4,  vce(cluster practice_id) strata(set_id)
matrix table = r(table)
local additional_`outcome'_4b: display %4.2f table[1,2]
local additional_`outcome'_4ll: display %4.2f table[5,2]
local additional_`outcome'_4ul: display %4.2f table[6,2]

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
stcox i.case##i.wave i.sex i.ethnicity i.imd i.urban i.region i.bmi i.smoking age1 age2 age3 ,  vce(cluster practice_id) strata(set_id)
contrast i.case#i.wave

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&ckd_stage!=.&cardiovascular!=.&diabetes!=.&hypertension!=.&immunosuppressed!=.&non_haem_cancer!=.&wave==1, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 if wave==1,  vce(cluster practice_id) strata(set_id)	
matrix table = r(table)
local full_`outcome'_1b: display %4.2f table[1,2]
local full_`outcome'_1ll: display %4.2f table[5,2]
local full_`outcome'_1ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&ckd_stage!=.&cardiovascular!=.&diabetes!=.&hypertension!=.&immunosuppressed!=.&non_haem_cancer!=.&wave==2, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 if wave==2,  vce(cluster practice_id) strata(set_id)	
matrix table = r(table)
local full_`outcome'_2b: display %4.2f table[1,2]
local full_`outcome'_2ll: display %4.2f table[5,2]
local full_`outcome'_2ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&ckd_stage!=.&cardiovascular!=.&diabetes!=.&hypertension!=.&immunosuppressed!=.&non_haem_cancer!=.&wave==3, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 if wave==3,  vce(cluster practice_id) strata(set_id)	
matrix table = r(table)
local full_`outcome'_3b: display %4.2f table[1,2]
local full_`outcome'_3ll: display %4.2f table[5,2]
local full_`outcome'_3ul: display %4.2f table[6,2]
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&ckd_stage!=.&cardiovascular!=.&diabetes!=.&hypertension!=.&immunosuppressed!=.&non_haem_cancer!=.&wave==4, cubic nknots(4)
stcox i.case i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 if wave==4,  vce(cluster practice_id) strata(set_id)	
matrix table = r(table)
local full_`outcome'_4b: display %4.2f table[1,2]
local full_`outcome'_4ll: display %4.2f table[5,2]
local full_`outcome'_4ul: display %4.2f table[6,2]				

drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&ckd_stage!=.&cardiovascular!=.&diabetes!=.&hypertension!=.&immunosuppressed!=.&non_haem_cancer!=., cubic nknots(4)
stcox i.case##i.wave i.sex i.ethnicity i.imd i.urban i.region i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3,  vce(cluster practice_id) strata(set_id)	
contrast i.case#i.wave
		
local lab1: label wave 1
local lab2: label wave 2
local lab3: label wave 3
local lab4: label wave 4

	file write tablecontent _n
	file write tablecontent ("`outcome'") _n
	
forvalues wave=1/4 {
	qui safecount if wave==`wave'  & case==0&`outcome'_denominator==1 & _st==1
	local denominator0 = round(r(N),5)
	qui safecount if wave==`wave' & case==0&_d==1 &  _st==1
	local event0 = round(r(N),5)
	qui su total_follow_up_`outcome' if wave==`wave'& case==0
	local person_year0 = r(mean)
	local rate0 = 100000*(`event0'/`person_year0')
	qui safecount if wave==`wave'  & case==1&`outcome'_denominator==1 & _st==1
	local denominator1 = round(r(N),5)
	qui safecount if wave==`wave' & case==1&_d==1 &  _st==1
	local event1 = round(r(N),5)
	qui su total_follow_up_`outcome' if wave==`wave'& case==1
	local person_year1 = r(mean)
	local rate1 = 100000*(`event1'/`person_year1')	
	file write tablecontent _tab ("`lab`wave''case0") _tab _tab (`denominator0') _tab _tab (`event0') _tab %10.0f (`person_year0') _tab _tab %3.2f (`rate0') _tab _tab _tab
	file write tablecontent ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _tab _tab _tab ("1.00") _n
	file write tablecontent _tab ("`lab`wave''case1") _tab _tab (`denominator1') _tab _tab (`event1') _tab %10.0f (`person_year1') _tab _tab %3.2f (`rate1') _tab _tab
	file write tablecontent  _tab %4.2f (`crude_`outcome'_`wave'b') _tab ("(") %4.2f (`crude_`outcome'_`wave'll') (" - ") %4.2f (`crude_`outcome'_`wave'ul') (")")
	file write tablecontent  _tab %4.2f (`minimal_`outcome'_`wave'b') _tab ("(") %4.2f (`minimal_`outcome'_`wave'll') (" - ") %4.2f (`minimal_`outcome'_`wave'ul') (")")
	file write tablecontent  _tab %4.2f (`additional_`outcome'_`wave'b') _tab ("(") %4.2f (`additional_`outcome'_`wave'll') (" - ") %4.2f (`additional_`outcome'_`wave'ul') (")")
	file write tablecontent  _tab %4.2f (`full_`outcome'_`wave'b') _tab ("(") %4.2f (`full_`outcome'_`wave'll') (" - ") %4.2f (`full_`outcome'_`wave'ul') (")") _tab _n
	}
}

file close tablecontent
