sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/crude_rates_death_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/crude_rates_death_2020.csv, write text replace
file write tablecontent _tab ("COVID-19 cohort") _tab ("Matched contemporary cohort") _n
file write tablecontent _tab ("Rate (/100000py) (95% CI)") _tab ("Rate (/100000py) (95% CI)") _n

*Calculate denominator for each cohort (i.e. 100000 person-years)
/*local cohort "2020 2020 hospitalised"
foreach x of local cohort {
use ./output/analysis_`x'.dta, clear, clear
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip = 100000 / r(mean)
}*/

use ./output/analysis_2020.dta, clear

*Total
file write tablecontent ("Total") _tab
stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
bysort case: egen total_follow_up = total(_t)
qui su total_follow_up if case==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0
local controls_multip = 100000 / r(mean)
qui safecount if case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Age
file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
bysort case agegroup: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & agegroup==`age'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & agegroup==`age'
local controls_multip = 100000 / r(mean)
qui safecount if agegroup==`age' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if agegroup==`age' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
bysort case sex: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & sex==`sex'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & sex==`sex'
local controls_multip = 100000 / r(mean)
qui safecount if sex==`sex' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if sex==`sex' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
bysort case imd: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & imd==`imd'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & imd==`imd'
local controls_multip = 100000 / r(mean)
qui safecount if imd==`imd' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if imd==`imd' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
bysort case ethnicity: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & ethnicity==`ethnicity'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & ethnicity==`ethnicity'
local controls_multip = 100000 / r(mean)
qui safecount if ethnicity==`ethnicity' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if ethnicity==`ethnicity' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}
file write tablecontent ("Missing") _tab
bysort case ethnicity: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & ethnicity==.
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & ethnicity==.
local controls_multip = 100000 / r(mean)
qui safecount if ethnicity==. & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if ethnicity==. & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
bysort case region: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & region==`region'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & region==`region'
local controls_multip = 100000 / r(mean)
qui safecount if region==`region' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if region==`region' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*Urban/rural
file write tablecontent ("Urban/rural") _n
local label_rural: label urban 0
local label_urban: label urban 1
file write tablecontent ("`label_urban'") _tab
bysort case urban: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & urban==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & urban==1
local controls_multip = 100000 / r(mean)
qui safecount if urban==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if urban==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*BMI
file write tablecontent ("Body mass index") _n
forvalues bmi=1/6 {
local label_`bmi': label bmi `bmi'
file write tablecontent ("`label_`bmi''") _tab
bysort case bmi: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & bmi==`bmi'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & bmi==`bmi'
local controls_multip = 100000 / r(mean)
qui safecount if bmi==`bmi' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if bmi==`bmi' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}
file write tablecontent ("Missing") _tab
bysort case bmi: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & bmi==.
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & bmi==.
local controls_multip = 100000 / r(mean)
qui safecount if bmi==. & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if bmi==. & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Smoking
file write tablecontent ("Smoking") _n
forvalues smoking=0/1 {
local label_`smoking': label smoking `smoking'
file write tablecontent ("`label_`smoking''") _tab
bysort case smoking: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & smoking==`smoking'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & smoking==`smoking'
local controls_multip = 100000 / r(mean)
qui safecount if smoking==`smoking' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if smoking==`smoking' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}
file write tablecontent ("Missing") _tab
bysort case smoking: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & smoking==.
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & smoking==.
local controls_multip = 100000 / r(mean)
qui safecount if smoking==. & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if smoking==. & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Baseline eGFR
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
bysort case egfr_group: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & egfr_group==`group'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & egfr_group==`group'
local controls_multip = 100000 / r(mean)
qui safecount if egfr_group==`group' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if egfr_group==`group' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*AKI
file write tablecontent ("Previous acute kidney injury") _tab
bysort case aki_baseline: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & aki_baseline==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & aki_baseline==1
local controls_multip = 100000 / r(mean)
qui safecount if aki_baseline==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if aki_baseline==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Cardiovascular diseases
file write tablecontent ("Cardiovascular diseases") _tab
bysort case cardiovascular: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & cardiovascular==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & cardiovascular==1
local controls_multip = 100000 / r(mean)
qui safecount if cardiovascular==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if cardiovascular==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Diabetes
file write tablecontent ("Diabetes") _tab
bysort case diabetes: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & diabetes==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & diabetes==1
local controls_multip = 100000 / r(mean)
qui safecount if diabetes==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if diabetes==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Hypertension
file write tablecontent ("Hypertension") _tab
bysort case hypertension: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & hypertension==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & hypertension==1
local controls_multip = 100000 / r(mean)
qui safecount if hypertension==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if hypertension==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Immunosuppressive diseases
file write tablecontent ("Immunosuppressive diseases") _tab
bysort case immunosuppressed: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & immunosuppressed==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & immunosuppressed==1
local controls_multip = 100000 / r(mean)
qui safecount if immunosuppressed==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if immunosuppressed==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*Cancer
file write tablecontent ("Non-haematological cancer") _tab
bysort case non_haem_cancer: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & non_haem_cancer==1
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & non_haem_cancer==1
local controls_multip = 100000 / r(mean)
qui safecount if non_haem_cancer==1 & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if non_haem_cancer==1 & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up

*GP consultations
file write tablecontent ("GP consultations prior year") _n
forvalues group=0/3 {
local label_`group': label gp_consults `group'
file write tablecontent ("`label_`group''") _tab
bysort case gp_consults: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & gp_consults==`group'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & gp_consults==`group'
local controls_multip = 100000 / r(mean)
qui safecount if gp_consults==`group' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if gp_consults==`group' & case==0 & death==1 & _st==1
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

*Hospital admissions
file write tablecontent ("Hospital admissions 5 years") _n
forvalues group=0/2 {
local label_`group': label admissions `group'
file write tablecontent ("`label_`group''") _tab
bysort case admissions: egen total_follow_up = total(_t)
qui su total_follow_up if case==1 & admissions==`group'
local cases_multip = 100000 / r(mean)
qui su total_follow_up if case==0 & admissions==`group'
local controls_multip = 100000 / r(mean)
qui safecount if admissions==`group' & case==1 & death==1 & _st==1
local cases_events = round(r(N),5)
local cases_rate : di %3.2f (`cases_events' * `cases_multip')
local cases_ef = exp(1.96/(sqrt(`cases_events')))
local cases_ul = `cases_rate' * `cases_ef'
local cases_ll = `cases_rate' / `cases_ef'
qui safecount if admissions==`group' & case==0 & death==1 & _st==1
local controls_`group' = round(r(N),5)
local controls_events = round(r(N),5)
local controls_rate : di %3.2f (`controls_events' * `controls_multip')
local controls_ef = exp(1.96/(sqrt(`controls_events')))
local controls_ul = `controls_rate' * `controls_ef'
local controls_ll = `controls_rate' / `controls_ef'
file write tablecontent ("`cases_rate'") (" (") %3.2f (`cases_ll')  ("-") %3.2f (`cases_ul') (")")  _tab ("`controls_rate'") (" (") %3.2f (`controls_ll')  ("-") %3.2f (`controls_ul') (")") _n
drop total_follow_up
}

file close tablecontent