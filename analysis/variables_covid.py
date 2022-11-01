#https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py
from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_covid(index_date_variable):
    variables_covid = dict(       
    covid_hospitalised=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.1, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_critical_care=patients.admitted_to_hospital(
        with_these_procedures=critical_care_codes,
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_critical_days=patients.admitted_to_hospital(
        with_at_least_one_day_in_critical_care=True,
        between= ["case_index_date", "case_index_date + 28 days"],
        return_expectations = {"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_acute_kidney_injury=patients.admitted_to_hospital(
        with_these_diagnoses=acute_kidney_injury_codes,
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_death=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["case_index_date", "case_index_date + 28 days"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
    ),
    covid_vax_1_date = patients.with_tpp_vaccination_record(
        target_disease_matches = "SARS-2 CORONAVIRUS",
        returning = "date",
        find_first_match_in_period = True,
        between = ["2020-11-01", "case_index_date - 7 days"],
        date_format = "YYYY-MM-DD",
        return_expectations = {
        "date": {
            "earliest": "2020-12-08",
            "latest": "2022-09-30",
        }
        },
    ),
    covid_vax_2_date = patients.with_tpp_vaccination_record(
        target_disease_matches = "SARS-2 CORONAVIRUS",
        returning = "date",
        find_first_match_in_period = True,
        between = ["covid_vax_1_date + 15 days", "case_index_date - 7 days"],
        date_format = "YYYY-MM-DD",
        return_expectations = {
        "date": {
            "earliest": "2020-12-31",
            "latest": "2022-09-30",
        }
        },
    ),
    covid_vax_3_date = patients.with_tpp_vaccination_record(
        target_disease_matches = "SARS-2 CORONAVIRUS",
        returning = "date",
        find_first_match_in_period = True,
        between = ["covid_vax_2_date + 15 days", "case_index_date - 7 days"],
        date_format = "YYYY-MM-DD",
        return_expectations = {
        "date": {
            "earliest": "2021-03-31",
            "latest": "2022-09-30",
        }
        },
    ),
    covid_vax_4_date = patients.with_tpp_vaccination_record(
        target_disease_matches = "SARS-2 CORONAVIRUS",    
        returning = "date",
        find_first_match_in_period = True,
        between = ["covid_vax_3_date + 15 days", "case_index_date - 7 days"],
        date_format = "YYYY-MM-DD",
        return_expectations = {
        "date": {
            "earliest": "2021-04-30",
            "latest": "2022-09-30",
        }
        },
    ),
    )
    return variables_covid