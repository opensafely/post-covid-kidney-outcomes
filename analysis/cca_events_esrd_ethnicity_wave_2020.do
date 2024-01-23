sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_esrd_ethnicity_wave_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_esrd_ethnicity_wave_2020.csv, write text replace
file write tablecontent _tab ("COVID Feb20-Aug20") _tab ("COVID Sep20-Jun21") _tab ("COVID Jul21-Nov21") _tab ("COVID Dec21-Dec22") _tab ("Matched Feb20-Aug20") _tab ("Matched Sep20-Jun21") _tab ("Matched Jul21-Nov21") _tab ("Matched Dec21-Dec22") _n

use ./output/analysis_complete_2020.dta, clear

*Ethnicity
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''")
forvalues i=1/4 {
qui safecount if ethnicity==`ethnicity' & wave==`i' & esrd==1 & case==1
local cases_`i' = round(r(N),5)
qui safecount if ethnicity==`ethnicity' & wave==`i' & esrd==1 & case==0
local controls_`i' = round(r(N),5)
}
file write tablecontent _tab (`cases_1') _tab (`cases_2') _tab (`cases_3') _tab (`cases_4') _tab (`controls_1') _tab (`controls_2') _tab (`controls_3') _tab (`controls_4') _n
}

file close tablecontent