#https://5b5368c1.opensafely-docs.pages.dev/case-control-studies/
#https://github.com/opensafely/documentation/pull/522

#Individuals extracted from covid_all_for_matching will be matched to individuals from 
# both potential_historical_general_population and potential_contemporary_general population. 

#Matching with potential_historical_general_population
#Anyone who has i) died or ii) has a code for dialysis or kidney transplant or with eGFR <15 
# before exactly 2 years before covid_diagnosis_date will be excluded
#5 individuals will then be matched based on age (within 2 years), sex, STP, IMD decile
# and date 2 years before covid_diagnosis_date
# => matched_historical_general_population

#Matching with potential_contemporary_general_population
#Anyone who has i) died or ii) has a code for dialysis or kidney transplant or with eGFR <15 
# before covid_diagnosis_date will be excluded
#5 individuals will then be matched based on age (within 2 years), sex, STP, IMD decile and covid_diagnosis_date
# => matched_contemporary_general_population


#https://github.com/opensafely-core/matching#readme:
from osmatching import match

match(
    case_csv="input_covid",
    match_csv="input_historical_general_population",
    matches_per_case=5,
    match_variables={
        "sex": "category",
        "age": 1,
        "stp": "category",
        "indexdate": "month_only",
    },
    index_date_variable="indexdate",
    closest_match_variables=["age"],
    date_exclusion_variables={
        "died_date_ons": "before",
        "previous_vte_gp": "before",
        "previous_vte_hospital": "before",
        "previous_stroke_gp": "before",
        "previous_stroke_hospital": "before",
    },
    output_suffix="_pneumonia",
    output_path="test_data",
)