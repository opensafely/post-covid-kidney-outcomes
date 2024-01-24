sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_stroke_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_stroke_2017.csv, write text replace
file write tablecontent _tab ("COVID-19 cohort") _tab ("Matched historical population cohort") _n

capture noisily import delimited ./output/input_stroke.csv, clear
keep incident_stroke incident_stroke_date patient_id
rename incident_stroke stroke

merge 1:m patient_id using ./output/analysis_complete_2017

drop if _merge==1
drop _merge

gen stroke_date = date(incident_stroke_date, "YMD")
format stroke_date %td

drop if stroke_date < (index_date - 28)
replace stroke_date = index_date + 1 if stroke_date < index_date + 1

bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

gen index_date_stroke = index_date
label var stroke "Stroke"
gen exit_date_stroke = stroke_date
format exit_date_stroke %td
replace exit_date_stroke = min(deregistered_date, death_date, end_date) if stroke_date==.
gen stroke_denominator = 1
gen follow_up_time_stroke = (exit_date_stroke - index_date_stroke)
label var follow_up_time_stroke "Follow-up time (Days)"
drop if follow_up_time_stroke<1
drop if follow_up_time_stroke>1096
gen follow_up_years_stroke = follow_up_time_stroke/365.25

*Total
file write tablecontent ("Total") _tab
qui safecount if case==1 & stroke==1
local cases_events = round(r(N),5)
qui safecount if case==0 & stroke==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _tab
file write tablecontent _n

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''") _tab
qui safecount if ethnicity==`ethnicity' & case==1 & stroke==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & case==0 & stroke==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n
}


file write tablecontent ("Missing") _tab
qui safecount if ethnicity==. & case==1 & stroke==1
local cases_events = round(r(N),5)
qui safecount if ethnicity==. & case==0 & stroke==1
local controls_events = round(r(N),5)
file write tablecontent (`cases_events') _tab (`controls_events') _n


file close tablecontent