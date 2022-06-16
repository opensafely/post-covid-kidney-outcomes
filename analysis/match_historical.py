#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#Individuals extracted from study_definition_covid_all_for_matching will be matched to individuals from 
    #study_definition_potential_historical_general_population

#Exclusions:
#kidney_replacement_therapy_date
#died_date_gp

#5 individuals will then be matched based on:
    # age (within 1 year),
    # sex
    # stp
    # imd (decile)
    # covid_diagnosis_date & covid_diagnosis_date_minus_2_years

#https://github.com/opensafely-core/matching#readme:
from osmatching import match

match(
    case_csv="input_covid_all_for_matching",
    match_csv="input_potential_historical_general_population",
    matches_per_case=5,
    match_variables={
        "sex": "category",
        "age": 1,
        "stp": "category",
        "imd": "category",
        "covid_diagnosis_date_minus_2_years": "2_years_earlier",
    },
    index_date_variable="covid_diagnosis_date",
    closest_match_variables=["age"],
    date_exclusion_variables={
        "kidney_replacement_therapy_date": "before",
        "died_date_gp": "before",
    },
    output_suffix="_historical",
    output_path="test_data",
)