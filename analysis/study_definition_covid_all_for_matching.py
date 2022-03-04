#study_definition_covid_all_for matching will be matched to
    #study_definition_potential_historical_general_population
    #and study_definition_potential_contemporary_general_population

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - patient_index_date (using sgss_positive, primary_care_covid or hospital_covid)

#Exclusion variables:
# - end_stage_renal_disease
# - died_date_gp

#Note:
# - Variables will be extracted at covid_diagnosis_date
# - Matching and follow-up will commence at patient_index_date (i.e. 28 days after covid_diagnosis_date)

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
#What is the purpose of demographic_variables here?

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
            #Is this the incidence of COVID? 
            #How does this interact with the incidence of #sgss_positive, primary_care_covid and hospital_covid (each 0.1)?
    },
    
    index_date="2020-02-01",

    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date"
        ),

    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT sars_cov_2 = "0"
        AND NOT stp = ""
        """,
        ),

