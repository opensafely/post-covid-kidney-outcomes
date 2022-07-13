#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#Individuals extracted from study_definition_covid_england will be matched to individuals from 
    #study_definition_contemporary_general_population (Template only - matching will be undertaken region by region)

#https://github.com/opensafely-core/matching#readme:
from osmatching import match

match(
    case_csv="input_covid_england",
    match_csv="input_potential_contemporary_population_england",
    matches_per_case=5,
    match_variables={
        "sex": "category",
        "age": 1,
        "stp": "category",
        "imd": "category",
        "covid_diagnosis_date": "no_offset", #i.e. exactly the same date
    },
    index_date_variable="covid_diagnosis_date",
    closest_match_variables=["age"],
    date_exclusion_variables={
        "kidney_replacement_therapy_date": "before",
        "died_date_gp": "before",
    },
    output_suffix="_contemporary",
    output_path="test_data",
)