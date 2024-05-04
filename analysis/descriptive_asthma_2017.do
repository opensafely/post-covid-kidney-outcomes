sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/descriptive_asthma_2017.log, replace t

cap file close tablecontent
file open tablecontent using ./output/descriptive_asthma_2017.csv, write text replace
file write tablecontent _tab ("Asthma cohort (pre-pandemic) (n(%))") _tab ("Matched cohort (pre-pandemic) (n(%))") _n

*Total
file write tablecontent ("Total") _tab
use ./output/analysis_asthma_2017.dta, clear
qui safecount if case==1
local cases_2017 = round(r(N),5)
qui safecount if case==0
local controls_2017 = round(r(N),5)
file write tablecontent %9.0f ("`cases_2017'") _tab %9.0f ("`controls_2017'") _n

*Total follow-up time
file write tablecontent ("Median follow-up (days) (IQR)") _tab
qui sum follow_up_time_esrd if case==1, d
local cases_q2 = r(p50)
local cases_q1 = r(p25)
local cases_q3 = r(p75)
qui sum follow_up_time_esrd if case==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %9.0f ("`cases_q2' (`cases_q1'-`cases_q3')") _tab %9.0f ("`controls_q2' (`controls_q1'-`controls_q3')") _n

*Age
file write tablecontent ("Median age (IQR)") _tab
qui sum age if case==1, d
local cases_q2 = r(p50)
local cases_q1 = r(p25)
local cases_q3 = r(p75)
qui sum age if case==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f ("`cases_q2' (`cases_q1'-`cases_q3')") _tab %3.1f ("`controls_q2' (`controls_q1'-`controls_q3')") _n
file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
qui safecount if agegroup==`age' & case==1
local cases_`age' = round(r(N),5)
local cases_`age'_pc = (`cases_`age''/`cases_2017')*100
qui safecount if agegroup==`age' & case==0
local controls_`age' = round(r(N),5)
local controls_`age'_pc = (`controls_`age''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`age'') (" (") %4.1f (`cases_`age'_pc') (")") _tab %9.0f (`controls_`age'') (" (") %4.1f (`controls_`age'_pc') (")") _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
qui safecount if sex==`sex' & case==1
local cases_`sex' = round(r(N),5)
local cases_`sex'_pc = (`cases_`sex''/`cases_2017')*100
qui safecount if sex==`sex' & case==0
local controls_`sex' = round(r(N),5)
local controls_`sex'_pc = (`controls_`sex''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`sex'') (" (") %4.1f (`cases_`sex'_pc') (")") _tab %9.0f (`controls_`sex'') (" (") %4.1f (`controls_`sex'_pc') (")") _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
qui safecount if imd==`imd' & case==1
local cases_`imd' = round(r(N),5)
local cases_`imd'_pc = (`cases_`imd''/`cases_2017')*100
qui safecount if imd==`imd' & case==0
local controls_`imd' = round(r(N),5)
local controls_`imd'_pc = (`controls_`imd''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`imd'') (" (") %4.1f (`cases_`imd'_pc') (")") _tab %9.0f (`controls_`imd'') (" (") %4.1f (`controls_`imd'_pc') (")") _n
}

*Ethnicity
file write tablecontent ("Ethnicity") _n
forvalues ethnicity1=1/6 {
local label_`ethnicity1': label ethnicity1 `ethnicity1'
file write tablecontent ("`label_`ethnicity1''") _tab
qui safecount if ethnicity1==`ethnicity1' & case==1
local cases_`ethnicity1' = round(r(N),5)
local cases_`ethnicity1'_pc = (`cases_`ethnicity1''/`cases_2017')*100
qui safecount if ethnicity1==`ethnicity1' & case==0
local controls_`ethnicity1' = round(r(N),5)
local controls_`ethnicity1'_pc = (`controls_`ethnicity1''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`ethnicity1'') (" (") %4.1f (`cases_`ethnicity1'_pc') (")") _tab %9.0f (`controls_`ethnicity1'') (" (") %4.1f (`controls_`ethnicity1'_pc') (")") _n
}

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
qui safecount if region==`region' & case==1
local cases_`region' = round(r(N),5)
local cases_`region'_pc = (`cases_`region''/`cases_2017')*100
qui safecount if region==`region' & case==0
local controls_`region' = round(r(N),5)
local controls_`region'_pc = (`controls_`region''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`region'') (" (") %4.1f (`cases_`region'_pc') (")") _tab %9.0f (`controls_`region'') (" (") %4.1f (`controls_`region'_pc') (")") _n
}

*Urban/rural
file write tablecontent ("Urban/rural") _n
local label_rural: label urban 0
local label_urban: label urban 1
file write tablecontent ("`label_urban'") _tab
qui safecount if urban==1 & case==1
local cases_urban = round(r(N),5)
local cases_urban_pc = (`cases_urban'/`cases_2017')*100
qui safecount if urban==1 & case==0
local controls_urban = round(r(N),5)
local controls_urban_pc = (`controls_urban'/`controls_2017')*100
file write tablecontent %9.0f (`cases_urban') (" (") %4.1f (`cases_urban_pc') (")") _tab %9.0f (`controls_urban') (" (") %4.1f (`controls_urban_pc') (")") _n
file write tablecontent ("`label_rural'") _tab
qui safecount if urban==0 & case==1
local cases_rural = round(r(N),5)
local cases_rural_pc = (`cases_rural'/`cases_2017')*100
qui safecount if urban==0 & case==0
local controls_rural = round(r(N),5)
local controls_rural_pc = (`controls_rural'/`controls_2017')*100
file write tablecontent %9.0f (`cases_rural') (" (") %4.1f (`cases_rural_pc') (")") _tab %9.0f (`controls_rural') (" (") %4.1f (`controls_rural_pc') (")") _n

*BMI
file write tablecontent ("Body mass index") _n
forvalues bmi=1/6 {
local label_`bmi': label bmi `bmi'
file write tablecontent ("`label_`bmi''") _tab
qui safecount if bmi==`bmi' & case==1
local cases_`bmi' = round(r(N),5)
local cases_`bmi'_pc = (`cases_`bmi''/`cases_2017')*100
qui safecount if bmi==`bmi' & case==0
local controls_`bmi' = round(r(N),5)
local controls_`bmi'_pc = (`controls_`bmi''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`bmi'') (" (") %4.1f (`cases_`bmi'_pc') (")") _tab %9.0f (`controls_`bmi'') (" (") %4.1f (`controls_`bmi'_pc') (")") _n
}
file write tablecontent ("Missing") _tab
qui safecount if bmi==. & case==1
local cases = round(r(N),5)
local cases_pc = (`cases'/`cases_2017')*100
qui safecount if bmi==. & case==0
local controls = round(r(N),5)
local controls_pc = (`controls'/`controls_2017')*100
file write tablecontent %9.0f (`cases') (" (") %4.1f (`cases_pc') (")") _tab %9.0f (`controls') (" (") %4.1f (`controls_pc') (")") _n


*Smoking
file write tablecontent ("Smoking") _n
forvalues smoking=0/1 {
local label_`smoking': label smoking `smoking'
file write tablecontent ("`label_`smoking''") _tab
qui safecount if smoking==`smoking' & case==1
local cases_smoking = round(r(N),5)
local cases_smoking_pc = (`cases_smoking'/`cases_2017')*100
qui safecount if smoking==`smoking' & case==0
local controls_smoking = round(r(N),5)
local controls_smoking_pc = (`controls_smoking'/`controls_2017')*100
file write tablecontent %9.0f (`cases_smoking') (" (") %4.1f (`cases_smoking_pc') (")") _tab %9.0f (`controls_smoking') (" (") %4.1f (`controls_smoking_pc') (")") _n
}
file write tablecontent ("Missing") _tab
qui safecount if smoking==. & case==1
local cases = round(r(N),5)
local cases_pc = (`cases'/`cases_2017')*100
qui safecount if smoking==. & case==0
local controls = round(r(N),5)
local controls_pc = (`controls'/`controls_2017')*100
file write tablecontent %9.0f (`cases') (" (") %4.1f (`cases_pc') (")") _tab %9.0f (`controls') (" (") %4.1f (`controls_pc') (")") _n


*Baseline eGFR
file write tablecontent ("Median baseline eGFR (IQR)") _tab
qui sum baseline_egfr if case==1, d
local cases_q2 = r(p50)
local cases_q1 = r(p25)
local cases_q3 = r(p75)
qui sum baseline_egfr if case==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`cases_q2') (" (") %3.1f (`cases_q1') ("-") %3.1f (`cases_q3') (")") _tab %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
qui safecount if egfr_group==`group' & case==1
local cases_`group' = round(r(N),5)
local cases_`group'_pc = (`cases_`group''/`cases_2017')*100
qui safecount if egfr_group==`group' & case==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`group'') (" (") %4.1f (`cases_`group'_pc') (")") _tab %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

*AKI
file write tablecontent ("Previous acute kidney injury") _tab
qui safecount if aki_baseline==1 & case==1
local cases_aki_baseline = round(r(N),5)
local cases_aki_baseline_pc = (`cases_aki_baseline'/`cases_2017')*100
qui safecount if aki_baseline==1 & case==0
local controls_aki_baseline = round(r(N),5)
local controls_aki_baseline_pc = (`controls_aki_baseline'/`controls_2017')*100
file write tablecontent %9.0f (`cases_aki_baseline') (" (") %4.1f (`cases_aki_baseline_pc') (")") _tab %9.0f (`controls_aki_baseline') (" (") %4.1f (`controls_aki_baseline_pc') (")") _n

*Cardiovascular diseases
file write tablecontent ("Cardiovascular diseases") _tab
qui safecount if cardiovascular==1 & case==1
local cases_cardiovascular = round(r(N),5)
local cases_cardiovascular_pc = (`cases_cardiovascular'/`cases_2017')*100
qui safecount if cardiovascular==1 & case==0
local controls_cardiovascular = round(r(N),5)
local controls_cardiovascular_pc = (`controls_cardiovascular'/`controls_2017')*100
file write tablecontent %9.0f (`cases_cardiovascular') (" (") %4.1f (`cases_cardiovascular_pc') (")") _tab %9.0f (`controls_cardiovascular') (" (") %4.1f (`controls_cardiovascular_pc') (")") _n

*Diabetes
file write tablecontent ("Diabetes") _tab
qui safecount if diabetes==1 & case==1
local cases_diabetes = round(r(N),5)
local cases_diabetes_pc = (`cases_diabetes'/`cases_2017')*100
qui safecount if diabetes==1 & case==0
local controls_diabetes = round(r(N),5)
local controls_diabetes_pc = (`controls_diabetes'/`controls_2017')*100
file write tablecontent %9.0f (`cases_diabetes') (" (") %4.1f (`cases_diabetes_pc') (")") _tab %9.0f (`controls_diabetes') (" (") %4.1f (`controls_diabetes_pc') (")") _n

*Hypertension
file write tablecontent ("Hypertension") _tab
qui safecount if hypertension==1 & case==1
local cases_hypertension = round(r(N),5)
local cases_hypertension_pc = (`cases_hypertension'/`cases_2017')*100
qui safecount if hypertension==1 & case==0
local controls_hypertension = round(r(N),5)
local controls_hypertension_pc = (`controls_hypertension'/`controls_2017')*100
file write tablecontent %9.0f (`cases_hypertension') (" (") %4.1f (`cases_hypertension_pc') (")") _tab %9.0f (`controls_hypertension') (" (") %4.1f (`controls_hypertension_pc') (")") _n

*Immunosuppressive diseases
file write tablecontent ("Immunosuppressive diseases") _tab
qui safecount if immunosuppressed==1 & case==1
local cases_immunosuppressed = round(r(N),5)
local cases_immunosuppressed_pc = (`cases_immunosuppressed'/`cases_2017')*100
qui safecount if immunosuppressed==1 & case==0
local controls_immunosuppressed = round(r(N),5)
local controls_immunosuppressed_pc = (`controls_immunosuppressed'/`controls_2017')*100
file write tablecontent %9.0f (`cases_immunosuppressed') (" (") %4.1f (`cases_immunosuppressed_pc') (")") _tab %9.0f (`controls_immunosuppressed') (" (") %4.1f (`controls_immunosuppressed_pc') (")") _n

*Cancer
file write tablecontent ("Non-haematological cancer") _tab
qui safecount if non_haem_cancer==1 & case==1
local cases_non_haem_cancer = round(r(N),5)
local cases_non_haem_cancer_pc = (`cases_non_haem_cancer'/`cases_2017')*100
qui safecount if non_haem_cancer==1 & case==0
local controls_non_haem_cancer = round(r(N),5)
local controls_non_haem_cancer_pc = (`controls_non_haem_cancer'/`controls_2017')*100
file write tablecontent %9.0f (`cases_non_haem_cancer') (" (") %4.1f (`cases_non_haem_cancer_pc') (")") _tab %9.0f (`controls_non_haem_cancer') (" (") %4.1f (`controls_non_haem_cancer_pc') (")") _n

*GP consultations
file write tablecontent ("Median GP consultations prior year (IQR)") _tab
qui sum gp_count if case==1, d
local cases_q2 = r(p50)
local cases_q1 = r(p25)
local cases_q3 = r(p75)
qui sum gp_count if case==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`cases_q2') (" (") %3.1f (`cases_q1') ("-") %3.1f (`cases_q3') (")") _tab %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("GP consultations prior year") _n
forvalues group=0/3 {
local label_`group': label gp_consults `group'
file write tablecontent ("`label_`group''") _tab
qui safecount if gp_consults==`group' & case==1
local cases_`group' = round(r(N),5)
local cases_`group'_pc = (`cases_`group''/`cases_2017')*100
qui safecount if gp_consults==`group' & case==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`group'') (" (") %4.1f (`cases_`group'_pc') (")") _tab %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

*Hospital admissions
file write tablecontent ("Median hospital admissions 5 years (IQR)") _tab
qui sum hosp_count if case==1, d
local cases_q2 = r(p50)
local cases_q1 = r(p25)
local cases_q3 = r(p75)
qui sum hosp_count if case==0, d
local controls_q2 = r(p50)
local controls_q1 = r(p25)
local controls_q3 = r(p75)
file write tablecontent %3.1f (`cases_q2') (" (") %3.1f (`cases_q1') ("-") %3.1f (`cases_q3') (")") _tab %3.1f (`controls_q2') (" (") %3.1f (`controls_q1') ("-") %3.1f (`controls_q3') (")") _n
file write tablecontent ("Hospital admissions 5 years") _n
forvalues group=0/2 {
local label_`group': label admissions `group'
file write tablecontent ("`label_`group''") _tab
qui safecount if admissions==`group' & case==1
local cases_`group' = round(r(N),5)
local cases_`group'_pc = (`cases_`group''/`cases_2017')*100
qui safecount if admissions==`group' & case==0
local controls_`group' = round(r(N),5)
local controls_`group'_pc = (`controls_`group''/`controls_2017')*100
file write tablecontent %9.0f (`cases_`group'') (" (") %4.1f (`cases_`group'_pc') (")") _tab %9.0f (`controls_`group'') (" (") %4.1f (`controls_`group'_pc') (")") _n
}

file close tablecontent