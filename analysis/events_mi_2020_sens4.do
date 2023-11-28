sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_mi_2020_sens4.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_mi_2020_sens4.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Matched contemporary cohort") _n
file write tablecontent ("COVID-19 overall")
use ./output/analysis_2020.dta, clear


*Remove invalid sets with missing smoking/BMI data
foreach var of varlist bmi smoking {
gen `var'_recorded = 0
replace `var'_recorded = 1 if case==1 & `var'!=.
replace `var'_recorded = 1 if case==0
bysort set_id: egen set_mean = mean(`var'_recorded)
drop if set_mean < 1
drop set_mean `var'_recorded
drop if case==0 & `var'==.
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n
}

*mi set the data
mi set mlong

*mi register 
mi register imputed ethnicity

noisily mi impute mlogit ethnicity esrd i.imd i.urban i.bmi i.smoking i.ckd_stage i.aki_baseline i.cardiovascular i.diabetes i.hypertension i.immunosuppressed i.non_haem_cancer i.gp_consults i.admissions i.agegroup i.sex i.stp, add(10) rseed(70548) augment force // can maybe remove the force option in the server

safetab ethnicity, m

*Remove invalid sets with ongoing missing ethnicity data
gen ethnicity_recorded = 0
replace ethnicity_recorded = 1 if case==1 & ethnicity!=.
replace ethnicity_recorded = 1 if case==0
bysort set_id: egen set_mean = mean(ethnicity_recorded)
drop if set_mean < 1
drop set_mean ethnicity_recorded
drop if case==0 & ethnicity==.
bysort set_id: egen set_n = count(_N)
drop if set_n <2
drop set_n

safetab ethnicity, m


mi stset exit_date_esrd, fail(esrd_date) origin(index_date_esrd) id(unique) scale(365.25)
drop age1 age2 age3
mkspline age = age if _st==1&sex!=.&ethnicity!=.&imd!=.&urban!=.&region!=.&bmi!=.&smoking!=., cubic nknots(4)


qui safecount if case==1 & _d==1 & _st==1
local cases_events = round(r(N),5)
qui safecount if case==0 & _d==1 & _st==1
local controls_events = round(r(N),5)
file write tablecontent _tab (`cases_events') _tab (`controls_events') _n

file write tablecontent _n

file write tablecontent ("By COVID-19 severity") _n

local severity1: label covid_severity 1
local severity2: label covid_severity 2
local severity3: label covid_severity 3

bysort covid_severity: egen total_follow_up = total(_t)
forvalues i=1/3 {
qui safecount if covid_severity==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/3 {
file write tablecontent ("`severity`i''") _tab (`cases`i'_events') _n
}
file write tablecontent _n


file write tablecontent ("By COVID-19 AKI") _n


local aki1: label covid_aki 1
local aki2: label covid_aki 2
local aki3: label covid_aki 3

forvalues i=1/3 {
qui safecount if covid_aki==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/3 {
file write tablecontent ("`aki`i''") _tab (`cases`i'_events') _n
}

file close tablecontent