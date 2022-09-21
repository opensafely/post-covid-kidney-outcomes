cap log close
log using ./logs/contemporary_matching_variables_stp5, replace t
clear

import delimited ./output/input_covid_matching_stp5.csv, delimiter(comma) varnames(1) case(preserve) 

tab male, m
tab year_of_birth, m
tab imd, m

save ./output/covid_matching_variables_stp5.dta, replace 

clear

import delimited ./output/input_contemporary_matching_stp5.csv, delimiter(comma) varnames(1) case(preserve)
 
tab male, m
tab year_of_birth, m
tab imd, m

save ./output/contemporary_matching_variables_stp5.dta, replace

log close