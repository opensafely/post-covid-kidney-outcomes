#covid_all_for matching will be matched to potential_contemporary_general_population and potential_historical_general_population

#Only matching variables (demographic_variables) and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - patient_index_date (using sgss_positive, primary_care_covid or hospital_covid)

#Exclusion variables:
# - esrd
# - died_before_patient_index_date (using patient_died_date_gp)

#Note:
# - Variables will be extracted at covid_diagnosis_date
# - Matching and follow-up will commence at patient_index_date

from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    filter_codes_by_category, #(from OS documentation)
    codelist_from_csv,
)

from codelists import *

from common_variables import generate_common_variables

(
    demographic_variables,
) = generate_common_variables(index_date_variable="patient_index_date")
#What is the purpose of demographic_variables here?

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, #incidence of?
    },
    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT covid_classification = "0"
        AND NOT stp = ""
        AND NOT died_before_patient_index_date
        AND NOT end_stage_renal_disease
        """,
        has_follow_up=patients.registered_with_one_practice_between(
            "covid_diagnosis_date - 3 months", "covid_diagnosis_date"
        ),
    ),

    index_date="2020-02-01",
    
    #SARS-CoV_2 infection:
    sgss_positive=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),
    primary_care_covid=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),
    hospital_covid=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),
        covid_diagnosis_date=patients.minimum_of(
        "sgss_positive", "primary_care_covid", "hospital_covid"
    ),