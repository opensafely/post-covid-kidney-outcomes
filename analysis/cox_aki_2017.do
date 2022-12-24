sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/cox_aki_2017.log, replace t
use ./output/analysis_2017.dta

stset exit_date_aki, fail(aki_date) origin(index_date) id(patient_id) scale(365.25)
foreach exposure of varlist	case			///
							covid_severity 	///
							covid_aki 		///
							covid_vax		///
							calendar_period {
	tab _d `exposure', col chi
	strate `exposure'
	stcox i.`exposure' i.sex age1 age2 age3, vce(cluster practice_id) strata(set_id)
	quietly stcox i.`exposure' i.sex age1 age2 age3, strata(set_id)
	est store A
	quietly stcox i.sex age1 age2 age3, strata(set_id)
	est store B
	lrtest B A
	stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
	quietly stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3, strata(set_id)
	est store A
	quietly stcox i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3, strata(set_id)
	est store B
	lrtest B A
	stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, vce(cluster practice_id) strata(set_id)
	quietly stcox i.`exposure' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, strata(set_id)
	est store A
	quietly stcox i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3, strata(set_id)
	est store B
	lrtest B A
	}

log close