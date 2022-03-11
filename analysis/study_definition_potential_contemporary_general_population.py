#study_definition_potential_contemporary_general_population will be matched to 
    #study_definition_covid_all_for_matching

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - covid_diagnosis_date (from match_contemporary based on study_definition_covid_all_for_matching)

#Exclusion variables (see match_contemporary):
# - renal_replacement_therapy before covid_diagnosis_date
# - died_date_gp before covid_diagnosis_date

#People with eGFR <15 on 2020-02-01 will be excluded but anyone with eGFR <15 between 2020-02-01
    # and covid_diagnosis_date will need to be excluded after cohort extraction

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

from common_variables import generate_common_variables

(
    demographic_variables,
) = generate_common_variables(index_date_variable="covid_diagnosis_date")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.98, #increased incidence to 0.98 
    },

    index_date="2018-02-01",

    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date"
        ),
    
    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT stp = ""
        AND NOT egfr_below_15_february_2020 = "1"
        """,
        ),

