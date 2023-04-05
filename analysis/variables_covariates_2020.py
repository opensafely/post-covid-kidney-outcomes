#https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py
from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_covariates_2020(index_date_variable):
    variables_covariates_2020 = dict(
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
    stp_updated=patients.registered_practice_as_of(
        "case_index_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "STP1": 1.0,
                    }
                },
            },
        ),

    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "2": 0.05, "3": 0.05, "4": 0.05, "5": 0.05}},
            "incidence": 0.75,
        },
    ),
    rural_urban=patients.address_as_of(
        "case_index_date",
        returning="rural_urban_classification",
        return_expectations={
            "rate": "universal",
            "category": 
                {"ratios": {
                    "1": 0.1,
                    "2": 0.1,
                    "3": 0.1,
                    "4": 0.1,
                    "5": 0.1,
                    "6": 0.1,
                    "7": 0.2,
                    "8": 0.2,
                }
            },
        },
    ),
    
    #Clinical covariates
    baseline_creatinine_feb2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-08-01","2020-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_mar2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-09-01","2020-02-29"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-10-01","2020-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-11-01","2020-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2018-12-01","2020-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-01-01","2020-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-02-01","2020-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-03-01","2020-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_oct2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-04-01","2020-09-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_nov2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-05-01","2020-10-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_dec2020=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-06-01","2020-11-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jan2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-07-01","2020-12-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_feb2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-08-01","2021-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_mar2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-09-01","2021-02-28"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-10-01","2021-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-11-01","2021-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2019-12-01","2021-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-01-01","2021-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-02-01","2021-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-03-01","2021-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_oct2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-04-01","2021-09-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_nov2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-05-01","2021-10-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_dec2021=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-06-01","2021-11-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jan2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-07-01","2021-12-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_feb2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-08-01","2022-01-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_mar2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-09-01","2022-02-28"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_apr2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-10-01","2022-03-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_may2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-11-01","2022-04-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jun2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2020-12-01","2022-05-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_jul2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-01-01","2022-06-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_aug2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-02-01","2022-07-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_sep2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-03-01","2022-08-31"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
    baseline_creatinine_oct2022=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=False,
        between=["2021-04-01","2022-09-30"],
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),
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
    gp_count=patients.with_gp_consultations(
        between=["case_index_date - 1 year", "case_index_date"],
        returning="number_of_matches_in_period",
        return_expectations={"int": {"distribution": "normal", "mean": 6, "stddev": 3},"incidence": 0.6,},
    ),
    #These need to be done differently
    body_mass_index=patients.most_recent_bmi(
        on_or_before="case_index_date",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01", "latest": "2022-10-31"},
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
    return variables_covariates_2020
