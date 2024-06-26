sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/descriptive_cca_covid_severity_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/descriptive_cca_covid_severity_2020.csv, write text replace
file write tablecontent _tab ("COVID-19 non-hospitalised") _tab ("COVID-19 hospitalised") _tab ("Matched contemporary cohort") _n
file write tablecontent _tab ("n (%)") _tab ("n (%)") _tab ("n (%)") _n

use ./output/analysis_complete_2020.dta, clear

*COVID severity - recode: non-hospitalised = 1 & hospitalised (including ICU) = 2
replace covid_severity = 2 if covid_severity==3

*Total
file write tablecontent ("Total") _tab
forvalues i=1/2 {
qui safecount if covid_severity==`i'
local cases`i' = round(r(N),5)
file write tablecontent %9.0f ("`cases`i''") _tab
}
qui safecount if covid_severity==0
local controls = round(r(N),5)
file write tablecontent %9.0f ("`controls'") _n

*Total follow-up time
file write tablecontent ("Median follow-up (days) (IQR)") _tab
forvalues i=1/2 {
qui sum follow_up_time_esrd if covid_severity==`i', d
local cases`i'_q2 = r(p50)
local cases`i'_q1 = r(p25)
local cases`i'_q3 = r(p75)
file write tablecontent %9.0f ("`cases`i'_q2' (`cases`i'_q1'-`cases`i'_q3')") _tab
}
qui sum follow_up_time_esrd if covid_severity==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %9.0f ("`controls_q2' (`controls_q1'-`controls_q3')") _n

*Age
file write tablecontent ("Median age (IQR)") _tab
forvalues i=1/2 {
qui sum age if covid_severity==`i', d
local cases`i'_q2 = r(p50)
local cases`i'_q1 = r(p25)
local cases`i'_q3 = r(p75)
file write tablecontent %3.1f ("`cases`i'_q2' (`cases`i'_q1'-`cases`i'_q3')") _tab
}
qui sum age if covid_severity==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f ("`controls_q2' (`controls_q1'-`controls_q3')") _n

file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
forvalues i=1/2 {
qui safecount if agegroup==`age' & covid_severity==`i'
local cases`i'_`age' = round(r(N),5)
local cases`i'_`age'_pc = (`cases`i'_`age''/`cases`i'')*100

file write tablecontent %9.0f (`cases`i'_`age'') (" (") %4.1f (`cases`i'_`age'_pc') (")") _tab 
}
qui safecount if agegroup==`age' & covid_severity==0
local controls_`age' = round(r(N),5)
local controls_`age'_pc = (`controls_`age''/`controls')*100
file write tablecontent %9.0f (`controls_`age'') (" (") %4.1f (`controls_`age'_pc') (")") _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
forvalues i=1/2 {
qui safecount if sex==`sex' & covid_severity==`i'
local cases`i'_`sex' = round(r(N),5)
local cases`i'_`sex'_pc = (`cases`i'_`sex''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`sex'') (" (") %4.1f (`cases`i'_`sex'_pc') (")") _tab
}
qui safecount if sex==`sex' & covid_severity==0
local controls_`sex' = round(r(N),5)
local controls_`sex'_pc = (`controls_`sex''/`controls')*100
file write tablecontent %9.0f (`controls_`sex'') (" (") %4.1f (`controls_`sex'_pc') (")") _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
forvalues i=1/2 {
qui safecount if imd==`imd' & covid_severity==`i'
local cases`i'_`imd' = round(r(N),5)
local cases`i'_`imd'_pc = (`cases`i'_`imd''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`imd'') (" (") %4.1f (`cases`i'_`imd'_pc') (")") _tab
}
qui safecount if imd==`imd' & covid_severity==0
local controls_`imd' = round(r(N),5)
local controls_`imd'_pc = (`controls_`imd''/`controls')*100
file write tablecontent %9.0f (`controls_`imd'') (" (") %4.1f (`controls_`imd'_pc') (")") _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity1=1/6 {
local label_`ethnicity1': label ethnicity1 `ethnicity1'
file write tablecontent ("`label_`ethnicity1''") _tab
forvalues i=1/2 {
qui safecount if ethnicity1==`ethnicity1' & covid_severity==`i'
local cases`i'_`ethnicity1' = round(r(N),5)
local cases`i'_`ethnicity1'_pc = (`cases`i'_`ethnicity1''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`ethnicity1'') (" (") %4.1f (`cases`i'_`ethnicity1'_pc') (")") _tab %9.0f
}
qui safecount if ethnicity1==`ethnicity1' & covid_severity==0
local controls_`ethnicity1' = round(r(N),5)
local controls_`ethnicity1'_pc = (`controls_`ethnicity1''/`controls')*100
file write tablecontent %9.0f (`controls_`ethnicity1'') (" (") %4.1f (`controls_`ethnicity1'_pc') (")") _n
}

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
forvalues i=1/2 {
qui safecount if region==`region' & covid_severity==`i'
local cases`i'_`region' = round(r(N),5)
local cases`i'_`region'_pc = (`cases`i'_`region''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`region'') (" (") %4.1f (`cases`i'_`region'_pc') (")") _tab
}
qui safecount if region==`region' & covid_severity==0
local controls_`region' = round(r(N),5)
local controls_`region'_pc = (`controls_`region''/`controls')*100
file write tablecontent %9.0f (`controls_`region'') (" (") %4.1f (`controls_`region'_pc') (")") _n
}

*Urban/rural
file write tablecontent ("Urban/rural") _n
local label_rural: label urban 0
local label_urban: label urban 1
file write tablecontent ("`label_urban'") _tab
forvalues i=1/2 {
qui safecount if urban==1 & covid_severity==`i'
local cases`i'_urban = round(r(N),5)
local cases`i'_urban_pc = (`cases`i'_urban'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_urban') (" (") %4.1f (`cases`i'_urban_pc') (")") _tab
}
qui safecount if urban==1 & covid_severity==0
local controls_urban = round(r(N),5)
local controls_urban_pc = (`controls_urban'/`controls')*100
file write tablecontent %9.0f (`controls_urban') (" (") %4.1f (`controls_urban_pc') (")") _n
file write tablecontent ("`label_rural'") _tab
forvalues i=1/2 {
qui safecount if urban==0 & covid_severity==`i'
local cases`i'_rural = round(r(N),5)
local cases`i'_rural_pc = (`cases`i'_rural'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_rural') (" (") %4.1f (`cases`i'_rural_pc') (")") _tab
}
qui safecount if urban==0 & covid_severity==0
local controls_rural = round(r(N),5)
local controls_rural_pc = (`controls_rural'/`controls')*100
file write tablecontent %9.0f (`controls_rural') (" (") %4.1f (`controls_rural_pc') (")") _n

*BMI
file write tablecontent ("Body mass index") _n
forvalues bmi=1/6 {
local label_`bmi': label bmi `bmi'
file write tablecontent ("`label_`bmi''") _tab
forvalues i=1/2 {
qui safecount if bmi==`bmi' & covid_severity==`i'
local cases_`bmi' = round(r(N),5)
local cases_`bmi'_pc = (`cases_`bmi''/`cases`i'')*100
file write tablecontent %9.0f (`cases_`bmi'') (" (") %4.1f (`cases_`bmi'_pc') (")") _tab
}
qui safecount if bmi==`bmi' & covid_severity==0
local controls_`bmi' = round(r(N),5)
local controls_`bmi'_pc = (`controls_`bmi''/`controls')*100
file write tablecontent %9.0f (`controls_`bmi'') (" (") %4.1f (`controls_`bmi'_pc') (")") _n
}
file write tablecontent ("Missing") _tab
forvalues i=1/2 {
qui safecount if bmi==. & covid_severity==`i'
local cases_bmi = round(r(N),5)
local cases_bmi_pc = (`cases_bmi'/`cases`i'')*100
file write tablecontent %9.0f (`cases_bmi') (" (") %4.1f (`cases_bmi_pc') (")") _tab
}
qui safecount if bmi==. & covid_severity==0
local controls_bmi = round(r(N),5)
local controls_bmi_pc = (`controls_bmi'/`controls')*100
file write tablecontent %9.0f (`controls_bmi') (" (") %4.1f (`controls_bmi_pc') (")") _n

*Smoking
file write tablecontent ("Smoking") _n
forvalues smoking=0/1 {
local label_`smoking': label smoking `smoking'
file write tablecontent ("`label_`smoking''") _tab
forvalues i=1/2 {
qui safecount if smoking==`smoking' & covid_severity==`i'
local cases_smoking = round(r(N),5)
local cases_smoking_pc = (`cases_smoking'/`cases`i'')*100
file write tablecontent %9.0f (`cases_smoking') (" (") %4.1f (`cases_smoking_pc') (")") _tab
}
qui safecount if smoking==`smoking' & covid_severity==0
local controls_smoking = round(r(N),5)
local controls_smoking_pc = (`controls_smoking'/`controls')*100
file write tablecontent %9.0f (`controls_smoking') (" (") %4.1f (`controls_smoking_pc') (")") _n
}
file write tablecontent ("Missing") _tab
forvalues i=1/2 {
qui safecount if smoking==. & covid_severity==`i'
local cases_smoking = round(r(N),5)
local cases_smoking_pc = (`cases_smoking'/`cases`i'')*100
file write tablecontent %9.0f (`cases_smoking') (" (") %4.1f (`cases_smoking_pc') (")") _tab
}
qui safecount if smoking==. & covid_severity==0
local controls_smoking = round(r(N),5)
local controls_smoking_pc = (`controls_smoking'/`controls')*100
file write tablecontent %9.0f (`controls_smoking') (" (") %4.1f (`controls_smoking_pc') (")") _n

*Baseline eGFR
file write tablecontent ("Median baseline eGFR (IQR)") _tab
forvalues i=1/2 {
qui sum baseline_egfr if covid_severity==`i', d
local cases`i'_q2 = r(p50)
local cases`i'_q1 = r(p25)
local cases`i'_q3 = r(p75)
file write tablecontent %3.1f (`cases`i'_q2') (" (") %3.1f (`cases`i'_q1') ("-") %3.1f (`cases`i'_q3') (")") _tab
}
qui sum baseline_egfr if covid_severity==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
forvalues i=1/2 {
qui safecount if egfr_group==`group' & covid_severity==`i'
local cases`i'_`group' = round(r(N),5)
local cases`i'_`group'_pc = (`cases`i'_`group''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`group'') (" (") %4.1f (`cases`i'_`group'_pc') (")") _tab
}
qui safecount if egfr_group==`group' & covid_severity==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls')*100
file write tablecontent %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

*AKI
file write tablecontent ("Previous acute kidney injury") _tab
forvalues i=1/2 {
qui safecount if aki_baseline==1 & covid_severity==`i'
local cases`i'_aki_baseline = round(r(N),5)
local cases`i'_aki_baseline_pc = (`cases`i'_aki_baseline'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_aki_baseline') (" (") %4.1f (`cases`i'_aki_baseline_pc') (")") _tab
}
qui safecount if aki_baseline==1 & covid_severity==0
local controls_aki_baseline = round(r(N),5)
local controls_aki_baseline_pc = (`controls_aki_baseline'/`controls')*100
file write tablecontent %9.0f (`controls_aki_baseline') (" (") %4.1f (`controls_aki_baseline_pc') (")") _n

*Cardiovascular diseases
file write tablecontent ("Cardiovascular diseases") _tab
forvalues i=1/2 {
qui safecount if cardiovascular==1 & covid_severity==`i'
local cases`i'_cardiovascular = round(r(N),5)
local cases`i'_cardiovascular_pc = (`cases`i'_cardiovascular'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_cardiovascular') (" (") %4.1f (`cases`i'_cardiovascular_pc') (")") _tab
}
qui safecount if cardiovascular==1 & covid_severity==0
local controls_cardiovascular = round(r(N),5)
local controls_cardiovascular_pc = (`controls_cardiovascular'/`controls')*100
file write tablecontent %9.0f (`controls_cardiovascular') (" (") %4.1f (`controls_cardiovascular_pc') (")") _n

*Diabetes
file write tablecontent ("Diabetes") _tab
forvalues i=1/2 {
qui safecount if diabetes==1 & covid_severity==`i'
local cases`i'_diabetes = round(r(N),5)
local cases`i'_diabetes_pc = (`cases`i'_diabetes'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_diabetes') (" (") %4.1f (`cases`i'_diabetes_pc') (")") _tab
}
qui safecount if diabetes==1 & covid_severity==0
local controls_diabetes = round(r(N),5)
local controls_diabetes_pc = (`controls_diabetes'/`controls')*100
file write tablecontent %9.0f (`controls_diabetes') (" (") %4.1f (`controls_diabetes_pc') (")") _n

*Hypertension
file write tablecontent ("Hypertension") _tab
forvalues i=1/2 {
qui safecount if hypertension==1 & covid_severity==`i'
local cases`i'_hypertension = round(r(N),5)
local cases`i'_hypertension_pc = (`cases`i'_hypertension'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_hypertension') (" (") %4.1f (`cases`i'_hypertension_pc') (")") _tab
}
qui safecount if hypertension==1 & covid_severity==0
local controls_hypertension = round(r(N),5)
local controls_hypertension_pc = (`controls_hypertension'/`controls')*100
file write tablecontent %9.0f (`controls_hypertension') (" (") %4.1f (`controls_hypertension_pc') (")") _n

*Immunosuppressive diseases
file write tablecontent ("Immunosuppressive diseases") _tab
forvalues i=1/2 {
qui safecount if immunosuppressed==1 & covid_severity==`i'
local cases`i'_immunosuppressed = round(r(N),5)
local cases`i'_immunosuppressed_pc = (`cases`i'_immunosuppressed'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_immunosuppressed') (" (") %4.1f (`cases`i'_immunosuppressed_pc') (")") _tab
}
qui safecount if immunosuppressed==1 & covid_severity==0
local controls_immunosuppressed = round(r(N),5)
local controls_immunosuppressed_pc = (`controls_immunosuppressed'/`controls')*100
file write tablecontent %9.0f (`controls_immunosuppressed') (" (") %4.1f (`controls_immunosuppressed_pc') (")") _n

*Cancer
file write tablecontent ("Non-haematological cancer") _tab
forvalues i=1/2 {
qui safecount if non_haem_cancer==1 & covid_severity==`i'
local cases`i'_non_haem_cancer = round(r(N),5)
local cases`i'_non_haem_cancer_pc = (`cases`i'_non_haem_cancer'/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_non_haem_cancer') (" (") %4.1f (`cases`i'_non_haem_cancer_pc') (")") _tab
}
qui safecount if non_haem_cancer==1 & covid_severity==0
local controls_non_haem_cancer = round(r(N),5)
local controls_non_haem_cancer_pc = (`controls_non_haem_cancer'/`controls')*100
file write tablecontent %9.0f (`controls_non_haem_cancer') (" (") %4.1f (`controls_non_haem_cancer_pc') (")") _n

*GP consultations
file write tablecontent ("Median GP consultations prior year (IQR)") _tab
forvalues i=1/2 {
qui sum gp_count if covid_severity==`i', d
local cases`i'_q2 = r(p50)
local cases`i'_q1 = r(p25)
local cases`i'_q3 = r(p75)
file write tablecontent %3.1f (`cases`i'_q2') (" (") %3.1f (`cases`i'_q1') ("-") %3.1f (`cases`i'_q3') (")") _tab 
}
qui sum gp_count if covid_severity==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("GP consultations prior year") _n
forvalues group=0/3 {
local label_`group': label gp_consults `group'
file write tablecontent ("`label_`group''") _tab
forvalues i=1/2 {
qui safecount if gp_consults==`group' & covid_severity==`i'
local cases`i'_`group' = round(r(N),5)
local cases`i'_`group'_pc = (`cases`i'_`group''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`group'') (" (") %4.1f (`cases`i'_`group'_pc') (")") _tab
}
qui safecount if gp_consults==`group' & covid_severity==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls')*100
file write tablecontent %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

*Hospital admissions
file write tablecontent ("Median hospital admissions 5 years (IQR)") _tab
forvalues i=1/2 {
qui sum hosp_count if covid_severity==`i', d
local cases`i'_q2 = r(p50)
local cases`i'_q1 = r(p25)
local cases`i'_q3 = r(p75)
file write tablecontent %3.1f (`cases`i'_q2') (" (") %3.1f (`cases`i'_q1') ("-") %3.1f (`cases`i'_q3') (")") _tab
}
qui sum hosp_count if covid_severity==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("Hospital admissions 5 years") _n
forvalues group=0/2 {
local label_`group': label admissions `group'
file write tablecontent ("`label_`group''") _tab
forvalues i=1/2 {
qui safecount if admissions==`group' & covid_severity==`i'
local cases`i'_`group' = round(r(N),5)
local cases`i'_`group'_pc = (`cases`i'_`group''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`group'') (" (") %4.1f (`cases`i'_`group'_pc') (")") _tab
}
qui safecount if admissions==`group' & covid_severity==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls')*100
file write tablecontent %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

*COVID-19 vaccination
file write tablecontent ("COVID-19 vaccination status") _n
forvalues vax=1/5 {
local label_`vax': label covid_vax `vax'
file write tablecontent ("`label_`vax''") _tab
forvalues i=1/2 {
qui safecount if covid_vax==`vax' & covid_severity==`i'
local cases`i'_`vax' = round(r(N),5)
local cases`i'_`vax'_pc = (`cases`i'_`vax''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`vax'') (" (") %4.1f (`cases`i'_`vax'_pc') (")") _tab
}
qui safecount if covid_vax==`vax' & covid_severity==0
local controls_`vax' = round(r(N),5)
local controls_`vax'_pc = (`controls_`vax''/`controls')*100
file write tablecontent %9.0f (`controls_`vax'') (" (") %4.1f (`controls_`vax'_pc') (")") _n
}

*COVID-19 wave
file write tablecontent ("COVID-19 wave") _n
forvalues wave=1/4 {
local label_`wave': label wave `wave'
file write tablecontent ("`label_`wave''") _tab
forvalues i=1/2 {
qui safecount if wave==`wave' & covid_severity==`i'
local cases`i'_`wave' = round(r(N),5)
local cases`i'_`wave'_pc = (`cases`i'_`wave''/`cases`i'')*100
file write tablecontent %9.0f (`cases`i'_`wave'') (" (") %4.1f (`cases`i'_`wave'_pc') (")") _tab
}
qui safecount if wave==`wave' & covid_severity==0
local controls_`wave' = round(r(N),5)
local controls_`wave'_pc = (`controls_`wave''/`controls')*100
file write tablecontent %9.0f (`controls_`wave'') (" (") %4.1f (`controls_`wave'_pc') (")") _n
}