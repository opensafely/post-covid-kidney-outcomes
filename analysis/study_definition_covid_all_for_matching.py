#study_definition_covid_all_for matching will be matched to
    #study_definition_potential_historical_general_population
    #and study_definition_potential_contemporary_general_population

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - patient_index_date (using sgss_positive, primary_care_covid or hospital_covid)

#Exclusion variables:
# - end_stage_renal_disease
# - died_before_patient_index_date (using patient_died_date_gp)

#Note:
# - Variables will be extracted at covid_diagnosis_date
# - Matching and follow-up will commence at patient_index_date 
    #(i.e. 28 days after covid_diagnosis_date)

from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    filter_codes_by_category,
    codelist_from_csv,
)

from codelists import *

from common_variables import generate_common_variables

(
    demographic_variables,
) = generate_common_variables(index_date_variable="covid_diagnosis_date")
#What is the purpose of demographic_variables here?

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7, #Is this the incidence of COVID? How does this interact with the incidence of 
            #sgss_positive, primary_care_covid and hospital_covid (each 0.1)?
    },
    
    index_date="2020-02-01",

    has_follow_up=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 3 months", "covid_diagnosis_date"
        ),
    
    #SARS-CoV_2 infection:
    sgss_positive=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),
    primary_care_covid=patients.with_these_clinical_events(
        any_primary_care_code,
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

    #Excluding ESRD patients:
    #Establish baseline creatinine
    #NB missing floats/integers will be returned as 0 by default
    baseline_creatinine=patients.most_recent_creatinine(
        on_or_before="covid_diagnosis_date - 14 days"
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "covid_diagnosis_date - 18 months", "latest": "covid_diagnosis_date - 14 days"},
            "float": {"distribution": "normal", "mean": 80, "stdev": 40},
            "incidence": 0.60,
        }
    )
    #CKD-EPI (2009) eGFR equation (Levey et al)
    if sex = "F" and baseline_creatinine <= 62 > 0 #Is this the correct way of specifying 0<SCr<=62?
        baseline_egfr = round(144*(baseline_creatinine/0.7)**(-0.329) * (0.993)**(age))
    if sex = "F" and baseline_creatinine > 62
        baseline_egfr = round(144*(baseline_creatinine/0.7)**(-1.209) * (0.993)**(age))
    if sex = "M" and baseline_creatinine <= 80 > 0
        baseline_egfr = round(141*(baseline_creatinine/0.9)**(-0.411) * (0.993)**(age))
    if sex = "M" and baseline_creatinine > 80
        baseline_egfr = round(141*(baseline_creatinine/0.9)**(-1.209) * (0.993)**(age))
    if baseline_creatinine = 0
        baseline_egfr = 0 #I.e. if no available baseline creatinine, no eGFR

    baseline_egfr_below_15_category=patients.categorised_as(
        {
            "1": NOT "baseline_egfr = "0"" AND "baseline_egfr < 15" #eGFR <15
            "0": "baseline_egfr = "0"" OR "baseline_egfr >= 15" #eGFR >=15
        },
        ),
        return_expectations={
            "category":{"ratios": {"0": 0.99, "1": 0.01}}
        },
    )
 
    #From: https://github.com/opensafely/COVID-19-vaccine-breakthrough/blob/updates-november/analysis/study_definition.py
    #Dialysis
    dialysis = patients.with_these_clinical_events(
        dialysis_codes,
        find_last_match_in_period = True,
        returning = "date",
        date_format = "YYYY-MM-DD",
        on_or_before = "covid_diagnosis_date",
        ),
   
    # Kidney transplant
    kidney_transplant = patients.with_these_clinical_events(
        kidney_transplant_codes, 
        returning = "date",
        date_format = "YYYY-MM-DD",
        find_last_match_in_period = True,
        on_or_before = "covid_diagnosis_date"
        ),

    end_stage_renal_disease=patients.satisfying(
        "dialysis OR kidney_transplant OR baseline_egfr_below_15",
            dialysis=patients.with_these_clinical_events(
                filter_codes_by_category(dialysis_codes, include=["dialysis"]),
                on_or_before = "covid_diagnosis_date", #Does this need to be re-specified given it is already defined above?
            ),
            kidney_transplant=patients.with_these_clinical_events(
                filter_codes_by_category(kidney_transplant_codes, include=["kidney_transplant"]),
                on_or_before = "covid_diagnosis_date",
            ),
            baseline_egfr_below_15=patients.satisfying(
                filter_codes_by_category(baseline_egfr_below_15_category, include=["1"])) #"1" = eGFR <15
        ),

    #Excluding anyone who died before patient_index_date (i.e.within 28 days of covid_diagnosis_date)
    died_before_patient_index_date=patients.died_date_gp(
        on_or_before="patient_index_date")
    
    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT covid_classification = "0"
        AND NOT stp = ""
        AND NOT died_before_patient_index_date
        AND NOT end_stage_renal_disease
        """,
        ),

