sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/cumhaz_2020.log, replace t

use ./output/analysis_complete_2020.dta, clear

local outcomes "esrd egfr_half death"

foreach out of local outcomes {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (case=0 case=1)
graph export "./output/stph_2020_case_`out'.svg", as(svg) replace
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (covid_severity=0 covid_severity=1 covid_severity=2)
graph export "./output/stph_2020_severity_`out'.svg", as(svg) replace
}