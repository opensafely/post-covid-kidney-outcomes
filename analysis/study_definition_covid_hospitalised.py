from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    filter_codes_by_category,
    codelist_from_csv,
)

from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
    },

    population=patients.satisfying(
        """
        has_follow_up
        AND index_date
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND NOT stp = ""
        AND NOT deceased = "1"
        AND NOT baseline_krt_primary_care = "1"
        AND NOT baseline_krt_icd_10 = "1"
        AND NOT baseline_krt_opcs_4 = "1"
        """,
    ),

    index_date=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-10-31"],
        return_expectations={"incidence": 0.1, "date": {"earliest": "2020-02-01"}},
    ),
    end_date = "2022-11-30",

    age=patients.age_as_of(
       "index_date",
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
    stp=patients.registered_practice_as_of(
        "index_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "STP1": 1.0,
                    }
                },
            },
        ),
    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "index_date + 28 days"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "index_date - 3 years", "latest": "index_date + 28 days"}},
        ),
    baseline_krt_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["1970-01-01", "index_date - 1 day"],
        returning="binary_flag",
        return_expectations = {"incidence": 0.05},
    ),
    baseline_krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between = ["1970-01-01", "index_date - 1 day"],
        return_expectations={"incidence": 0.05},
    ),
    baseline_krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between = ["1970-01-01", "index_date - 1 day"],
        return_expectations={"incidence": 0.05},
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "index_date - 3 months", "index_date + 28 days",
        return_expectations={"incidence":0.95,
    }
    ),
    imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=0 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },

    ),
)