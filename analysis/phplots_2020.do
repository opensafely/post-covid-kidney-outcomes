sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/phplots_2020.log, replace t

use ./output/analysis_complete_2020.dta, clear

/*drop ethnicity1

replace covid_severity = 2 if covid_severity==3
gen covid_severity1 = 0
replace covid_severity1 = 1 if covid_severity1==1
gen covid_severity2 = 0
replace covid_severity2 = 1 if covid_severity==2

gen ethnicity1 = 0
replace ethnicity1 = 1 if ethnicity==1
gen ethnicity2 = 0
replace ethnicity2 = 1 if ethnicity==2
gen ethnicity3 = 0
replace ethnicity3 = 1 if ethnicity==3
gen ethnicity4 = 0
replace ethnicity4 = 1 if ethnicity==4
gen ethnicity5 = 0
replace ethnicity5 = 1 if ethnicity==5

gen ckd_stage1 = 0
replace ckd_stage1 = 1 if ckd_stage==1
gen ckd_stage2 = 0
replace ckd_stage2 = 1 if ckd_stage==2
gen ckd_stage3 = 0
replace ckd_stage3 = 1 if ckd_stage==3
gen ckd_stage4 = 0
replace ckd_stage4 = 1 if ckd_stage==4
gen ckd_stage5 = 0
replace ckd_stage5 = 1 if ckd_stage==5
gen ckd_stage6 = 0
replace ckd_stage6 = 1 if ckd_stage==6*/

/*local outcomes "esrd egfr_half death"

foreach out of local outcomes {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (case=0 case=1)
graph export "./output/stph_2020_case_`out'.png", as(png) replace
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (covid_severity=0 covid_severity=1 covid_severity=2)
graph export "./output/stph_2020_severity_`out'.png", as(png) replace
}
*/

/*stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)
stphplot, by(case) adjustfor(age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax)
qui stcox i.case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (case=0 case=1)
graph export "./output/stph_2020_case_`out'.png", as(png) replace
stphplot, by(covid_severity) adjustfor(age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax)
qui stcox i.covid_severity i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax age1 age2 age3 i.sex i.stp, vce(cluster practice_id)
stcurve, cumhaz at (covid_severity=0 covid_severity=1 covid_severity=2)
graph export "./output/stph_2020_severity_`out'.png", as(png) replace
}
*/

gen ln_time_esrd = ln(follow_up_time_esrd)
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.case##c.ln_time_esrd, vce(cluster practice_id) strata(set_id)
estat phtest, d
qui stcox i.case##c.ln_time_esrd i.ethnicity i.ckd_stage i.aki_baseline i.diabetes i.bmi i.cardiovascular i.hypertension i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
estat phtest, d
qui stcox i.covid_severity##c.ln_time_esrd i.ethnicity i.ckd_stage i.aki_baseline i.diabetes i.bmi i.cardiovascular i.hypertension i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
estat phtest, d


/*
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox i.case##c.ln_time_esrd ethnicity1 ethnicity2 ethnicity3 ethnicity4 ethnicity5 ckd_stage1 ckd_stage2 ckd_stage3 ckd_stage4 ckd_stage5 ckd_stage6 aki_baseline diabetes i.imd i.urban i.bmi i.smoking i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
foreach var of varlist case ckd_stage1 ckd_stage2 ckd_stage3 ckd_stage4 ckd_stage5 ckd_stage6 aki_baseline diabetes {
estat phtest, plot(`var')
graph export "./output/phplot_2020_case_esrd_`var'.svg", as(svg) replace
}
qui stcox covid_severity0 covid_severity1 covid_severity2 ethnicity1 ethnicity2 ethnicity3 ethnicity4 ethnicity5 ckd_stage1 ckd_stage2 ckd_stage3 ckd_stage4 ckd_stage5 ckd_stage6 aki_baseline diabetes i.imd i.urban i.bmi i.smoking i.cardiovascular i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)
foreach var of varlist covid_severity0 covid_severity1 covid_severity2 ckd_stage1 ckd_stage2 ckd_stage3 ckd_stage4 ckd_stage5 ckd_stage6 aki_baseline diabetes {
estat phtest, plot(`var')
graph export "./output/phplot_2020_severity_esrd_`var'.svg", as(svg) replace
}
*/

