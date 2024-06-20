sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr

use ./output/analysis_complete_2020.dta, clear

replace covid_severity = 2 if covid_severity==3

local outcomes "esrd egfr_half death"

foreach out of local outcomes {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
sts graph, by(case) title("`out'") graphregion(fcolor(white)) ylabel(.75(.1)1)
graph export ./output/km_2020_case_`out'.svg, as(svg) replace
sts graph, by(covid_severity) title("`out'") graphregion(fcolor(white)) ylabel(.75(.1)1)
graph export ./output/km_2020_severity_`out'.svg, as(svg) replace

qui stcox case i.ethnicity /*i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, vce(cluster practice_id) strata(set_id)*/
estat phtest, detail
* Plot schoenfeld residuals 
estat phtest, plot(case) ///
graphregion(fcolor(white)) ///
ylabel(, nogrid labsize(small)) ///
xlabel(, labsize(small)) ///
xtitle("Time", size(small)) ///
ytitle("Scaled Schoenfeld Residuals", size(small)) ///
msize(small) ///
mcolor(gs6) ///
msymbol(circle_hollow) ///
scheme(s1mono) ///
title ("`out'", position(11) size(medsmall)) ///
note("")
graph export ./output/schoenplot_2020_case_`out'.svg, as(svg) replace
}