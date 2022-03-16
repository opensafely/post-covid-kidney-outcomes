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

    #Need to develop OPCS-4 codelist for critical_care_codes

    critical_care_covid=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes AND critical_care_codes
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
        with_these_diagnoses=covid_codes AND acute_kidney_injury_codes
        returning="date_admitted",
        between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.05, "date": {"earliest": "index_date"}},
    ),

    covid_hospitalised_dialysis=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes AND dialysis_codes
        returning="date_admitted",
        between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.005, "date": {"earliest": "index_date"}},
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
            AND NOT covid__hospitalised_dialysis
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
                    }
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


    #Dialysis
    dialysis_date = patients.with_these_clinical_events(
        dialysis_codes,
        between = ["1980-01-01", "2022-02-01"]
        find_first_match_in_period = True,
        returning = "date",
        date_format = "YYYY-MM-DD",
        ),
   
    #Kidney transplant
    kidney_transplant_date = patients.with_these_clinical_events(
        kidney_transplant_codes, 
        between = ["1980-01-01", "2022-02-01"]
        find_first_match_in_period = True,
        returning = "date",
        date_format = "YYYY-MM-DD",
        ),

    renal_replacement_therapy_date=minumum.of(
        "dialysis_date", "kidney_transplant_date"   
        ),

    #When matching, anyone with eGFR <15 by 2020-02-01 (for contemporary) or 2018-02-01 (for historical) will be excluded

    #Creatinine as of 2020-02-01
    #NB missing floats/integers will be returned as 0 by default
    creatinine_february_2020=patients.most_recent_creatinine(
        on_or_before="2020-02-01"
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2018-02-01 - 18 months", "latest": "2020-01-31"},
            "float": {"distribution": "normal", "mean": 80, "stdev": 40},
            "incidence": 0.60,
        }
    )
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

    #Creatinine as of 2018-02-01
    #NB missing floats/integers will be returned as 0 by default
    creatinine_february_2018=patients.most_recent_creatinine(
        on_or_before="2018-02-01"
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2016-02-01 - 18 months", "latest": "2018-01-31"},
            "float": {"distribution": "normal", "mean": 80, "stdev": 40},
            "incidence": 0.60,
        }
    )
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

    #Excluding anyone who died before patient_index_date (i.e.within 28 days of covid_diagnosis_date)
    died_before_patient_index_date=patients.died_date_gp(
        on_or_before="patient_index_date")
    


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

  covid_vax_1_date = patients.with_vaccination_record(
    returning = "date",
    tpp = {"target_disease_matches": "SARS-2 CORONAVIRUS",},
    find_first_match_in_period = True,
    between = ["2020-12-08", end_date],
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


        
        af=patients.with_these_clinical_events(
            af_codes,
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.05},
        ),
        anticoag_rx=patients.with_these_medications(
            combine_codelists(doac_codes, warfarin_codes),
            between=[f"{index_date_variable} - 3 months", f"{index_date_variable}"],
            return_expectations={
                "date": {
                    "earliest": "index_date - 3 months",
                    "latest": "index_date",
                }
            },
        ),
        ),
        esrd=patients.with_these_clinical_events(
            esrd_codes,
            on_or_before=f"{index_date_variable}",
            return_first_date_in_period=True,
            include_month=True,
        ),
    )
    return common_variables


#https://github.com/opensafely/long-covid-sick-notes/blob/master/analysis/common_variables.py

    from cohortextractor import (
    patients,
    codelist,
    filter_codes_by_category,
    combine_codelists,
)
from codelists import *
from variable_loop import get_codelist_variable

variables = {
    "diag_central_nervous_system": [central_nervous_system_codes],
    "diag_pregnancy_complication": [pregnancy_complication_codes],
    "diag_congenital_disease": [congenital_disease_codes],
    "diag_auditory_disorder": [auditory_disorder_codes],
    "diag_cardio_disorder": [cardio_disorder_codes],
    "diag_bloodcell_disorder": [bloodcell_disorder_codes],
    "diag_connective_tissue": [connective_tissue_disorder_codes],
    "diag_digestive_disorder": [digestive_disorder_codes],
    "diag_endocrine_disorder": [endocrine_disorder_codes],
    "diag_fetus_newborn_disorder": [fetus_newborn_disorder_codes],
    "diag_hematopoietic_disorder": [hematopoietic_disorder_codes],
    "diag_immune_disorder": [immune_disorder_codes],
    "diag_labor_delivery_disorder": [labor_delivery_disorder_codes],
    "diag_musculoskeletal_disorder": [musculoskeletal_disorder_codes],
    "diag_nervous_disorder": [nervous_disorder_codes],
    "diag_puerperium_disorder": [puerperium_disorder_codes],
    "diag_respiratory_disorder": [respiratory_disorder_codes],
    "diag_skin_disorder": [skin_disorder_codes],
    "diag_genitourinary_disorder": [genitourinary_disorder_codes],
    "diag_infectious_disease": [infectious_disease_codes],
    "diag_mental_disorder": [mental_disorder_codes],
    "diag_metabolic_disease": [metabolic_disease_codes],
    "diag_neoplastic_disease": [neoplastic_disease_codes],
    "diag_nutritional_disorder": [nutritional_disorder_codes],
    "diag_poisoning": [poisoning_codes],
    "diag_trauma": [trauma_codes],
    "diag_visual_disorder": [visual_disorder_codes],
}

covariates = {k: get_codelist_variable(v) for k, v in variables.items()}

def generate_common_variables(index_date_variable):

    # Outcomes
    # History of outcomes - https://github.com/opensafely/post-covid-outcomes-research/blob/main/analysis/common_variables.py (looked for recent history of outcomes)
    outcome_variables = dict(
        # Primary outcome - ESRD
        esrd_gp=patients.with_these_clinical_events(
            filter_codes_by_category(esrd_codes_gp, include["esrd"]),
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD"
            on_or_after=f"{index_date_variable} + 1 days",
            return_expectations={"date": "index_date"}},
        ),
        esrd_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=filter_codes_by_category(
                esrd_codes_hospital, include["esrd"]),
            ),
            on_or_after=f"{index_date_variable} + 1 days",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "index_date"}},
        ),
        #Secondary outcomes
        # 50% reduction in eGFR - need to extract first eGFR measurement each calendar month not within 14 days of a hospital admission
            creatinine=patients.with_these_clinical_events(
            creatinine_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable}",
            returning="numeric_value",
            include_date_of_match=True,
            include_month=True,
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
                "date": {"earliest": "2016-08-01", "latest": "2022-02-01"},
                "incidence": 0.95,
            },
        ),
        #Will need to create separate monthly codes? How to exclude measurements proximal to hospital admissions?
            creatinine082016=patients.with_these_clinical_events(
            creatinine_codes
            find_first_match_in_period=True,
            between=("2016-08-01", "2016-08-31"),
            returning="numeric_value",
            include_date_of_match=True,
            include_month=True,
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stdev": 15},
                "date": {"earliest": "2016-08-01", "latest": "2016-08-31"},
                "incidence": 0.01,
            },
        ),

        # Acute kidney injury - post-covid-outcomes included AKI from GP & ONS as well
        aki=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=aki_codes,
            on_or_after=f"{index_date_variable} + 1 days",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "index_date"}},
        ),
        # Death - GP only (not ONS as not available for linkage before 2019)
        death=patients.with_these_clinical_events(
            filter_codes_by_category(death_codes_gp, include["death"]),
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD"
            on_or_after=f"{index_date_variable} + 1 days",
            return_expectations={"date": "index_date"}},
        ),
        
        #Covariables

        **covariates,
    )

    demographic_variables = dict(
        #Can we get date of birth? Age can then be calculated from covid_diagnosis_date for matching
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
        imd=patients.categorised_as(
            {
                "0": "DEFAULT",
                "1": """
                        index_of_multiple_deprivation >=1
                    AND index_of_multiple_deprivation < 32844*1/5
                    """,
                "2": """
                        index_of_multiple_deprivation >= 32844*1/5
                    AND index_of_multiple_deprivation < 32844*2/5
                    """,
                "3": """
                        index_of_multiple_deprivation >= 32844*2/5
                    AND index_of_multiple_deprivation < 32844*3/5
                    """,
                "4": """
                        index_of_multiple_deprivation >= 32844*3/5
                    AND index_of_multiple_deprivation < 32844*4/5
                    """,
                "5": """
                        index_of_multiple_deprivation >= 32844*4/5
                    AND index_of_multiple_deprivation < 32844
                    """,
            },
            index_of_multiple_deprivation=patients.address_as_of(
                "index_date",
                returning="index_of_multiple_deprivation",
                round_to_nearest=100,
            ),
            #This will give us IMD at 2020-02-01 for covid_all_for_matching
            #Should we use covid_diagnosis_date and a variable for the equivalent matched historical date instead?
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
        deregistered=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "index_date"},
                "incidence": 0.5,
            },
        ),
    )

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