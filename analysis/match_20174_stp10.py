import pandas as pd
from osmatching import match

match(
    case_csv="input_covid_matching_20174_stp10",
    match_csv="input_20174_matching_stp10",
    matches_per_case=5,
    match_variables={
        "male": "category",
        "age": 0,
    },
    index_date_variable="covid_date",
    replace_match_index_date_with_case="3_years_earlier",
    date_exclusion_variables={
        "death_date": "before",
        "date_deregistered": "before",
        "krt_outcome_date": "before",
    },
    output_suffix="_20174_4stp10",
    output_path="output",
)