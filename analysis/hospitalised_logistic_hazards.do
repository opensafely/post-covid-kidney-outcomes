**Nonparametric estimation of survival curves
gen survtime_death = follow_up_time_death
stset survtime_death, failure(death=1)
sts graph, by(case) xlabel(0(100)1000)

gen survtime_esrd = follow_up_time_esrd
stset survtime_esrd, failure(esrd=1)
sts graph, by(case) xlabel(0(100)1000)

**Parametric estimation of survival curves via hazards model

/**Create person-week dataset for survival analyses**/

/*We want our new dataset to include 1 observation per person per week alive, starting at time = 0*/
*Individuals who survive to the end of follow-up will survtime_death time points*
*Individuals who die will have survtime_death - 1 time points*
clear
use ./output/analysis_hospitalised.dta

*Create survival time by week
gen survtime_death = floor(follow_up_time_death/7)

*expand data to person-time*
*expand replaces each observation in the dataset with n copies of the observation, where n is equal to the required expression rounded to the nearest integer.
gen time = 0
expand survtime_death if time == 0
*creates rows for each week survived
bysort unique: replace time = _n - 1
*for each individual, time in each row is replaced by the row number minus 1 (i.e. timepoint k)
*e.g. for an individual for whom survtime_death = 40 weeks, timepoint k in their row 1 = 0, up to timepoint k in their row 40 = 39

*Create time-squared variable for analyses*
gen timesq = time*time

*Save the dataset to your working directory for future use*
save analysis_hospitalised_surv, replace

/**Hazard ratios**/
clear

use "analysis_hospitalised_surv.dta"

*Fit a pooled logistic hazards model *
logistic event case case#c.time case#c.time#c.time c.time c.time#c.time 

/**Survival curves: run regression then do:**/

*Create a dataset with all time points under each treatment level*
*Re-expand data with rows for all timepoints*
*Drop extra rows (where time > 0)
drop if time != 0
*Create rows for maximum number of weeks
expand 148 if time ==0 
bysort unique: replace time = _n - 1	 
		
*Create 2 copies of each subject, and set outcome to missing and treatment -- use only the newobs*
expand 2 , generate(interv) 
replace qsmk = interv	