from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists
)

from codelists import *

COVID = "output/input_combined_stps_covid_2017.csv"

from variables_covid import generate_covid
variables_covid= generate_covid(index_date_variable="case_index_date")

from variables_covariates import generate_covariates
variables_covariates= generate_covariates(index_date_variable="case_index_date")

from variables_outcomes_2020 import generate_outcomes_2020
variables_outcomes_2020= generate_outcomes_2020(index_date_variable="case_index_date")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence" : 0.2
    },
    population=patients.which_exist_in_file(COVID), 
    #Start of observation period (note, needs to be called index date)
    index_date="2020-02-01",
    case_index_date=patients.with_value_from_file(
        COVID, 
        returning="covid_date", 
        returning_type="date"), 

    **variables_covid,
    **variables_covariates,  
    **variables_outcomes_2020,  
) 
