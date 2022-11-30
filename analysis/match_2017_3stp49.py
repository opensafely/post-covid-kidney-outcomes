import pandas as pd
from osmatching import match

match(
    case_csv="input_covid3_matching_2017_stp49",
    match_csv="input_2017_matching_stp49",
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
    output_suffix="_2017_3stp49",
    output_path="output",
)