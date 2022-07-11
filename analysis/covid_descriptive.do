cap log close
log using ./logs/covid_descriptive, replace t
clear

use ./output/covid_england.dta

**Descriptive statistics
* By COVID-19 severity
foreach stratum of varlist 	covid_severity 				///
							covid_acute_kidney_injury 	///
							covid_krt					///
							covid_vax_status			///
							calendar_period {
	by `stratum',sort: sum age baseline_egfr body_mass_index follow_up_time, de
	total follow_up_time, over(`stratum')
	}

foreach var of varlist 	agegroup 						///
						male 							///
						imd 							///
						ethnicity 						///
						region_9 						///
						stp 							///
						baseline_egfr_cat 				///
						ckd_stage 						///	
						atrial_fibrillation_or_flutter	///
						chronic_liver_disease			///
						diabetes						///
						haematological_cancer			///
						heart_failure					///
						hiv								///
						hypertension					///
						non_haematological_cancer		///
						myocardial_infarction			///
						peripheral_vascular_disease		///
						rheumatoid_arthritis			///
						stroke							///
						systemic_lupus_erythematosus	///
						immunosuppression				///
						bmicat							///
						smoking {						
	tab	`var' covid_severity, m col chi
	tab `var' covid_acute_kidney_injury, m col chi
	tab `var' covid_krt, m col chi
	tab `var' covid_vax_status, m col chi
	tab `var' calendar_period, m col chi
	}

* End-stage renal disease (stratified)
sum krt_outcome
sum egfr_below15_outcome_date
stset exit_date, fail(esrd_date) origin(index_date) id(patient_id) scale(365.25)
foreach stratum of varlist 	covid_severity 				///
							covid_acute_kidney_injury 	///
							covid_krt					///
							covid_vax_status 			///
							calendar_period {
	tab _d `stratum', col chi
	strate `stratum'
	strate `stratum' agegroup
	strate `stratum' male
	strate `stratum' ethnicity
	strate `stratum' imd
	strate `stratum' baseline_egfr_cat
	strate `stratum' diabetes
	sts graph, failure by(`stratum') title(Cumulative ESRD after SARS-CoV-2 survival by `stratum') ylab(0(0.02)0.20, angle(horizontal)) ytitle(Cumulative ESRD) xtitle(Follow-up (years))
	graph export ./output/esrd_`stratum'.svg,  replace
	}

* 50% reduction in eGFR (stratified)
stset exit_date_egfr_reduction, fail(egfr_reduction50_outcome_date) origin(index_date_egfr_reduction) id(patient_id) scale(365.25)
foreach stratum of varlist 	covid_severity 				///
							covid_acute_kidney_injury 	///
							covid_krt					///
							covid_vax_status 			///
							calendar_period {
	tab _d `stratum', col chi
	strate `stratum'
	strate `stratum' agegroup
	strate `stratum' male
	strate `stratum' ethnicity
	strate `stratum' imd
	strate `stratum' baseline_egfr_cat
	strate `stratum' diabetes
	sts graph, failure by(`stratum') title(Cumulative 50% eGFR reduction after SARS-CoV-2 survival by `stratum') ylab(0(0.02)0.20, angle(horizontal)) ytitle(Cumulative 50% eGFR reduction) xtitle(Follow-up (years))
	graph export ./output/egfr_reduction_`stratum'.svg,  replace
	}

* Acute kidney injury rates (stratified)
stset exit_date_aki, fail(aki_outcome_date) origin(index_date) id(patient_id) scale(365.25)
foreach stratum of varlist 	covid_severity 				///
							covid_acute_kidney_injury 	///
							covid_krt					///
							covid_vax_status 			///
							calendar_period {
	tab _d `stratum', col chi
	strate `stratum'
	strate `stratum' agegroup
	strate `stratum' male
	strate `stratum' ethnicity
	strate `stratum' imd
	strate `stratum' baseline_egfr_cat
	strate `stratum' diabetes
	sts graph, failure by(`stratum') title(Cumulative AKI after SARS-CoV-2 survival by `stratum') ylab(0(0.02)0.20, angle(horizontal)) ytitle(Cumulative AKI) xtitle(Follow-up (years))
	graph export ./output/aki_`stratum'.svg, replace
	}
	
* Death rates (stratified)
stset exit_date_death, fail(death_date) origin(index_date) id(patient_id) scale(365.25)
foreach stratum of varlist 	covid_severity 				///
							covid_acute_kidney_injury 	///
							covid_krt					///
							covid_vax_status 			///
							calendar_period {
	tab _d `stratum', col chi
	strate `stratum'
	strate `stratum' agegroup
	strate `stratum' male
	strate `stratum' ethnicity
	strate `stratum' imd
	strate `stratum' baseline_egfr_cat
	strate `stratum' diabetes
	sts graph, failure by(`stratum') title(Cumulative mortality after SARS-CoV-2 survival by `stratum') ylab(0(0.10)0.50, angle(horizontal)) ytitle(Cumulative mortality) xtitle(Follow-up (years))
	graph export ./output/mortality_`stratum'.svg,  replace
	}
	
save ./output/covid_descriptive.dta, replace 
log close
