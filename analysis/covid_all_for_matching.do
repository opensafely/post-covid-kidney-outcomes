cd repos/output
log using covid_all_for_matching, replace

**Need to include date of death
gen end_of_follow_up = date(deregistered, "YMD")
format end_of_follow_up %td
replace end_of_follow_up = 2022-01-31 if end_of_follow_up==.

insheet using "input_covid_all_for_matching.csv", comma

gen indexdate = date(covid_diagnosis_date, "YMD")
format indexdate %td
drop if indexdate ==.
gen indexmonth = mofd(indexdate)
format indexmonth %tm



**This should be 0 if only individuals with COVID were extracted
drop covid_diagnosis_date
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date

assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
label define sexLab 1 "male" 0 "female"
label values male sexLab
label var male "sex = 0 F, 1 M"

rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
replace imd = . if imd_o==-1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5=1 4=2 3=3 2=4 1=5 .=.

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" 
label values imd imd 

noi di "DROPPING IF NO IMD" 
drop if imd>=.


* Smoking
label define smoking_label 1 "Current/former smoker" 0 "Non-smoker"
label values smoking smoking_label

* Ethnicity (5 category)
replace ethnicity = 6 if ethnicity==.
label define ethnicity_label 	1 "White"  								///
						2 "Mixed" 								///
						3 "Asian or Asian British"				///
						4 "Black"  								///
						5 "Other"								///
						6 "Unknown"
label values ethnicity ethnicity_label


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

* Seven regions
recode region_9 2=1 3=2 1 8=3 4 9=4 5=5 6=6 7=7, gen(region_7)

label define region_7 	1 "East"							///
						2 "London" 							///
						3 "Midlands"						///
						4 "North East and Yorkshire"		///
						5 "North West"						///
						6 "South East"						///	
						7 "South West"
label values region_7 region_7
label var region_7 "Region of England (7 regions)"
drop region_string

	
**************************
*  Categorise variables  *
**************************
* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old

* Create categorised age
drop if age <18
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


* Check there are no missing ages
assert age<.
assert agegroup<.

* Create restricted cubic splines fir age
mkspline age = age, cubic nknots(4)

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

gen indexdate_string=string(indexdate, "%td") 
gen index_month=substr( indexdate_string ,3,7)

gen baseline_egfr=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022"
foreach x of  local month_year  {
replace baseline_egfr=egfr_baseline_creatinine_`x' if  index_month=="`x'" 
drop egfr_baseline_creatinine_`x'
}


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





save $outdir/covid_all_for_matching, replace -