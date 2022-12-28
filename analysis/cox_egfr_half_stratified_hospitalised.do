sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd

cap log close
log using ./logs/cox_egfr_half_stratified_hospitalised.log, replace t
use ./output/analysis_hospitalised.dta

stset exit_date, fail(egfr_half_date) origin(index_date) id(patient_id) scale(365.25)
foreach interaction of varlist	critical_care	///
								acute_kidney_injury {
	stcox i.case##i.`interaction' i.sex age1 age2 age3 i.month, vce(cluster practice_id)
	quietly stcox i.case##i.`interaction' i.sex age1 age2 age3 i.month
	est store A
	quietly stcox i.sex age1 age2 age3 i.month
	est store B
	lrtest B A
	stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
	quietly stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month
	est store A
	quietly stcox i.sex i.ethnicity i.imd i.region i.urban i.bmi i.smoking age1 age2 age3 i.month
	est store B
	lrtest B A
	stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month, vce(cluster practice_id)
	quietly stcox i.case##i.`interaction' i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month
	est store A
	quietly stcox i.sex i.ethnicity i.imd i.region i.urban i.bmi i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.smoking age1 age2 age3 i.month
	est store B
	lrtest B A
	}

log close