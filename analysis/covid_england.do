cap log close
log using ./logs/covid_england, replace t
clear

import delimited ./output/input_covid_england.csv, delimiter(comma) varnames(1) case(preserve) 

**Exclusions
* Age <18
drop if age <18

* Anyone not registered at one practice for 3 months before COVID-19 diagnosis
drop if has_follow_up==0

* Pre-existing kidney replacement therapy
drop if baseline_krt_primary_care==1
drop baseline_krt_primary_care
drop if baseline_krt_icd_10==1
drop baseline_krt_icd_10
drop if baseline_krt_opcs_4==1
drop baseline_krt_opcs_4

* Baseline eGFR <15 as at February 2020
assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
label define sexLab 1 "Male" 0 "Female"
label values male sexLab
label var male "Sex (0=F 1=M)"

replace baseline_creatinine_feb2020 = . if !inrange(baseline_creatinine_feb2020, 20, 3000)
gen mgdl_baseline_creatinine_feb2020 = baseline_creatinine_feb2020/88.4
gen min_baseline_creatinine_feb2020=.
replace min_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.7 if male==0
replace min_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.9 if male==1
replace min_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020^-0.329  if male==0
replace min_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020^-0.411  if male==1
replace min_baseline_creatinine_feb2020 = 1 if min_baseline_creatinine_feb2020<1
gen max_baseline_creatinine_feb2020=.
replace max_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.7 if male==0
replace max_baseline_creatinine_feb2020 = mgdl_baseline_creatinine_feb2020/0.9 if male==1
replace max_baseline_creatinine_feb2020 = max_baseline_creatinine_feb2020^-1.209
replace max_baseline_creatinine_feb2020 = 1 if max_baseline_creatinine_feb2020>1
gen egfr_baseline_creatinine_feb2020 = min_baseline_creatinine_feb2020*max_baseline_creatinine_feb2020*141
replace egfr_baseline_creatinine_feb2020 = egfr_baseline_creatinine_feb2020*(0.993^age)
replace egfr_baseline_creatinine_feb2020 = egfr_baseline_creatinine_feb2020*1.018 if male==0
drop if egfr_baseline_creatinine_feb2020 <15
drop baseline_creatinine_feb2020
drop mgdl_baseline_creatinine_feb2020
drop min_baseline_creatinine_feb2020
drop max_baseline_creatinine_feb2020

* Baseline eGFR <15 at time of COVID diagnosis using baseline creatinine updated monthly
gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
drop if covid_date ==.
drop covid_diagnosis_date
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date

foreach baseline_creatinine_monthly of varlist 	baseline_creatinine_mar2020 ///
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
												baseline_creatinine_jan2022 {
replace `baseline_creatinine_monthly' = . if !inrange(`baseline_creatinine_monthly', 20, 3000)
gen mgdl_`baseline_creatinine_monthly' = `baseline_creatinine_monthly'/88.4
gen min_`baseline_creatinine_monthly'=.
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if male==0
replace min_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if male==1
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.329 if male==0
replace min_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'^-0.411 if male==1
replace min_`baseline_creatinine_monthly' = 1 if min_`baseline_creatinine_monthly'<1
gen max_`baseline_creatinine_monthly'=.
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.7 if male==0
replace max_`baseline_creatinine_monthly' = mgdl_`baseline_creatinine_monthly'/0.9 if male==1
replace max_`baseline_creatinine_monthly' = max_`baseline_creatinine_monthly'^-1.209
replace max_`baseline_creatinine_monthly' = 1 if max_`baseline_creatinine_monthly'>1
gen egfr_`baseline_creatinine_monthly' = min_`baseline_creatinine_monthly'*max_`baseline_creatinine_monthly'*141
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*(0.993^age)
replace egfr_`baseline_creatinine_monthly' = egfr_`baseline_creatinine_monthly'*1.018 if male==0
drop `baseline_creatinine_monthly'
drop mgdl_`baseline_creatinine_monthly'
drop min_`baseline_creatinine_monthly'
drop max_`baseline_creatinine_monthly'
}

gen covid_date_string=string(covid_date, "%td") 
gen covid_month=substr( covid_date_string ,3,7)

gen baseline_egfr=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022"
foreach x of  local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if  covid_month=="`x'"
drop if baseline_egfr <15
drop egfr_baseline_creatinine_`x'
}
label var baseline_egfr "Baseline eGFR at COVID diagnosis"

* COVID-19 death
drop if covid_death==1
drop covid_death

**Exposure stratification
* COVID-19 severity
gen covid_severity = covid_hospitalised
replace covid_severity = 2 if covid_critical_care==1
replace covid_severity = 2 if covid_critical_days!=0
label define covid_severity_label	0 "SARS-CoV-2 without hospitalisation" 								///
									1 "COVID-19 with hospitalisation" 2 "COVID-19 with critical care"
label values covid_severity covid_severity_label
label var covid_severity "SARS-CoV-2 severity"
drop covid_hospitalised
drop covid_critical_care
drop covid_critical_days

* COVID-19 acute kidney injury
label define covid_acute_kidney_injury_label	0 "COVID-19 without acute kidney injury" 				///
												1 "COVID-19 with acute kidney injury"
label values covid_acute_kidney_injury covid_acute_kidney_injury_label
label var covid_acute_kidney_injury "COVID-19 acute kidney injury"

* COVID-19 kidney replacement therapy
gen covid_krt = covid_krt_icd_10
replace covid_krt = covid_krt_opcs_4 if covid_krt_icd_10==0
label define covid_krt_label	0 "COVID-19 without kidney replacement therapy" 						///
								1 "COVID-19 with kidney replacement therapy"
label values covid_krt covid_krt_label
label var covid_krt "COVID-19 kidney replacement therapy"
drop covid_krt_icd_10
drop covid_krt_opcs_4

* COVID-19 vaccination status
gen covidvax1date = date(covid_vax_1_date, "YMD")
format covidvax1date %td
gen covidvax2date = date(covid_vax_2_date, "YMD")
format covidvax2date %td
gen covidvax3date = date(covid_vax_3_date, "YMD")
format covidvax3date %td
gen covidvax4date = date(covid_vax_4_date, "YMD")
format covidvax4date %td
gen covid_vax_status = .
replace covid_vax_status = 4 if covidvax4date!=.
replace covid_vax_status = 3 if covid_vax_status==. &covidvax3date!=.
replace covid_vax_status = 2 if covid_vax_status==. &covidvax2date!=.
replace covid_vax_status = 1 if covid_vax_status==. &covidvax1date!=.
replace covid_vax_status = 0 if covid_vax_status==.

drop covidvax1date
drop covidvax2date
drop covidvax3date
drop covidvax4date
label define covid_vax_label	0 "SARS-CoV-2 pre-vaccination"			///
								1 "SARS-CoV-2 after 1 vaccine dose"		///
								2 "SARS-CoV-2 after 2 vaccine doses"	///
								3 "SARS-CoV-2 after 3 vaccine doses"	///
								4 "SARS-CoV-2 after 4 vaccine doses"
label values covid_vax_status covid_vax_label
label var covid_vax_status "Vaccination status"

* Calendar period
gen calendar_period = 1 if covid_month=="feb2020"
replace calendar_period = 1 if covid_month=="mar2020"
replace calendar_period = 1 if covid_month=="apr2020"
replace calendar_period = 1 if covid_month=="may2020"
replace calendar_period = 1 if covid_month=="jun2020"
replace calendar_period = 2 if covid_month=="jul2020"
replace calendar_period = 2 if covid_month=="aug2020"
replace calendar_period = 3 if covid_month=="sep2020"
replace calendar_period = 3 if covid_month=="oct2020"
replace calendar_period = 3 if covid_month=="nov2020"
replace calendar_period = 4 if covid_month=="dec2020"
replace calendar_period = 4 if covid_month=="jan2021"
replace calendar_period = 4 if covid_month=="feb2021"
replace calendar_period = 5 if covid_month=="mar2021"
replace calendar_period = 5 if covid_month=="apr2021"
replace calendar_period = 5 if covid_month=="may2021"
replace calendar_period = 5 if covid_month=="jun2021"
replace calendar_period = 5 if covid_month=="jul2021"
replace calendar_period = 5 if covid_month=="aug2021"
replace calendar_period = 5 if covid_month=="sep2021"
replace calendar_period = 5 if covid_month=="oct2021"
replace calendar_period = 5 if covid_month=="nov2021"
replace calendar_period = 6 if covid_month=="dec2021"
replace calendar_period = 6 if covid_month=="jan2022"
label define calendar_period_label	1 "February 2020 to June 2020"		///
									2 "July 2020 to August 2020"		///
									3 "September 2020 to November 2020"	///
									4 "December 2020 to February 2021"	///
									5 "March 2021 to November 2021"		///
									6 "December 2021 to January 2022"
label values calendar_period calendar_period_label
label var calendar_period "Calendar period"

**Covariates
* Age
recode 	age 			min/49.9999=1 	///
						50/59.9999=2 	///
						60/69.9999=3 	///
						70/79.9999=4 	///
						80/max=5, 		///
						gen(agegroup) 

label define agegroup 	1 "18-<50" 		///
						2 "50-<60" 		///
						3 "60-<70" 		///
						4 "70-<80" 		///
						5 "80+"
label values agegroup agegroup
label var agegroup "Age group"


* Check there are no missing ages
assert age<.
assert agegroup<.

* Create restricted cubic splines fir age
mkspline age = age, cubic nknots(4)

* IMD
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
drop imd_o
recode imd 5=1 4=2 3=3 2=4 1=5 .=.
label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" 
label values imd imd
label var imd "Index of Multiple Deprivation"
noi di "DROPPING IF NO IMD" 
drop if imd>=.

* Smoking
label define smoking_label 1 "Current/former smoker" 0 "Non-smoker"
label values smoking smoking_label
label var smoking "Smoking status"

* Ethnicity (5 category)
replace ethnicity = 6 if ethnicity==.
label define ethnicity_label 	1 "White"  								///
								2 "Mixed" 								///
								3 "Asian or Asian British"				///
								4 "Black"  								///
								5 "Other"								///
								6 "Unknown"
label values ethnicity ethnicity_label
label var ethnicity "Ethnicity"


/*  Geographical location  */
* Region
rename region region_string
assert inlist(region_string, 								///
					"East Midlands", 						///
					"East",  								///
					"London", 								///
					"North East", 							///
					"North West", 							///
					"South East", 							///
					"South West",							///
					"West Midlands", 						///
					"Yorkshire and The Humber") 
* Nine regions
gen     region_9 = 1 if region_string=="East Midlands"
replace region_9 = 2 if region_string=="East"
replace region_9 = 3 if region_string=="London"
replace region_9 = 4 if region_string=="North East"
replace region_9 = 5 if region_string=="North West"
replace region_9 = 6 if region_string=="South East"
replace region_9 = 7 if region_string=="South West"
replace region_9 = 8 if region_string=="West Midlands"
replace region_9 = 9 if region_string=="Yorkshire and The Humber"

label define region_9 	1 "East Midlands" 					///
						2 "East"   							///
						3 "London" 							///
						4 "North East" 						///
						5 "North West" 						///
						6 "South East" 						///
						7 "South West"						///
						8 "West Midlands" 					///
						9 "Yorkshire and The Humber"
label values region_9 region_9
label var region_9 "Region of England (9 regions)"

* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old

* Baseline eGFR groups
egen baseline_egfr_cat = cut(baseline_egfr), at(0, 15, 30, 45, 60, 75, 90, 105, 5000)
recode baseline_egfr_cat 0=1 15=2 30=3 45=4 60=5 75=6 90=7 105=8
label define egfr_group 1 "<15" 2 "15-29" 3 "30-44" 4 "45-59" 5 "60-74" 6 "75-89" 7 "90-104" 8 "???105"
label values baseline_egfr_cat egfr_group
label var baseline_egfr_cat "Baseline eGFR"
* NB - only baseline eGFR >15 should be included

* Baseline CKD stage
gen ckd_stage = baseline_egfr_cat
recode ckd_stage 6/8=5 .=6
label define ckd_stage 1 "CKD 5" 2 "CKD 4" 3 "CKD 3B" 4 "CKD 3A" 5 "No CKD" 6 "No eGFR measurement"
label values ckd_stage ckd_stage
label var ckd_stage "CKD stage"


/*  Body Mass Index  */
* BMI (NB: watch for missingness)
replace body_mass_index = . if !inrange(body_mass_index, 15, 50)
gen 	bmicat = .
recode  bmicat . = 1 if body_mass_index<18.5
recode  bmicat . = 2 if body_mass_index<25
recode  bmicat . = 3 if body_mass_index<30
recode  bmicat . = 4 if body_mass_index<35
recode  bmicat . = 5 if body_mass_index<40
recode  bmicat . = 6 if body_mass_index<.
replace bmicat = . if body_mass_index>=.

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			
					
label values bmicat bmicat
label var bmicat "BMI category"

**Outcomes
* Index date (COVID-19 diagnosis + 28 days)
gen index_date = covid_date + 28
format index_date %td
label var index_date "Index date"

* Monthly eGFR follow-up
foreach followup_creatinine_monthly of varlist 	followup_creatinine_feb2020 ///
												followup_creatinine_mar2020 ///
												followup_creatinine_apr2020 ///
												followup_creatinine_may2020 ///
												followup_creatinine_jun2020 ///
												followup_creatinine_jul2020 ///
												followup_creatinine_aug2020 ///
												followup_creatinine_sep2020 ///
												followup_creatinine_oct2020 ///
												followup_creatinine_nov2020 ///
												followup_creatinine_dec2020 ///
												followup_creatinine_jan2021 ///
												followup_creatinine_feb2021 ///
												followup_creatinine_mar2021 ///
												followup_creatinine_apr2021 ///
												followup_creatinine_may2021 ///
												followup_creatinine_jun2021 ///
												followup_creatinine_jul2021 ///
												followup_creatinine_aug2021 ///
												followup_creatinine_sep2021 ///
												followup_creatinine_oct2021 ///
												followup_creatinine_nov2021 ///
												followup_creatinine_dec2021 ///
												followup_creatinine_jan2022 {
replace `followup_creatinine_monthly' = . if !inrange(`followup_creatinine_monthly', 20, 3000)
gen mgdl_`followup_creatinine_monthly' = `followup_creatinine_monthly'/88.4
gen min_`followup_creatinine_monthly'=.
replace min_`followup_creatinine_monthly' = mgdl_`followup_creatinine_monthly'/0.7 if male==0
replace min_`followup_creatinine_monthly' = mgdl_`followup_creatinine_monthly'/0.9 if male==1
replace min_`followup_creatinine_monthly' = min_`followup_creatinine_monthly'^-0.329 if male==0
replace min_`followup_creatinine_monthly' = min_`followup_creatinine_monthly'^-0.411 if male==1
replace min_`followup_creatinine_monthly' = 1 if min_`followup_creatinine_monthly'<1
gen max_`followup_creatinine_monthly'=.
replace max_`followup_creatinine_monthly' = mgdl_`followup_creatinine_monthly'/0.7 if male==0
replace max_`followup_creatinine_monthly' = mgdl_`followup_creatinine_monthly'/0.9 if male==1
replace max_`followup_creatinine_monthly' = max_`followup_creatinine_monthly'^-1.209
replace max_`followup_creatinine_monthly' = 1 if max_`followup_creatinine_monthly'>1
gen egfr_`followup_creatinine_monthly' = min_`followup_creatinine_monthly'*max_`followup_creatinine_monthly'*141
replace egfr_`followup_creatinine_monthly' = egfr_`followup_creatinine_monthly'*(0.993^age)
replace egfr_`followup_creatinine_monthly' = egfr_`followup_creatinine_monthly'*1.018 if male==0
drop `followup_creatinine_monthly'
drop mgdl_`followup_creatinine_monthly'
drop min_`followup_creatinine_monthly'
drop max_`followup_creatinine_monthly'
}

* eGFR <15 (earliest month)
gen egfr_below15_outcome_date=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022"
foreach x of  local month_year  {
  replace egfr_below15_outcome_date=date("15`x'", "DMY") if egfr_below15_outcome_date==.& egfr_followup_creatinine_`x'<15 & date("01`x'", "DMY")>=index_date
}
format egfr_below15_outcome_date %td

* ESRD date
gen esrd_date = egfr_below15_outcome_date
format esrd_date %td
gen krt_outcome = date(krt_outcome_date, "YMD")
replace esrd_date = krt_outcome if esrd_date==.

* Exit date
gen death_date = date(death_date_gp, "YMD")
format death_date %td
drop death_date_gp
gen exit_date = esrd_date
format exit_date %td
gen deregistered_date = date(deregistered, "YMD")
format deregistered_date %td
drop deregistered
gen deregistered_days = (deregistered_date - index_date)
drop if deregistered_days<0
gen end_date = date("2022-01-31", "YMD")
format end_date %td
replace exit_date = min(deregistered_date, death_date, end_date) if esrd_date==.
gen follow_up_time = (exit_date - index_date)
label var follow_up_time "Follow-up time (Days)"

* 50% reduction in eGFR (earliest month) (or ESRD)
gen egfr_reduction50_outcome_date=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022"
foreach x of  local month_year  {
  replace egfr_reduction50_outcome_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_reduction50_outcome_date==.& egfr_followup_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>=index_date
  format egfr_reduction50_outcome_date %td
}
replace egfr_reduction50_outcome_date=esrd_date if egfr_reduction50_outcome_date==.

* Index date (50% reduction in eGFR)
gen index_date_egfr_reduction = index_date
replace index_date_egfr_reduction =. if baseline_egfr==.

* Exit date (50% reduction in eGFR)
gen exit_date_egfr_reduction = egfr_reduction50_outcome_date
format exit_date_egfr_reduction %td
replace exit_date_egfr_reduction = min(deregistered_date,death_date,end_date)  if egfr_reduction50_outcome_date==.
gen follow_up_time_egfr_outcome = (exit_date_egfr_reduction - index_date)
label var follow_up_time_egfr_outcome "Follow-up time (50% eGFR reduction) (Days)"

* AKI date
gen aki_outcome_date = date(acute_kidney_injury_outcome, "YMD")
format aki_outcome_date %td

* Exit date (AKI)
gen exit_date_aki = aki_outcome_date
format exit_date_aki %td
replace exit_date_aki = min(deregistered_date,esrd_date,death_date,end_date)  if aki_outcome_date==.
gen follow_up_time_aki = (exit_date_aki - index_date)
label var follow_up_time_aki "Follow-up time (AKI) (Days)"

* Exit date (death)
gen exit_date_death = death_date
format exit_date_death %td
replace exit_date_death = min(deregistered_date,end_date)  if death_date==.
gen follow_up_time_death = (exit_date_death - index_date)
label var follow_up_time_death "Follow-up time (death) (Days)"
	
save ./output/covid_england.dta, replace 
log close
