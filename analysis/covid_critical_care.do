cap log close
log using ./logs/covid_critical_care, replace t
clear

import delimited ./output/input_covid_critical_care.csv, delimiter(comma) varnames(1) case(preserve) 

**Exclusions
* Age <18
drop if age <18

* Anyone not registered at one practice for 3 months before COVID-19 diagnosis
drop if has_follow_up==0

* Calendar period
gen covid_date = date(covid_diagnosis_date, "YMD")
format covid_date %td
drop if covid_date ==.
drop covid_diagnosis_date
drop sgss_positive_date
drop primary_care_covid_date
drop hospital_covid_date
gen covid_date_string=string(covid_date, "%td") 
gen covid_month=substr( covid_date_string ,3,7)
gen calendar_period = 1 if covid_month=="feb2020"
replace calendar_period = 1 if covid_month=="mar2020"
replace calendar_period = 1 if covid_month=="apr2020"
replace calendar_period = 1 if covid_month=="may2020"
replace calendar_period = 1 if covid_month=="jun2020"
replace calendar_period = 2 if covid_month=="jul2020"
replace calendar_period = 2 if covid_month=="aug2020"
replace calendar_period = 2 if covid_month=="sep2020"
replace calendar_period = 2 if covid_month=="oct2020"
replace calendar_period = 2 if covid_month=="nov2020"
replace calendar_period = 3 if covid_month=="dec2020"
replace calendar_period = 3 if covid_month=="jan2021"
replace calendar_period = 3 if covid_month=="feb2021"
replace calendar_period = 4 if covid_month=="mar2021"
replace calendar_period = 4 if covid_month=="apr2021"
replace calendar_period = 4 if covid_month=="may2021"
replace calendar_period = 4 if covid_month=="jun2021"
replace calendar_period = 4 if covid_month=="jul2021"
replace calendar_period = 4 if covid_month=="aug2021"
replace calendar_period = 4 if covid_month=="sep2021"
replace calendar_period = 4 if covid_month=="oct2021"
replace calendar_period = 4 if covid_month=="nov2021"
replace calendar_period = 5 if covid_month=="dec2021"
replace calendar_period = 5 if covid_month=="jan2022"
replace calendar_period = 5 if covid_month=="feb2022"
replace calendar_period = 5 if covid_month=="mar2022"
replace calendar_period = 5 if covid_month=="apr2022"
replace calendar_period = 5 if covid_month=="may2022"
replace calendar_period = 5 if covid_month=="jun2022"
replace calendar_period = 5 if covid_month=="jul2022"

label define calendar_period_label	1 "Feb20-Jun20"		///
									2 "Jul20-Nov20"		///
									3 "Dec20-Feb21"		///
									4 "Mar21-Nov21"		///
									5 "Dec21-Jul22"
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

*Sex
assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
label define sexLab 1 "Male" 0 "Female"
label values male sexLab
label var male "Sex (0=F 1=M)"

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

*critical_procedures = admitted to hospital + critical care procedure codes
*critical_days = admitted to hospital + at least 1 day in critical care in SUS

*Compare critical_procedures and critical_days
tab hospitalised
tab critical_procedures
tab critical_days

*Critical care interventions
tab mechanical_ventilation
tab non_invasive_ventilation
tab kidney_replacement_therapy
tab haemofiltration

gen critical_source = hospitalised
replace critical_source = 0 if hospitalised==1
replace critical_source = 1 if critical_procedures==1 &critical_days==1
replace critical_source = 2 if critical_procedures==1 &critical_days==0
replace critical_source = 3 if critical_procedures==0 &critical_days==1
label define critical_source_label	0 "No critical care" 								///
									1 "Concordant" 						///
									2 "Procedure only"									///
									3 "Days only"
label values critical_source critical_source_label
label var critical_source "Critical care coding source"
tab critical_source

gen critical = critical_source
replace critical = 1 if critical_source==2
replace critical = 1 if critical_source==3
label define critical_label	0 "No critical care" 					///
							1 "Critical  care" 						
label values critical critical_label
label var critical "COVID-19 severity"
tab critical

foreach var of varlist	mechanical_ventilation			///
						non_invasive_ventilation		///
						kidney_replacement_therapy		///
						haemofiltration {
		tab `var' critical_procedures, m row chi
		}

gen interventions = critical_procedures
**Critical care interventions in those with procedure codes**
replace interventions = 2 if interventions==1 &mechanical_ventilation==1
replace interventions = 3 if interventions==2 &haemofiltration==1
replace interventions = 4 if interventions==2 &kidney_replacement_therapy==1
replace interventions = 5 if interventions==1 &non_invasive_ventilation==1
replace interventions = 6 if interventions==5 &haemofiltration==1
replace interventions = 7 if interventions==5 &kidney_replacement_therapy==1
replace interventions = 8 if interventions==1 &haemofiltration==1
replace interventions = 9 if interventions==1 &kidney_replacement_therapy==1
label define interventions_label 	0 "No critical interventions"	///
									1 "Other interventions"			///
									2 "MV only"						///
									3 "MV+CVVH"						///
									4 "MV+KRT"						///	
									5 "NIV only"					///
									6 "NIV+CVVH"					///		
									7 "NIV+KRT"						///
									8 "CVVH only"					///
									9 "KRT only"					
label values interventions interventions_label
label var interventions "Critical care interventions"
tab interventions

foreach var of varlist 	agegroup 						///
						male 							///
						imd 							///
						ethnicity 						///
						region_9 						///
						stp								///
						calendar_period {						
	tab `var' critical_procedures, m row chi
	tab `var' critical_days, m row chi
	tab	`var' critical, m row chi
	}
	
save ./output/covid_critical_care.dta, replace 
log close
