from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

# https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py

def generate_common_variables(index_date_variable):
    common_variables = dict(
        deregistered=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD"
        ),
        # Outcomes
        # History of outcomes - https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py (looked for recent history of outcomes)
        # Primary outcome - ESRD
        esrd_gp=patients.with_these_clinical_events(
            filter_codes_by_category(esrd_codes_gp, include["esrd"]),
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD"
            on_or_after=f"{index_date_variable} + 1 days",
            return_expectations={"date": "index_date"}},
        ),
        esrd_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=filter_codes_by_category(
                esrd_codes_hospital, include["esrd"]),
            ),
            on_or_after=f"{index_date_variable} + 1 days",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "index_date"}},
        ),
        #Secondary outcomes
        # 50% reduction in eGFR - need to extract first eGFR measurement each calendar month not within 14 days of a hospital admission
            creatinine=patients.with_these_clinical_events(
            creatinine_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable}",
            returning="numeric_value",
            include_date_of_match=True,
            include_month=True,
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
                "date": {"earliest": "2016-08-01", "latest": "2022-02-01"},
                "incidence": 0.95,
            },
        ),
        #Will need to create separate monthly codes? How to exclude measurements proximal to hospital admissions?
            creatinine082016=patients.with_these_clinical_events(
            creatinine_codes
            find_first_match_in_period=True,
            between=("2016-08-01", "2016-08-31"),
            returning="numeric_value",
            include_date_of_match=True,
            include_month=True,
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stdev": 15},
                "date": {"earliest": "2016-08-01", "latest": "2016-08-31"},
                "incidence": 0.01,
            },
        ),

        # Acute kidney injury - post-covid-outcomes included AKI from GP & ONS as well
        aki=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=aki_codes,
            on_or_after=f"{index_date_variable} + 1 days",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "index_date"}},
        ),
        # Death - GP only (not ONS as not available for linkage before 2019)
        death=patients.with_these_clinical_events(
            filter_codes_by_category(death_codes_gp, include["death"]),
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD"
            on_or_after=f"{index_date_variable} + 1 days",
            return_expectations={"date": "index_date"}},
        ),
        
        #Covariables            
        age=patients.age_as_of(
            f"{index_date_variable}",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.51}},
            }
        ),
        ethnicity=patients.with_these_clinical_events(
            ethnicity_codes,
            returning="category",
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable}",
            return_expectations={
                "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
                "incidence": 0.75,
            },
        ),
        practice_id=patients.registered_practice_as_of(
            "index_date",
            returning="pseudo_id",
            return_expectations={
                "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
                "incidence": 1,
            },
        ),
        stp=patients.registered_practice_as_of(
            "index_date",
            returning="stp_code",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "STP1": 0.1,
                        "STP2": 0.1,
                        "STP3": 0.1,
                        "STP4": 0.1,
                        "STP5": 0.1,
                        "STP6": 0.1,
                        "STP7": 0.1,
                        "STP8": 0.1,
                        "STP9": 0.1,
                        "STP10": 0.1,
                    }
                },
            },
        ),
        region=patients.registered_practice_as_of(
            "index_date",
            returning="nuts1_region_name",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "North East": 0.1,
                        "North West": 0.1,
                        "Yorkshire and The Humber": 0.1,
                        "East Midlands": 0.1,
                        "West Midlands": 0.1,
                        "East": 0.1,
                        "London": 0.2,
                        "South East": 0.1,
                        "South West": 0.1,
                    },
                },
            },
        ),
        imd=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "100": 0.1,
                        "200": 0.1,
                        "300": 0.1,
                        "400": 0.1,
                        "500": 0.1,
                        "600": 0.1,
                        "700": 0.1,
                        "800": 0.1,
                        "900": 0.1,
                        "1000": 0.1,
                    }
                },
            },
        ),
        af=patients.with_these_clinical_events(
            af_codes,
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.05},
        ),
        anticoag_rx=patients.with_these_medications(
            combine_codelists(doac_codes, warfarin_codes),
            between=[f"{index_date_variable} - 3 months", f"{index_date_variable}"],
            return_expectations={
                "date": {
                    "earliest": "index_date - 3 months",
                    "latest": "index_date",
                }
            },
        ),
        ),
        esrd=patients.with_these_clinical_events(
            esrd_codes,
            on_or_before=f"{index_date_variable}",
            return_first_date_in_period=True,
            include_month=True,
        ),
    )
    return common_variables