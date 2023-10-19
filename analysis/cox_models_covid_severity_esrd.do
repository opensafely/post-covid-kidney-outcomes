clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cox_models_covid_severity_esrd.log, replace t
cap file close tablecontent
file open tablecontent using ./output/cox_models_covid_severity_esrd.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab _tab ("Contemporary general population comparison") _n
file write tablecontent _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _tab ("Crude rate (/100000py) (95% CI)") _tab ("Fully-adjusted HR (95% CI)") _tab ("p-value for interaction") _n

local cohort "2017 2020"
use ./output/analysis_2017.dta, clear

*Age group
forvalues j=1/3 {
local label`j': label covid_severity `j'
forvalues i=1/6 {
local label_`i': label agegroup `i'
}
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.agegroup i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/6 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.agegroup, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/6 {
bysort covid_severity: egen total_follow_up_`i' = total(_t) if agegroup==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & agegroup==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & agegroup==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Age") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/6 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}

*Sex
forvalues i=0/1 {
local label_`i': label sex `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.sex i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=0/1 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.sex, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=0/1 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if sex==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & sex==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & sex==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Sex") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}


*Ethnicity
forvalues i=1/5 {
local label_`i': label ethnicity `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.ethnicity, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/5 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if ethnicity==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & ethnicity==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & ethnicity==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Ethnicity") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}

*IMD
forvalues i=1/5 {
local label_`i': label imd `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.imd, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/5 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if imd==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & imd==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & imd==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Index of multiple deprivation") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}

*Diabetes
label define diabetes 0 "No diabetes" 1 "Diabetes"
label values diabetes diabetes
forvalues i=0/1 {
local label_`i': label diabetes `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=0/1 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.diabetes, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=0/1 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if diabetes==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & diabetes==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & diabetes==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Diabetes") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}


*Baseline eGFR
forvalues i=1/7 {
local label_`i': label egfr_group `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.egfr_group i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.egfr_group i.imd i.ethnicity i.urban i.bmi i.smoking i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/7 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.egfr_group, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/7 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if egfr_group==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & egfr_group==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & egfr_group==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Baseline eGFR") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/7 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}

*Previous AKI
label define aki_baseline 0 "No previous AKI" 1 "Previous AKI"
label values aki_baseline aki_baseline
forvalues i=0/1 {
local label_`i': label aki_baseline `i'
}
*Obtain p-values for interaction
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store a
qui stcox i.covid_severity##i.aki_baseline i.diabetes i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p_`x' = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=0/1 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.aki_baseline, eform
local int_`j'`i'b_`x' = r(estimate)
local int_`j'`i'll_`x' = r(lb)
local int_`j'`i'ul_`x' = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=0/1 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if aki_baseline==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & aki_baseline==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & aki_baseline==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i'_`x' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i'_`x' = `cases_rate`j'`i'_`x'' * `cases_ef'
local cases_ll`j'`i'_`x' = `cases_rate`j'`i'_`x'' / `cases_ef'
}
}
}
file write tablecontent ("Previous AKI") _tab _tab _tab (`p_2017') _tab _tab _tab (`p_2020') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=0/1 {
file write tablecontent ("`label_`i''") _tab (`cases_rate`j'`i'_2017') (" (") %3.2f (`cases_ll`j'`i'_2017')  ("-") %3.2f (`cases_ul`j'`i'_2017') (")") _tab %4.2f (`int_`j'`i'b_2017') (" (") %4.2f (`int_`j'`i'll_2017') ("-") %4.2f (`int_`j'`i'ul_2017') (")") _tab _tab (`cases_rate`j'`i'_2020') (" (") %3.2f (`cases_ll`j'`i'_2020')  ("-") %3.2f (`cases_ul`j'`i'_2020') (")") _tab %4.2f (`int_`j'`i'b_2020') (" (") %4.2f (`int_`j'`i'll_2020') ("-") %4.2f (`int_`j'`i'ul_2020') (")") _n
}
}


*COVID-19 wave
use ./output/analysis_2020.dta, clear
forvalues i=1/4 {
local label_`i': label wave `i'
}
*Obtain p-values for interaction
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.wave i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/4 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.wave, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/4 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if wave==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & wave==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & wave==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i' = `cases_rate`j'`i'' * `cases_ef'
local cases_ll`j'`i' = `cases_rate`j'`i'' / `cases_ef'
}
}
file write tablecontent ("COVID-19 wave") _tab _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/4 {
file write tablecontent ("`label_`i''") _tab _tab _tab _tab (`cases_rate`j'`i'') (" (") %3.2f (`cases_ll`j'`i'')  ("-") %3.2f (`cases_ul`j'`i'') (")") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _n
}
}

*COVID-19 vaccination status
forvalues i=1/5 {
local label_`i': label covid_vax `i'
}
*Obtain p-values for interaction
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.wave i.covid_vax, strata(set_id)
est store a
qui stcox i.covid_severity##i.covid_vax i.wave i.imd i.ethnicity i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, strata(set_id)
est store b
qui lrtest b a
local p = r(p)
*Obtain stratum specific HRs
forvalues j=1/3 {
forvalues i=1/5 {
lincom `j'.covid_severity + `j'.covid_severity#`i'.covid_vax, eform
local int_`j'`i'b = r(estimate)
local int_`j'`i'll = r(lb)
local int_`j'`i'ul = r(ub)
}
}
*Obtain stratum-specific rates
forvalues i=1/5 {
capture drop total_follow_up_`i'
bysort covid_severity: egen total_follow_up_`i' = total(_t) if covid_vax==`i'
forvalues j=1/3 {
qui su total_follow_up_`i' if covid_severity==`j' & covid_vax==`i'
local cases_multip = 100000 / r(mean)
qui safecount if covid_severity==`j' & _d==1 & _st==1 & covid_vax==`i'
local cases_events = round(r(N),5)
local cases_rate`j'`i' = (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul`j'`i' = `cases_rate`j'`i'' * `cases_ef'
local cases_ll`j'`i' = `cases_rate`j'`i'' / `cases_ef'
}
}
file write tablecontent ("COVID-19 vaccination") _tab _tab _tab _tab _tab _tab (`p') _n
forvalues j=1/3 {
file write tablecontent ("`label`j''") _n
forvalues i=1/5 {
file write tablecontent ("`label_`i''") _tab _tab _tab _tab (`cases_rate`j'`i'') (" (") %3.2f (`cases_ll`j'`i'')  ("-") %3.2f (`cases_ul`j'`i'') (")") _tab %4.2f (`int_`j'`i'b') (" (") %4.2f (`int_`j'`i'll') ("-") %4.2f (`int_`j'`i'ul') (")") _n
}
}

file close tablecontent
