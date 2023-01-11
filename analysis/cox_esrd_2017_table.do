*************************************************************************
*Do file: 08_hhClassif_an_mv_analysis_perEth5Group_HR_table.do
*
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing minimally and fully-adjusted HRs for risk factors
* of interest, across 2 outcomes 
*
*Requires: final analysis dataset (analysis_dataset.dta)

*
*Coding: K Wing, base on file from HFORBES, based on file from Krishnan Bhaskaran
*
*Date drafted: 17th June 2021
*************************************************************************
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
*run globals of lists of diagnoses and symptoms, then make loc
do ./analysis/masterlists.do

*checking tabulations
capture log close
log using ./logs/cox_esrd_2017_table.log, replace t

	
prog drop _all


prog define hr
	syntax, outcome(string)
	*above will need edited when also have the historical population to compare to

	*get denominator			
	count
	local denom=r(N)
	*get number of people with specific outcome (events column)
	cou if esrd== 1
	local events=round(r(N),5)
	*calculate proportion of people with events
	local percWEvent=100*(`events'/`denom')
	*get ORs for each regression analysis
	*crude 
	display "`outcome' adjusted only for age, sex and STP"
	*tabulate values for checking output table against log files
	safetab `exposure' esrd
	*Cox regression
	stset exit_date, fail(esrd_date) origin(index_date) id(patient_id) scale(365.25)
	capture noisily stcox i.`exposure' i.sex age1 age2 age3, vce(cluster practice_id) strata(set_id)
	*this lincom ensures HR and CI can be stored in the r values
	capture noisily lincom 1.`exposure'
	local hr_minimally_adjusted = r(estimate)
	local lb_minimally_adjusted = r(lb)
	local ub_minimally_adjusted = r(ub)
	*additionally adjusted
	display "`outcome' additionally adjusted for ethnicity, socioeconomic deprivation, region, rural/urban, BMI & smoking"
	capture noisily stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
	capture noisily lincom 1.`exposure'
	local hr_additionally_adjusted = r(estimate)
	local lb_additionally_adjusted = r(lb)
	local ub_additionally_adjusted = r(ub)
	*Fully adjusted
	display "`outcome' fully adjusted"
	capture noisily stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
	capture noisily lincom 1.`exposure'
	local hr_fully_adjusted = r(estimate)
	local lb_fully_adjusted = r(lb)
	local ub_fully_adjusted = r(ub)
					
	*get variable name
	local varlab: variable label `exposure'
	display "`varlab'"
	*get category name
	*local category: label `catLabel' `i'
	*display "Category label: `category'"
	
	*write each row
	*crude 
	file write tablecontents  ("`varLab'") _tab ("Adjusted for age, sex and STP") _tab %4.2f (`hr_crude')  " (" %4.2f (`lb_crude') "-" %4.2f (`ub_crude') ")" _tab (`events') _tab %3.1f (`percWEvent') ("%")  _n
	*depr and ethnicity adjusted
	file write tablecontents  _tab _tab ("Additionally adjusted for ethnicity, IMD, region, rural/urban, BMI and smoking") _tab %4.2f (`hr_deprEth_adj')  " (" %4.2f (`lb_deprEth_adj') "-" %4.2f (`ub_deprEth_adj') ")"  _n
	*fully adjusted
	file write tablecontents  _tab _tab ("Additionally adjusted for comorbidities") _tab %4.2f (`hr_full_adj')  " (" %4.2f (`lb_full_adj') "-" %4.2f (`ub_full_adj') ")"  _n

end

*call program and output tables

use ./output/analysis_2017.dta, clear
file open tablecontents using ./output/cox_esrd_2017_table.txt, t w replace
file write tablecontents "Hazard ratios for end-stage renal disease after SARS-CoV-2 infection compared to matched historical comparator population" _n _n
file write tablecontents ("Outcome") _tab _tab ("HR (95% CI)") _tab ("Number of events") _tab ("Proportion of population with events") _n

*loop through each exposure
foreach exposure in $exposure {
	cap noisily hr, outcome(`exposure')
	file write tablecontents _n
}

cap file close tablecontents 
cap log close