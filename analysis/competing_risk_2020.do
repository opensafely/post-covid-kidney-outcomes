clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./output/competing_risk_2020.log, replace t

local outcomes "esrd egfr_half"

foreach out of local outcomes {
use ./output/analysis_complete_2020.dta, clear

gen failure=0
replace failure = 2 if death_date!=.
replace failure = 1 if `out'_date!=.

stset exit_date_`out', failure(failure==1) exit(time end_date) id(unique) scale(365.25)

**Can't stratify by set_id in stcrreg
*Options are to adjust for matching factors or cluster by set_id instead
stcrreg i.case age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, compete(failure == 2) vce(cluster practice_id)

replace covid_severity = 2 if covid_severity==3
stcrreg i.covid_severity age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, compete(failure == 2) vce(cluster practice_id)
}
