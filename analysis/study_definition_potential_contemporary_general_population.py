#potential_contemporary_general_population will be matched to covid_all_for_matching

#Only matching variables (demographic_variables) and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - patient_index_date (using sgss_positive, primary_care_covid or hospital_covid) from covid_all_for_matching

#Exclusion variables:
# - esrd
# - died_before_patient_index_date_minus_two_years (using patient_died_date_gp)

#Note:
# - Variables will be extracted at covid_diagnosis_date_minus_2_years
# - Matching and follow-up will commence at patient_index_date_minus_2_years

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
        AND NOT stp = ""
        AND NOT died_before_patient_index_date
        AND NOT end_stage_renal_disease
        """,
        has_follow_up=patients.registered_with_one_practice_between(
            "covid_diagnosis_date - 3 months", "covid_diagnosis_date"
#If covid_diagnosis_date is not in common_variables - will this still get picked up?
        ),
    ),
    index_date="2020-02-01",

    ),
