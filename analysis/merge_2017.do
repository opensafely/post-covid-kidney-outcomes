sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

* Open a log file
cap log close
log using ./logs/merge_2017.log, replace t

*(0)=========Get total cases and potential matches figure for flowchart - extra bit of work in this file is to drop comparators without the necessary follow-up or who died before case index date============
/*Has follow-up needs checked as there is nowhere previously where it is checked against the matched cases case index date, plus the death_date variable for controls so far is only related to the
*index date, not the case_index_date*/
*case
capture noisily import delimited ./output/input_covid_matching.csv, clear
di "***********************FLOWCHART 1. NUMBER OF POTENTIAL CASES AND CONTROLS********************:"
di "**Potential COVID-19 cases extracted from OpenSAFELY:**"
safecount

*comparator
capture noisily import delimited ./output/input_2017_matching.csv, clear
di "**Potential historical comparators extracted from OpenSAFELY:**"
safecount

capture noisily import delimited ./output/covid_matching_2017.csv, clear
di "*Potential COVID-19 cases after data management:*"
safecount

capture noisily import delimited ./output/2017_matching.csv, clear
di "Potential historical comparators after data management"
safecount


*(1)=========Get all the (case and comparator related) variables from the matched cases and matched controls files============
*COVID-19
capture noisily import delimited ./output/input_combined_stps_covid_2017.csv, clear
*drop age & covid_diagnosis_date
keep patient_id death_date date_deregistered imd stp krt_outcome_date male covid_date covid_month set_id case match_counts
tempfile covid_2017_matched
*for dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `covid_2017_matched', replace
*Number of matched COVID-19 cases
count

*Historical comparators
capture noisily import delimited ./output/input_combined_stps_matches_2017.csv, clear
*drop age
keep patient_id death_date date_deregistered imd stp krt_outcome_date male set_id case covid_date
tempfile 2017_matched
*for dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `2017_matched', replace
*Number of matched historical comparators
count


*(2)=========Add the case and comparator information from above to the files with the rest of the information============
*import matched COVID-19 cases with additional variables and merge with extraction file
capture noisily import delimited ./output/input_covid_2017_additional.csv, clear
merge 1:1 patient_id using `covid_2017_matched'
keep if _merge==3
drop _merge
tempfile covid_2017_complete
save `covid_2017_complete', replace
di "***********************FLOWCHART 2. Number of matched COVID-19 cases and historical comparators****************************************:"
di "**Matched COVID-19:**"
safecount


capture noisily import delimited ./output/input_2017_additional.csv, clear
merge 1:1 patient_id using `2017_matched'
keep if _merge==3
drop _merge
tempfile 2017_complete
save `2017_complete', replace
di "**Matched comparators:**"
safecount


*NOTE: Flowchart re: who was dropped here due date exclusions can be obtained from the STP matching logs (if needed)
*/

*(3)=========Append case and comparator files together============
append using `covid_2017_complete', force
order patient_id set_id match_count case
gsort set_id -case
*drop any comparators that don't have sufficient follow upon
count if case==0

di "***********************FLOWCHART 1. NUMBER OF MATCHED CASES AND MATCHED COMPARATORS: COMBINED FILE********************:"
safecount
tab case
*save a list of final cases for analysis unmatched cases in next bit
preserve
	keep if case==1
	keep patient_id
	tempfile covid_2017_matched_list
	save `covid_2017_matched_list', replace
restore



*(4)=========Create a file of unmatched cases for descriptive analysis============
*import list of all cases (pre-matching)
preserve
	capture noisily import delimited ./output/input_covid_matching.csv, clear
	*for dummy data, should do nothing in the real data
	duplicates drop patient_id, force
	tempfile covid_prematching
	save `covid_prematching', replace
	use `covid_2017_matched_list', clear
	merge 1:1 patient_id using `covid_prematching'
	*want to keep the ones not matched as they were in the original extract file but not in the list of matches
	keep if _merge==2
	safecount
	*save file for descriptive analysis
	save output/covid_unmatched_2017.dta, replace
	di "***********************FLOWCHART 4. NUMBER OF UMATCHED CASES FROM UNMATCHED CASES FILE (TO CONFIRM IT ALIGNS WITH THE ABOVE FLOWCHART POINTS)********************:"
	safecount
restore





*(5)=========VARIABLE CLEANING============

*label case variables
label define case 0 "Comparator (historical)" ///
				  1 "COVID-19"
label values case case
safetab case 

*(a)===Ethnicity (5 category)====
* Ethnicity (5 category)
replace ethnicity = . if ethnicity==.
label define ethnicity 	1 "White"  					///
						2 "Mixed" 					///
						3 "Asian or Asian British"	///
						4 "Black"  					///
						5 "Other"					
						
label values ethnicity ethnicity
safetab ethnicity

 *re-order ethnicity
 gen eth5=1 if ethnicity==1
 replace eth5=2 if ethnicity==3
 replace eth5=3 if ethnicity==4
 replace eth5=4 if ethnicity==2
 replace eth5=5 if ethnicity==5
 replace eth5=. if ethnicity==.

 label define eth5 			1 "White"  					///
							2 "South Asian"				///						
							3 "Black"  					///
							4 "Mixed"					///
							5 "Other"					
					
label values eth5 eth5
safetab eth5, m

*create an ethnicity for table 1 (includes unknown)
*ETHNICITY
*create an ethnicity variable with missing shown as "Unknown" just for this analysis
generate eth5Table1=eth5
replace eth5Table1=6 if eth5Table1==.
label define eth5Table1 			1 "White"  					///
									2 "South Asian"				///						
									3 "Black"  					///
									4 "Mixed"					///
									5 "Other"					///
									6 "Unknown"
					
label values eth5Table1 eth5Table1
safetab eth5Table1, m


*(b)===STP====
*For ease of future analysis(?) am going to recode these as numerical ordered at this stage, also drop if STP is missing
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old



*(c)===IMD===
* Reverse the order (so high is more deprived)
tab imd
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 Least deprived" 2 "2" 3 "3" 4 "4" 5 "5 Most deprived" .u "Unknown"
label values imd imd
*check after reordering
tab imd




***Need to calculate age from year of birth**

**Age**
gen index_date = date(case_index_date, "YMD")
gen index_year = yofd(index_date)
gen age = index_year - year_of_birth
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


* Check there are no missing ages
assert age<.
assert agegroup<.

* Create restricted cubic splines for age
mkspline age = age, cubic nknots(4)

*Sex
gen sex = 1 if male == "Male"
replace sex = 0 if male == "Female"
label define sex 0"Female" 1"Male"
label values sex sex
safetab sex
safecount


**BMI**

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

recode bmicat 1/3 . = 1 4=2 5=3 6=4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		
label values obese4cat obese4cat
order obese4cat, after(bmicat)

gen obese4cat_withmiss = obese4cat
replace obese4cat_withmiss =. if bmicat ==.

* Smoking
gen ever_smoked = 1 if smoking_status=="S"
replace ever_smoked = 1 if smoking_status=="E"
replace ever_smoked = 0 if smoking_status=="N"
replace ever_smoked = . if smoking_status=="M"
label define smoking_label 1 "Current/former smoker" 0 "Non-smoker"
label values ever_smoked smoking_label
label var ever_smoked "Smoking status"

*(e)===Rural-urban===
*label the urban rural categories
replace rural_urban=. if rural_urban<1|rural_urban>8
label define rural_urban 1 "urban major conurbation" ///
							  2 "urban minor conurbation" ///
							  3 "urban city and town" ///
							  4 "urban city and town in a sparse setting" ///
							  5 "rural town and fringe" ///
							  6 "rural town and fringe in a sparse setting" ///
							  7 "rural village and dispersed" ///
							  8 "rural village and dispersed in a sparse setting"
label values rural_urban rural_urban
safetab rural_urban, miss

*generate a binary rural urban (with missing assigned to urban)
generate rural_urbanBroad=.
replace rural_urbanBroad=1 if rural_urban<=4|rural_urban==.
replace rural_urbanBroad=0 if rural_urban>4 & rural_urban!=.
label define rural_urbanBroad 0 "Rural" 1 "Urban"
label values rural_urbanBroad rural_urbanBroad
safetab rural_urbanBroad rural_urban, miss
label var rural_urbanBroad "Rural-Urban"

*Baseline eGFR
format index_date %td
foreach creatinine_monthly of varlist 	creatinine_feb2017 ///
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
										creatinine_oct2019 ///
										creatinine_nov2019 ///
										creatinine_dec2019 ///
										creatinine_jan2020 ///
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
										creatinine_sep2022 {
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

gen index_date_string=string(index_date, "%td") 
gen index_month=substr(index_date_string ,3,7)

gen baseline_egfr=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 oct2019 nov2019 dec2019 jan2020 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022"
foreach x of local month_year  {
replace baseline_egfr=egfr_creatinine_`x' if index_month=="`x'"
drop if baseline_egfr <15
}
label var baseline_egfr "Baseline eGFR"

* Baseline eGFR groups
egen baseline_egfr_cat = cut(baseline_egfr), at(0, 15, 30, 45, 60, 75, 90, 105, 5000)
recode baseline_egfr_cat 0=1 15=2 30=3 45=4 60=5 75=6 90=7 105=8
label define egfr_group 1 "<15" 2 "15-29" 3 "30-44" 4 "45-59" 5 "60-74" 6 "75-89" 7 "90-104" 8 "≥105"
label values baseline_egfr_cat egfr_group
label var baseline_egfr_cat "Baseline eGFR range"
* NB - only baseline eGFR >15 should be included

* Baseline CKD stage
gen ckd_stage = baseline_egfr_cat
recode ckd_stage 6/8=5 .=6
label define ckd_stage 1 "CKD 5" 2 "CKD 4" 3 "CKD 3B" 4 "CKD 3A" 5 "No CKD" 6 "No baseline eGFR measurement"
label values ckd_stage ckd_stage
label var ckd_stage "Baseline CKD stage"

* eGFR <15 (earliest month)
replace index_date = index_date + 28
gen egfr_below15_outcome_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 oct2019 nov2019 dec2019 jan2020 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022"
foreach x of local month_year  {
  replace egfr_below15_outcome_date=date("15`x'", "DMY") if egfr_below15_outcome_date==.& egfr_creatinine_`x'<15 & date("01`x'", "DMY")>=index_date
}
format egfr_below15_outcome_date %td

* ESRD date
gen esrd_date = egfr_below15_outcome_date
format esrd_date %td
gen krt_outcome = date(krt_outcome_date, "YMD")
replace esrd_date = krt_outcome if esrd_date==.

* Exit date
gen death_date1 = date(death_date, "YMD")
format death_date1 %td
drop death_date
rename death_date1 death_date
gen exit_date = esrd_date
format exit_date %td
gen deregistered_date = date(date_deregistered, "YMD")
format deregistered_date %td
drop date_deregistered
gen deregistered_days = (deregistered_date - index_date)
drop if deregistered_days<0
gen end_date = date("2022-09-30", "YMD") if case==1
replace end_date = date("2020-01-31", "YMD") if case==0
format end_date %td
replace exit_date = min(deregistered_date, death_date, end_date) if esrd_date==.
gen follow_up_time = (exit_date - index_date)
label var follow_up_time "Follow-up time (Days)"
drop if follow_up_time<0
drop if follow_up_time>972

* 50% reduction in eGFR (earliest month) (or ESRD)
gen egfr_reduction50_outcome_date=.
local month_year "feb2017 mar2017 apr2017 may2017 jun2017 jul2017 aug2017 sep2017 oct2017 nov2017 dec2017 jan2018 feb2018 mar2018 apr2018 may2018 jun2018 jul2018 aug2018 sep2018 oct2018 nov2018 dec2018 jan2019 feb2019 mar2019 apr2019 may2019 jun2019 jul2019 aug2019 sep2019 oct2019 nov2019 dec2019 jan2020 feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022"
foreach x of local month_year {
  replace egfr_reduction50_outcome_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_reduction50_outcome_date==.& egfr_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>=index_date
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


*(h)Flag comparators who have a known covid date that is within the follow up period
generate compBecameCaseDurFUP1=0 if case==0
replace compBecameCaseDurFUP1=1 if first_known_covid19>(case_index_date + 28) & first_known_covid19<=(case_index_date + 85) & case==0
la var compBecameCaseDurFUP1 "comparator who had COVID during FUP period 1"
generate compBecameCaseDurFUP2=0 if case==0
replace compBecameCaseDurFUP2=1 if first_known_covid19>(case_index_date + 85) & first_known_covid19<=(case_index_date + 180) & case==0
la var compBecameCaseDurFUP2 "comparator who had COVID during FUP period 2"
generate compBecameCaseDurFUP3=0 if case==0
replace  compBecameCaseDurFUP3=1 if first_known_covid19>(case_index_date + 180) & case==0
la var compBecameCaseDurFUP3 "comparator who had COVID during FUP period 3"


*save final file
save ./output/longCovidSymp_analysis_dataset_contemporary.dta, replace
*save a version that contains only the patient_ids and removes duplicates (for correcting imd and any other covariates assessed independent of case index date)
duplicates drop patient_id, force
keep patient_id
capture noisily export delimited using "./output/longCovidSymp_analysis_dataset_contemporary.csv", replace



log close



