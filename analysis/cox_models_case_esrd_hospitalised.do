clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models_case_esrd_hospitalised.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_models_case_esrd_hospitalised.csv, write text replace
file write tablecontent _tab ("COVID-19 crude rate (/100000py) (95% CI)") _tab ("Pneumonia (pre-pandemic) crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _n

use ./output/analysis_hospitalised.dta, clear

*Age group
file write tablecontent ("Age") _n
forvalues i=1/6 {
local label_`i': label agegroup `i'
}
file write tablecontent ("`label_1'")
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month i.agegroup
est store a
qui stcox i.case##i.agegroup i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month 
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
*return list
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/6 {
lincom 1.case + 1.case#`i'.agegroup, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
bysort case: egen total_follow_up = total(_t) if agegroup==1
qui su total_follow_up if case==1 & agegroup==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & agegroup==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & agegroup==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & agegroup==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %5.4f (`p')
file write tablecontent _n
forvalues i=2/6 {
local label_`i': label agegroup `i'
file write tablecontent ("`label_`i''")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if agegroup==`i'
qui su total_follow_up if case==1 & agegroup==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & agegroup==`i'
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & agegroup==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & agegroup==`i'
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _n
}


*Sex
file write tablecontent ("Sex") _n
forvalues i=0/1 {
local label_`i': label sex `i'
}
file write tablecontent ("`label_0'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_0b = r(estimate)
local int_0ll = r(lb)
local int_0ul = r(ub)
lincom 1.case + 1.case#1.sex, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
bysort case: egen total_follow_up = total(_t) if sex==0
qui su total_follow_up if case==1 & sex==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & sex==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & sex==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & sex==0
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_0b') (" (") %4.2f (`int_0ll') ("-") %4.2f (`int_0ul') (")") _tab %5.4f (`p')
file write tablecontent _n
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if sex==1
qui su total_follow_up if case==1 & sex==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & sex==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & sex==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & sex==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _n

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.ethnicity i.sex i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
lincom 1.case + 1.case#`i'.ethnicity, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
bysort case: egen total_follow_up = total(_t) if ethnicity==1
qui su total_follow_up if case==1 & ethnicity==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & ethnicity==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & ethnicity==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & ethnicity==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %5.4f (`p')
file write tablecontent _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if ethnicity==`i'
qui su total_follow_up if case==1 & ethnicity==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & ethnicity==`i'
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & ethnicity==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & ethnicity==`i'
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues i=1/5 {
local label_`i': label imd `i'
}
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.imd i.sex i.ethnicity i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/5 {
lincom 1.case + 1.case#`i'.imd, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
bysort case: egen total_follow_up = total(_t) if imd==1
qui su total_follow_up if case==1 & imd==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & imd==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & imd==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & imd==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %5.4f (`p')

file write tablecontent _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if imd==`i'
qui su total_follow_up if case==1 & imd==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & imd==`i'
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & imd==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & imd==`i'
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _n
}

*Diabetes
file write tablecontent ("Diabetes") _n
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
forvalues i=0/1 {
local label_`i': label diabetes `i'
}
file write tablecontent ("`label_0'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.diabetes i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_0b = r(estimate)
local int_0ll = r(lb)
local int_0ul = r(ub)
lincom 1.case + 1.case#1.diabetes, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
bysort case: egen total_follow_up = total(_t) if diabetes==0
qui su total_follow_up if case==1 & diabetes==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & diabetes==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & diabetes==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & diabetes==0
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_0b') (" (") %4.2f (`int_0ll') ("-") %4.2f (`int_0ul') (")") _tab %5.4f (`p')
file write tablecontent _n
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if diabetes==1
qui su total_follow_up if case==1 & diabetes==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & diabetes==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & diabetes==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & diabetes==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _n

*Baseline eGFR
file write tablecontent ("Baseline eGFR") _n
forvalues i=1/7 {
local label_`i': label egfr_group `i'
}
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.egfr_group i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.egfr_group i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
forvalues i=2/7 {
lincom 1.case + 1.case#`i'.egfr_group, eform
local int_`i'b = r(estimate)
local int_`i'll = r(lb)
local int_`i'ul = r(ub)
}
bysort case: egen total_follow_up = total(_t) if egfr_group==1
qui su total_follow_up if case==1 & egfr_group==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & egfr_group==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & egfr_group==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & egfr_group==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")") _tab %5.4f (`p')
file write tablecontent _n
forvalues i=2/7 {
file write tablecontent ("`label_`i''")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if egfr_group==`i'
qui su total_follow_up if case==1 & egfr_group==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & egfr_group==`i'
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & egfr_group==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & egfr_group==`i'
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_`i'b') (" (") %4.2f (`int_`i'll') ("-") %4.2f (`int_`i'ul') (")") _n
}


*Previous AKI
file write tablecontent ("Previous AKI") _n
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
label values aki_baseline aki_baseline
forvalues i=0/1 {
local label_`i': label aki_baseline `i'
}
file write tablecontent ("`label_0'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store a
qui stcox i.case##i.aki_baseline i.sex i.ethnicity i.imd i.urban i.stp i.bmi i.smoking i.ckd_stage i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.month age1 age2 age3
est store b
qui lrtest b a
local p = r(p)
lincom 1.case, eform
local int_0b = r(estimate)
local int_0ll = r(lb)
local int_0ul = r(ub)
lincom 1.case + 1.case#1.aki_baseline, eform
local int_1b = r(estimate)
local int_1ll = r(lb)
local int_1ul = r(ub)
bysort case: egen total_follow_up = total(_t) if aki_baseline==0
qui su total_follow_up if case==1 & aki_baseline==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & aki_baseline==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & aki_baseline==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & aki_baseline==0
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_0b') (" (") %4.2f (`int_0ll') ("-") %4.2f (`int_0ul') (")") _tab %5.4f (`p')
file write tablecontent _n
file write tablecontent ("`label_1'")
use ./output/analysis_hospitalised.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t) if aki_baseline==1
qui su total_follow_up if case==1 & aki_baseline==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & aki_baseline==1
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & _d==1 & _st==1 & aki_baseline==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & _d==1 & _st==1 & aki_baseline==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab %4.2f (`int_1b') (" (") %4.2f (`int_1ll') ("-") %4.2f (`int_1ul') (")")

file close tablecontent