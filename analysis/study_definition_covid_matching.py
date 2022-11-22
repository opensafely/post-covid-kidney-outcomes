#Study defintion for people with COVID-19 to be matched to contemporary and historical comparators

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - covid_diagnosis_date + 28 days

#Exclusion variables:
# - ESRD before covid_diagnosis_date
# - deceased before covid_diagnosis_date

#Note:
# - Variables will be extracted at covid_diagnosis_date
# - Matching and follow-up will commence at 28 days after covid_diagnosis_date

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
        AND NOT stp = ""
        AND NOT sars_cov_2 = "0"
        AND NOT deceased = "1"
        AND NOT baseline_krt_primary_care = "1"
        AND NOT baseline_krt_icd_10 = "1"
        AND NOT baseline_krt_opcs_4 = "1"
        """,
    ),

#Matching variables
    age=patients.age_as_of(
       "2020-02-01",
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
        "2020-02-01",
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

#Exposure - SARS-CoV-2 infection

    sgss_positive_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-09-30"],
        return_expectations={"incidence": 0.4, "date": {"earliest": "2020-02-01"}},
    ),
    
    primary_care_covid_date=patients.with_these_clinical_events(
        any_covid_primary_care_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-09-30"],
        return_expectations={"incidence": 0.2, "date": {"earliest": "2020-02-01"}},
    ),

    hospital_covid_date=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        between = ["2020-02-01", "2022-09-30"],
        return_expectations={"incidence": 0.1, "date": {"earliest": "2020-02-01"}},
    ),
    
    covid_diagnosis_date=patients.minimum_of(
        "sgss_positive_date", "primary_care_covid_date", "hospital_covid_date",
    ),

    sars_cov_2=patients.categorised_as(
        {
        "0": "DEFAULT",
        "SARS-COV-2": 
            """
            primary_care_covid_date
            OR sgss_positive_date
            OR hospital_covid_date
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

#Exclusion variables

    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "covid_diagnosis_date + 28 days"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2020-02-01", "latest": "2022-09-30"}},
        ),
    death_date=patients.with_death_recorded_in_primary_care(
        between = ["2020-02-01", "2022-09-30"],
        returning="date_of_death",
        date_format= "YYYY-MM-DD",
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2018-02-01", "latest": "2022-09-30"}},
    ),
    baseline_krt_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["1970-01-01", "covid_diagnosis_date"],
        returning="binary_flag",
        return_expectations = {"incidence": 0.05},
    ),
    baseline_krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between = ["1970-01-01", "covid_diagnosis_date"],
        return_expectations={"incidence": 0.05},
    ),
    baseline_krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between = ["1970-01-01", "covid_diagnosis_date"],
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
    baseline_creatinine_mar2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-09-01","2020-02-29"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-10-01","2020-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-11-01","2020-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-12-01","2020-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-01-01","2020-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-02-01","2020-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-03-01","2020-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_oct2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-04-01","2020-09-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_nov2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-05-01","2020-10-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_dec2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-06-01","2020-11-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jan2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-07-01","2020-12-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_feb2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-08-01","2021-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_mar2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-09-01","2021-02-28"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-10-01","2021-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-11-01","2021-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-12-01","2021-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-01-01","2021-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-02-01","2021-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-03-01","2021-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_oct2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-04-01","2021-09-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_nov2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-05-01","2021-10-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_dec2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-06-01","2021-11-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jan2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-07-01","2021-12-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_feb2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-08-01","2022-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_mar2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-09-01","2022-02-28"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-10-01","2022-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-11-01","2022-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-12-01","2022-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-01-01","2022-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-02-01","2022-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-03-01","2022-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    krt_outcome_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between = ["2020-02-01", "2022-09-30"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-09-30"}}
    ),
    krt_outcome_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["2020-02-01", "2022-09-30"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-09-30"}}
    ),
    krt_outcome_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["2020-02-01", "2022-09-30"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-09-30"}}
    ),
    krt_outcome_date=patients.minimum_of(
        "krt_outcome_primary_care", "krt_outcome_icd_10", "krt_outcome_opcs_4",
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date",
        return_expectations={"incidence":0.95,
    }
    ),
    date_deregistered=patients.date_deregistered_from_all_supported_practices(
        between= ["2020-02-01", "2022-09-30"],
        date_format="YYYY-MM-DD",
    ),

)