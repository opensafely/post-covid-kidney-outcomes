#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#Individuals extracted from study_definition_covid_northeast will be matched to individuals from 
    #study_definition_contemporary_general_population_northeast

#https://github.com/opensafely-core/matching#readme:
from osmatching import match

match(
    case_csv="input_covid_northeast",
    match_csv="input_potential_contemporary_population_northeast",
    matches_per_case=5,
    match_variables={
        "sex": "category",
        "age": 1,
        "stp": "category",
        "imd": "category",
        "covid_date": "no_offset", #i.e. exactly the same date
    },
    index_date_variable="covid_date",
    closest_match_variables=["age"],
    date_exclusion_variables={
        "krt_incident_date": "before",
        "deceased": "before",
    },
    output_suffix="_contemporary",
    output_path="output",
)