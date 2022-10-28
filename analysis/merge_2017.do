/*==============================================================================
DO FILE NAME:			09_longCovidSymp_cr_analysis_dataset.do
PROJECT:				Long covid symptoms
DATE: 					29th Aug 2022
AUTHOR:					Kevin Wing 										
DESCRIPTION OF FILE:	Creates a file containing the matched cases and comparators ready for analysis, and a file of the cases that could not be matched for descr analysis
DATASETS USED:			.csv
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir

t


sysdir set PLUS "/Users/kw/Documents/GitHub/households-research/analysis/adofiles" 
sysdir set PERSONAL "/Users/kw/Documents/GitHub/households-research/analysis/adofiles" 

							
==============================================================================*/
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
						70/79.9999=5						
						80/max=6, 		///
						gen(agegroup) 

label define agegroup 	1 "18-<40" 		///
						2 "40-<50" 		///
						3 "50-<60" 		///
						4 "60-<70" 		///
						5 "70-<80"		///
						6 "80+"
label values agegroup agegroup


* Check there are no missing ages
assert age<.
assert agegroup<.

* Create restricted cubic splines fir age
mkspline age = age, cubic nknots(4)

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


*generate a binary rural urban (with missing assigned to urban)
generate rural_urbanBroad=.
replace rural_urbanBroad=1 if rural_urban<=4|rural_urban==.
replace rural_urbanBroad=0 if rural_urban>4 & rural_urban!=.
label define rural_urbanBroad 0 "Rural" 1 "Urban"
label values rural_urbanBroad rural_urbanBroad
safetab rural_urbanBroad rural_urban, miss
label var rural_urbanBroad "Rural-Urban"


*(f) Recode all dates from the strings 
*order variables to make for loop quicker
order patient_id case_index_date first_pos_test first_pos_testw2 covid_tpp_prob covid_tpp_probw2 covid_hosp pos_covid_test_ever infect_parasite neoplasms blood_diseases endocr_nutr_dis mental_disorder nervous_sys_dis ear_mastoid_dis circ_sys_dis resp_system_dis digest_syst_dis skin_disease musculo_dis genitourin_dis pregnancy_compl perinatal_dis congenital_dis injury_poison death_date dereg_date first_known_covid19
*have to rename some variables here as too long
foreach var of varlist case_index_date - first_known_covid19 {
	capture noisily confirm string variable `var'
	capture noisily rename `var' `var'_dstr
	capture noisily gen `var' = date(`var'_dstr, "YMD")
	capture noisily drop `var'_dstr
	capture noisily format `var' %td 

}


*(g) Sex
gen sex = 1 if male == "M"
replace sex = 0 if sexOrig == "F"
replace sex =. if sexOrig=="I"
replace sex =. if sexOrig=="U"
label define sex 0"Female" 1"Male"
label values sex sex
safetab sex
safecount
drop sexOrig


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



