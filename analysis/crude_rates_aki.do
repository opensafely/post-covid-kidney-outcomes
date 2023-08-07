sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/crude_rates_aki.log, replace t

cap file close tablecontent
file open tablecontent using ./output/crude_rates_aki.csv, write text replace
file write tablecontent _tab ("Pre-pandemic general population comparison") _tab _tab ("Contemporary general population comparison") _tab _tab ("Pre-pandemic hospitalised comparison") _n
file write tablecontent _tab ("COVID-19 cohort") _tab ("General population cohort") _tab ("COVID-19 cohort") _tab ("General population cohort") _tab ("Hospitalised COVID-19 cohort") _tab ("Hospitalised pneumonia cohort") _n
file write tablecontent _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _n

*Calculate denominator for each cohort (i.e. 100000 person-years)
local cohort "2017 2020 hospitalised"
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip_`x' = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip_`x' = 100000 / r(mean)
}

*Total
file write tablecontent ("Total") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Age
file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if agegroup==`age' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if agegroup==`age' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if sex==`sex' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if sex==`sex' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if imd==`imd' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if imd==`imd' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity1=1/6 {
local label_`ethnicity1': label ethnicity1 `ethnicity1'
file write tablecontent ("`label_`ethnicity1''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if ethnicity1==`ethnicity1' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if ethnicity1==`ethnicity1' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if region==`region' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if region==`region' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*Urban/rural
file write tablecontent ("Urban/rural") _n
local label_rural: label urban 0
local label_urban: label urban 1
file write tablecontent ("`label_urban'") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if urban==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if urban==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*BMI
file write tablecontent ("Body mass index") _n
forvalues bmi=1/6 {
local label_`bmi': label bmi `bmi'
file write tablecontent ("`label_`bmi''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if bmi==`bmi' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if bmi==`bmi' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
foreach x of local cohort {
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if bmi==. & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if bmi==. & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab
}
file write tablecontent _n

*Smoking
file write tablecontent ("Smoking") _n
forvalues smoking=0/1 {
local label_`smoking': label smoking `smoking'
file write tablecontent ("`label_`smoking''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if smoking==`smoking' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if smoking==`smoking' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
foreach x of local cohort {
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if smoking==. & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if smoking==. & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab
}
file write tablecontent _n

*Baseline eGFR
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if egfr_group==`group' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if egfr_group==`group' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*AKI
file write tablecontent ("Previous acute kidney injury") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if aki_baseline==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if aki_baseline==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Cardiovascular diseases
file write tablecontent ("Cardiovascular diseases") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if cardiovascular==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if cardiovascular==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Diabetes
file write tablecontent ("Diabetes") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if diabetes==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if diabetes==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Hypertension
file write tablecontent ("Hypertension") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if hypertension==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if hypertension==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Immunosuppressive diseases
file write tablecontent ("Immunosuppressive diseases") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if immunosuppressed==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if immunosuppressed==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*Cancer
file write tablecontent ("Non-haematological cancer") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if non_haem_cancer==1 & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if non_haem_cancer==1 & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n

*GP consultations
file write tablecontent ("GP consultations prior year") _n
forvalues group=0/3 {
local label_`group': label gp_consults `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if gp_consults==`group' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if gp_consults==`group' & case==0 & aki==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*Hospital admissions
file write tablecontent ("Hospital admissions 5 years") _n
forvalues group=0/2 {
local label_`group': label admissions `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if admissions==`group' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if admissions==`group' & case==0 & aki==1 & _st==1
local controls_`group' = round(r(N),5)
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*COVID-19 vaccination status
file write tablecontent ("COVID-19 vaccination status") _n
forvalues group=1/5 {
use ./output/analysis_2020.dta
local label_`group': label covid_vax `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if covid_vax==`group' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if covid_vax==`group' & case==0 & aki==1 & _st==1
local controls_`group' = round(r(N),5)
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}

*COVID-19 wave
file write tablecontent ("COVID-19 wave") _n
forvalues group=1/4 {
use ./output/analysis_2020.dta
local label_`group': label wave `group'
file write tablecontent ("`label_`group''") _tab
foreach x of local cohort {
use ./output/analysis_`x'.dta
stset exit_date_aki, fail(aki_date) origin(index_date_aki) id(unique) scale(365.25)
qui safecount if wave==`group' & case==1 & aki==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip_`x'')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if wave==`group' & case==0 & aki==1 & _st==1
local controls_`group' = round(r(N),5)
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip_`x'')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _tab 
}
file write tablecontent _n
}