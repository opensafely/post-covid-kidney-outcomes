clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models_severity_death.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_models_severity_death.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _n

local cohort "2017 2020"

*Age group
file write tablecontent ("Age") _n
label define agegroup 	1 "18-39" 		///
						2 "40-49" 		///
						3 "50-59" 		///
						4 "60-69" 		///
						5 "70-79"		///
						6 "80+"
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
qui stcox i.covid_severity##i.agegroup i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions
est store a
qui stcox i.covid_severity i.agegroup i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions
est store b
qui lrtest b a
local p1_`x' = r(p)
local p2_`x' .
local p3_`x' .
local p4_`x' .
local p5_`x' .
local p6_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/6 {
local label_`i': label agegroup `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if agegroup!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}


*Sex
file write tablecontent ("Sex") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p0_`x' = r(p)
local p1_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
local label_`i': label sex `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if sex!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p1_`x' = r(p)
local p2_`x' .
local p3_`x' .
local p4_`x' .
local p5_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if ethnicity!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.imd i.sex i.ethnicity i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.imd i.sex i.ethnicity i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p1_`x' = r(p)
local p2_`x' .
local p3_`x' .
local p4_`x' .
local p5_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label imd `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if imd!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.ethnicity i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}


*Diabetes
file write tablecontent ("Diabetes") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.diabetes i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p0_`x' = r(p)
local p1_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
label define diabetes 0 "No diabetes" 1 "Diabetes"
local label_`i': label diabetes `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if diabetes!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}

*Baseline eGFR
file write tablecontent ("Baseline eGFR") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&egfr_group!=., cubic nknots(4)
qui stcox i.covid_severity##i.egfr_group i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.egfr_group i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p1_`x' = r(p)
local p2_`x' .
local p3_`x' .
local p4_`x' .
local p5_`x' .
local p6_`x' .
local p7_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/7 {
local label_`i': label egfr_group `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if egfr_group!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=.&egfr_group!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.egfr_group i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}

*Previous AKI
file write tablecontent ("Previous AKI") _n
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.aki_baseline i.diabetes i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store a
qui stcox i.covid_severity i.diabetes i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3
est store b
qui lrtest b a
local p0_`x' = r(p)
local p1_`x' .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
local label_`i': label aki_baseline `i'
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
drop if aki_baseline!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.diabetes i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'_`x'')
}
file write tablecontent _n
}
}

*COVID-19 wave
file write tablecontent ("COVID-19 wave") _n
foreach x of local cohort {
use ./output/analysis_2020.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.wave i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3
est store a
qui stcox i.covid_severity i.wave i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3
est store b
qui lrtest b a
local p1 = r(p)
local p2 .
local p3 .
local p4 .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/4 {
local label_`i': label wave `i'
file write tablecontent ("`label_`i''")
use ./output/analysis_2020.dta, clear
drop if wave!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'') _n
}
}

*COVID-19 vaccination status
file write tablecontent ("COVID-19 vaccination") _n
foreach x of local cohort {
use ./output/analysis_2020.dta, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.covid_severity##i.covid_vax i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave age1 age2 age3
est store a
qui stcox i.covid_severity i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax i.wave age1 age2 age3
est store b
qui lrtest b a
local p1 = r(p)
local p2 .
local p3 .
local p4 .
local p5 .
}
forvalues j=1/3 {
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label covid_vax `i'
file write tablecontent ("`label_`i''")
use ./output/analysis_2020.dta, clear
drop if covid_vax!=`i'
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
bysort covid_severity: egen total_follow_up = total(_t)
qui su total_follow_up if covid_severity==`j'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave age1 age2 age3, vce(cluster practice_id)
matrix table = r(table)
local full_overall_b: display %4.2f table[1,(`j'+1)]
local full_overall_ll: display %4.2f table[5,(`j'+1)]
local full_overall_ul: display %4.2f table[6,(`j'+1)]
file write tablecontent _tab %4.2f (`full_overall_b') (" (") %4.2f (`full_overall_ll') ("-") %4.2f (`full_overall_ul') (")") _tab %5.4f (`p`i'') _n
}
}
file close tablecontent