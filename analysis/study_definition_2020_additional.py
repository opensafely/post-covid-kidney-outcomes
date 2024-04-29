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
        "date": {"earliest": "1900-01-01", "latest": "2022-12-31"},
        "rate": "uniform",
        "incidence" : 0.2
    },
    population=patients.which_exist_in_file(MATCHES), 
    #Start of observation period (note, needs to be called index date)
    index_date="2017-02-01",
    case_index_date=patients.with_value_from_file(
        MATCHES, 
        returning="covid_date", 
        returning_type="date"),
    
    #covid_vax_1_date = patients.with_tpp_vaccination_record(
        #target_disease_matches = "SARS-2 CORONAVIRUS",
        #returning = "date",
        #find_first_match_in_period = True,
        #between = ["2020-11-01", "case_index_date - 7 days"],
        #date_format = "YYYY-MM-DD",
        #return_expectations = {
        #"date": {
            #"earliest": "2020-12-08",
            #"latest": "2022-12-31",
        #}
        #},
    #),
    #covid_vax_2_date = patients.with_tpp_vaccination_record(
        #target_disease_matches = "SARS-2 CORONAVIRUS",
        #returning = "date",
        #find_first_match_in_period = True,
        #between = ["covid_vax_1_date + 15 days", "case_index_date - 7 days"],
        #date_format = "YYYY-MM-DD",
        #return_expectations = {
        #"date": {
            #"earliest": "2020-12-31",
            #"latest": "2022-12-31",
        #}
        #},
    #),
    #covid_vax_3_date = patients.with_tpp_vaccination_record(
        #target_disease_matches = "SARS-2 CORONAVIRUS",
        #returning = "date",
        #find_first_match_in_period = True,
        #between = ["covid_vax_2_date + 15 days", "case_index_date - 7 days"],
        #date_format = "YYYY-MM-DD",
        #return_expectations = {
        #"date": {
            #"earliest": "2021-03-31",
            #"latest": "2022-12-31",
        #}
        #},
    #),
    #covid_vax_4_date = patients.with_tpp_vaccination_record(
        #target_disease_matches = "SARS-2 CORONAVIRUS",    
        #returning = "date",
        #find_first_match_in_period = True,
        #between = ["covid_vax_3_date + 15 days", "case_index_date - 7 days"],
        #date_format = "YYYY-MM-DD",
        #return_expectations = {
        #"date": {
            #"earliest": "2021-04-30",
            #"latest": "2022-12-31",
        #}
        #},
    #),

    **variables_covariates_2020,  
    **variables_outcomes_2020,  
) 
