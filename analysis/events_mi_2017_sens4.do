sysdir set PLUS ./analysis/adofiles
sysdir set PERSONAL ./analysis/adofiles
pwd
cap log close
macro drop hr
log using ./logs/events_mi_2017_sens4.log, replace t

cap file close tablecontent
file open tablecontent using ./output/events_mi_2017_sens4.csv, write text replace
file write tablecontent _tab ("COVID-19") _tab ("Matched historical cohort") _n
file write tablecontent ("COVID-19 overall")
use ./output/analysis_2017.dta, clear

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
file write tablecontent _n


file write tablecontent ("By COVID-19 wave") _n


local wave1: label wave 1
local wave2: label wave 2
local wave3: label wave 3
local wave4: label wave 4

forvalues i=1/4 {
qui safecount if wave==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/4 {
file write tablecontent ("`wave`i''") _tab (`cases`i'_events') _n
}
file write tablecontent _n

file write tablecontent ("By COVID-19 vaccination status") _n


local vax1: label covid_vax 1
local vax2: label covid_vax 2
local vax3: label covid_vax 3
local vax4: label covid_vax 4
local vax5: label covid_vax 5

forvalues i=1/5 {
qui safecount if covid_vax==`i' & _d==1 & _st==1
local cases`i'_events = round(r(N),5)
}

forvalues i=1/5 {
file write tablecontent ("`vax`i''") _tab (`cases`i'_events') _n
}
file close tablecontent