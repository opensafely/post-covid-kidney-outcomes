clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models_severity_esrd.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_models_case_severity.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _n

local cohort "2017 2020"
use ./output/analysis_2017.dta, clear

*Age group
file write tablecontent ("Age") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/6 {
local label_`i': label agegroup `i'
}
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/6 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.agegroup, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if agegroup==1
qui su total_follow_up if covid_severity==`j' & agegroup==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & agegroup==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
forvalues i=2/6 {
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if agegroup==`i'
qui su total_follow_up if covid_severity==`j' & agegroup==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & agegroup==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b_`x'') (" (") %4.2f (`int_`j'`i'll_`x'') ("-") %4.2f (`int_`j'`i'ul_`x'') (")") _tab
}
file write tablecontent _n
}
}

*Sex
file write tablecontent ("Sex") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
local label_`i': label sex `i'
}
file write tablecontent ("`label_0'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
lincom `j'.covid_severity + `j'.covid_severity#1.sex, eform
local int_`j'1b_`x' = r(estimate)
local int_`j'1ll_`x' = r(lb)
local int_`j'1ul_`x' = r(ub)
bysort covid_severity: egen total_follow_up = total(_t) if sex==0
qui su total_follow_up if covid_severity==`j' & sex==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & sex==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if sex==1
qui su total_follow_up if covid_severity==`j' & sex==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & sex==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'1b_`x'') (" (") %4.2f (`int_`j'1ll_`x'') ("-") %4.2f (`int_`j'1ul_`x'') (")") _tab
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.ethnicity, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if ethnicity==1
qui su total_follow_up if covid_severity==`j' & ethnicity==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & ethnicity==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if ethnicity==`i'
qui su total_follow_up if covid_severity==`j' & ethnicity==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & ethnicity==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b_`x'') (" (") %4.2f (`int_`j'`i'll_`x'') ("-") %4.2f (`int_`j'`i'ul_`x'') (")") _tab
}
file write tablecontent _n
}
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label imd `i'
}
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.imd, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if imd==1
qui su total_follow_up if covid_severity==`j' & imd==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & imd==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
forvalues i=2/5 {
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if imd==`i'
qui su total_follow_up if covid_severity==`j' & imd==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & imd==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b_`x'') (" (") %4.2f (`int_`j'`i'll_`x'') ("-") %4.2f (`int_`j'`i'ul_`x'') (")") _tab
}
file write tablecontent _n
}
}

*Diabetes
file write tablecontent ("Diabetes") _n
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
local label_`i': label diabetes `i'
}
file write tablecontent ("`label_0'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
lincom `j'.covid_severity + `j'.covid_severity#1.diabetes, eform
local int_`j'1b_`x' = r(estimate)
local int_`j'1ll_`x' = r(lb)
local int_`j'1ul_`x' = r(ub)
bysort covid_severity: egen total_follow_up = total(_t) if diabetes==0
qui su total_follow_up if covid_severity==`j' & diabetes==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & diabetes==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if diabetes==1
qui su total_follow_up if covid_severity==`j' & diabetes==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & diabetes==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'1b_`x'') (" (") %4.2f (`int_`j'1ll_`x'') ("-") %4.2f (`int_`j'1ul_`x'') (")") _tab
}
file write tablecontent _n
}

*Baseline eGFR
file write tablecontent ("Baseline eGFR") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/7 {
local label_`i': label egfr_group `i'
}
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.egfr_group i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.egfr_group i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/7 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.egfr_group, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if egfr_group==1
qui su total_follow_up if covid_severity==`j' & egfr_group==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & egfr_group==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
forvalues i=2/7 {
file write tablecontent ("`label_`i''")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if egfr_group==`i'
qui su total_follow_up if covid_severity==`j' & egfr_group==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & egfr_group==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b_`x'') (" (") %4.2f (`int_`j'`i'll_`x'') ("-") %4.2f (`int_`j'`i'ul_`x'') (")") _tab
}
file write tablecontent _n
}
}

*Previous AKI
file write tablecontent ("Previous AKI") _n
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
label values aki_baseline aki_baseline
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
local label_`i': label aki_baseline `i'
}
file write tablecontent ("`label_0'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.aki_baseline i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
lincom `j'.covid_severity + `j'.covid_severity#1.diabetes, eform
local int_`j'1b_`x' = r(estimate)
local int_`j'1ll_`x' = r(lb)
local int_`j'1ul_`x' = r(ub)
bysort covid_severity: egen total_follow_up = total(_t) if diabetes==0
qui su total_follow_up if covid_severity==`j' & diabetes==0
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & diabetes==0
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p')
}
file write tablecontent _n
file write tablecontent ("`label_1'")
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if diabetes==1
qui su total_follow_up if covid_severity==`j' & diabetes==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & diabetes==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'1b_`x'') (" (") %4.2f (`int_`j'1ll_`x'') ("-") %4.2f (`int_`j'1ul_`x'') (")") _tab
}
file write tablecontent _n
}

*COVID-19 wave
use ./output/analysis_2020.dta, clear
file write tablecontent ("COVID-19 wave") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/4 {
local label_`i': label wave `i'
}
file write tablecontent ("`label_1'")
use ./output/analysis_2020.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.wave i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/4 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.wave, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if wave==1
qui su total_follow_up if covid_severity==`j' & wave==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & wave==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p') _n
forvalues i=2/4 {
use ./output/analysis_2020.dta, clear
file write tablecontent ("`label_`i''")
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if wave==`i'
qui su total_follow_up if covid_severity==`j' & wave==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & wave==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _n
}
}

*COVID-19 vaccination status
use ./output/analysis_2020.dta, clear
file write tablecontent ("COVID-19 vaccination") _n
forvalues j=1/3{
local label`j': label covid_severity `j'
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
local label_`i': label covid_vax `i'
}
file write tablecontent ("`label_1'")
use ./output/analysis_2020.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.covid_vax i.wave i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
lincom `j'.covid_severity, eform
local int_`j'b = r(estimate)
local int_`j'll = r(lb)
local int_`j'ul = r(ub)
forvalues i=2/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.covid_vax, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
bysort covid_severity: egen total_follow_up = total(_t) if covid_vax==1
qui su total_follow_up if covid_severity==`j' & covid_vax==1
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==1 & _d==1 & _st==1 & covid_vax==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'b') (" (") %4.2f (`int_`j'll') ("-") %4.2f (`int_`j'ul') (")") _tab %5.4f (`p') _n
forvalues i=2/5 {
use ./output/analysis_2020.dta, clear
file write tablecontent ("`label_`i''")
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
bysort covid_severity: egen total_follow_up = total(_t) if covid_vax==`i'
qui su total_follow_up if covid_severity==`j' & covid_vax==`i'
local cases_py = r(mean)
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & covid_vax==`i'
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
file write tablecontent _tab _tab _tab _tab ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _n
}
}

file close tablecontent
