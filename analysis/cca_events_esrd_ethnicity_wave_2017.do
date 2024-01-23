sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cca_events_esrd_ethnicity_wave_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/cca_events_esrd_ethnicity_wave_2017.csv, write text replace
file write tablecontent _tab ("Feb20-Aug20") _tab ("Sep20-Jun21") _tab ("Jul21-Nov21") _tab ("Dec21-Dec22") _tab ("Matched historical cohort") _n

use ./output/analysis_complete_2017.dta, clear

*Ethnicity
forvalues ethnicity=1/5 {
local label_`ethnicity': label ethnicity `ethnicity'
file write tablecontent ("`label_`ethnicity''")
forvalues i=0/4 {
qui safecount if ethnicity==`ethnicity' & wave==`i' & esrd==1
local events_`i' = round(r(N),5)
}
file write tablecontent _tab (`events_1') _tab (`events_2') _tab (`events_3') _tab (`events_4') _tab (`events_0') _n
}

file close tablecontent