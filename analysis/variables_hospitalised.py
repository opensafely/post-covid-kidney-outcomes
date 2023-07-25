from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_hospitalised(index_date_variable):
    variables_hospitalised=dict(       
    critical_care=patients.admitted_to_hospital(
        with_these_procedures=critical_care_codes,
        returning="binary_flag",
        between=["patient_index_date", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.05,
        },
    ),
    critical_days=patients.admitted_to_hospital(
        with_at_least_one_day_in_critical_care=True,
        between=["patient_index_date", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.05,
        },
    ),
    acute_kidney_injury=patients.admitted_to_hospital(
        with_these_diagnoses=acute_kidney_injury_codes,
        returning="binary_flag",
        between=["patient_index_date", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.40,
        },
    ),
    krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between=["patient_index_date", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.01,
        },
    ),
    krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between=["patient_index_date", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.01,
        },
    ),
    practice_id=patients.registered_practice_as_of(
        "patient_index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 25, "stddev": 5},
            "incidence": 0.5,
        },
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "patient_index_date - 3 months", "patient_index_date + 28 days",
        return_expectations={"incidence":0.95,
        },
    ),
    deceased=patients.with_death_recorded_in_primary_care(
        returning="binary_flag",
        between=["1970-01-01", "patient_index_date + 28 days"],
        return_expectations={"incidence": 0.01, 
        },
    ),
    baseline_krt_primary_care=patients.with_these_clinical_events(
        kidney_replacement_therapy_primary_care_codes,
        between=["1970-01-01", "patient_index_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.05,
        },
    ),
    baseline_krt_icd_10=patients.admitted_to_hospital(
        with_these_diagnoses=kidney_replacement_therapy_icd_10_codes,
        returning="binary_flag",
        between=["1970-01-01", "patient_index_date"],
        return_expectations={"incidence": 0.05,
        },
    ),
    baseline_krt_opcs_4=patients.admitted_to_hospital(
        with_these_procedures=kidney_replacement_therapy_opcs_4_codes,
        returning="binary_flag",
        between=["1970-01-01", "patient_index_date"],
        return_expectations={"incidence": 0.05,
        },
    ),
    age=patients.age_as_of(
       "patient_index_date",
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
            "patient_index_date",
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
        "patient_index_date",
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
    stp=patients.registered_practice_as_of(
        "patient_index_date",
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
        "patient_index_date",
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
    acute_kidney_injury_baseline=patients.admitted_to_hospital(
        with_these_diagnoses=acute_kidney_injury_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.05},
    ),
    atrial_fibrillation_or_flutter=patients.with_these_clinical_events(
        atrial_fibrillation_or_flutter_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.05},
    ),
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.2},
    ),
    haematological_cancer=patients.with_these_clinical_events(
        haematological_cancer_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.01},
    ),
    heart_failure=patients.with_these_clinical_events(
        heart_failure_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.04},
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.2},
    ),
    non_haematological_cancer=patients.with_these_clinical_events(
        non_haematological_cancer_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    myocardial_infarction=patients.with_these_clinical_events(
        myocardial_infarction_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.1},
    ),
    peripheral_vascular_disease=patients.with_these_clinical_events(
        peripheral_vascular_disease_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    rheumatoid_arthritis=patients.with_these_clinical_events(
        rheumatoid_arthritis_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.05},
    ),
    stroke=patients.with_these_clinical_events(
        stroke_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    systemic_lupus_erythematosus=patients.with_these_clinical_events(
        systemic_lupus_erythematosus_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.02},
    ),
    smoking_status=patients.categorised_as(
         {
            "S": "most_recent_smoking_code='S'",
            "E": """
                 most_recent_smoking_code='E' OR (
                   most_recent_smoking_code='N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code='N' AND NOT ever_smoked",
            "M": "DEFAULT",
         },
        return_expectations={
             "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
         },
        most_recent_smoking_code=patients.with_these_clinical_events(
             smoking_codes,
             find_last_match_in_period=True,
             on_or_before="patient_index_date",
             returning="category",
         ),
        ever_smoked=patients.with_these_clinical_events(
             filter_codes_by_category(smoking_codes, include=["S", "E"]),
             on_or_before="patient_index_date",
         ),
     ),
    body_mass_index=patients.most_recent_bmi(
        on_or_before="patient_index_date",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01", "latest": "2022-12-31"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8, "min": 18, "max": 45},
            "incidence": 0.95,
        }
    ),
    immunosuppression=patients.with_these_clinical_events(
        immunosuppression_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        return_expectations={"incidence": 0.05},
    ),
    gp_count=patients.with_gp_consultations(
        between=["patient_index_date - 1 year", "patient_index_date"],
        returning="number_of_matches_in_period",
        return_expectations={"int": {"distribution": "normal", "mean": 6, "stddev": 3},"incidence": 0.6,},
    ),
    hosp_count=patients.admitted_to_hospital(
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="number_of_matches_in_period",
        return_expectations={"int": {"distribution": "normal", "mean": 1, "stddev": 1},"incidence": 0.6,},
    ),
    )
    return variables_hospitalised