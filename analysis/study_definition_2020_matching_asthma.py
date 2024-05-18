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
        "date": {"earliest": "1980-01-01", "latest": "2023-01-31"},
        "rate": "uniform",
        "incidence": 0.7, 
    },

    population=patients.satisfying(
        """
        has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND NOT stp = ""
        AND NOT deceased = "1"
        AND NOT baseline_krt_primary_care = "1"
        AND NOT baseline_krt_icd_10 = "1"
        AND NOT baseline_krt_opcs_4 = "1"
        AND NOT previous_cabg = "1"
        AND NOT previous_angio = "1"
        """,
    ),  

    index_date="2020-02-01",

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

    sgss_positive_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-12-31"],
        return_expectations={"incidence": 0.4, "date": {"earliest": "2020-02-01"}},
    ),
    
    primary_care_covid_date=patients.with_these_clinical_events(
        any_covid_primary_care_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-12-31"],
        return_expectations={"incidence": 0.2, "date": {"earliest": "2020-02-01"}},
    ),

    hospital_covid_date=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-12-31"],
        return_expectations={"incidence": 0.1, "date": {"earliest": "2020-02-01"}},
    ),

#Coronary procedures as control exposure

    cabg_diagnosis_date=patients.admitted_to_hospital(
        with_these_procedures=cabg_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-12-31"],
        return_expectations={"incidence": 0.1, "date": {"earliest": "2020-02-01"}},
    ),

   angio_diagnosis_date=patients.admitted_to_hospital(
        with_these_procedures=angio_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-12-31"],
        return_expectations={"incidence": 0.1, "date": {"earliest": "2020-02-01"}},
    ),
    covid_diagnosis_date=patients.minimum_of(
        "cabg_diagnosis_date", "angio_diagnosis_date",
    ),
    
    sars_cov_2=patients.categorised_as(
        {
        "0": "DEFAULT",
        "SARS-COV-2": 
            """
            covid_diagnosis_date
            """,
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "SARS-COV-2": 0.7,
                    "0": 0.3,
                }
            },
        },
    ),
    #Exclude all people who died before 2020-02-01

    previous_cabg=patients.admitted_to_hospital(
        with_these_procedures=cabg_codes,
        returning="binary_flag",
        between = ["1970-01-01", "2020-01-31"],
        return_expectations={"incidence": 0.05},
    ),
    previous_angio=patients.admitted_to_hospital(
        with_these_procedures=angio_codes,
        returning="binary_flag",
        between = ["1970-01-01", "2020-01-31"],
        return_expectations={"incidence": 0.05},
    ),
    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2020-02-01", "latest": "2020-01-31"}},
        ),
    #Obtain date of death for those who remain alive at 2020-02-01
    death_date=patients.with_death_recorded_in_primary_care(
        between = ["index_date", "2023-01-31"],
        returning="date_of_death",
        date_format= "YYYY-MM-DD",
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2020-02-01", "latest": "2023-01-31"}},
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
    krt_outcome_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["index_date", "2023-01-31"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2023-01-31"}}
    ),
    krt_outcome_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["index_date", "2023-01-31"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2023-01-31"}}
    ),
    krt_outcome_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["index_date", "2023-01-31"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2023-01-31"}}
    ),
    krt_outcome_date=patients.minimum_of(
        "krt_outcome_primary_care", "krt_outcome_icd_10", "krt_outcome_opcs_4",
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "2022-10-31", "index_date",
        return_expectations={"incidence":0.95},
    ),
    date_deregistered=patients.date_deregistered_from_all_supported_practices(
        between= ["2020-02-01", "2023-01-31"],
        date_format="YYYY-MM-DD",
    ),
)