sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/descriptive_asthma_ethnicity_2020.log, replace t

cap file close tablecontent
file open tablecontent using ./output/descriptive_asthma_ethnicity_2020.csv, write text replace
file write tablecontent _tab ("COVID-19 cohort (n(%))") _tab _tab _tab _tab _tab _tab ("Matched contemporary cohort (n(%))") _n
file write tablecontent _tab ("White") _tab ("South Asian") _tab ("Black") _tab ("Mixed") _tab ("Other") _tab ("Unknown") _tab ("White") _tab ("South Asian") _tab ("Black") _tab ("Mixed") _tab ("Other") _tab ("Unknown") _n

*Total
file write tablecontent ("Total") _tab
use ./output/analysis_asthma_2020.dta, clear
forvalues i=1/6 {
qui safecount if case==1 & ethnicity1==`i'
local cases_`i' = round(r(N),5)
qui safecount if case==0 & ethnicity1==`i'
local controls_`i' = round(r(N),5)
}

forvalues i=1/6 {
if `cases_`i''>5 & `cases_`i''!=. {
file write tablecontent %9.0f ("`cases_`i''") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`i''>5 & `controls_`i''!=. {
file write tablecontent %9.0f ("`controls_`i''") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Total follow-up time
file write tablecontent ("Median follow-up (days) (IQR)") _tab
forvalues i=1/6 {
qui sum follow_up_time_esrd if case==1 & ethnicity1==`i', d
local cases_q2_`i' = r(p50)
local cases_q1_`i' = r(p25)
local cases_q3_`i' = r(p75)
qui sum follow_up_time_esrd if case==0 & ethnicity1==`i', d
local controls_q2_`i' = r(p50)
local controls_q1_`i' = r(p25)
local controls_q3_`i' = r(p75)
}

forvalues i=1/6 {
if `cases_`i''>5 & `cases_`i''!=. {
file write tablecontent %9.0f ("`cases_q2_`i'' (`cases_q1_`i''-`cases_q3_`i'')") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`i''>5 & `controls_`i''!=. {
file write tablecontent %9.0f ("`controls_q2_`i'' (`controls_q1_`i''-`controls_q3_`i'')") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

file write tablecontent _n

*Age
file write tablecontent ("Median age (IQR)") _tab
forvalues i=1/6 {
qui sum age if case==1 & ethnicity1==`i', d
local cases_q2_`i' = r(p50)
local cases_q1_`i' = r(p25)
local cases_q3_`i' = r(p75)
qui sum age if case==0 & ethnicity1==`i', d
local controls_q2_`i' = r(p50)
local controls_q1_`i' = r(p25)
local controls_q3_`i' = r(p75)
}

forvalues i=1/6 {
if `cases_`i''>5 & `cases_`i''!=. {
file write tablecontent %9.0f ("`cases_q2_`i'' (`cases_q1_`i''-`cases_q3_`i'')") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`i''>5 & `controls_`i''!=. {
file write tablecontent %9.0f ("`controls_q2_`i'' (`controls_q1_`i''-`controls_q3_`i'')") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

file write tablecontent ("Age") _n
forvalues age=1/6 {
local label_`age': label agegroup `age'
file write tablecontent ("`label_`age''") _tab
forvalues i=1/6 {
qui safecount if agegroup==`age' & case==1 & ethnicity1==`i'
local cases_`age'_`i' = round(r(N),5)
local cases_`age'_pc_`i' = (`cases_`age'_`i''/`cases_`i'')*100
qui safecount if agegroup==`age' & case==0 & ethnicity1==`i'
local controls_`age'_`i' = round(r(N),5)
local controls_`age'_pc_`i' = (`controls_`age'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`age'_`i''>5 & `cases_`age'_`i''!=. {
file write tablecontent %9.0f (`cases_`age'_`i'') (" (") %4.1f (`cases_`age'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`age'_`i''>5 & `controls_`age'_`i''!=. {
file write tablecontent %9.0f (`controls_`age'_`i'') (" (") %4.1f (`controls_`age'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*Sex
file write tablecontent ("Sex") _n
forvalues sex=0/1 {
local label_`sex': label sex `sex'
file write tablecontent ("`label_`sex''") _tab
forvalues i=1/6 {
qui safecount if sex==`sex' & case==1 & ethnicity1==`i'
local cases_`sex'_`i' = round(r(N),5)
local cases_`sex'_pc_`i' = (`cases_`sex'_`i''/`cases_`i'')*100
qui safecount if sex==`sex' & case==0 & ethnicity1==`i'
local controls_`sex'_`i' = round(r(N),5)
local controls_`sex'_pc_`i' = (`controls_`sex'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`sex'_`i''>5 & `cases_`sex'_`i''!=. {
file write tablecontent %9.0f (`cases_`sex'_`i'') (" (") %4.1f (`cases_`sex'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`sex'_`i''>5 & `controls_`sex'_`i''!=. {
file write tablecontent %9.0f (`controls_`sex'_`i'') (" (") %4.1f (`controls_`sex'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*IMD
file write tablecontent ("Index of multiple deprivation") _n
forvalues imd=1/5 {
local label_`imd': label imd `imd'
file write tablecontent ("`label_`imd''") _tab
forvalues i=1/6 {
qui safecount if imd==`imd' & case==1 & ethnicity1==`i'
local cases_`imd'_`i' = round(r(N),5)
local cases_`imd'_pc_`i' = (`cases_`imd'_`i''/`cases_`i'')*100
qui safecount if imd==`imd' & case==0 & ethnicity1==`i'
local controls_`imd'_`i' = round(r(N),5)
local controls_`imd'_pc_`i' = (`controls_`imd'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`imd'_`i''>5 & `cases_`imd'_`i''!=. {
file write tablecontent %9.0f (`cases_`imd'_`i'') (" (") %4.1f (`cases_`imd'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`imd'_`i''>5 & `controls_`imd'_`i''!=. {
file write tablecontent %9.0f (`controls_`imd'_`i'') (" (") %4.1f (`controls_`imd'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*Region
file write tablecontent ("Region") _n
forvalues region=1/9 {
local label_`region': label region `region'
file write tablecontent ("`label_`region''") _tab
forvalues i=1/6 {
qui safecount if region==`region' & case==1 & ethnicity1==`i'
local cases_`region'_`i' = round(r(N),5)
local cases_`region'_pc_`i' = (`cases_`region'_`i''/`cases_`i'')*100
qui safecount if region==`region' & case==0 & ethnicity1==`i'
local controls_`region'_`i' = round(r(N),5)
local controls_`region'_pc_`i' = (`controls_`region'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`region'_`i''>5 & `cases_`region'_`i''!=. {
file write tablecontent %9.0f (`cases_`region'_`i'') (" (") %4.1f (`cases_`region'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`region'_`i''>5 & `controls_`region'_`i''!=. {
file write tablecontent %9.0f (`controls_`region'_`i'') (" (") %4.1f (`controls_`region'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*Urban/rural
file write tablecontent ("Urban/rural") _n
forvalues urban=0/1 {
local label_`urban': label urban `urban'
file write tablecontent ("`label_`urban''") _tab
forvalues i=1/6 {
qui safecount if urban==`urban' & case==1 & ethnicity1==`i'
local cases_`urban'_`i' = round(r(N),5)
local cases_`urban'_pc_`i' = (`cases_`urban'_`i''/`cases_`i'')*100
qui safecount if urban==`urban' & case==0 & ethnicity1==`i'
local controls_`urban'_`i' = round(r(N),5)
local controls_`urban'_pc_`i' = (`controls_`urban'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`urban'_`i''>5 & `cases_`urban'_`i''!=. {
file write tablecontent %9.0f (`cases_`urban'_`i'') (" (") %4.1f (`cases_`urban'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`urban'_`i''>5 & `controls_`urban'_`i''!=. {
file write tablecontent %9.0f (`controls_`urban'_`i'') (" (") %4.1f (`controls_`urban'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*BMI
file write tablecontent ("Body mass index") _n
forvalues bmi=1/6 {
local label_`bmi': label bmi `bmi'
file write tablecontent ("`label_`bmi''") _tab
forvalues i=1/6 {
qui safecount if bmi==`bmi' & case==1 & ethnicity1==`i'
local cases_`bmi'_`i' = round(r(N),5)
local cases_`bmi'_pc_`i' = (`cases_`bmi'_`i''/`cases_`i'')*100
qui safecount if bmi==`bmi' & case==0 & ethnicity1==`i'
local controls_`bmi'_`i' = round(r(N),5)
local controls_`bmi'_pc_`i' = (`controls_`bmi'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`bmi'_`i''>5 & `cases_`bmi'_`i''!=. {
file write tablecontent %9.0f (`cases_`bmi'_`i'') (" (") %4.1f (`cases_`bmi'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`bmi'_`i''>5 & `controls_`bmi'_`i''!=. {
file write tablecontent %9.0f (`controls_`bmi'_`i'') (" (") %4.1f (`controls_`bmi'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
forvalues i=1/6 {
qui safecount if bmi==. & case==1 & ethnicity1==`i'
local cases_bmi_`i' = round(r(N),5)
local cases_bmi_pc_`i' = (`cases_bmi_`i''/`cases_`i'')*100
qui safecount if bmi==. & case==0 & ethnicity1==`i'
local controls_bmi_`i' = round(r(N),5)
local controls_bmi_pc_`i' = (`controls_bmi_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_bmi_`i''>5 & `cases_bmi_`i''!=. {
file write tablecontent %9.0f (`cases_bmi_`i'') (" (") %4.1f (`cases_bmi_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_bmi_`i''>5 & `controls_bmi_`i''!=. {
file write tablecontent %9.0f (`controls_bmi_`i'') (" (") %4.1f (`controls_bmi_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n



*Smoking
file write tablecontent ("Smoking") _n
forvalues smoking=0/1 {
local label_`smoking': label smoking `smoking'
file write tablecontent ("`label_`smoking''") _tab
forvalues i=1/6 {
qui safecount if smoking==`smoking' & case==1 & ethnicity1==`i'
local cases_`smoking'_`i' = round(r(N),5)
local cases_`smoking'_pc_`i' = (`cases_`smoking'_`i''/`cases_`i'')*100
qui safecount if smoking==`smoking' & case==0 & ethnicity1==`i'
local controls_`smoking'_`i' = round(r(N),5)
local controls_`smoking'_pc_`i' = (`controls_`smoking'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`smoking'_`i''>5 & `cases_`smoking'_`i''!=. {
file write tablecontent %9.0f (`cases_`smoking'_`i'') (" (") %4.1f (`cases_`smoking'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`smoking'_`i''>5 & `controls_`smoking'_`i''!=. {
file write tablecontent %9.0f (`controls_`smoking'_`i'') (" (") %4.1f (`controls_`smoking'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}
file write tablecontent ("Missing") _tab
forvalues i=1/6 {
qui safecount if smoking==. & case==1 & ethnicity1==`i'
local cases_smoking_`i' = round(r(N),5)
local cases_smoking_pc_`i' = (`cases_smoking_`i''/`cases_`i'')*100
qui safecount if smoking==. & case==0 & ethnicity1==`i'
local controls_smoking_`i' = round(r(N),5)
local controls_smoking_pc_`i' = (`controls_smoking_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_smoking_`i''>5 & `cases_smoking_`i''!=. {
file write tablecontent %9.0f (`cases_smoking_`i'') (" (") %4.1f (`cases_smoking_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_smoking_`i''>5 & `controls_smoking_`i''!=. {
file write tablecontent %9.0f (`controls_smoking_`i'') (" (") %4.1f (`controls_smoking_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n


*Baseline eGFR
file write tablecontent ("Median baseline eGFR (IQR)") _tab
forvalues i=1/6 {
qui sum baseline_egfr if case==1 & ethnicity1==`i', d
local cases_q2_`i' = r(p50)
local cases_q1_`i' = r(p25)
local cases_q3_`i' = r(p75)
qui sum baseline_egfr if case==0 & ethnicity1==`i', d
local controls_q2_`i' = r(p50)
local controls_q1_`i' = r(p25)
local controls_q3_`i' = r(p75)
}

forvalues i=1/6 {
if `cases_`i''>5 & `cases_`i''!=. {
file write tablecontent %3.1f (`cases_q2_`i'') (" (") %3,1f (`cases_q1_`i'') ("-") %3.1f (`cases_q3_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`i''>5 & `controls_`i''!=. {
file write tablecontent %3.1f (`controls_q2_`i'') (" (") %3,1f (`controls_q1_`i'') ("-") %3.1f (`controls_q3_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
file write tablecontent ("Baseline eGFR range") _n
forvalues group=1/7 {
local label_`group': label egfr_group `group'
file write tablecontent ("`label_`group''") _tab
forvalues i=1/6 {
qui safecount if egfr_group==`group' & case==1 & ethnicity1==`i'
local cases_`group'_`i' = round(r(N),5)
local cases_`group'_pc_`i' = (`cases_`group'_`i''/`cases_`i'')*100
qui safecount if egfr_group==`group' & case==0 & ethnicity1==`i'
local controls_`group'_`i' = round(r(N),5)
local controls_`group'_pc_`i' = (`controls_`group'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`group'_`i''>5 & `cases_`group'_`i''!=. {
file write tablecontent %9.0f (`cases_`group'_`i'') (" (") %4.1f (`cases_`group'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`group'_`i''>5 & `controls_`group'_`i''!=. {
file write tablecontent %9.0f (`controls_`group'_`i'') (" (") %4.1f (`controls_`group'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}


*AKI
file write tablecontent ("Previous acute kidney injury") _tab
forvalues i=1/6 {
qui safecount if aki_baseline==1 & case==1 & ethnicity1==`i'
local cases_aki_`i' = round(r(N),5)
local cases_aki_pc_`i' = (`cases_aki_`i''/`cases_`i'')*100
qui safecount if aki_baseline==1 & case==0 & ethnicity1==`i'
local controls_aki_`i' = round(r(N),5)
local controls_aki_pc_`i' = (`controls_aki_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_aki_`i''>5 & `cases_aki_`i''!=. {
file write tablecontent %9.0f (`cases_aki_`i'') (" (") %4.1f (`cases_aki_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_aki_`i''>5 & `controls_aki_`i''!=. {
file write tablecontent %9.0f (`controls_aki_`i'') (" (") %4.1f (`controls_aki_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Cardiovascular diseases
file write tablecontent ("Cardiovascular diseases") _tab
forvalues i=1/6 {
qui safecount if cardiovascular==1 & case==1 & ethnicity1==`i'
local cases_cardiovascular_`i' = round(r(N),5)
local cases_cardiovascular_pc_`i' = (`cases_cardiovascular_`i''/`cases_`i'')*100
qui safecount if cardiovascular==1 & case==0 & ethnicity1==`i'
local controls_cardiovascular_`i' = round(r(N),5)
local controls_cardiovascular_pc_`i' = (`controls_cardiovascular_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_cardiovascular_`i''>5 & `cases_cardiovascular_`i''!=. {
file write tablecontent %9.0f (`cases_cardiovascular_`i'') (" (") %4.1f (`cases_cardiovascular_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_cardiovascular_`i''>5 & `controls_cardiovascular_`i''!=. {
file write tablecontent %9.0f (`controls_cardiovascular_`i'') (" (") %4.1f (`controls_cardiovascular_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Diabetes
file write tablecontent ("Diabetes") _tab
forvalues i=1/6 {
qui safecount if diabetes==1 & case==1 & ethnicity1==`i'
local cases_diabetes_`i' = round(r(N),5)
local cases_diabetes_pc_`i' = (`cases_diabetes_`i''/`cases_`i'')*100
qui safecount if diabetes==1 & case==0 & ethnicity1==`i'
local controls_diabetes_`i' = round(r(N),5)
local controls_diabetes_pc_`i' = (`controls_diabetes_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_diabetes_`i''>5 & `cases_diabetes_`i''!=. {
file write tablecontent %9.0f (`cases_diabetes_`i'') (" (") %4.1f (`cases_diabetes_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_diabetes_`i''>5 & `controls_diabetes_`i''!=. {
file write tablecontent %9.0f (`controls_diabetes_`i'') (" (") %4.1f (`controls_diabetes_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Hypertension
file write tablecontent ("Hypertension") _tab
forvalues i=1/6 {
qui safecount if hypertension==1 & case==1 & ethnicity1==`i'
local cases_hypertension_`i' = round(r(N),5)
local cases_hypertension_pc_`i' = (`cases_hypertension_`i''/`cases_`i'')*100
qui safecount if hypertension==1 & case==0 & ethnicity1==`i'
local controls_hypertension_`i' = round(r(N),5)
local controls_hypertension_pc_`i' = (`controls_hypertension_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_hypertension_`i''>5 & `cases_hypertension_`i''!=. {
file write tablecontent %9.0f (`cases_hypertension_`i'') (" (") %4.1f (`cases_hypertension_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_hypertension_`i''>5 & `controls_hypertension_`i''!=. {
file write tablecontent %9.0f (`controls_hypertension_`i'') (" (") %4.1f (`controls_hypertension_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Immunosuppressive diseases
file write tablecontent ("Immunosuppressive diseases") _tab
forvalues i=1/6 {
qui safecount if immunosuppressed==1 & case==1 & ethnicity1==`i'
local cases_immunosuppressed_`i' = round(r(N),5)
local cases_immunosuppressed_pc_`i' = (`cases_immunosuppressed_`i''/`cases_`i'')*100
qui safecount if immunosuppressed==1 & case==0 & ethnicity1==`i'
local controls_immunosuppressed_`i' = round(r(N),5)
local controls_immunosuppressed_pc_`i' = (`controls_immunosuppressed_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_immunosuppressed_`i''>5 & `cases_immunosuppressed_`i''!=. {
file write tablecontent %9.0f (`cases_immunosuppressed_`i'') (" (") %4.1f (`cases_immunosuppressed_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_immunosuppressed_`i''>5 & `controls_immunosuppressed_`i''!=. {
file write tablecontent %9.0f (`controls_immunosuppressed_`i'') (" (") %4.1f (`controls_immunosuppressed_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*Cancer
file write tablecontent ("Non-haematological cancer") _tab
qui safecount if non_haem_cancer==1 & case==1
forvalues i=1/6 {
qui safecount if non_haem_cancer==1 & case==1 & ethnicity1==`i'
local cases_non_haem_cancer_`i' = round(r(N),5)
local cases_non_haem_cancer_pc_`i' = (`cases_non_haem_cancer_`i''/`cases_`i'')*100
qui safecount if non_haem_cancer==1 & case==0 & ethnicity1==`i'
local controls_non_haem_cancer_`i' = round(r(N),5)
local controls_non_haem_cancer_pc_`i' = (`controls_non_haem_cancer_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_non_haem_cancer_`i''>5 & `cases_non_haem_cancer_`i''!=. {
file write tablecontent %9.0f (`cases_non_haem_cancer_`i'') (" (") %4.1f (`cases_non_haem_cancer_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_non_haem_cancer_`i''>5 & `controls_non_haem_cancer_`i''!=. {
file write tablecontent %9.0f (`controls_non_haem_cancer_`i'') (" (") %4.1f (`controls_non_haem_cancer_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*COVID-19 hospitalisation
file write tablecontent ("COVID-19 hospitalisation") _tab
qui safecount if covid_covariate==1 & case==1
forvalues i=1/6 {
qui safecount if covid_covariate==1 & case==1 & ethnicity1==`i'
local cases_covid_covariate_`i' = round(r(N),5)
local cases_covid_covariate_pc_`i' = (`cases_covid_covariate_`i''/`cases_`i'')*100
qui safecount if covid_covariate==1 & case==0 & ethnicity1==`i'
local controls_covid_covariate_`i' = round(r(N),5)
local controls_covid_covariate_pc_`i' = (`controls_covid_covariate_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_covid_covariate_`i''>5 & `cases_covid_covariate_`i''!=. {
file write tablecontent %9.0f (`cases_covid_covariate_`i'') (" (") %4.1f (`cases_covid_covariate_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_covid_covariate_`i''>5 & `controls_covid_covariate_`i''!=. {
file write tablecontent %9.0f (`controls_covid_covariate_`i'') (" (") %4.1f (`controls_covid_covariate_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n

*GP consultations
file write tablecontent ("Median GP consultations prior year (IQR)") _tab
forvalues i=1/6 {
qui sum gp_count if case==1 & ethnicity1==`i', d
local cases_q2_`i' = r(p50)
local cases_q1_`i' = r(p25)
local cases_q3_`i' = r(p75)
qui sum gp_count if case==0 & ethnicity1==`i', d
local controls_q2_`i' = r(p50)
local controls_q1_`i' = r(p25)
local controls_q3_`i' = r(p75)
}

forvalues i=1/6 {
if `cases_`i''>5 & `cases_`i''!=. {
file write tablecontent %3.1f (`cases_q2_`i'') (" (") %3,1f (`cases_q1_`i'') ("-") %3.1f (`cases_q3_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`i''>5 & `controls_`i''!=. {
file write tablecontent %3.1f (`controls_q2_`i'') (" (") %3,1f (`controls_q1_`i'') ("-") %3.1f (`controls_q3_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n


*Hospital admissions
file write tablecontent ("Hospital admissions 5 years") _n
forvalues group=0/2 {
local label_`group': label admissions `group'
file write tablecontent ("`label_`group''") _tab
forvalues i=1/6 {
qui safecount if admissions==`group' & case==1 & ethnicity1==`i'
local cases_`group'_`i' = round(r(N),5)
local cases_`group'_pc_`i' = (`cases_`group'_`i''/`cases_`i'')*100
qui safecount if admissions==`group' & case==0 & ethnicity1==`i'
local controls_`group'_`i' = round(r(N),5)
local controls_`group'_pc_`i' = (`controls_`group'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`group'_`i''>5 & `cases_`group'_`i''!=. {
file write tablecontent %9.0f (`cases_`group'_`i'') (" (") %4.1f (`cases_`group'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`group'_`i''>5 & `controls_`group'_`i''!=. {
file write tablecontent %9.0f (`controls_`group'_`i'') (" (") %4.1f (`controls_`group'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}

*COVID-19 vaccination
file write tablecontent ("COVID-19 vaccination status") _n
forvalues vax=1/5 {
local label_`vax': label covid_vax `vax'
file write tablecontent ("`label_`vax''") _tab
forvalues i=1/6 {
qui safecount if covid_vax==`vax' & case==1 & ethnicity1==`i'
local cases_`vax'_`i' = round(r(N),5)
local cases_`vax'_pc_`i' = (`cases_`vax'_`i''/`cases_`i'')*100
qui safecount if covid_vax==`vax' & case==0 & ethnicity1==`i'
local controls_`vax'_`i' = round(r(N),5)
local controls_`vax'_pc_`i' = (`controls_`vax'_`i''/`controls_`i'')*100
}
forvalues i=1/6 {
if `cases_`vax'_`i''>5 & `cases_`vax'_`i''!=. {
file write tablecontent %9.0f (`cases_`vax'_`i'') (" (") %4.1f (`cases_`vax'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}

forvalues i=1/6 {
if `controls_`vax'_`i''>5 & `controls_`vax'_`i''!=. {
file write tablecontent %9.0f (`controls_`vax'_`i'') (" (") %4.1f (`controls_`vax'_pc_`i'') (")") _tab
}
else {
file write tablecontent ("REDACTED") _tab
}
}
file write tablecontent _n
}


file close tablecontent