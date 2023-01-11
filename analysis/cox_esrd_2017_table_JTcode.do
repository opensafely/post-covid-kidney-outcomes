********************************************************************************
*
*	Do-file:		202_cox_models.do
*
*	Programmed by:	John & Alex
*
*	Data used:		None
*
*	Data created:   None
*
*	Other output:	None
*
********************************************************************************
*
*	Purpose:		
*
*	Note:			
********************************************************************************

clear

cap log close
log using ./logs/cox_esrd_2017_table_JTcode.log, replace t

tempname measures
	postfile `measures' ///
		str20(comparator) str20(outcome) str10(model) ptime_covid num_events_covid rate_covid /// 
		ptime_comparator num_events_comparator rate_comparator hr lc uc ///
		using ./output/cox_esrd_2017_JTcode, replace
		
use ./output/analysis_2017.dta
gen new_patient_id = _n

global crude i.case
global minimal i.case i.sex age1 age2 age3
*problem with region
global additional i.case i.sex i.ethnicity i.imd i.urban i.bmi i.smoking age1 age2 age3
global full i.case i.sex i.ethnicity i.imd i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3



stset exit_date, fail(esrd_date) origin(index_date) id(patient_id) scale(365.25)

foreach model in crude minimal additional full {
	stcox $`model', vce(cluster practice_id) strata(set_id)
	matrix b = r(table)
			local hr = b[1,2]
			local lc = b[5,2] 
			local uc = b[6,2]
			
			estat phtest, detail
		

			stptime if case == 1
			local rate_covid = `r(rate)'
			local ptime_covid = `r(ptime)'
			local events_covid .
			if `r(failures)' == 0 | `r(failures)' > 5 local events_covid `r(failures)'
			
			stptime if case == 0
			local rate_comparator = `r(rate)'
			local ptime_comparator = `r(ptime)'
			local events_comparator .
			if `r(failures)' == 0 | `r(failures)' > 5 local events_comparator `r(failures)'

			post `measures'  ("Historical") ("ESRD") ("`model'")  ///
							(`ptime_covid') (`events_covid') (`rate_covid') (`ptime_comparator') (`events_comparator')  (`rate_comparator')  ///
							(`hr') (`lc') (`uc')
			
			}
postclose `measures'

* Change postfiles to csv
use ./output/cox_esrd_2017_JTcode, replace

export delimited using ./output/cox_esrd_2017_JTcode, replace

log close