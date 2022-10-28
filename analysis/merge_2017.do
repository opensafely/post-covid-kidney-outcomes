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
*case
/*for cases the variables I want are: age, case, covid_hosp, covid_tpp_prob, covid_tpp_probw2, death_date, dereg_date, first_known_covid19, first_pos_test, first_pos_testw2, had_covid_hosp, has_died, has_follow_up, imd, match_counts, pos_covid_test_ever, set_id, sex, stp*/

capture noisily import delimited ./output/input_covid_matched_cases_allSTPs.csv, clear
keep patient_id age case covid_hosp covid_tpp_prob covid_tpp_probw2 death_date dereg_date first_known_covid19 first_pos_test first_pos_testw2 had_covid_hosp has_died has_follow_up imd match_counts pos_covid_test_ever  set_id sex stp
tempfile cases_match_info
*for dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `cases_match_info', replace
*NUMBER OF MATCHED CASES
count


*comparator
/*for comparator the variables I want are: age, case, covid_hosp, covid_tpp_prob, covid_tpp_probw2, first_known_covid19, first_pos_test, first_pos_testw2, imd, pos_covid_test_ever, set_id, sex, stp*/
*DON'T NEED has_follow_up, has_died, death_date or dereg_date from the original file - these are all created new based on case_index_date in the new file
capture noisily import delimited ./output/input_covid_matched_matches_allSTPs.csv, clear
keep patient_id age case covid_hosp covid_tpp_prob covid_tpp_probw2 first_known_covid19 first_pos_test first_pos_testw2 imd pos_covid_test_ever set_id sex stp
tempfile comp_match_info
*for dummy data, should do nothing in the real data
duplicates drop patient_id, force
save `comp_match_info', replace
*NUMBER OF MATCHED CONTROLS BEFORE DROPPING THOSE DUE TO FOLLOW-UP ISSUES RELATED TO CASE_INDEX_DATE (SEE BELOW)
count


*(2)=========Add the case and comparator information from above to the files with the rest of the information============
*import (matched) cases with variables and merge with match variables
capture noisily import delimited ./output/input_complete_covid_communitycases.csv, clear
merge 1:1 patient_id using `cases_match_info'
keep if _merge==3
drop _merge
tempfile cases_with_vars_and_match_info
save `cases_with_vars_and_match_info', replace
di "***********************FLOWCHART 2. NUMBER OF MATCHED CASES AND MATCHED COMPARATORS BEFORE DROPPING CONTROLS INELIGIBLE DUE TO HAS_FOLLOW_UP AND DEATH_DATE VARS********************:"
di "**Matched cases:**"
safecount


capture noisily import delimited ./output/input_complete_controls_contemporary.csv, clear
merge 1:1 patient_id using `comp_match_info'
keep if _merge==3
drop _merge
tempfile comp_with_vars_and_match_info
save `comp_with_vars_and_match_info', replace
di "**Matched comparators:**"
safecount


*NOTE: Flowchart re: who was dropped here due date exclusions can be obtained from the STP matching logs (if needed)
*/

*(3)=========Append case and comparator files together, drop controls with required has follow up and tidy up, then check number as expected============
append using `cases_with_vars_and_match_info', force
order patient_id set_id match_count case
gsort set_id -case
*drop any comparators that don't have sufficient follow upon
count if case==0 & has_follow_up==0
drop if case==0 & has_follow_up==0
*drop any comparators who have has_died as 1
count if case==0 & has_died==1
drop if case==0 & has_died==1

*redo match_count variable after having done this
generate match_countsNew=.
order patient_id set_id match_counts match_countsNew case
by set_id: replace match_countsNew=_N-1
replace match_countsNew=. if case==0
drop match_counts
rename match_countsNew match_counts

*count then drop cases with no matches
count if match_counts==0
drop if match_counts==0
tab case
tab match_counts
di "***********************FLOWCHART 1. NUMBER OF MATCHED CASES AND MATCHED COMPARATORS: COMBINED FILE, AFTER DROPPING INELGIIBLE CONTROLS (AS ABOVE) AND CASES WITH MATCH_COUNTS==0********************:"
safecount
tab case
*save a list of final cases for analysis unmatched cases in next bit
preserve
	keep if case==1
	keep patient_id
	tempfile final_matchedCases_list
	save `final_matchedCases_list', replace
restore



*(4)=========Create a file of unmatched cases for descriptive analysis============
*import list of all cases (pre-matching)
preserve
	capture noisily import delimited ./output/input_covid_communitycases_correctedCaseIndex.csv, clear
	*for dummy data, should do nothing in the real data
	duplicates drop patient_id, force
	tempfile origCaseList
	save `origCaseList', replace
	use `final_matchedCases_list', clear
	merge 1:1 patient_id using `origCaseList'
	*want to keep the ones not matched as they were in the original extract file but not in the list of matches
	keep if _merge==2
	safecount
	*save file for descriptive analysis
	save output/longCovidSymp_UnmatchedCases_analysis_dataset.dta, replace
	di "***********************FLOWCHART 4. NUMBER OF UMATCHED CASES FROM UNMATCHED CASES FILE (TO CONFIRM IT ALIGNS WITH THE ABOVE FLOWCHART POINTS)********************:"
	safecount
restore





*(5)=========VARIABLE CLEANING============

*label case variables
label define case 0 "Comparator (contemporary)" ///
				  1 "Case"
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


* Ethnicity (16 category)
replace ethnicity_16 = . if ethnicity==.
label define ethnicity_16 									///
						1 "British or Mixed British" 		///
						2 "Irish" 							///
						3 "Other White" 					///
						4 "White + Black Caribbean" 		///
						5 "White + Black African"			///
						6 "White + Asian" 					///
 						7 "Other mixed" 					///
						8 "Indian or British Indian" 		///
						9 "Pakistani or British Pakistani" 	///
						10 "Bangladeshi or British Bangladeshi" ///
						11 "Other Asian" 					///
						12 "Caribbean" 						///
						13 "African" 						///
						14 "Other Black" 					///
						15 "Chinese" 						///
						16 "Other" 							
						
label values ethnicity_16 ethnicity_16
safetab ethnicity_16,m

* Ethnicity (16 category grouped further)
* Generate a version of the full breakdown with mixed in one group
gen eth16 = ethnicity_16
recode eth16 4/7 = 99
recode eth16 11 = 16
recode eth16 14 = 16
recode eth16 8 = 4
recode eth16 9 = 5
recode eth16 10 = 6
recode eth16 12 = 7
recode eth16 13 = 8
recode eth16 15 = 9
recode eth16 99 = 10
recode eth16 16 = 11

label define eth16 	///
						1 "British" ///
						2 "Irish" ///
						3 "Other White" ///
						4 "Indian" ///
						5 "Pakistani" ///
						6 "Bangladeshi" ///					
						7 "Caribbean" ///
						8 "African" ///
						9 "Chinese" ///
						10 "All mixed" ///
						11 "All Other" 
label values eth16 eth16
safetab eth16,m



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

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd
*check after reordering
tab imd




*(d)===Categorical age - 2 versions===
*age categorised with children split up
egen ageCat=cut(age), at (0, 3, 6, 12, 18, 40, 50, 60, 70, 80, 200)
recode ageCat 0=0 3=1 6=2 12=3 18=4 40=5 50=6 60=7 70=8 80=9
label define ageCat 0 "0-2" 1 "3-5" 2 "6-11" 3 "12-17" 4 "18-39" 5 "40-49" 6 "50-59" 7 "60-69" 8 "70-79" 9 "80+"
label values ageCat ageCat
safetab ageCat, miss
la var ageCat "Age categorised"

*age categorised with children combined
egen ageCatChildCombined=cut(age), at (0, 18, 40, 50, 60, 70, 80, 200)
recode ageCatChildCombined 0=0 18=1 40=2 50=3 60=4 70=5 80=6
label define ageCatChildCombined 0 "<18" 1 "18-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80+"
label values ageCatChildCombined ageCatChildCombined
safetab ageCatChildCombined, miss
la var ageCatChildCombined "Age categorised (children combined)"


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

*create a 4 category rural urban variable based upon meeting with Roz 21st October
generate rural_urbanFive=.
la var rural_urbanFive "Rural Urban in five categories"
replace rural_urbanFive=1 if rural_urban==1
replace rural_urbanFive=2 if rural_urban==2
replace rural_urbanFive=3 if rural_urban==3|rural_urban==4
replace rural_urbanFive=4 if rural_urban==5|rural_urban==6
replace rural_urbanFive=5 if rural_urban==7|rural_urban==8
label define rural_urbanFive 1 "Urban major conurbation" 2 "Urban minor conurbation" 3 "Urban city and town" 4 "Rural town and fringe" 5 "Rural village and dispersed"
label values rural_urbanFive rural_urbanFive
safetab rural_urbanFive, miss

*generate a binary rural urban (with missing assigned to urban)
generate rural_urbanBroad=.
replace rural_urbanBroad=1 if rural_urban<=4|rural_urban==.
replace rural_urbanBroad=0 if rural_urban>4 & rural_urban!=.
label define rural_urbanBroad 0 "Rural" 1 "Urban"
label values rural_urbanBroad rural_urbanBroad
safetab rural_urbanBroad rural_urban, miss
label var rural_urbanBroad "Rural-Urban"




*(e)===Pre-existing clinical comorbidities===
*number of broad diagnostic categories containing records in the one year before COVID-19
egen numPreExistingComorbs=rowtotal(comorb_infection_or_parasite-comorb_injury_poisoning)
*have a look at this
sum numPreExistingComorbs, detail
la var numPreExistingComorbs "Number of comorbidities diagnosed in prev yr"
*for now create a category with 0, 1, 2+
egen preExistComorbCat=cut(numPreExistingComorbs), at (0, 1, 2, 200) 
label define preExistComorbCat 0 "0" 1 "1" 2 "2+"
label values preExistComorbCat preExistComorbCat
safetab preExistComorbCat, miss
la var preExistComorbCat "Number of comorbidities diagnosed in prev yr"



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
rename sex sexOrig
gen sex = 1 if sexOrig == "M"
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



*(i)Flag cases who are hospitalised with COVID after the start of follow-up, and which period this was in
generate caseHospForCOVIDDurFUP1=0 if case==1
replace caseHospForCOVIDDurFUP1=1 if covid_hosp>(case_index_date + 28) & covid_hosp<=(case_index_date + 85) & case==1
la var caseHospForCOVIDDurFUP1 "case who was hospitalised for COVID during FUP period 1"
generate caseHospForCOVIDDurFUP2=0 if case==1
replace caseHospForCOVIDDurFUP2=1 if covid_hosp>(case_index_date + 85) & covid_hosp<=(case_index_date + 180) & case==1
la var caseHospForCOVIDDurFUP2 "case who was hospitalised for COVID during FUP period 1"
generate caseHospForCOVIDDurFUP3=0 if case==1
replace caseHospForCOVIDDurFUP3=1 if covid_hosp>(case_index_date + 180)  & case==1
la var caseHospForCOVIDDurFUP3 "comparator who had COVID during FUP period 3"
	

*save final file
save ./output/longCovidSymp_analysis_dataset_contemporary.dta, replace
*save a version that contains only the patient_ids and removes duplicates (for correcting imd and any other covariates assessed independent of case index date)
duplicates drop patient_id, force
keep patient_id
capture noisily export delimited using "./output/longCovidSymp_analysis_dataset_contemporary.csv", replace



log close



