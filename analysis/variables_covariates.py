#https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py
from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_covariates(index_date_variable):
    variables_covariates = dict(
    practice_id=patients.registered_practice_as_of(
        "case_index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 25, "stddev": 5},
            "incidence": 0.5,
        },
    ),
    year_of_birth=patients.date_of_birth(
        date_format= "YYYY", 
        return_expectations={
            "date": {"earliest": "1950-01-01", "latest": "2000-01-01"},
            "rate": "uniform",
            "incidence": 1,
        },
    ),
    imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=0 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "case_index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),
    region=patients.registered_practice_as_of(
        "case_index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and The Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East": 0.1,
                    "London": 0.2,
                    "South East": 0.1,
                    "South West": 0.1,
                },
            },
        },
    ),

    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),
    ## may consider also using patients.with_ethnicity_from_sus?

    #Clinical covariates
    atrial_fibrillation_or_flutter=patients.with_these_clinical_events(
        atrial_fibrillation_or_flutter_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.05},
    ),
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.2},
    ),
    haematological_cancer=patients.with_these_clinical_events(
        haematological_cancer_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.01},
    ),
    heart_failure=patients.with_these_clinical_events(
        heart_failure_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.04},
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.2},
    ),
    non_haematological_cancer=patients.with_these_clinical_events(
        non_haematological_cancer_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    myocardial_infarction=patients.with_these_clinical_events(
        myocardial_infarction_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.1},
    ),
    peripheral_vascular_disease=patients.with_these_clinical_events(
        peripheral_vascular_disease_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    rheumatoid_arthritis=patients.with_these_clinical_events(
        rheumatoid_arthritis_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.05},
    ),
    stroke=patients.with_these_clinical_events(
        stroke_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    systemic_lupus_erythematosus=patients.with_these_clinical_events(
        systemic_lupus_erythematosus_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.02},
    ),
    smoking_status=patients.categorised_as(
         {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
         },
        return_expectations={
             "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
         },
        most_recent_smoking_code=patients.with_these_clinical_events(
             smoking_codes,
             find_last_match_in_period=True,
             on_or_before="case_index_date",
             returning="category",
         ),
        ever_smoked=patients.with_these_clinical_events(
             filter_codes_by_category(smoking_codes, include=["S", "E"]),
             on_or_before="case_index_date",
         ),
     ),
    #These need to be done differently
    body_mass_index=patients.most_recent_bmi(
        on_or_before="case_index_date",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-01-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8, "min": 18, "max": 45},
            "incidence": 0.95,
        }
    ),
    immunosuppression=patients.with_these_clinical_events(
        immunosuppression_codes,
        returning="binary_flag",
        on_or_before="case_index_date",
        return_expectations={"incidence": 0.05},
    ),
    )
    return variables_covariates
