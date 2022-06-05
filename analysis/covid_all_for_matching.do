log using covid_all_for_matching, replace
insheet using "input_covid_all_for_matching.csv", comma
replace most_recent_creatinine_march_202 = . if !inrange(most_recent_creatinine_march_202, 20, 3000)
gen most_recent_egfr_march_2020 = most_recent_creatinine_march_202

replace most_recent_egfr_march_2020 = . if most_recent_creatinine_march_202 == 0
replace most_recent_egfr_march_2020 = . if !inrange(most_recent_creatinine_march_202, 20, 3000)

gen baseline_creatinine_mgdl = most_recent_creatinine_march_202/88.4

gen min=.
replace min = baseline_creatinine_mgdl/0.7 if sex=="F"
replace min = baseline_creatinine_mgdl/0.9 if sex=="M"
replace min = min^-0.329  if sex=="F"
replace min = min^-0.411  if sex=="M"
replace min = 1 if min<1

gen max=.
replace max=baseline_creatinine_mgdl/0.7 if sex=="F"
replace max=baseline_creatinine_mgdl/0.9 if sex=="M"
replace max=max^-1.209
replace max=1 if max>1

gen baseline_egfr=min*max*141
replace baseline_egfr=baseline_egfr*(0.993^age_march_2020)
replace baseline_egfr=baseline_egfr*1.018 if sex=="F"
label var baseline_egfr "baseline eGFR (CKD-EPI 2009)"
drop if baseline_egfr <15

save $outdir/covid_all_for_matching, replace 