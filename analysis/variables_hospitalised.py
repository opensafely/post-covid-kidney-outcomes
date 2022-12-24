from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_hospitalised(index_date_variable, end_date_variable):
    variables_hospitalised = dict(       
    critical_care=patients.admitted_to_hospital(
        with_these_procedures=critical_care_codes,
        returning="binary_flag",
        between = [f"{index_date_variable}", f"{index_date_variable} + 28 days"],
        return_expectations={"incidence": 0.05, "date": {"earliest" : f"{index_date_variable}", "latest": f"{index_date_variable} + 28 days"}},
    ),
    )
    return variables_hospitalised