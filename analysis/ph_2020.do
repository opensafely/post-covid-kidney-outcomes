sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/ph_2020.log, replace t

use ./output/analysis_complete_2020.dta, clear

local outcomes "esrd egfr_half aki death"

foreach out of local outcomes {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
estat phtest, d
}