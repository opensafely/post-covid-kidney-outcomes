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

 


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, 
            #Is this the incidence of COVID? 
            #How does this interact with the incidence of #sgss_positive, primary_care_covid and hospital_covid (each 0.1)?
    },

    has_follow_up=patients.registered_with_one_practice_between(
        "index_date - 3 months", "index_date"
        ),

    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT sars_cov_2 = "0"
        AND NOT stp = ""
        AND NOT egfr_below_15_february_2020 = "1"
        """,
        ),

