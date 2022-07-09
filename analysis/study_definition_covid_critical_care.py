#To compare critical care procedure codelist with SUS critical care flag

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
        AND imd > 0
        AND NOT sars_cov_2 = "0"
        AND NOT stp = ""
        AND NOT covid_hospitalised ="0"
        """,
    ),  

    sgss_positive_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
        return_expectations={"incidence": 0.4, "date": {"earliest": "2020-02-01"}},
    ),
    
    primary_care_covid_date=patients.with_these_clinical_events(
        any_covid_primary_care_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
        return_expectations={"incidence": 0.2, "date": {"earliest": "2020-02-01"}},
    ),

    hospital_covid_date=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
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

    covid_hospitalised=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="binary_flag",
        find_first_match_in_period = True,
        between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
        return_expectations={"incidence": 0.2, "date": {"earliest" : "2020-02-01", "latest": "2022-06-30"}},
    ),
    covid_critical_care_procedures=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        with_these_procedures=critical_care_codes,
        returning="binary_flag",
        find_first_match_in_period = True,
        between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2020-02-01", "latest": "2022-06-30"}},
    ),
    covid_critical_care_flag=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="days_in_critical_care",
        find_first_match_in_period = True,
        between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
        return_expectations = {
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.2,
        },
    ),
    
    age=patients.age_as_of(
        "covid_diagnosis_date",
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
        "covid_diagnosis_date",
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
        "covid_diagnosis_date",
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
        "covid_diagnosis_date",
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

    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        on_or_before="covid_diagnosis_date",
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),


    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date",
        return_expectations={"incidence":0.95,
    }
    ),
)