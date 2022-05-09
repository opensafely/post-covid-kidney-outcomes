#https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py

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
    "sgss_positive", "primary_care_covid", "hospital_covid"
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

covid_hospitalised_acute_kidney_injury=patients.admitted_to_hospital(
    with_these_diagnoses=covid_codes,
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

covid_vax_1_date = patients.with_vaccination_record(
    returning = "date",
    tpp = {"target_disease_matches": "SARS-2 CORONAVIRUS",},
    find_first_match_in_period = True,
    between = ["2020-11-01", end_date],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2020-12-08",
        "latest": end_date,
      }
    },
),
covid_vax_2_date = patients.with_vaccination_record(
    returning = "date",
    tpp = {"target_disease_matches": "SARS-2 CORONAVIRUS",},
    find_first_match_in_period = True,
    between = ["covid_vax_1_date + 15 days", end_date],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2020-12-31",
        "latest": end_date,
      }
    },
),
covid_vax_3_date = patients.with_vaccination_record(
    returning = "date",
    tpp = {"target_disease_matches": "SARS-2 CORONAVIRUS",},
    find_first_match_in_period = True,
    between = ["covid_vax_2_date + 15 days", end_date],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2021-03-31",
        "latest": end_date,
      }
    },
),

covid_vax_4_date = patients.with_vaccination_record(
    returning = "date",
    tpp = {"target_disease_matches": "SARS-2 CORONAVIRUS",},
    find_first_match_in_period = True,
    between = ["covid_vax_3_date + 15 days", end_date],
    date_format = "YYYY-MM-DD",
    return_expectations = {
      "date": {
        "earliest": "2021-04-31",
        "latest": end_date,
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
creatinine_february_2020=patients.most_recent_creatinine(
    on_or_before="2020-02-01",
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2019-08-01", "latest": "2020-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
#CKD-EPI (2009) eGFR equation (Levey et al)
if sex = "F" and creatinine_february_2020 <= 62 > 0 #Is this the correct way of specifying 0<SCr<=62?
    egfr_february_2020 = round(144*(creatinine_february_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True, #Is this the correct way of importing the date from creatinine_february_2020?
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_february_2020 > 62
    egfr_february_2020 = round(144*(creatinine_february_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2020 <= 80 > 0
    egfr_february_2020 = round(141*(creatinine_february_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2020 > 80
    egfr_february_2020 = round(141*(creatinine_february_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_february_2020 = 0
    egfr_february_2020 = 0 #I.e. if no available creatinine_february_2020, no eGFR
        include_measurement_date=False 

egfr_below_15_february_2020=patients.satisfying(
    ""
        egfr_february_2020 <15
    AND NOT egfr_february_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),

#Creatinine as of 2018-02-01 (for historical comparator group)
#NB missing floats/integers will be returned as 0 by default
creatinine_february_2018=patients.most_recent_creatinine(
    on_or_before="2018-02-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2016-08-01", "latest": "2018-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    },
),
#CKD-EPI (2009) eGFR equation (Levey et al)
if sex = "F" and creatinine_february_2018 <= 62 > 0 #Is this the correct way of specifying 0<SCr<=62?
    egfr_february_2018 = round(144*(creatinine_february_2018/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True, #Is this the correct way of importing the date from creatinine_february_2020?
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_february_2018 > 62
    egfr_february_2018 = round(144*(creatinine_february_2018/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2018 <= 80 > 0
    egfr_february_2018 = round(141*(creatinine_february_2018/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2018 > 80
    egfr_february_2018 = round(141*(creatinine_february_2018/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_february_2018 = 0
    egfr_february_2018 = 0 #I.e. if no available creatinine_february_2018, no eGFR
        include_measurement_date=False 
    egfr_below_15_february_2018=patients.satisfying(
    ""
        egfr_february_2018 <15
    AND NOT egfr_february_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
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
chronic_respiratory_disease=patients.with_these_clinical_events(
    chronic_respiratory_disease_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
dementia=patients.with_these_clinical_events(
    dementia_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.03},
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
other_neurological_conditions=patients.with_these_clinical_events(
    other_neurological_conditions_codes,
    returning="binary_flag",
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.01},
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
sickle_cell_disease=patients.with_these_clinical_events(
    sickle_cell_disease_codes,
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
    returning="binary_flag",
    systemic_lupus_erythematosus_codes,
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
insulin=patients.with_these_clinical_events(
    insulin_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
non_insulin_antidiabetic_drugs=patients.with_these_clinical_events(
    non_insulin_antidiabetic_drugs,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
diabetes_drugs=patients.with_these_clinical_events(
    diabetes_drugs_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
immunosuppression=patients.with_these_clinical_events(
    immunosuppression_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),
anticoagulation=patients.with_these_clinical_events(
    anticoagulation_codes,
    on_or_before=f"{index_date_variable}",
        return_expectations={"incidence": 0.05},
),

creatinine_march_2020=patients.most_recent_creatinine(
    on_or_before="2020-03-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-02-01 - 17 months", "latest": "2020-02-29"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_march_2020 <= 62 > 0
    egfr_march_2020 = round(144*(creatinine_march_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_march_2020 > 62
    egfr_march_2020 = round(144*(creatinine_march_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_march_2020 <= 80 > 0
    egfr_march_2020 = round(141*(creatinine_march_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_march_2020 > 80
    egfr_march_2020 = round(141*(creatinine_march_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_march_2020 = 0
    egfr_march_2020 = 0
        include_measurement_date=False 

egfr_below_15_march_2020=patients.satisfying(
    ""
        egfr_march_2020 <15
    AND NOT egfr_march_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_april_2020=patients.most_recent_creatinine(
    on_or_before="2020-04-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-03-01 - 17 months", "latest": "2020-03-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_april_2020 <= 62 > 0
    egfr_april_2020 = round(144*(creatinine_april_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_april_2020 > 62
    egfr_april_2020 = round(144*(creatinine_april_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_april_2020 <= 80 > 0
    egfr_april_2020 = round(141*(creatinine_april_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_april_2020 > 80
    egfr_april_2020 = round(141*(creatinine_april_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_april_2020 = 0
    egfr_april_2020 = 0
        include_measurement_date=False 

egfr_below_15_april_2020=patients.satisfying(
    ""
        egfr_april_2020 <15
    AND NOT egfr_april_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_may_2020=patients.most_recent_creatinine(
    on_or_before="2020-05-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-04-01 - 17 months", "latest": "2020-04-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_may_2020 <= 62 > 0
    egfr_may_2020 = round(144*(creatinine_may_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_may_2020 > 62
    egfr_may_2020 = round(144*(creatinine_may_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_may_2020 <= 80 > 0
    egfr_may_2020 = round(141*(creatinine_may_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_may_2020 > 80
    egfr_may_2020 = round(141*(creatinine_may_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_may_2020 = 0
    egfr_may_2020 = 0
        include_measurement_date=False 

egfr_below_15_may_2020=patients.satisfying(
    ""
        egfr_may_2020 <15
    AND NOT egfr_may_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_june_2020=patients.most_recent_creatinine(
    on_or_before="2020-06-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-05-01 - 17 months", "latest": "2020-05-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_june_2020 <= 62 > 0
    egfr_june_2020 = round(144*(creatinine_june_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_june_2020 > 62
    egfr_june_2020 = round(144*(creatinine_june_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_june_2020 <= 80 > 0
    egfr_june_2020 = round(141*(creatinine_june_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_june_2020 > 80
    egfr_june_2020 = round(141*(creatinine_june_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_june_2020 = 0
    egfr_june_2020 = 0
        include_measurement_date=False 

egfr_below_15_june_2020=patients.satisfying(
    ""
        egfr_june_2020 <15
    AND NOT egfr_june_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_july_2020=patients.most_recent_creatinine(
    on_or_before="2020-07-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-06-01 - 17 months", "latest": "2020-06-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_july_2020 <= 62 > 0
    egfr_july_2020 = round(144*(creatinine_july_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_july_2020 > 62
    egfr_july_2020 = round(144*(creatinine_july_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2020 <= 80 > 0
    egfr_july_2020 = round(141*(creatinine_july_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2020 > 80
    egfr_july_2020 = round(141*(creatinine_july_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_july_2020 = 0
    egfr_july_2020 = 0
        include_measurement_date=False 

egfr_below_15_july_2020=patients.satisfying(
    ""
        egfr_july_2020 <15
    AND NOT egfr_july_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_august_2020=patients.most_recent_creatinine(
    on_or_before="2020-08-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-07-01 - 17 months", "latest": "2020-07-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_august_2020 <= 62 > 0
    egfr_august_2020 = round(144*(creatinine_august_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_august_2020 > 62
    egfr_august_2020 = round(144*(creatinine_august_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_august_2020 <= 80 > 0
    egfr_august_2020 = round(141*(creatinine_august_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2020 > 80
    egfr_august_2020 = round(141*(creatinine_august_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_august_2020 = 0
    egfr_august_2020 = 0
        include_measurement_date=False 

egfr_below_15_august_2020=patients.satisfying(
    ""
        egfr_august_2020 <15
    AND NOT egfr_august_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_september_2020=patients.most_recent_creatinine(
    on_or_before="2020-09-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-08-01 - 17 months", "latest": "2020-08-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_september_2020 <= 62 > 0
    egfr_september_2020 = round(144*(creatinine_september_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_september_2020 > 62
    egfr_september_2020 = round(144*(creatinine_september_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_september_2020 <= 80 > 0
    egfr_september_2020 = round(141*(creatinine_september_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_september_2020 > 80
    egfr_september_2020 = round(141*(creatinine_september_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_september_2020 = 0
    egfr_september_2020 = 0
        include_measurement_date=False 

egfr_below_15_september_2020=patients.satisfying(
    ""
        egfr_september_2020 <15
    AND NOT egfr_september_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_october_2020=patients.most_recent_creatinine(
    on_or_before="2020-10-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-09-01 - 17 months", "latest": "2020-09-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_october_2020 <= 62 > 0
    egfr_october_2020 = round(144*(creatinine_october_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_october_2020 > 62
    egfr_october_2020 = round(144*(creatinine_october_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_october_2020 <= 80 > 0
    egfr_october_2020 = round(141*(creatinine_october_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_october_2020 > 80
    egfr_october_2020 = round(141*(creatinine_october_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_october_2020 = 0
    egfr_october_2020 = 0
        include_measurement_date=False 

egfr_below_15_october_2020=patients.satisfying(
    ""
        egfr_october_2020 <15
    AND NOT egfr_october_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_november_2020=patients.most_recent_creatinine(
    on_or_before="2020-11-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-10-01 - 17 months", "latest": "2020-10-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_november_2020 <= 62 > 0
    egfr_november_2020 = round(144*(creatinine_november_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_november_2020 > 62
    egfr_november_2020 = round(144*(creatinine_november_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_november_2020 <= 80 > 0
    egfr_november_2020 = round(141*(creatinine_november_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_november_2020 > 80
    egfr_november_2020 = round(141*(creatinine_november_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_november_2020 = 0
    egfr_november_2020 = 0
        include_measurement_date=False 

egfr_below_15_november_2020=patients.satisfying(
    ""
        egfr_november_2020 <15
    AND NOT egfr_november_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_december_2020=patients.most_recent_creatinine(
    on_or_before="2020-12-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-11-01 - 17 months", "latest": "2020-11-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_december_2020 <= 62 > 0
    egfr_december_2020 = round(144*(creatinine_december_2020/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_december_2020 > 62
    egfr_december_2020 = round(144*(creatinine_december_2020/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_december_2020 <= 80 > 0
    egfr_december_2020 = round(141*(creatinine_december_2020/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_december_2020 > 80
    egfr_december_2020 = round(141*(creatinine_december_2020/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_december_2020 = 0
    egfr_december_2020 = 0
        include_measurement_date=False 

egfr_below_15_december_2020=patients.satisfying(
    ""
        egfr_december_2020 <15
    AND NOT egfr_december_2020 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_january_2021=patients.most_recent_creatinine(
    on_or_before="2021-01-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2020-12-01 - 17 months", "latest": "2020-12-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_january_2021 <= 62 > 0
    egfr_january_2021 = round(144*(creatinine_january_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_january_2021 > 62
    egfr_january_2021 = round(144*(creatinine_january_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_january_2021 <= 80 > 0
    egfr_january_2021 = round(141*(creatinine_january_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_january_2021 > 80
    egfr_january_2021 = round(141*(creatinine_january_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_january_2021 = 0
    egfr_january_2021 = 0
        include_measurement_date=False 

egfr_below_15_january_2021=patients.satisfying(
    ""
        egfr_january_2021 <15
    AND NOT egfr_january_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_february_2021=patients.most_recent_creatinine(
    on_or_before="2021-02-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-01-01 - 17 months", "latest": "2021-01-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_february_2021 <= 62 > 0
    egfr_february_2021 = round(144*(creatinine_february_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_february_2021 > 62
    egfr_february_2021 = round(144*(creatinine_february_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2021 <= 80 > 0
    egfr_february_2021 = round(141*(creatinine_february_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_february_2021 > 80
    egfr_february_2021 = round(141*(creatinine_february_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_february_2021 = 0
    egfr_february_2021 = 0
        include_measurement_date=False 

egfr_below_15_february_2021=patients.satisfying(
    ""
        egfr_february_2021 <15
    AND NOT egfr_february_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_march_2021=patients.most_recent_creatinine(
    on_or_before="2021-03-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-02-01 - 17 months", "latest": "2021-02-29"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_march_2021 <= 62 > 0
    egfr_march_2021 = round(144*(creatinine_march_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_march_2021 > 62
    egfr_march_2021 = round(144*(creatinine_march_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_march_2021 <= 80 > 0
    egfr_march_2021 = round(141*(creatinine_march_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_march_2021 > 80
    egfr_march_2021 = round(141*(creatinine_march_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_march_2021 = 0
    egfr_march_2021 = 0
        include_measurement_date=False 

egfr_below_15_march_2021=patients.satisfying(
    ""
        egfr_march_2021 <15
    AND NOT egfr_march_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_april_2021=patients.most_recent_creatinine(
    on_or_before="2021-04-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-03-01 - 17 months", "latest": "2021-03-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_april_2021 <= 62 > 0
    egfr_april_2021 = round(144*(creatinine_april_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_april_2021 > 62
    egfr_april_2021 = round(144*(creatinine_april_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_april_2021 <= 80 > 0
    egfr_april_2021 = round(141*(creatinine_april_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_april_2021 > 80
    egfr_april_2021 = round(141*(creatinine_april_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_april_2021 = 0
    egfr_april_2021 = 0
        include_measurement_date=False 

egfr_below_15_april_2021=patients.satisfying(
    ""
        egfr_april_2021 <15
    AND NOT egfr_april_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_may_2021=patients.most_recent_creatinine(
    on_or_before="2021-05-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-04-01 - 17 months", "latest": "2021-04-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_may_2021 <= 62 > 0
    egfr_may_2021 = round(144*(creatinine_may_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_may_2021 > 62
    egfr_may_2021 = round(144*(creatinine_may_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_may_2021 <= 80 > 0
    egfr_may_2021 = round(141*(creatinine_may_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_may_2021 > 80
    egfr_may_2021 = round(141*(creatinine_may_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_may_2021 = 0
    egfr_may_2021 = 0
        include_measurement_date=False 

egfr_below_15_may_2021=patients.satisfying(
    ""
        egfr_may_2021 <15
    AND NOT egfr_may_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_june_2021=patients.most_recent_creatinine(
    on_or_before="2021-06-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-05-01 - 17 months", "latest": "2021-05-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_june_2021 <= 62 > 0
    egfr_june_2021 = round(144*(creatinine_june_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_june_2021 > 62
    egfr_june_2021 = round(144*(creatinine_june_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_june_2021 <= 80 > 0
    egfr_june_2021 = round(141*(creatinine_june_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_june_2021 > 80
    egfr_june_2021 = round(141*(creatinine_june_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_june_2021 = 0
    egfr_june_2021 = 0
        include_measurement_date=False 

egfr_below_15_june_2021=patients.satisfying(
    ""
        egfr_june_2021 <15
    AND NOT egfr_june_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_july_2021=patients.most_recent_creatinine(
    on_or_before="2021-07-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-06-01 - 17 months", "latest": "2021-06-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_july_2021 <= 62 > 0
    egfr_july_2021 = round(144*(creatinine_july_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_july_2021 > 62
    egfr_july_2021 = round(144*(creatinine_july_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2021 <= 80 > 0
    egfr_july_2021 = round(141*(creatinine_july_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2021 > 80
    egfr_july_2021 = round(141*(creatinine_july_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_july_2021 = 0
    egfr_july_2021 = 0
        include_measurement_date=False 

egfr_below_15_july_2021=patients.satisfying(
    ""
        egfr_july_2021 <15
    AND NOT egfr_july_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_august_2021=patients.most_recent_creatinine(
    on_or_before="2021-08-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-07-01 - 17 months", "latest": "2021-07-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_august_2021 <= 62 > 0
    egfr_august_2021 = round(144*(creatinine_august_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_august_2021 > 62
    egfr_august_2021 = round(144*(creatinine_august_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_august_2021 <= 80 > 0
    egfr_august_2021 = round(141*(creatinine_august_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_july_2021 > 80
    egfr_august_2021 = round(141*(creatinine_august_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_august_2021 = 0
    egfr_august_2021 = 0
        include_measurement_date=False 

egfr_below_15_august_2021=patients.satisfying(
    ""
        egfr_august_2021 <15
    AND NOT egfr_august_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_september_2021=patients.most_recent_creatinine(
    on_or_before="2021-09-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-08-01 - 17 months", "latest": "2021-08-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_september_2021 <= 62 > 0
    egfr_september_2021 = round(144*(creatinine_september_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_september_2021 > 62
    egfr_september_2021 = round(144*(creatinine_september_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_september_2021 <= 80 > 0
    egfr_september_2021 = round(141*(creatinine_september_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_september_2021 > 80
    egfr_september_2021 = round(141*(creatinine_september_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_september_2021 = 0
    egfr_september_2021 = 0
        include_measurement_date=False 

egfr_below_15_september_2021=patients.satisfying(
    ""
        egfr_september_2021 <15
    AND NOT egfr_september_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_october_2021=patients.most_recent_creatinine(
    on_or_before="2021-10-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-09-01 - 17 months", "latest": "2021-09-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_october_2021 <= 62 > 0
    egfr_october_2021 = round(144*(creatinine_october_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_october_2021 > 62
    egfr_october_2021 = round(144*(creatinine_october_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_october_2021 <= 80 > 0
    egfr_october_2021 = round(141*(creatinine_october_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_october_2021 > 80
    egfr_october_2021 = round(141*(creatinine_october_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_october_2021 = 0
    egfr_october_2021 = 0
        include_measurement_date=False 

egfr_below_15_october_2021=patients.satisfying(
    ""
        egfr_october_2021 <15
    AND NOT egfr_october_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_november_2021=patients.most_recent_creatinine(
    on_or_before="2021-11-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-10-01 - 17 months", "latest": "2021-10-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_november_2021 <= 62 > 0
    egfr_november_2021 = round(144*(creatinine_november_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_november_2021 > 62
    egfr_november_2021 = round(144*(creatinine_november_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_november_2021 <= 80 > 0
    egfr_november_2021 = round(141*(creatinine_november_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_november_2021 > 80
    egfr_november_2021 = round(141*(creatinine_november_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_november_2021 = 0
    egfr_november_2021 = 0
        include_measurement_date=False 

egfr_below_15_november_2021=patients.satisfying(
    ""
        egfr_november_2021 <15
    AND NOT egfr_november_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_december_2021=patients.most_recent_creatinine(
    on_or_before="2021-12-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-11-01 - 17 months", "latest": "2021-11-30"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_december_2021 <= 62 > 0
    egfr_december_2021 = round(144*(creatinine_december_2021/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_december_2021 > 62
    egfr_december_2021 = round(144*(creatinine_december_2021/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_december_2021 <= 80 > 0
    egfr_december_2021 = round(141*(creatinine_december_2021/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_december_2021 > 80
    egfr_december_2021 = round(141*(creatinine_december_2021/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_december_2021 = 0
    egfr_december_2021 = 0
        include_measurement_date=False 

egfr_below_15_december_2021=patients.satisfying(
    ""
        egfr_december_2021 <15
    AND NOT egfr_december_2021 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),
creatinine_january_2022=patients.most_recent_creatinine(
    on_or_before="2022-01-01"
    include_measurement_date=True,
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest": "2021-12-01 - 17 months", "latest": "2021-12-31"},
        "float": {"distribution": "normal", "mean": 80, "stdev": 40},
        "incidence": 0.60,
    }
),
if sex = "F" and creatinine_january_2022 <= 62 > 0
    egfr_january_2022 = round(144*(creatinine_january_2022/0.7)**(-0.329) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "F" and creatinine_january_2022 > 62
    egfr_january_2022 = round(144*(creatinine_january_2022/0.7)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_january_2022 <= 80 > 0
    egfr_january_2022 = round(141*(creatinine_january_2022/0.9)**(-0.411) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if sex = "M" and creatinine_january_2022 > 80
    egfr_january_2022 = round(141*(creatinine_january_2022/0.9)**(-1.209) * (0.993)**(age))
        include_measurement_date=True,
        date_format="YYYY-MM-DD"
if creatinine_january_2022 = 0
    egfr_january_2022 = 0
        include_measurement_date=False 

egfr_below_15_january_2022=patients.satisfying(
    ""
        egfr_january_2022 <15
    AND NOT egfr_january_2022 = "0"
    ""
        include_measurement_date=True
        date_format="YYYY-MM-DD"
        return_expectations={
            "incidence": 0.01,}
),





























    return common_variables




    #Clinical variables incomplete
    clinical_variables = dict(
        obese=patients.satisfying(
            """
            bmi >= 30
            """,
            bmi=patients.most_recent_bmi(
                between=[
                    f"{index_date_variable} - 10 year",
                    f"{index_date_variable} - 1 day",
                ],
                minimum_age_at_measurement=16,
            ),
        ),
        smoking_status=patients.categorised_as(
            {
                "S": "most_recent_smoking_code = 'S' OR smoked_last_18_months",
                "E": """
                        (most_recent_smoking_code = 'E' OR (
                        most_recent_smoking_code = 'N' AND ever_smoked
                        )
                        ) AND NOT smoked_last_18_months
                """,
                "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
                "M": "DEFAULT",
            },
            return_expectations={
                "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
            },
            most_recent_smoking_code=patients.with_these_clinical_events(
                clear_smoking_codes,
                find_last_match_in_period=True,
                on_or_before=f"{index_date_variable} - 1 day",
                returning="category",
            ),
            ever_smoked=patients.with_these_clinical_events(
                filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
                returning="binary_flag",
                on_or_before=f"{index_date_variable} - 1 day",
            ),
            smoked_last_18_months=patients.with_these_clinical_events(
                filter_codes_by_category(clear_smoking_codes, include=["S"]),
                between=[f"{index_date_variable} - 548 day", f"{index_date_variable}"],
            ),
        ),
        hypertension=patients.with_these_clinical_events(
            hypertension_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        diabetes=patients.with_these_clinical_events(
            diabetes_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        chronic_resp_dis=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),

    #Need to review chronic_respiratory_disease_codes to ensure these include asthma and COPD
        asthma=patients.categorised_as(
            {
                "0": "DEFAULT",
                "1": """
                (
                    recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                    )
                ) AND (
                    prednisolone_last_year = 0 OR 
                    prednisolone_last_year > 4
                )
            """,
                "2": """
                (
                    recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                    )
                ) AND
                prednisolone_last_year > 0 AND
                prednisolone_last_year < 5
                
            """,
            },
            return_expectations={
                "category": {"ratios": {"0": 0.8, "1": 0.1, "2": 0.1}},
            },
            asthma_code_ever=patients.with_these_clinical_events(
                asthma_codes,
                returning="binary_flag",
                on_or_before=f"{index_date_variable} - 1 day",
            ),
            recent_asthma_code=patients.with_these_clinical_events(
                asthma_codes,
                returning="binary_flag",
                between=[
                    f"{index_date_variable} - 3 year",
                    f"{index_date_variable} - 1 day",
                ],
            ),
            copd_code_ever=patients.with_these_clinical_events(
                chronic_respiratory_disease_codes,
                on_or_before=f"{index_date_variable} - 1 day",
            ),
            prednisolone_last_year=patients.with_these_medications(
                pred_codes,
                between=[
                    f"{index_date_variable} - 1 year",
                    f"{index_date_variable} - 1 day",
                ],
                returning="number_of_matches_in_period",
            ),
        ),
        chronic_cardiac_dis=patients.with_these_clinical_events(
            chronic_cardiac_disease_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        lung_cancer=patients.with_these_clinical_events(
            lung_cancer_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        haem_cancer=patients.with_these_clinical_events(
            haem_cancer_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        other_cancer=patients.with_these_clinical_events(
            other_cancer_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        chronic_liver_dis=patients.with_these_clinical_events(
            chronic_liver_disease_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        other_neuro=patients.with_these_clinical_events(
            other_neuro,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        dysplenia=patients.with_these_clinical_events(
            spleen_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        hiv=patients.with_these_clinical_events(
            hiv_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        permanent_immunodef=patients.with_these_clinical_events(
            permanent_immune_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        temporary_immunodef=patients.with_these_clinical_events(
            temp_immune_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
        ),
        ra_sle_psoriasis=patients.with_these_clinical_events(
            ra_sle_psoriasis_codes,
            returning="binary_flag",
            on_or_before=f"{index_date_variable} - 1 day",
            include_date_of_match=True,
            find_last_match_in_period=True,
            date_format="YYYY-MM-DD",
        ),
    )
    return outcome_variables, demographic_variables, clinical_variables


    with_these_decision_support_values(algorithm, on_or_before=None, on_or_after=None, between=None, find_first_match_in_period=None, find_last_match_in_period=None, returning='numeric_value', include_date_of_match=False, date_format=None, ignore_missing_values=False, return_expectations=None)