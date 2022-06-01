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

#Exclusion variables (see match_historical and match_contemporary):
# - kidney_replacement_therapy before covid_diagnosis_date
# - died_date_gp before covid_diagnosis_date

#People with eGFR <15 on 2020-02-01 will be excluded but anyone with eGFR <15 between 2020-02-01
    # and covid_diagnosis_date will need to be excluded after cohort extraction

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
from common_variables import common_variables

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
            #Is this the incidence of COVID? 
            #How does this interact with the incidence of #sgss_positive, primary_care_covid and hospital_covid (each 0.1)?
    },

    index_date="2020-02-01",  

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
    #    AND NOT egfr_below_15_february_2020 = "1"

    sgss_positive=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
        return_expectations={"incidence": 0.4, "date": {"earliest": "index_date"}},
    ),
    
    primary_care_covid=patients.with_these_clinical_events(
        any_covid_primary_care_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
        return_expectations={"incidence": 0.2, "date": {"earliest": "index_date"}},
    ),

    hospital_covid=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        on_or_before="2022-01-31",
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),
    
    covid_diagnosis_date=patients.minimum_of(
        "sgss_positive", "primary_care_covid", "hospital_covid",
    ),
       
    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date",
        return_expectations={"incidence":0.95,
    }
    ),

**common_variables
)