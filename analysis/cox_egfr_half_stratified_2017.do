sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/cox_egfr_half_stratified_2017.log, replace t
use ./output/analysis_2017.dta

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(patient_id) scale(365.25)
foreach exposure of varlist	case			///
							covid_severity	///
							covid_aki {
	stcox i.`exposure'##i.ckd_stage i.sex age1 age2 age3, vce(cluster practice_id)
	quietly stcox i.`exposure'##i.ckd_stage i.sex age1 age2 age3
	est store A
	quietly stcox i.sex age1 age2 age3
	est store B
	lrtest B A
	stcox i.`exposure'##i.ckd_stage i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3, vce(cluster practice_id)
	quietly stcox i.`exposure'##i.ckd_stage i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3
	est store A
	quietly stcox i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3
	est store B
	lrtest B A
	}

log close