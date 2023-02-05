sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_u_hospitalised_case_interactions.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cox_u_hospitalised_case_interactions.txt, write text replace
file write tablecontent ("Kidney outcomes after COVID-19 hospitalisation compared to a pre-pandemic population hospitalised for pneumonia by critical care admission and acute kidney injury") _n
file write tablecontent _n
file write tablecontent ("Populations restricted to those who survived 28 days after hospital admission") _n
file write tablecontent ("Clustering by general practice accounted for using robust standard errors") _n
file write tablecontent _n
file write tablecontent ("Cox regression models:") _n
file write tablecontent ("1. Crude") _n
file write tablecontent ("2. Minimally adjusted: adjusted for age (using spline functions), sex and calendar month") _n
file write tablecontent ("3. Additionally adjusted: Additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, body mass index and smoking") _n
file write tablecontent ("4. Fully adjusted: Additionally adjusted for CKD stage, cardiovascular diseases, diabetes, hypertension, immunocompromise and cancer") _n
file write tablecontent _n
file write tablecontent _tab _tab _tab _tab _tab _tab ("Number") _tab ("Event") _tab ("Total person-years") _tab ("Rate per 100,000") _tab ("Crude") _tab _tab _tab _tab _tab _tab _tab ("Minimally adjusted") _tab _tab _tab _tab _tab ("Additionally adjusted") _tab _tab _tab _tab _tab ("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab _tab ("p-value for interaction") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("p-value for interaction") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("p-value for interaction") _tab _tab ("HR") _tab ("95% CI") _tab _tab ("p-value for interaction") _n

use ./output/analysis_hospitalised.dta, clear
foreach interaction of varlist critical_care adm_aki {
foreach outcome of varlist esrd egfr_half aki death {
use ./output/analysis_hospitalised.dta, clear
stset time_end_`outcome', fail(time_`outcome') origin(time_zero_`outcome') id(unique) scale(365.25)
	
stcox i.case##i.`interaction', vce(cluster practice_id)
matrix table = r(table)
local m1_p_`interaction'_`outcome': display %5.3f table[4,8]

stcox i.case##i.`interaction' i.sex age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m2_p_`interaction'_`outcome': display %5.3f table[4,8]

stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m3_p_`interaction'_`outcome': display %5.3f table[4,8]

stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)		
matrix table = r(table)
local m4_p_`interaction'_`outcome': display %5.3f table[4,8]
	
use ./output/analysis_hospitalised.dta, clear
drop if `interaction'==1
stset time_end_`outcome', fail(time_`outcome') origin(time_zero_`outcome') id(unique) scale(365.25)
bysort case: egen _t_0_`interaction'_`outcome' = total(_t)

stcox i.case, vce(cluster practice_id)
matrix table = r(table)
local m1_0_`outcome'_b: display %4.2f table[1,2]
local m1_0_`outcome'_ll: display %4.2f table[5,2]
local m1_0_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m2_0_`outcome'_b: display %4.2f table[1,2]
local m2_0_`outcome'_ll: display %4.2f table[5,2]
local m2_0_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m3_0_`outcome'_b: display %4.2f table[1,2]
local m3_0_`outcome'_ll: display %4.2f table[5,2]
local m3_0_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.region i.urban i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)		
matrix table = r(table)
local m4_0_`outcome'_b: display %4.2f table[1,2]
local m4_0_`outcome'_ll: display %4.2f table[5,2]
local m4_0_`outcome'_ul: display %4.2f table[6,2]

local lab0: label case 0
local lab1: label case 1
local lab2: label `interaction' 0
local lab3: label `interaction' 1

	qui safecount if case==0 & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case== 0 & `outcome'==1 & _st==1
	local event = round(r(N),5)
	qui su _t_0_`interaction'_`outcome' if case==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent ("`interaction'-`outcome'") _n
	file write tablecontent _tab ("`lab0' `lab2'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab ("1.00") _tab _tab _tab %5.3f (`m1_p_`interaction'_`outcome'') _tab _tab _tab _tab ("1.00") _tab _tab _tab %5.3f (`m2_p_`interaction'_`outcome'') _tab _tab _tab _tab ("1.00") _tab _tab _tab %5.3f (`m3_p_`interaction'_`outcome'') _tab _tab _tab _tab ("1.00") _tab _tab _tab %5.3f (`m4_p_`interaction'_`outcome'') _n
	
	qui safecount if case==1  & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case == 1 & `outcome'==1 &  _st==1
	local event = round(r(N),5)
	qui su _t_0_`interaction'_`outcome' if case==1
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab1' `lab2'") _tab _tab _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') 
	file write tablecontent _tab _tab _tab %4.2f (`m1_0_`outcome'_b') _tab ("(") %4.2f (`m1_0_`outcome'_ll') (" - ") %4.2f (`m1_0_`outcome'_ul') (")")
	file write tablecontent _tab _tab _tab _tab _tab %4.2f (`m2_0_`outcome'_b') _tab ("(") %4.2f (`m2_0_`outcome'_ll') (" - ") %4.2f (`m2_0_`outcome'_ul') (")")
	file write tablecontent _tab _tab _tab _tab _tab %4.2f (`m3_0_`outcome'_b') _tab ("(") %4.2f (`m3_0_`outcome'_ll') (" - ") %4.2f (`m3_0_`outcome'_ul') (")")
	file write tablecontent _tab _tab _tab _tab _tab %4.2f (`m4_0_`outcome'_b') _tab ("(") %4.2f (`m4_0_`outcome'_ll') (" - ") %4.2f (`m4_0_`outcome'_ul') (")") _tab _n _n

use ./output/analysis_hospitalised.dta, clear
drop if `interaction'==0
stset time_end_`outcome', fail(time_`outcome') origin(time_zero_`outcome') id(unique) scale(365.25)
bysort case: egen _t_1_`interaction'_`outcome' = total(_t)

stcox i.case, vce(cluster practice_id)
matrix table = r(table)
local m1_1_`outcome'_b: display %4.2f table[1,2]
local m1_1_`outcome'_ll: display %4.2f table[5,2]
local m1_1_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m2_1_`outcome'_b: display %4.2f table[1,2]
local m2_1_`outcome'_ll: display %4.2f table[5,2]
local m2_1_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
matrix table = r(table)
local m3_1_`outcome'_b: display %4.2f table[1,2]
local m3_1_`outcome'_ll: display %4.2f table[5,2]
local m3_1_`outcome'_ul: display %4.2f table[6,2]

stcox i.case i.sex i.ethnicity i.imd i.region i.urban i.bmi i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)		
matrix table = r(table)
local m4_1_`outcome'_b: display %4.2f table[1,2]
local m4_1_`outcome'_ll: display %4.2f table[5,2]
local m4_1_`outcome'_ul: display %4.2f table[6,2]

local lab0: label case 0
local lab1: label case 1
local lab2: label `interaction' 0
local lab3: label `interaction' 1

	qui safecount if case==0 & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case==0 & `outcome'==1 & _st==1
	local event = round(r(N),5)
	qui su _t_1_`interaction'_`outcome' if case==0
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	
	file write tablecontent _n
	file write tablecontent _tab ("`lab0' `lab3'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_year') _tab _tab %3.2f (`rate') _tab _tab _tab ("1.00") _tab _tab _tab _tab _tab _tab _tab ("1.00") _tab _tab _tab _tab _tab _tab _tab ("1.00") _tab _tab _tab _tab _tab _tab _tab ("1.00") _tab _tab _tab _n
	
	qui safecount if case==1  & `outcome'_denominator==1 & _st==1
	local denominator = round(r(N),5)
	qui safecount if case == 1 & `outcome'==1 &  _st==1
	local event = round(r(N),5)
	qui su _t_1_`interaction'_`outcome' if case==1
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	file write tablecontent _tab ("`lab1' `lab3'") _tab _tab _tab (`denominator') _tab (`event') _tab %11.1f (`person_year') _tab _tab %3.2f (`rate') 
	file write tablecontent  _tab _tab _tab %4.2f (`m1_1_`outcome'_b') _tab ("(") %4.2f (`m1_1_`outcome'_ll') (" - ") %4.2f (`m1_1_`outcome'_ul') (")")
	file write tablecontent  _tab _tab _tab _tab _tab %4.2f (`m2_1_`outcome'_b') _tab ("(") %4.2f (`m2_1_`outcome'_ll') (" - ") %4.2f (`m2_1_`outcome'_ul') (")")
	file write tablecontent  _tab _tab _tab _tab _tab %4.2f (`m3_1_`outcome'_b') _tab ("(") %4.2f (`m3_1_`outcome'_ll') (" - ") %4.2f (`m3_1_`outcome'_ul') (")")
	file write tablecontent  _tab _tab _tab _tab _tab %4.2f (`m4_1_`outcome'_b') _tab ("(") %4.2f (`m4_1_`outcome'_ll') (" - ") %4.2f (`m4_1_`outcome'_ul') (")") _tab _n _n
	
}
}