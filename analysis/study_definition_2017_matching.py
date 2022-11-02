#study_definition_2017_matching will be matched to 
    #study_definition_covid_matching

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd

#Exclusion characteristics:
# - kidney_replacement_therapy on or before 2022-01-31
# - eGFR <15 on or before 2022-01-31
# - deceased on or before 2022-01-31

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
        "date": {"earliest": "1980-01-01", "latest": "2019-09-30"},
        "rate": "uniform",
        "incidence": 0.7, 
    },

    population=patients.satisfying(
        """
        has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT deceased = "1"
        AND NOT baseline_krt_primary_care = "1"
        AND NOT baseline_krt_icd_10 = "1"
        AND NOT baseline_krt_opcs_4 = "1"
        """,
    ),  

    index_date="2017-02-01",

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
    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2017-02-01", "latest": "2022-01-31"}},
        ),
    death_date=patients.with_death_recorded_in_primary_care(
        between = ["index_date", "2019-09-30"],
        returning="date_of_death",
        date_format= "YYYY-MM-DD",
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2017-02-01", "latest": "2019-09-30"}},
    ),
    baseline_krt_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["1970-01-01", "index_date"],
        returning="binary_flag",
        return_expectations = {"incidence": 0.05},
    ),
    baseline_krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.05},
    ),
    baseline_krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.05},
    ),
    baseline_creatinine_feb2017=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2015-08-01","2017-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    krt_outcome_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["index_date", "2019-09-30"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2017-02-01", "latest": "2019-09-30"}}
    ),
    krt_outcome_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["index_date", "2019-09-30"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2017-02-01", "latest": "2019-09-30"}}
    ),
    krt_outcome_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["index_date", "2019-09-30"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2017-02-01", "latest": "2019-09-30"}}
    ),
    krt_outcome_date=patients.minimum_of(
        "krt_outcome_primary_care", "krt_outcome_icd_10", "krt_outcome_opcs_4",
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "2016-10-31", "index_date",
        return_expectations={"incidence":0.95},
    ),
    date_deregistered=patients.date_deregistered_from_all_supported_practices(
        between= ["2017-02-01", "2019-09-30"],
        date_format="YYYY-MM-DD",
    ),
)