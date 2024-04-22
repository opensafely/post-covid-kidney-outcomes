clear
sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./output/competing_risk_chronic_2020.log, replace t

local outcomes "esrd egfr_half"

foreach out of local outcomes {
use ./output/analysis_complete_2020.dta, clear

**Exclude people with COVID-KRT (i.e. within 28 days of first diagnosis)

drop if covid_krt==3
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

gen failure=0
replace failure = 2 if death_date!=.
replace failure = 1 if `out'_date!=.

stset exit_date_`out', failure(failure==1) exit(time end_date) id(unique) scale(365.25)

**Can't stratify by set_id in stcrreg
*Options are to adjust for matching factors or cluster by set_id instead
stcrreg i.case age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, compete(failure == 2) vce(cluster practice_id)

replace covid_severity = 2 if covid_severity==3
stcrreg i.covid_severity age1 age2 age3 i.sex i.stp i.ethnicity i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.covid_vax, compete(failure == 2) vce(cluster practice_id)

**Exclude COVID-KRT events but include subsequent events suggestive of ESRD

use ./output/analysis_complete_2020.dta, clear

*ESRD redefined by not including KRT codes 28 days before COVID
gen chronic_krt_date = date(krt_outcome2_date, "YMD")
format chronic_krt_date %td
drop krt_outcome2_date
replace esrd_date=. if covid_krt==3
replace esrd_date=egfr15_date if esrd_date==.
replace esrd_date = chronic_krt_date if esrd_date==.
drop exit_date_esrd
gen exit_date_esrd = esrd_date
format exit_date_esrd %td
replace exit_date_esrd = min(deregistered_date, death_date, end_date, covid_exit) if esrd_date==.
replace exit_date_esrd = covid_exit if covid_exit < esrd_date
replace esrd_date=. if covid_exit<esrd_date&case==0

*50% reduction in eGFR redefined by not including KRT codes 28 days before COVID
drop egfr_half_date
gen egfr_half_date=.
local month_year "feb2020 mar2020 apr2020 may2020 jun2020 jul2020 aug2020 sep2020 oct2020 nov2020 dec2020 jan2021 feb2021 mar2021 apr2021 may2021 jun2021 jul2021 aug2021 sep2021 oct2021 nov2021 dec2021 jan2022 feb2022 mar2022 apr2022 may2022 jun2022 jul2022 aug2022 sep2022 oct2022 nov2022 dec2022 jan2023"
foreach x of local month_year {
  replace egfr_half_date=date("15`x'", "DMY") if baseline_egfr!=. & egfr_half_date==.& egfr_creatinine_`x'<0.5*baseline_egfr & date("01`x'", "DMY")>index_date
  format egfr_half_date %td
}
replace egfr_half_date=esrd_date if egfr_half_date==.
drop exit_date_egfr_half
gen exit_date_egfr_half = egfr_half_date
format exit_date_egfr_half %td
replace exit_date_egfr_half = min(deregistered_date,death_date,end_date,covid_exit) if egfr_half_date==. & index_date_egfr_half!=.
replace exit_date_egfr_half = covid_exit if covid_exit < egfr_half_date

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
