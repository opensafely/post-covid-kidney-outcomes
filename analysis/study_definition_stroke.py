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
        (sex = "M" OR sex = "F")
        AND NOT deceased = "1"
        AND incident_stroke = "1"
        """,
    ),  

    index_date="2017-02-01",

    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    #Exclude all people who died before 2017-02-01
    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between = ["1970-01-01", "index_date"],
        return_expectations={"incidence": 0.10, "date": {"earliest" : "2015-02-01", "latest": "2020-01-31"}},
        ),
    incident_stroke=patients.admitted_to_hospital(
        with_these_diagnoses=incident_stroke_codes,
        returning="binary_flag",
        between = ["1970-01-01", "2023-01-31"],
        return_expectations={"incidence": 0.05},
    ),
    incident_stroke_date=patients.admitted_to_hospital(
        with_these_diagnoses=incident_stroke_codes,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        between = ["1970-01-01", "2023-01-31"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest" : "2017-02-01", "latest": "2020-01-31"}}
    ),
)