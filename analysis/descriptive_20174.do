sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/descriptive_20174.log, replace t
use ./output/analysis_20174.dta

foreach var of varlist 	age				///
						baseline_egfr	///
						esrd_time		///
						follow_up_time {
	by case,sort: sum `var', de
	by covid_severity,sort: sum `var', de
	by covid_aki,sort: sum `var', de
	by covid_krt,sort: sum `var', de
	by covid_vax,sort: sum `var', de
	by calendar_period,sort: sum `var', de
	}

foreach exposure of varlist	case			///
							covid_severity 	///
							covid_aki 		///
							covid_krt		///
							covid_vax		///
							calendar_period {
	total follow_up_time, over(`exposure')
	tab agegroup `exposure', m col chi
	tab sex `exposure', m col chi
	tab ethnicity1 `exposure', m col chi
	tab region `exposure', m col chi
	tab stp `exposure', m col chi
	tab urban `exposure', m col chi
	tab bmi `exposure', m col chi
	tab smoking `exposure', m col chi
	tab egfr_group `exposure', m col chi
	tab ckd_stage `exposure', m col chi
	tab afib `exposure', m col chi
	tab liver `exposure', m col chi
	tab diabetes `exposure', m col chi
	tab haem_cancer `exposure', m col chi
	tab heart_failure `exposure', m col chi
	tab hiv `exposure', m col chi
	tab hypertension `exposure', m col chi
	tab non_haem_cancer `exposure', m col chi
	tab myocardial_infarction `exposure', m col chi
	tab pvd `exposure', m col chi
	tab rheumatoid `exposure', m col chi
	tab stroke `exposure', m col chi
	tab lupus `exposure', m col chi
	tab cardiovascular `exposure', m col chi
	tab immunosuppressed `exposure', m col chi
	}

log close