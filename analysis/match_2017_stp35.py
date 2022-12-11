import pandas as pd
from osmatching import match

match(
    case_csv="input_covid_matching_2017_stp35",
    match_csv="input_2017_matching_stp35",
    matches_per_case=3,
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
    output_suffix="_2017_stp35",
    output_path="output",
)