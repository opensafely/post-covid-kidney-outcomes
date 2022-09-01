#study_definition_contemporary_stp24_matching will be matched to 
    #study_definition_covid_stp24_matching (restricted to STP24)

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
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
    },

    population=patients.satisfying(
        """
        has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd >= 0
        AND stp = "STP24"
        AND NOT deceased = "1"
        AND NOT baseline_krt_primary_care = "1"
        AND NOT baseline_krt_icd_10 = "1"
        AND NOT baseline_krt_opcs_4 = "1"
        """,
    ),  

    index_date="2020-02-01",

#Matching variables
    year_of_birth=patients.date_of_birth(
        date_format= "YYYY", 
        return_expectations={
            "date": {"earliest": "1950-01-01", "latest": "2000-01-01"},
            "rate": "uniform",
            "incidence": 1,
        },
    ),
    age=patients.age_as_of(
        "2020-01-31",
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
                },
            },
        },
    ),
    stp=patients.registered_practice_as_of(
        "index_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "STP1": 1,
                    }
                },
            },
        ),

#Exclusion variables

    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2020-02-01", "latest": "2022-01-31"}},
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
    baseline_creatinine_feb2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-08-01","2020-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "2019-10-31", "2022-01-31",
        return_expectations={"incidence":0.95},
    ),
)