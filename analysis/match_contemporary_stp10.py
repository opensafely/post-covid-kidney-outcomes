#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#Individuals extracted from study_definition_covid_stp10 will be matched to individuals from 
    #study_definition_contemporary_general_population_stp10

#https://github.com/opensafely-core/matching#readme:
import pandas as pd
from osmatching import match

match(
    case_csv="covid_stp01_matching",
    match_csv="contemporary_stp10_matching",
    matches_per_case=5,
    match_variables={
        "male": "category",
        "year_of_birth": 0,
        "imd": "category",
    },
    index_date_variable="covid_date",
    replace_match_index_date_with_case="no_offset",
    output_suffix="_contemporary_stp10",
    output_path="output",
)