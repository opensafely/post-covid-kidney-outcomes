sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr

use ./output/analysis_complete_2017.dta, clear

replace covid_severity = 2 if covid_severity==3

stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
sts graph, by(case) title("esrd") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2017_case_esrd.svg, as(svg) replace
sts graph, by(covid_severity) title("esrd") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2017_severity_esrd.svg, as(svg) replace

stset exit_date_egfr_half, fail(egfr_half_date) origin(index_date_egfr_half) id(unique) scale(365.25)
sts graph, by(case) title("egfr_half") graphregion(fcolor(white)) ylabel(.90(.1)1)
graph export ./output/km_2017_case_egfr_half.svg, as(svg) replace
sts graph, by(covid_severity) title("egfr_half") graphregion(fcolor(white)) ylabel(.95(.1)1)
graph export ./output/km_2017_severity_egfr_half.svg, as(svg) replace

stset exit_date_death, fail(death_date) origin(index_date_death) id(unique) scale(365.25)
sts graph, by(case) title("death") graphregion(fcolor(white)) ylabel(.90(.1)1)
graph export ./output/km_2017_case_death.svg, as(svg) replace
sts graph, by(covid_severity) title("death") graphregion(fcolor(white)) ylabel(.65(.1)1)
graph export ./output/km_2017_severity_death.svg, as(svg) replace

local outcomes "esrd egfr_half death"

foreach out of local outcomes {
stset exit_date_`out', fail(`out'_date) origin(index_date_`out') id(unique) scale(365.25)
qui stcox case i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
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
graph export ./output/schoenplot_2017_case_`out'.svg, as(svg) replace
}

gen covid_severity1 = 0
replace covid_severity1 = 1 if covid_severity==1
gen covid_severity2 = 0
replace covid_severity2 = 1 if covid_severity==2

forvalues i = 1/2 {
stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
qui stcox covid_severity`i' i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions, vce(cluster practice_id) strata(set_id)
estat phtest, detail
* Plot schoenfeld residuals 
estat phtest, plot(covid_severity`i') ///
graphregion(fcolor(white)) ///
ylabel(, nogrid labsize(small)) ///
xlabel(, labsize(small)) ///
xtitle("Time", size(small)) ///
ytitle("Scaled Schoenfeld Residuals", size(small)) ///
msize(small) ///
mcolor(gs6) ///
msymbol(circle_hollow) ///
scheme(s1mono) ///
title ("esrd", position(11) size(medsmall)) ///
note("")
graph export ./output/schoenplot_2017_severity`i'_esrd.svg, as(svg) replace
}