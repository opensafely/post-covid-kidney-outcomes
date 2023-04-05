from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists
)

from codelists import *

MATCHES = "output/input_combined_stps_matches_2020.csv"

from variables_covariates_2020 import generate_covariates_2020
variables_covariates_2020= generate_covariates_2020(index_date_variable="case_index_date")

from variables_outcomes_2020 import generate_outcomes_2020
variables_outcomes_2020= generate_outcomes_2020(index_date_variable="case_index_date")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "2022-11-30"},
        "rate": "uniform",
        "incidence" : 0.2
    },
    population=patients.which_exist_in_file(MATCHES), 
    #Start of observation period (note, needs to be called index date)
    index_date="2020-02-01",
    case_index_date=patients.with_value_from_file(
        MATCHES, 
        returning="covid_date", 
        returning_type="date"), 

    **variables_covariates_2020,  
    **variables_outcomes_2020,  
) 
