sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/analysis_hospitalised.log, replace t

capture noisily import delimited ./output/input_covid_hospitalised.csv, clear
tempfile covid_hospitalised
save `covid_hospitalised', replace
di "COVID-19 hospitalised:"
safecount

capture noisily import delimited ./output/input_pneumonia_hospitalised.csv, clear
tempfile pneumonia_hospitalised
save `pneumonia_hospitalised', replace
di "Pneumonia hospitalised:"
safecount

append using `covid_hospitalised', force

**ID
* Need to create unique identifiers as individuals may be in both covid_hospitalised and pneumonia_hospitalised so will have the same patient_id
gen unique = _n
label var unique "Unique ID"

** Exclusions
* Index of multiple deprivation missing
* Ordered 1-5 from most deprived to least deprived
label define imd 1 "1 Most deprived" 2 "2" 3 "3" 4 "4" 5 "5 Least deprived"
label values imd imd
tab imd, m
drop if imd==0
safetab imd

* STP missing
drop if stp==""
bysort stp: gen stp1 = 1 if _n==1
replace stp1 = sum(stp1)
drop stp
rename stp1 stp
label define stp 	1 "1"	///
					2 "2"	///
					3 "3"	///
					4 "4"	///
					5 "5"	///
					6 "6"	///
					7 "7"	///
					8 "8"	///
					9 "9"	///
					10 "10"	///
					11 "11"	///					
					12 "12"	///
					13 "13"	///
					14 "14"	///
					15 "15"	///
					16 "16"	///
					17 "17"	///
					18 "18"	///
					19 "19"	///
					20 "20"	///
					21 "21"	///					
					22 "22"	///
					23 "23"	///
					24 "24"	///
					25 "25"	///
					26 "26"	///
					27 "27"	///
					28 "28"	///
					29 "29"	///
					30 "30"	///
					31 "31"	
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

* Create new index date variable 28 days after case_index_date (i.e. to exclude anyone who does not survive to start follow-up)
gen index_date = date(patient_index_date, "YMD")
format index_date %td
gen index_date_28 = index_date + 28
format index_date_28 %td

* Deregistered before index_date + 29 days
gen deregistered_date = date(date_deregistered, "YMD")
format deregistered_date %td
drop date_deregistered 
drop if deregistered_date < index_date_28 + 1

* Kidney replacement therapy before index_date
gen krt_date = date(krt_outcome_date, "YMD")
format krt_date %td
drop krt_outcome_date
drop if krt_date < index_date
replace krt_date = index_date_28 + 1 if krt_date < index_date_28 + 1

* Death before index_date + 29 days (i.e. only include people who survived beyond 28 days after admission)
drop if deceased==1
drop deceased
gen death_date1 = date(death_date, "YMD")
format death_date1 %td
drop death_date
rename death_date1 death_date
gen deceased = 0
replace deceased = 1 if death_date < index_date_28 + 1
label define deceased 0 "Alive at 28 days after index date" 1 "Deceased within 28 days of index date"
label values deceased deceased
tab covid deceased
tab pneumonia deceased
drop if deceased==1
drop deceased

* eGFR <15 before index_date - should apply to matched historical comparators only
gen sex1 = 1 if sex=="M"
replace sex1 = 0 if sex=="F"
drop sex
rename sex1 sex
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
												baseline_creatinine_oct2022 ///
												baseline_creatinine_nov2022 ///
												baseline_creatinine_dec2022 {
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
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022"
foreach x of local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if index_month=="`x'"
drop egfr_baseline_creatinine_`x'
}
label var baseline_egfr "Baseline eGFR"
gen baseline_esrd = 0
replace baseline_esrd = 1 if baseline_egfr <15
label define baseline_esrd 0 "No ESRD" 1 "ESRD"
label values baseline_esrd baseline_esrd
tab covid baseline_esrd
tab pneumonia baseline_esrd
drop if baseline_esrd==1
drop baseline_esrd

** Exposure
gen case = covid
replace case = 0 if covid==.
label define case 0 "Pneumonia (pre-pandemic)" ///
				  1 "COVID-19"
label values case case
tab case covid
tab case pneumonia
drop covid
drop pneumonia
safetab case 

* Critical care during index admission
replace critical_care = 1 if critical_days==1
drop critical_days
label define critical_care	0 "Ward-based"		///
							1 "Critical care"
label values critical_care critical_care
label var critical_care "Critical care"
safetab critical_care, m
gen case_critical_care = critical_care
replace case_critical_care = 2 if case==1
replace case_critical_care = 3 if case==1 &critical_care==1
label define case_critical_care	0 "Ward-based pneumonia (pre-pandemic)" 	///
								1 "Critical care pneumonia (pre-pandemic)"	///
								2 "Ward-based COVID-19" 					///
								3 "Critical care COVID-19"
label values case_critical_care case_critical_care
safetab case_critical_care, m

* Acute kidney injury during index admission
rename acute_kidney_injury adm_aki
label define adm_aki	0 "No AKI"	///
						1 "AKI"
label values adm_aki adm_aki
label var adm_aki "Acute kidney injury"
safetab adm_aki, m
gen case_adm_aki = adm_aki
replace case_adm_aki = 2 if case==1
replace case_adm_aki = 3 if case==1 &adm_aki==1
label define case_adm_aki	0 "No AKI pneumonia (pre-pandemic)"	///
										1 "AKI pneumonia (pre-pandemic)" 	///
										2 "No AKI COVID-19" 				///
										3 "AKI COVID-19"
label values case_adm_aki case_adm_aki
safetab case_adm_aki, m

* Kidney replacement therapy during index admission
gen krt = adm_aki
replace krt = 2 if krt_icd_10==1
drop krt_icd_10
replace krt = 2 if krt_opcs_4==1
drop krt_opcs_4
label define krt	0 "No AKI" 				///
					1 "AKI without KRT"		///
					2 "AKI requiring KRT"
label values krt krt
label var krt "Kidney replacement therapy"
safetab krt, m
gen case_krt = krt
replace case_krt = 3 if case==1
replace case_krt = 4 if case==1 &krt==1
replace case_krt = 5 if case==1 &krt==2
label define case_krt	0 "No AKI pneumonia (pre-pandemic)" 			///
						1 "AKI without KRT pneumonia (pre-pandemic)"	///
						2 "AKI requiring KRT pneumonia (pre-pandemic)"	///
						3 "No AKI COVID-19"								///
						4 "AKI without KRT COVID-19"					///
						5 "AKI requiring KRT COVID-19"
label values case_krt case_krt
safetab case_krt, m

* COVID-19 vaccination status
gen covidvax1date = date(covid_vax_1_date, "YMD")
format covidvax1date %td
gen covidvax2date = date(covid_vax_2_date, "YMD")
format covidvax2date %td
gen covidvax3date = date(covid_vax_3_date, "YMD")
format covidvax3date %td
gen covidvax4date = date(covid_vax_4_date, "YMD")
format covidvax4date %td
*First vaccination in the UK was on 08/12/2020
*di date("20201208", "YMD") -> 22257
foreach var of varlist covidvax1date covidvax2date covidvax3date covidvax4date {
replace `var' = . if `var'<22257
}
gen covid_vax = case
replace covid_vax = 5 if covidvax4date!=.
replace covid_vax = 4 if covid_vax==1 &covidvax3date!=.
replace covid_vax = 3 if covid_vax==1 &covidvax2date!=.
replace covid_vax = 2 if covid_vax==1 &covidvax1date!=.
drop covidvax1date
drop covidvax2date
drop covidvax3date
drop covidvax4date
label define covid_vax	0 "Pneumonia (pre-pandemic)"	///
						1 "COVID pre-vaccination"			///
						2 "COVID 1 vaccine dose"			///
						3 "COVID 2 vaccine doses"			///
						4 "COVID 3 vaccine doses"			///
						5 "COVID 4 vaccine doses"
label values covid_vax covid_vax
label var covid_vax "COVID-19 vaccination status"
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
replace wave = 4 if index_month=="nov2022"
replace wave = 4 if index_month=="dec2022"
label define wave	0 "Pneumonia (pre-pandemic)"	///
					1 "COVID Feb20-Aug20"	///
					2 "COVID Sep20-Jun21"	///
					3 "COVID Jul21-Nov21"	///
					4 "COVID Dec21-Dec22"	
label values wave wave
label var wave "COVID-19 wave"
safetab wave, m

* Month
gen month_string=substr(index_date_string ,3,3)
gen month = 1 if month_string=="jan"
replace month = 2 if month_string=="feb"
replace month = 3 if month_string=="mar"
replace month = 4 if month_string=="apr"
replace month = 5 if month_string=="may"
replace month = 6 if month_string=="jun"
replace month = 7 if month_string=="jul"
replace month = 8 if month_string=="aug"
replace month = 9 if month_string=="sep"
replace month = 10 if month_string=="oct"
replace month = 11 if month_string=="nov"
replace month = 12 if month_string=="dec"
drop month_string
label define month	1 "January"		///
					2 "February"	///
					3 "March"		///
					4 "April"		///
					5 "May"			///
					6 "June"		///
					7 "July"		///
					8 "August"		///
					9 "September"	///
					10 "October"	///
					11 "November"	///
					12 "December"
label values month month
safetab month case, m

** Covariates
** Covariates
* Check of GP consultations over past year by groups
sum gp_count, detail
bysort case: sum gp_count, detail
egen gp_consults = cut(gp_count), at(0, 1, 3, 10, 1500)
recode gp_consults 3=2 10=3
label define gp_consults 0 "0" 1 "1-2" 2 "3-9" 3 ">9"
label values gp_consults gp_consults
label var gp_consults "GP interactions"
tab case gp_consults

* Check of hospital admissions in preceding 5 years
sum hosp_count, detail
bysort case: sum hosp_count, detail
egen admissions = cut(hosp_count), at(0, 1, 2, 1000)
label define admissions 0 "0" 1 "1" 2 ">1"
label values admissions admissions
label var admissions "Hospital admissions"
tab case admissions

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

label define agegroup 	1 "18-39" 		///
						2 "40-49" 		///
						3 "50-59" 		///
						4 "60-69" 		///
						5 "70-79"		///
						6 "80+"
label values agegroup agegroup
label var agegroup "Age group"
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
rename acute_kidney_injury_baseline aki_baseline
safetab aki_baseline
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
										creatinine_oct2022 ///
										creatinine_nov2022 ///
										creatinine_dec2022 ///
										creatinine_jan2023 {
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
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year  {
  replace egfr15_date=date("15`x'", "DMY") if egfr15_date==.& egfr_creatinine_`x'<15 & date("01`x'", "DMY")>index_date
}
format egfr15_date %td

* ESRD date
gen index_date_esrd = index_date
gen esrd_date = egfr15_date
format esrd_date %td
replace esrd_date = krt_date if krt_date < egfr15_date
replace esrd_date = krt_date if esrd_date==.
gen esrd = 0
replace esrd = 1 if esrd_date!=.
label var esrd "Kidney failure"
gen esrd_time = (esrd_date - index_date_esrd)
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
								critical_care	///
								krt		{
								by `exposure',sort: sum esrd_time, de
								tab esrd_time_cat `exposure', m col chi
								}
	
* Exit date
gen exit_date_esrd = esrd_date
format exit_date_esrd %td
gen end_date = date("2023-01-31", "YMD") if case==1
replace end_date = date("2020-01-31", "YMD") if case==0
format end_date %td
replace exit_date_esrd = min(deregistered_date, death_date, end_date) if esrd_date==.
gen esrd_denominator = 1
gen follow_up_time_esrd = (exit_date_esrd - index_date_esrd)
label var follow_up_time_esrd "Follow-up time (ESRD) (Days)"
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
drop if follow_up_time_esrd<1
drop if follow_up_time_esrd>1040
tab case follow_up_cat_esrd
* Time zero variable to account for differences in length of follow-up
gen time_zero_esrd = date("2000-01-01", "YMD")
gen time_end_esrd = time_zero_esrd + follow_up_time_esrd
gen time_esrd = time_zero_esrd + esrd_time

* 50% eGFR reduction (earliest month) (or ESRD)
gen egfr_half_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year {
  replace egfr_half_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_half_date==.& egfr_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>index_date
  format egfr_half_date %td
}
replace egfr_half_date=esrd_date if egfr_half_date==.
gen egfr_half = 0
replace egfr_half = 1 if egfr_half_date!=.
label var egfr_half "50% reduction in eGFR"
* Index date (50% eGFR reduction)
gen index_date_egfr_half = index_date
replace index_date_egfr_half =. if baseline_egfr==.
gen egfr_half_time = (egfr_half_date - index_date_egfr_half)
* Exit date (50% eGFR reduction)
gen exit_date_egfr_half = egfr_half_date
format exit_date_egfr_half %td
replace exit_date_egfr_half = min(deregistered_date,death_date,end_date) if egfr_half_date==. & index_date_egfr_half!=.
gen follow_up_time_egfr_half = (exit_date_egfr_half - index_date_egfr_half)
label var follow_up_time_egfr_half "Follow-up time (50% eGFR reduction) (Days)"
gen egfr_half_denominator = 0
replace egfr_half_denominator = 1 if index_date_egfr_half!=.
gen time_zero_egfr_half = date("2000-01-01", "YMD")
gen time_end_egfr_half = time_zero_egfr_half + follow_up_time_egfr_half
gen time_egfr_half = time_zero_egfr_half + egfr_half_time

* AKI (or ESRD)
gen index_date_aki = index_date
gen aki_date = date(acute_kidney_injury_outcome, "YMD")
format aki_date %td
drop acute_kidney_injury_outcome
replace aki_date = esrd_date if aki_date==.
gen aki = 0
replace aki = 1 if aki_date!=.
label var aki "Acute kidney injury"
gen aki_time = (aki_date - index_date_aki)
* Exit date (AKI)
gen exit_date_aki = aki_date
format exit_date_aki %td
replace exit_date_aki = min(deregistered_date,death_date,end_date)  if aki_date==.
gen aki_denominator = 1
gen follow_up_time_aki = (exit_date_aki - index_date_aki)
label var follow_up_time_aki "Follow-up time (AKI) (Days)"
gen time_zero_aki = date("2000-01-01", "YMD")
gen time_end_aki = time_zero_aki + follow_up_time_aki
gen time_aki = time_zero_aki + aki_time

* Exit date (death)
gen index_date_death = index_date
gen exit_date_death = death_date
gen death = 0
replace death = 1 if death_date!=.
label var death "Death"
gen death_time = (death_date - index_date_death)
format exit_date_death %td
replace exit_date_death = min(deregistered_date,end_date)  if death_date==.
gen death_denominator = 1
gen follow_up_time_death = (exit_date_death - index_date_death)
label var follow_up_time_death "Follow-up time (death) (Days)"
gen time_zero_death = date("2000-01-01", "YMD")
gen time_end_death = time_zero_death + follow_up_time_death
gen time_death = time_zero_death + death_time

*ESRD by time period (i.e. including 0-1 days (because if ESRD before index date, this was set to index_date + 1))
*0-1 days
gen esrd_date1 = esrd_date if esrd_date < (index_date_esrd + 2)
gen exit_date1_esrd = esrd_date1
gen index_date1_esrd = index_date_esrd
format exit_date1_esrd %td
replace exit_date1_esrd = min(deregistered_date, death_date, end_date, index_date_esrd) if esrd_date1==.
*stset exit_date1_esrd, fail(esrd_date1) origin(index_date1_esrd) id(unique) scale(365.25)
*2-29 days
gen esrd_date29 = esrd_date if esrd_date < (index_date_esrd + 30) 
gen exit_date29_esrd = esrd_date29
gen index_date29_esrd = index_date_esrd + 2
format exit_date29_esrd %td
replace exit_date29_esrd = min(deregistered_date, death_date, end_date, (index_date_esrd + 29)) if esrd_date29==.
*stset exit_date29_esrd, fail(esrd_date29) origin(index_date29_esrd) id(unique) scale(365.25)
*30-89 days
gen esrd_date89 = esrd_date if esrd_date < (index_date_esrd + 90) 
gen exit_date89_esrd = esrd_date89
gen index_date89_esrd = index_date_esrd + 30
format exit_date89_esrd %td
replace exit_date89_esrd = min(deregistered_date, death_date, end_date, (index_date_esrd + 89)) if esrd_date89==.
*stset exit_date89_esrd, fail(esrd_date89) origin(index_date89_esrd) id(unique) scale(365.25)
*90-179 days
gen esrd_date179 = esrd_date if esrd_date < (index_date_esrd + 180) 
gen exit_date179_esrd = esrd_date179
gen index_date179_esrd = index_date_esrd + 90
format exit_date179_esrd %td
replace exit_date179_esrd = min(deregistered_date, death_date, end_date, (index_date_esrd + 179)) if esrd_date179==.
*stset exit_date179_esrd, fail(esrd_date179) origin(index_date179_esrd) id(unique) scale(365.25)
*180+ days
gen index_datemax_esrd = index_date_esrd + 180
gen exit_datemax_esrd = exit_date_esrd
gen esrd_datemax = esrd_date
*stset exit_date_esrd, fail(esrd_date) origin(index_datemax_esrd) id(unique) scale(365.25)

*Secondary outcomes by time period
local outcome "egfr_half aki death"
foreach out of local outcome {
*0-29 days
gen `out'_date29 = `out'_date if `out'_date < (index_date_`out' + 30) 
gen exit_date29_`out' = `out'_date29
gen index_date29_`out' = index_date_`out'
format exit_date29_`out' %td
replace exit_date29_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 29)) if `out'_date29==.
*stset exit_date29_`out', fail(`out'_date29) origin(index_date29_`out') id(unique) scale(365.25)
*30-89 days
gen `out'_date89 = `out'_date if `out'_date < (index_date_`out' + 90) 
gen exit_date89_`out' = `out'_date89
gen index_date89_`out' = index_date_`out' + 30
format exit_date89_`out' %td
replace exit_date89_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 89)) if `out'_date89==.
*stset exit_date89_`out', fail(`out'_date89) origin(index_date89_`out') id(unique) scale(365.25)
*90-179 days
gen `out'_date179 = `out'_date if `out'_date < (index_date_`out' + 180) 
gen exit_date179_`out' = `out'_date179
gen index_date179_`out' = index_date_`out' + 90
format exit_date179_`out' %td
replace exit_date179_`out' = min(deregistered_date, death_date, end_date, (index_date_`out' + 179)) if `out'_date179==.
*stset exit_date179_`out', fail(`out'_date179) origin(index_date179_`out') id(unique) scale(365.25)
*180+ days
gen index_datemax_`out' = index_date_`out' + 180
gen exit_datemax_`out' = exit_date_`out'
gen `out'_datemax = `out'_date
*stset exit_date_`out', fail(`out'_date) origin(index_datemax_`out') id(unique) scale(365.25)
}	

save ./output/analysis_hospitalised.dta, replace
log close