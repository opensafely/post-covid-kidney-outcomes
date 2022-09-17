#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#https://github.com/opensafely-core/matching#readme:
import pandas as pd
from osmatching import match

match(
    case_csv="input_covid_matching_stp25",
    match_csv="input_contemporary_matching_stp25",
    matches_per_case=5,
    match_variables={
        "male": "category",
        "year_of_birth": 0,
        "imd": "category",
    },
    index_date_variable="covid_date",
    replace_match_index_date_with_case="no_offset",
    output_suffix="_contemporary_stp25",
    output_path="output",
)