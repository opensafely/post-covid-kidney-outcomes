sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/analysis_2017.log, replace t

** Analysis cohort selection
capture noisily import delimited ./output/input_covid_matching.csv, clear
di "Potential COVID-19 cases extracted from OpenSAFELY:"
safecount
capture noisily import delimited ./output/input_2017_matching.csv, clear
di "Potential historical comparators extracted from OpenSAFELY:"
safecount
capture noisily import delimited ./output/covid_matching_2017.csv, clear
di "Potential COVID-19 cases after application of exclusion criteria:"
safecount
capture noisily import delimited ./output/2017_matching.csv, clear
di "Potential historical comparators after application of exclusion criteria:"
safecount
* Import COVID-19 dataset comprising individuals matched with historical comparators (limited matching variables only)	
capture noisily import delimited ./output/input_combined_stps_covid_2017.csv, clear
* Drop age & covid_diagnosis_date
keep patient_id death_date date_deregistered stp krt_outcome_date male covid_date covid_month set_id case match_counts
tempfile covid_2017_matched
* For dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `covid_2017_matched', replace
* Number of matched COVID-19 cases
count
* Import matched historical comparators (limited matching variables only)
capture noisily import delimited ./output/input_combined_stps_matches_2017.csv, clear
* Drop age
keep patient_id death_date date_deregistered stp krt_outcome_date male set_id case covid_date
tempfile 2017_matched
* For dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `2017_matched', replace
* Number of matched historical comparators
count
* Merge limited COVID-19 dataset with additional variables
capture noisily import delimited ./output/input_covid_2017_additional.csv, clear
merge 1:1 patient_id using `covid_2017_matched'
keep if _merge==3
drop _merge
tempfile covid_2017_complete
save `covid_2017_complete', replace
di "Matched COVID-19 cases:"
safecount
* Merge limited historical comparator dataset with additional variables
capture noisily import delimited ./output/input_2017_additional.csv, clear
merge 1:1 patient_id using `2017_matched'
keep if _merge==3
drop _merge
tempfile 2017_complete
save `2017_complete', replace
di "Matched historical comparators:"
safecount
* Append matched COVID-19 cases and historical comparators
append using `covid_2017_complete', force
order patient_id set_id match_count case
gsort set_id -case
count if case==0
di "Matched COVID-19 cases and historical comparators:"
safecount
tab case
* Save list of matched COVID-19 cases
preserve
	keep if case==1
	keep patient_id
	tempfile covid_2017_matched_list
	save `covid_2017_matched_list', replace
restore
* Generate list of unmatched COVID-19 cases
preserve
	capture noisily import delimited ./output/input_covid_matching.csv, clear
	* For dummy data, should do nothing in the real data
	duplicates drop patient_id, force
	tempfile covid_prematching
	save `covid_prematching', replace
	use `covid_2017_matched_list', clear
	merge 1:1 patient_id using `covid_prematching'
	keep if _merge==2
	safecount
	save output/covid_unmatched_2017.dta, replace
	di "Unmatched COVID-19 cases:"
	safecount
restore

**ID
* Need to create unique identifiers as individuals may be in both covid_2017_matched and 2017_matched so will have the same patient_id
gen unique = _n
label var unique "Unique ID"


** Exclusions
* Index of multiple deprivation missing
* Ordered 1-5 from most deprived to least deprived
label var imd "Index of multiple deprivation (IMD)"
label define imd 1 "1 Most deprived" 2 "2" 3 "3" 4 "4" 5 "5 Least deprived"
label values imd imd
tab imd, m
drop if imd==0
safetab imd

* STP missing
drop stp
tab stp_updated
drop if stp_updated==""
bysort stp_updated: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_updated
label values stp stp
label var stp "STP"
safetab stp

* Region missing
rename region region_string
gen region = 1 if region_string=="East Midlands"
replace region = 2 if region_string=="East"
replace region = 3 if region_string=="London"
replace region = 4 if region_string=="North East"
replace region = 5 if region_string=="North West"
replace region = 6 if region_string=="South East"
replace region = 7 if region_string=="South West"
replace region = 8 if region_string=="West Midlands"
replace region = 9 if region_string=="Yorkshire and The Humber"
replace region = 10 if region_string==""
label define region 	1 "East Midlands" 					///
						2 "East"   							///
						3 "London" 							///
						4 "North East" 						///
						5 "North West" 						///
						6 "South East" 						///
						7 "South West"						///
						8 "West Midlands" 					///
						9 "Yorkshire and The Humber"		///
						10 "Missing"
label values region region
label var region "Region"
tab region
drop if region==10
safetab region

* Exclusions due to deregistration and kidney replacement therapy will be checked (should already have been applied from previous steps in workflow)
gen index_date = date(case_index_date, "YMD")
format index_date %td

* Deregistered before index_date
gen deregistered_date = date(date_deregistered, "YMD")
format deregistered_date %td
drop date_deregistered 
drop if deregistered_date < index_date

* Kidney replacement therapy before index_date
gen krt_date = date(krt_outcome_date, "YMD")
format krt_date %td
drop krt_outcome_date
drop if krt_date < index_date
gen index_date_28 = index_date + 28
format index_date_28 %td
replace krt_date = index_date_28 if krt_date < index_date_28

* Death before index_date + 28 days (i.e. only include people who survived 28 days after index_date)
gen death_date1 = date(death_date, "YMD")
format death_date1 %td
drop death_date
rename death_date1 death_date
gen deceased = 0
replace deceased = 1 if death_date < index_date_28
label define deceased 0 "Alive at 28 days after index date" 1 "Deceased within 28 days of index date"
label values deceased deceased
tab case deceased
drop if deceased==1
drop deceased

* eGFR <15 before index_date - should apply to matched historical comparators only
gen index_year = yofd(index_date)
gen age = index_year - year_of_birth
gen sex = 1 if male == "Male"
label var sex "Sex"
replace sex = 0 if male == "Female"
label define sex 0"Female" 1"Male"
label values sex sex
foreach baseline_creatinine_monthly of varlist 	baseline_creatinine_feb2017 ///
												baseline_creatinine_mar2017 ///
												baseline_creatinine_apr2017 ///
												baseline_creatinine_may2017 ///
												baseline_creatinine_jun2017 ///
												baseline_creatinine_jul2017 ///
												baseline_creatinine_aug2017 ///
												baseline_creatinine_sep2017 ///
												baseline_creatinine_oct2017 ///
												baseline_creatinine_nov2017 ///
												baseline_creatinine_dec2017 ///
												baseline_creatinine_jan2018 ///
												baseline_creatinine_feb2018 ///
												baseline_creatinine_mar2018 ///
												baseline_creatinine_apr2018 ///
												baseline_creatinine_may2018 ///
												baseline_creatinine_jun2018 ///
												baseline_creatinine_jul2018 ///
												baseline_creatinine_aug2018 ///
												baseline_creatinine_sep2018 ///
												baseline_creatinine_oct2018 ///
												baseline_creatinine_nov2018 ///
												baseline_creatinine_dec2018 ///
												baseline_creatinine_jan2019 ///
												baseline_creatinine_feb2019 ///
												baseline_creatinine_mar2019 ///
												baseline_creatinine_apr2019 ///
												baseline_creatinine_may2019 ///
												baseline_creatinine_jun2019 ///
												baseline_creatinine_jul2019 ///
												baseline_creatinine_aug2019 ///
												baseline_creatinine_sep2019 ///
												baseline_creatinine_feb2020 ///
												baseline_creatinine_mar2020 ///
												baseline_creatinine_apr2020 ///
												baseline_creatinine_may2020 ///
												baseline_creatinine_jun2020 ///
												baseline_creatinine_jul2020 ///
												baseline_creatinine_aug2020 ///
												baseline_creatinine_sep2020 ///
												baseline_creatinine_oct2020 ///
												baseline_creatinine_nov2020 ///
												baseline_creatinine_dec2020 ///
												baseline_creatinine_jan2021 ///
												baseline_creatinine_feb2021 ///
												baseline_creatinine_mar2021 ///
												baseline_creatinine_apr2021 ///
												baseline_creatinine_may2021 ///
												baseline_creatinine_jun2021 ///
												baseline_creatinine_jul2021 ///
												baseline_creatinine_aug2021 ///
												baseline_creatinine_sep2021 ///
												baseline_creatinine_oct2021 ///
												baseline_creatinine_nov2021 ///
												baseline_creatinine_dec2021 ///
												baseline_creatinine_jan2022 ///
												baseline_creatinine_feb2022 ///
												baseline_creatinine_mar2022 ///
												baseline_creatinine_apr2022 ///
												baseline_creatinine_may2022 ///
												baseline_creatinine_jun2022 ///
												baseline_creatinine_jul2022 ///
												baseline_creatinine_aug2022 ///
												baseline_creatinine_sep2022 ///
												baseline_creatinine_oct2022 {
replace `baseline_creatinine_monthly' = . if !inrange(`baseline_creatinine_monthly', 20, 3000)
gen mgdl_`baseline_creatinine_monthly' = `baseline_creatinine_monthly'/88.4
gen min_`baseline_creatinine_monthly'=.
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if sex==0
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if sex==1
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.329 if sex==0
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.411 if sex==1
replace min_`baseline_creatinine_monthly' = 1 if min_`baseline_creatinine_monthly'<1
gen max_`baseline_creatinine_monthly'=.
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if sex==0
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if sex==1
replace max_`baseline_creatinine_monthly' = max_`baseline_creatinine_monthly'^-1.209
replace max_`baseline_creatinine_monthly' = 1 if max_`baseline_creatinine_monthly'>1
gen egfr_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'*max_`baseline_creatinine_monthly'*141
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*(0.993^age)
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*1.018 if sex==0
drop `baseline_creatinine_monthly'
drop mgdl_`baseline_creatinine_monthly'
drop min_`baseline_creatinine_monthly'
drop max_`baseline_creatinine_monthly'
}
gen index_date_string=string(index_date, "%td") 
gen index_month=substr(index_date_string ,3,7)
gen baseline_egfr=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022"
foreach x of local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if index_month=="`x'"
drop egfr_baseline_creatinine_`x'
}
label var baseline_egfr "Baseline eGFR"
gen baseline_esrd = 0
replace baseline_esrd = 1 if baseline_egfr <15
label define baseline_esrd 0 "No ESRD" 1 "ESRD"
label values baseline_esrd baseline_esrd
tab case baseline_esrd
drop if baseline_esrd==1
drop baseline_esrd

* Drop COVID-19 cases without any matched historical comparators after further application of exclusion criteria
generate match_counts1=.
order patient_id set_id match_counts match_counts1
bysort set_id: replace match_counts1=_N-1
replace match_counts1=. if case==0
drop match_counts
rename match_counts1 match_counts
count if match_counts==0
drop if match_counts==0
safetab case
tab match_counts

bysort set_id: egen set_case_mean = mean(case) // if mean of exposure var is 0 then only uncase in set, if 1 then only case in set
gen valid_set = (set_case_mean>0 & set_case_mean<1) // ==1 is valid set containing both case and uncase
tab valid_set, miss
tab valid_set case, col
keep if valid_set==1
drop valid_set set_case_mean

** Exposure
label define case 0 "Historical comparator" ///
				  1 "SARS-CoV-2"
label values case case
safetab case 

* COVID-19 severity
gen covid_severity = case
replace covid_severity = 2 if covid_hospitalised==1
replace covid_severity = 3 if covid_critical_care==1
replace covid_severity = 3 if covid_critical_days==1
label define covid_severity	0 "Historical comparator"		///
							1 "Non-hospitalised COVID" ///
							2 "Hospitalised COVID"		///
							3 "Critical care COVID"
label values covid_severity covid_severity
label var covid_severity "SARS-CoV-2 severity"
drop covid_critical_care
drop covid_critical_days
safetab covid_severity, m

* COVID-19 acute kidney injury
gen covid_aki = case
replace covid_aki = 2 if covid_hospitalised==1
replace covid_aki = 3 if covid_acute_kidney_injury==1
label define covid_aki	0 "Historical comparator" 			///
						1 "Non-hospitalised COVID"		///
						2 "Hospitalised COVID"	///
						3 "Hospitalised COVID-AKI"
label values covid_aki covid_aki
label var covid_aki "COVID-19 acute kidney injury"
drop covid_acute_kidney_injury
safetab covid_aki, m

* COVID-19 kidney replacement therapy
gen covid_krt_combined = covid_krt_icd_10
replace covid_krt_combined = covid_krt_opcs_4 if covid_krt_icd_10==0
gen covid_krt = case
replace covid_krt = 2 if covid_hospitalised==1
replace covid_krt = 3 if covid_krt_combined==1
label define covid_krt	0 "Historical comparator" 			///
						1 "Non-hospitalised SARS-CoV-2"		///
						2 "No KRT hospitalised COVID-19"	///
						3 "KRT hospitalised COVID-19"
label values covid_krt covid_krt
label var covid_krt "COVID-19 kidney replacement therapy"
drop covid_krt_icd_10
drop covid_krt_opcs_4
safetab covid_krt, m

* COVID-19 vaccination status
gen covidvax1date = date(covid_vax_1_date, "YMD")
format covidvax1date %td
gen covidvax2date = date(covid_vax_2_date, "YMD")
format covidvax2date %td
gen covidvax3date = date(covid_vax_3_date, "YMD")
format covidvax3date %td
gen covidvax4date = date(covid_vax_4_date, "YMD")
format covidvax4date %td
gen covid_vax = case
replace covid_vax = 5 if covidvax4date!=.
replace covid_vax = 4 if covid_vax==1 &covidvax3date!=.
replace covid_vax = 3 if covid_vax==1 &covidvax2date!=.
replace covid_vax = 2 if covid_vax==1 &covidvax1date!=.
drop covidvax1date
drop covidvax2date
drop covidvax3date
drop covidvax4date
label define covid_vax	0 "Historical comparator"	///
						1 "Pre-vaccination"			///
						2 "1 vaccine dose"			///
						3 "2 vaccine doses"			///
						4 "3 vaccine doses"			///
						5 "4 vaccine doses"
label values covid_vax covid_vax
label var covid_vax "Vaccination status"
safetab covid_vax, m

* COVID-19 wave
gen wave = case
replace wave = 2 if index_month=="sep2020"
replace wave = 2 if index_month=="oct2020"
replace wave = 2 if index_month=="nov2020"
replace wave = 2 if index_month=="dec2020"
replace wave = 2 if index_month=="jan2021"
replace wave = 2 if index_month=="feb2021"
replace wave = 2 if index_month=="mar2021"
replace wave = 2 if index_month=="apr2021"
replace wave = 2 if index_month=="may2021"
replace wave = 2 if index_month=="jun2021"
replace wave = 3 if index_month=="jul2021"
replace wave = 3 if index_month=="aug2021"
replace wave = 3 if index_month=="sep2021"
replace wave = 3 if index_month=="oct2021"
replace wave = 3 if index_month=="nov2021"
replace wave = 4 if index_month=="dec2021"
replace wave = 4 if index_month=="jan2022"
replace wave = 4 if index_month=="feb2022"
replace wave = 4 if index_month=="mar2022"
replace wave = 4 if index_month=="apr2022"
replace wave = 4 if index_month=="may2022"
replace wave = 4 if index_month=="jun2022"
replace wave = 4 if index_month=="jul2022"
replace wave = 4 if index_month=="aug2022"
replace wave = 4 if index_month=="sep2022"
replace wave = 4 if index_month=="oct2022"
label define wave	0 "Historical comparator"	///
					1 "Febuary20-August20"	///
					2 "September20-June21"	///
					3 "July21-November21"	///
					4 "December21-October22"	
label values wave wave
label var wave "COVID-19 wave"
safetab wave, m

** Covariates
* Age
tab age
safecount
recode 	age 			min/39.9999=1 	///
						40/49.9999=2 	///
						50/59.9999=3 	///
						60/69.9999=4 	///
						70/79.9999=5	///					
						80/max=6, 		///
						gen(agegroup) 

label var age "Age"
label values age age
label define agegroup 	1 "18-39" 		///
						2 "40-49" 		///
						3 "50-59" 		///
						4 "60-69" 		///
						5 "70-79"		///
						6 "80+"
label var agegroup "Age group"
label values agegroup agegroup

* Check there are no missing ages
assert age<.
assert agegroup<.
* Create restricted cubic splines for age
mkspline age = age, cubic nknots(4)

* Sex
safetab sex
safecount

* Ethnicity
* 1 = White ethnicities (white British, white Irish, with other)
* 2 = Mixed ethnicities (white & black Caribbean, white & black African, white & Asian, other mixed ethnicities)
* 3 = South Asian ethnicities (Indian, Pakistani, Bangladeshi, other South Asian)
* 4 = Black ethnicities (black Caribbean, black African, other black)
* 5 = Other ethnicities (Chinese, all other ethnicities)
* . = Unknown ethnicity
replace ethnicity = . if ethnicity==.
replace ethnicity=6 if ethnicity==2
replace ethnicity=2 if ethnicity==3
replace ethnicity=3 if ethnicity==4
replace ethnicity=4 if ethnicity==6
label define ethnicity 	1 "White"  		///
						2 "South Asian"	///						
						3 "Black"  		///
						4 "Mixed"		///
						5 "Other"								
label values ethnicity ethnicity
safetab ethnicity, m
* Ethnicity (including unknown ethnicity)
gen ethnicity1 = ethnicity
replace ethnicity1=6 if ethnicity1==.
label define ethnicity1	1 "White"  					///
						2 "South Asian"				///						
						3 "Black"  					///
						4 "Mixed"					///
						5 "Other"					///
						6 "Unknown"	
label values ethnicity1 ethnicity1
label var ethnicity1 "Ethnicity"
safetab ethnicity1, m

* Urban/rural
replace rural_urban=. if rural_urban<1|rural_urban>8
label define rural_urban 1 "Urban major conurbation" 						///
						 2 "Urban minor conurbation" 						///
						 3 "Urban city and town" 							///
						 4 "Urban city and town in a sparse setting" 		///
						 5 "Rural town and fringe" 							///
						 6 "Rural town and fringe in a sparse setting" 		///
						 7 "Rural village and dispersed" 					///
						 8 "Rural village and dispersed in a sparse setting"
label values rural_urban rural_urban
tab rural_urban, m
* Urban (binary)
* Urban = 1-4 + missing, Rural = 5-8
generate urban=.
replace urban=1 if rural_urban<=4|rural_urban==.
replace urban=0 if rural_urban>4 & rural_urban!=.
label var urban "Urban/rural"
label define urban 0 "Rural" 1 "Urban"
label values urban urban
tab urban rural_urban, m
tab case urban

* BMI
replace body_mass_index = . if !inrange(body_mass_index, 15, 50)
gen 	bmi = .
recode  bmi . = 1 if body_mass_index<18.5
recode  bmi . = 2 if body_mass_index<25
recode  bmi . = 3 if body_mass_index<30
recode  bmi . = 4 if body_mass_index<35
recode  bmi . = 5 if body_mass_index<40
recode  bmi . = 6 if body_mass_index<.
replace bmi = . if body_mass_index>=.
label define bmi	1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"				
label values bmi bmi
label var bmi "Body mass index (BMI)"
safetab bmi, m

* Smoking
gen smoking = 1 if smoking_status=="S"
replace smoking = 1 if smoking_status=="E"
replace smoking = 0 if smoking_status=="N"
replace smoking = . if smoking_status=="M"
label define smoking 1 "Current/former smoker" 0 "Non-smoker"
label values smoking smoking
label var smoking "Smoking status"
safetab smoking, m

* Baseline eGFR groups
* All baseline eGFR <15 should already by excluded
egen egfr_group = cut(baseline_egfr), at(0, 15, 30, 45, 60, 75, 90, 105, 5000)
recode egfr_group 0=8 15=7 30=6 45=5 60=4 75=3 90=2 105=1
label define egfr_group 1 "≥105" 2 "90-104" 3 "75-89" 4 "60-74" 5 "45-59" 6 "30-44" 7 "15-29" 8 "<15"
label values egfr_group egfr_group
label var egfr_group "Baseline eGFR range"
safetab egfr_group, m

* Baseline CKD stage
* No CKD = eGFR >59, CKD 3A = eGFR 45-59, CKD 3B = eGFR 30-44, CKD 4 = eGFR 15-29, CKD 5 = eGFR <15
* CKD 5 should already be excluded
gen ckd_stage = egfr_group
recode ckd_stage 2/4=1 5=2 6=3 7=4 8=5 .=6
label define ckd_stage 1 "No CKD" 2 "CKD 3A" 3 "CKD 3B" 4 "CKD 4" 5 "CKD 5" 6 "No baseline eGFR measurement"
label values ckd_stage ckd_stage
label var ckd_stage "Baseline CKD stage"
safetab ckd_stage, m

* Comorbidities
gen afib = atrial_fibrillation_or_flutter
drop atrial_fibrillation_or_flutter
safetab afib
gen liver = chronic_liver_disease
drop chronic_liver_disease
safetab liver
label var diabetes "Diabetes"
safetab diabetes
gen haem_cancer = haematological_cancer
drop haematological_cancer
safetab haem_cancer
safetab heart_failure
safetab hiv
label var hypertension "Hypertension"
safetab hypertension
gen non_haem_cancer = non_haematological_cancer
drop non_haematological_cancer
label var non_haem_cancer "Cancer (non-haematological)"
safetab non_haem_cancer
safetab myocardial_infarction
gen pvd = peripheral_vascular_disease
drop peripheral_vascular_disease
safetab pvd
gen rheumatoid = rheumatoid_arthritis
drop rheumatoid_arthritis
safetab rheumatoid
safetab stroke
gen lupus = systemic_lupus_erythematosus
drop systemic_lupus_erythematosus
safetab lupus

*Group comorbidities
gen cardiovascular = afib
replace cardiovascular = 1 if heart_failure==1
replace cardiovascular = 1 if myocardial_infarction==1
replace cardiovascular = 1 if pvd==1
replace cardiovascular = 1 if stroke==1
label var cardiovascular "Cardiovascular diseases"
gen immunosuppressed = haem_cancer
replace immunosuppressed = 1 if hiv==1
replace immunosuppressed = 1 if rheumatoid==1
replace immunosuppressed = 1 if lupus==1
label var immunosuppressed "Immunosuppressive diseases"
safetab cardiovascular
safetab immunosuppressed
 
**Outcomes
* ESRD
* eGFR <15 (earliest month)
foreach creatinine_monthly of varlist	creatinine_feb2017 ///
										creatinine_mar2017 ///
										creatinine_apr2017 ///
										creatinine_may2017 ///
										creatinine_jun2017 ///
										creatinine_jul2017 ///
										creatinine_aug2017 ///
										creatinine_sep2017 ///
										creatinine_oct2017 ///
										creatinine_nov2017 ///
										creatinine_dec2017 ///
										creatinine_jan2018 ///
										creatinine_feb2018 ///
										creatinine_mar2018 ///
										creatinine_apr2018 ///
										creatinine_may2018 ///
										creatinine_jun2018 ///
										creatinine_jul2018 ///
										creatinine_aug2018 ///
										creatinine_sep2018 ///
										creatinine_oct2018 ///
										creatinine_nov2018 ///
										creatinine_dec2018 ///
										creatinine_jan2019 ///
										creatinine_feb2019 ///
										creatinine_mar2019 ///
										creatinine_apr2019 ///
										creatinine_may2019 ///
										creatinine_jun2019 ///
										creatinine_jul2019 ///
										creatinine_aug2019 ///
										creatinine_sep2019 ///
										creatinine_feb2020 ///
										creatinine_mar2020 ///
										creatinine_apr2020 ///
										creatinine_may2020 ///
										creatinine_jun2020 ///
										creatinine_jul2020 ///
										creatinine_aug2020 ///
										creatinine_sep2020 ///
										creatinine_oct2020 ///
										creatinine_nov2020 ///
										creatinine_dec2020 ///
										creatinine_jan2021 ///
										creatinine_feb2021 ///
										creatinine_mar2021 ///
										creatinine_apr2021 ///
										creatinine_may2021 ///
										creatinine_jun2021 ///
										creatinine_jul2021 ///
										creatinine_aug2021 ///
										creatinine_sep2021 ///
										creatinine_oct2021 ///
										creatinine_nov2021 ///
										creatinine_dec2021 ///
										creatinine_jan2022 ///
										creatinine_feb2022 ///
										creatinine_mar2022 ///
										creatinine_apr2022 ///
										creatinine_may2022 ///
										creatinine_jun2022 ///
										creatinine_jul2022 ///
										creatinine_aug2022 ///
										creatinine_sep2022 ///
										creatinine_oct2022 {
replace `creatinine_monthly' = . if !inrange(`creatinine_monthly', 20, 3000)
gen mgdl_`creatinine_monthly' = `creatinine_monthly'/88.4
gen min_`creatinine_monthly'=.
replace min_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.7 if sex==0
replace min_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.9 if sex==1
replace min_`creatinine_monthly' = min_`creatinine_monthly'^-0.329 if sex==0
replace min_`creatinine_monthly' = min_`creatinine_monthly'^-0.411 if sex==1
replace min_`creatinine_monthly' = 1 if min_`creatinine_monthly'<1
gen max_`creatinine_monthly'=.
replace max_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.7 if sex==0
replace max_`creatinine_monthly' = mgdl_`creatinine_monthly'/0.9 if sex==1
replace max_`creatinine_monthly' = max_`creatinine_monthly'^-1.209
replace max_`creatinine_monthly' = 1 if max_`creatinine_monthly'>1
gen egfr_`creatinine_monthly' = min_`creatinine_monthly'*max_`creatinine_monthly'*141
replace egfr_`creatinine_monthly' = egfr_`creatinine_monthly'*(0.993^age)
replace egfr_`creatinine_monthly' = egfr_`creatinine_monthly'*1.018 if sex==0
drop `creatinine_monthly'
drop mgdl_`creatinine_monthly'
drop min_`creatinine_monthly'
drop max_`creatinine_monthly'
}

replace index_date = index_date_28
drop index_date_28
gen egfr15_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022"
foreach x of local month_year  {
  replace egfr15_date=date("15`x'", "DMY") if egfr15_date==.& egfr_creatinine_`x'<15 & date("01`x'", "DMY")>=index_date
}
format egfr15_date %td

* ESRD date
gen index_date_esrd = index_date
gen esrd_date = egfr15_date
format esrd_date %td
replace esrd_date = krt_date if esrd_date==.
gen esrd = 0
replace esrd = 1 if esrd_date!=.
label var esrd "Kidney failure"
gen esrd_time = (esrd_date - index_date)
label var esrd_time "Time to ESRD (Days)"
gen esrd_time_cat = esrd_time
recode esrd_time_cat	min/-1=1	///
						0=2			///
						1/28=3		///
						29/90=4		///
						91/180=5	///
						181/365=6	///
						366/730=7	///
						731/973=8	///
						974/max=9
label define esrd_time_cat	1 "<0 days"			///
							2 "0 days"			///
							3 "1 to 28 days"	///
							4 "20 to 90 days"	///
							5 "91 to 180 days"	///
							6 "181 to 365 days"	///
							7 "366 to 730 days"	///
							8 "731 to 973 days"	///
							9 ">973 days"
label values esrd_time_cat esrd_time_cat
foreach exposure of varlist 	case			///
								covid_severity	///
								covid_aki		{
								by `exposure',sort: sum esrd_time, de
								tab esrd_time_cat `exposure', m col chi
								}
gen exit_date_esrd = esrd_date
format exit_date_esrd %td
gen end_date = date("2022-11-30", "YMD") if case==1
replace end_date = date("2019-11-30", "YMD") if case==0
format end_date %td
replace exit_date_esrd = min(deregistered_date, death_date, end_date) if esrd_date==.
gen esrd_denominator = 1
gen follow_up_time_esrd = (exit_date_esrd - index_date_esrd)
label var follow_up_time_esrd "Follow-up time (Days)"
gen follow_up_cat_esrd = follow_up_time_esrd
recode follow_up_cat_esrd	min/-29=1 	///
						-28/-1=2 	///
						0=3			///
						1/365=4 	///
						366/730=5	///
						731/1040=6	///					
						1041/max=7
label define follow_up_cat_esrd 	1 "<-29 days" 	///
							2 "-28 to -1 days" 		///
							3 "0 days"				///
							4 "1 to 365 days"		///
							5 "366 to 730 days" 	///
							6 "731 to 1040 days"	///
							7 ">1040 days"
label values follow_up_cat_esrd follow_up_cat_esrd
label var follow_up_cat_esrd "Follow_up time"
tab case follow_up_cat_esrd
tab covid_krt follow_up_cat_esrd
drop if follow_up_time_esrd<0
drop if follow_up_time_esrd>1040
tab case follow_up_cat_esrd
tab covid_krt follow_up_cat_esrd
gen follow_up_years_esrd = follow_up_time_esrd/365.25

* 50% eGFR reduction (earliest month) (or ESRD)
gen egfr_half_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022"
foreach x of local month_year {
  replace egfr_half_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_half_date==.& egfr_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>=index_date
  format egfr_half_date %td
}
replace egfr_half_date=esrd_date if egfr_half_date==.
gen egfr_half = 0
replace egfr_half = 1 if egfr_half_date!=.
label var egfr_half "50% reduction in eGFR"
* Index date (50% eGFR reduction)
gen index_date_egfr_half = index_date
replace index_date_egfr_half =. if baseline_egfr==.
* Exit date (50% eGFR reduction)
gen exit_date_egfr_half = egfr_half_date
format exit_date_egfr_half %td
replace exit_date_egfr_half = min(deregistered_date,death_date,end_date) if egfr_half_date==. & index_date_egfr_half!=.
gen follow_up_time_egfr_half = (exit_date_egfr_half - index_date_egfr_half)
label var follow_up_time_egfr_half "Follow-up time (50% eGFR reduction) (Days)"
gen egfr_half_denominator = 0
replace egfr_half_denominator = 1 if index_date_egfr_half!=.
gen follow_up_years_egfr_half = follow_up_time_egfr_half/365.25

* AKI (or ESRD)
gen index_date_aki = index_date
gen aki_date = date(acute_kidney_injury_outcome, "YMD")
format aki_date %td
drop acute_kidney_injury_outcome
replace aki_date = esrd_date if aki_date==.
gen aki = 0
replace aki = 1 if aki_date!=.
label var aki "Acute kidney injury"
* Exit date (AKI)
gen exit_date_aki = aki_date
format exit_date_aki %td
replace exit_date_aki = min(deregistered_date,death_date,end_date)  if aki_date==.
gen aki_denominator = 1
gen follow_up_time_aki = (exit_date_aki - index_date_aki)
label var follow_up_time_aki "Follow-up time (AKI) (Days)"
gen follow_up_years_aki = follow_up_time_aki/365.25

* Exit date (death)
gen index_date_death = index_date
gen exit_date_death = death_date
gen death = 0
replace death = 1 if death_date!=.
label var death "Death"
format exit_date_death %td
replace exit_date_death = min(deregistered_date,end_date)  if death_date==.
gen death_denominator = 1
gen follow_up_time_death = (exit_date_death - index_date_death)
label var follow_up_time_death "Follow-up time (death) (Days)"
gen follow_up_years_death = follow_up_time_death/365.25

stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)

foreach outcome of varlist esrd egfr_half aki death {
	bysort case: egen total_follow_up_`outcome' = total(_t)
	forvalues i=0/1
	di Denominator case=`i' `outcome':
	count if case==`i' & `outcome'_denominator==1
	local denominator = r(N)
	di Denominator(_st=1) case=`i' `outcome':
	count if case==`i' & `outcome'_denominator==1 & _st==1
	local st_denominator = r(N)
	di Events case=`i' `outcome':
	count if case==`i' & `outcome'==1
	local event = r(N)
	di Events (_st=1) case=`i' `outcome':
	count if case==`i' & `outcome'==1 & _st==1
	local st_event = r(N)
	di Total follow_up case=`i' `outcome':
	su total_follow_up_`outcome' if case==`i'
	local person_year = r(mean)
	local rate = 100000*(`event'/`person_year')
	di Rate case=`i' `outcome':
	di `rate'
	local st_rate = 100000*(`st_event'/`person_year')
	di Rate (_st=1) case=`i' `outcome':
	di `st_rate'
	}
}

save ./output/analysis_2017.dta, replace
log close



