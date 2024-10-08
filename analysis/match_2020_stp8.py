import pandas as pd
from osmatching import match

match(
    case_csv="input_covid_matching_2020_stp8",
    match_csv="input_2020_matching_stp8",
    matches_per_case=3,
    match_variables={
        "male": "category",
        "age": 0,
    },
    index_date_variable="covid_date",
    replace_match_index_date_with_case="no_offset",
    date_exclusion_variables={
        "death_date": "before",
        "date_deregistered": "before",
        "krt_outcome_date": "before",
        "covid_diagnosis_date": "before",
    },
    output_suffix="_2020_stp8",
    output_path="output",
)