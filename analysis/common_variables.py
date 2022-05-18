#https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py
from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_common_variables(index_date_variable):
    common_variables = dict(
    deregistered=patients.date_deregistered_from_all_supported_practices(
        date_format="YYYY-MM-DD"
    ),

#Exposure - SARS-CoV-2 infection:
sgss_positive=patients.with_test_result_in_sgss(
    pathogen="SARS-CoV-2",
    test_result="positive",
    returning="date",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
),
primary_care_covid=patients.with_these_clinical_events(
    any_covid_primary_care_code,
    returning="date",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
),
hospital_covid=patients.admitted_to_hospital(
    with_these_diagnoses=covid_codes,
    returning="date_admitted",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
),
    
covid_diagnosis_date=patients.minimum_of(
    "sgss_positive", "primary_care_covid", "hospital_covid",
    date_format="YYYY-MM-DD"
),

sars_cov_2=patients.categorised_as(
    {
    "0": "DEFAULT",
    "SARS-COV-2": 
        """
        primary_care_covid
        OR sgss_positive
        OR hospital_covid
        """,
    },
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "SARS-COV-2": 0.7,
            }
        },
    },
),
critical_care_covid=patients.admitted_to_hospital(
    with_these_diagnoses=covid_codes,
    with_these_procedures=critical_care_codes,
    returning="date_admitted",
    between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.05, "date": {"earliest": "index_date"}},
),

covid_severity=patients.categorised_as(
    {
    "0": "DEFAULT",
    "sars-cov-2 non-hospitalised": 
        """
        primary_care_covid
        OR sgss_positive
        AND NOT hospital_covid
        """,
    "covid hospitalised":
        """
        hospital_covid
        AND NOT critical_care_covid
        """,
    "covid critical care": 
        """
        critical_care_covid
        """,
    },
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "sars-cov-2 on-hospitalised": 0.8,
                "covid hospitalised": 0.18,
                "covid critical care": 0.02,
            }
        },
    },
),

hospitalised_acute_kidney_injury=patients.admitted_to_hospital(
    with_these_diagnoses=acute_kidney_injury_codes,
    returning="date_admitted",
    between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.05, "date": {"earliest": "index_date"}},
),
kidney_replacement_therapy_icd_10=patients.admitted_to_hospital(
    with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
    returning="date_admitted",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.05, "date": {"earliest": "2000-01-01"}},
),
kidney_replacement_therapy_opcs_4=patients.admitted_to_hospital(
    with_these_diagnoses=kidney_replacement_therapy_opcs_4_codes,
    returning="date_admitted",
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.05, "date": {"earliest": "2000-01-01"}},
),
hospital_kidney_replacement_therapy_date=patients.minimum_of(
    "kidney_replacement_therapy_icd_10", "kidney_replacement_therapy_opcs_4"
),

covid_acute_kidney_injury=patients.categorised_as(
    {
    "0": "DEFAULT",
    "covid hospitalised no acute kidney injury":
        """
        hospital_covid
        AND NOT covid_hospitalised_acute_kidney_injury
        AND NOT covid_hospitalised_dialysis
        """,    
    "covid hospitalised acute kidney injury": 
        """
        covid_hospitalised_acute_kidney_injury
        AND NOT covid_hospitalised_dialysis
        """,
    "covid hospitalised dialysis":
        """
        covid_hospitalised_dialysis
        """,
    },
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "covid hospitalised no acute kidney injury": 0.7,
                "covid hospitalised acute kidney injury": 0.27,
                "covid hospitalised dialysis": 0.03,
            },
        },
    },
),

kidney_replacement_therapy_primary_care=patients.with_these_clinical_events(
    kidney_replacement_therapy_primary_care_codes,
    between = ["1980-01-01", "2022-02-01"],
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
),

kidney_replacement_therapy_date=patients.minimum_of(
    "kidney_replacement_therapy_primary_care", "kidney_replacement_therapy_icd_10", "kidney_replacement_therapy_opcs_4"

),

covid_vax_1_date = patients.with_tpp_vaccination_record(
    target_disease_matches = "SARS-2 CORONAVIRUS",
    returning = "date",
    find_first_match_in_period = True,
    between = ["2020-11-01", "2022-01-31"],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2020-12-08",
        "latest": "2022-01-31",
      }
    },
),
covid_vax_2_date = patients.with_tpp_vaccination_record(
    target_disease_matches = "SARS-2 CORONAVIRUS",
    returning = "date",
    find_first_match_in_period = True,
    between = ["covid_vax_1_date + 15 days", "2022-01-31"],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2020-12-31",
        "latest": "2022-01-31",
      }
    },
),
covid_vax_3_date = patients.with_tpp_vaccination_record(
    target_disease_matches = "SARS-2 CORONAVIRUS",
    returning = "date",
    find_first_match_in_period = True,
    between = ["covid_vax_2_date + 15 days", "2022-01-31"],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2021-03-31",
        "latest": "2022-01-31",
      }
    },
),

covid_vax_4_date = patients.with_tpp_vaccination_record(
    target_disease_matches = "SARS-2 CORONAVIRUS",    
    returning = "date",
    find_first_match_in_period = True,
    between = ["covid_vax_3_date + 15 days", "2022-01-31"],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2021-04-31",
        "latest": "2022-01-31",
      }
    },
),

#Matching variables
month_of_birth=patients.date_of_birth(
    date_format=None, 
    return_expectations=None
),

age=patients.age_as_of(
    f"{index_date_variable}",
    return_expectations={
        "rate": "universal",
        "int": {"distribution": "population_ages"},
    },
),
    
sex=patients.sex(
    return_expectations={
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
    }
),

imd=patients.address_as_of(
    "index_date",
    returning="index_of_multiple_deprivation",
    round_to_nearest=100,
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "100": 0.1,
                "200": 0.1,
                "300": 0.1,
                "400": 0.1,
                "500": 0.1,
                "600": 0.1,
                "700": 0.1,
                "800": 0.1,
                "900": 0.1,
                "1000": 0.1,
            },
        },
    },
),

stp=patients.registered_practice_as_of(
    "index_date",
    returning="stp_code",
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "STP1": 0.1,
                "STP2": 0.1,
                "STP3": 0.1,
                "STP4": 0.1,
                "STP5": 0.1,
                "STP6": 0.1,
                "STP7": 0.1,
                "STP8": 0.1,
                "STP9": 0.1,
                "STP10": 0.1,
                }
            },
        },
    ),
    
#Exclusion variables

died_date_gp=patients.with_death_recorded_in_primary_care(
    on_or_after="2020-02-01",
    returning="date_of_death",
    return_expectations={
        "date": {"earliest" : "2020-02-01"},
        "rate" : "exponential_increase"
        },
    ),
#When matching, anyone with eGFR <15 by 2020-02-01 (for contemporary) or 2018-02-01 (for historical) will be excluded

#Creatinine as of 2020-02-01
#NB missing floats/integers will be returned as 0 by default
creatinine_february_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-02-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2019-08-01", "latest": "2020-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
#Creatinine as of 2018-02-01 (for historical comparator group)
#NB missing floats/integers will be returned as 0 by default
creatinine_february_2018=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2018-02-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2016-08-01", "latest": "2018-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    },
),

#Social variables
practice_id=patients.registered_practice_as_of(
    "index_date",
    returning="pseudo_id",
    return_expectations={
        "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
        "incidence": 1,
    },
),
region=patients.registered_practice_as_of(
    "index_date",
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
    on_or_before=f"{index_date_variable}",
    return_expectations={
        "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
        "incidence": 0.75,
    },
),

#Clinical covariables
#index_date_variable needs to be covid_diagnosis_date or equivalent date in matched comparator groups
atrial_fibrillation_or_flutter=patients.with_these_clinical_events(
    atrial_fibrillation_or_flutter_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.05},
),
chronic_liver_disease=patients.with_these_clinical_events(
    chronic_liver_disease_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
diabetes=patients.with_these_clinical_events(
    diabetes_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.2},
),
haematological_cancer=patients.with_these_clinical_events(
    haematological_cancer_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.01},
),
heart_failure=patients.with_these_clinical_events(
    heart_failure_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.04},
),
hiv=patients.with_these_clinical_events(
    hiv_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
hypertension=patients.with_these_clinical_events(
    hypertension_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.2},
),
non_haematological_cancer=patients.with_these_clinical_events(
    non_haematological_cancer_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
myocardial_infarction=patients.with_these_clinical_events(
    myocardial_infarction_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.1},
),
peripheral_vascular_disease=patients.with_these_clinical_events(
    peripheral_vascular_disease_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
rheumatoid_arthritis=patients.with_these_clinical_events(
    rheumatoid_arthritis_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
stroke=patients.with_these_clinical_events(
    stroke_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
systemic_lupus_erythematosus=patients.with_these_clinical_events(
    systemic_lupus_erythematosus_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.02},
),
smoking=patients.with_these_clinical_events(
    smoking_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.2},
),
#These need to be done differently
body_mass_index=patients.with_these_clinical_events(
    body_mass_index_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
immunosuppression=patients.with_these_clinical_events(
    immunosuppression_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
creatinine_march_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-03-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-02-01 - 17 months", "latest": "2020-02-29"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_april_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-04-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-03-01 - 17 months", "latest": "2020-03-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_may_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-05-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-04-01 - 17 months", "latest": "2020-04-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_june_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-06-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-05-01 - 17 months", "latest": "2020-05-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_july_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-07-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-06-01 - 17 months", "latest": "2020-06-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_august_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-08-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-07-01 - 17 months", "latest": "2020-07-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_september_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-09-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-08-01 - 17 months", "latest": "2020-08-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_october_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-10-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-09-01 - 17 months", "latest": "2020-09-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_november_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-11-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-10-01 - 17 months", "latest": "2020-10-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_december_2020=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2020-12-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-11-01 - 17 months", "latest": "2020-11-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_january_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-01-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-12-01 - 17 months", "latest": "2020-12-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_february_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-02-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-01-01 - 17 months", "latest": "2021-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_march_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-03-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-02-01 - 17 months", "latest": "2021-02-29"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_april_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-04-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-03-01 - 17 months", "latest": "2021-03-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_may_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-05-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-04-01 - 17 months", "latest": "2021-04-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_june_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-06-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-05-01 - 17 months", "latest": "2021-05-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_july_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-07-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-06-01 - 17 months", "latest": "2021-06-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_august_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-08-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-07-01 - 17 months", "latest": "2021-07-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_september_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-09-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-08-01 - 17 months", "latest": "2021-08-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_october_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-10-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-09-01 - 17 months", "latest": "2021-09-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_november_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-11-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-10-01 - 17 months", "latest": "2021-10-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_december_2021=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2021-12-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-11-01 - 17 months", "latest": "2021-11-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
creatinine_january_2022=patients.with_these_clinical_events(
    creatinine_codes,
    on_or_before="2022-01-01",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-12-01 - 17 months", "latest": "2021-12-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),

)

