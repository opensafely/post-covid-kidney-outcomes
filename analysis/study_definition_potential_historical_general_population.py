#study_definition_potential_historical_general_population will be matched to 
    #study_definition_covid_all_for_matching

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - patient_index_date (using sgss_positive, primary_care_covid or hospital_covid) 
    #from study_definition_covid_all_for_matching

#Exclusion variables:
# - end_stage_renal_disease
# - died_before_patient_index_date_minus_two_years (using patient_died_date_gp)

#Note:
# - Variables will be extracted at covid_diagnosis_date_minus_2_years 
    #(based on covid_diagnosis_date in study_definition_covid_all_for_matching)
# - Matching and follow-up will commence at patient_index_date_minus_2_years 
    # (i.e. 28 days after covid_diagnosis_date_minus_2_years)

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
) = generate_common_variables(index_date_variable="covid_diagnosis_date_minus_2_years")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.98, #increased incidence to 0.98 
    },

    index_date="2018-02-01",

    has_follow_up_minus_2_years=patients.registered_with_one_practice_between(
        "covid_diagnosis_date - 27 months", "covid_diagnosis_date - 2 years"
        ),
    
    #Excluding ESRD patients:
    #Establish baseline creatinine as for covid_all_for_matching 2 years earlier
    #NB missing floats/integers will be returned as 0 by default
    baseline_creatinine=patients.most_recent_creatinine(
        on_or_before="covid_diagnosis_date - 744 days" #I.e. 2 years and 14 days before covid_diagnosis_date from covid_all_for_matching
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "covid_diagnosis_date - 42 months", "latest": "covid_diagnosis_date - 744 days"},
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
        on_or_before = "covid_diagnosis_date - 744 days",
        ),
   
    # Kidney transplant
    kidney_transplant = patients.with_these_clinical_events(
        kidney_transplant_codes, 
        returning = "date",
        date_format = "YYYY-MM-DD",
        find_last_match_in_period = True,
        on_or_before = "covid_diagnosis_date - 744 days"
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
            baseline_egfr_below_15=patients.satisfying(
                filter_codes_by_category(baseline_egfr_below_15_category, include=["1"])) #"1" = eGFR <15
            ),
        ),

    #Excluding anyone who died before patient_index_date 
        #(i.e. within 28 days after covid_diagnosis_date_minus_2_years)
    died_before_patient_index_date_minus_2_years=patients.died_date_gp(
        on_or_before="patient_index_date_minus_2_years")

    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18)
        AND (sex = "M" OR sex = "F")
        AND imd > 0
        AND NOT stp = ""
        """,
        on_or_before = "2020-02-01"
        #intended to restrict to pre-pandemic data only (i.e. exclude covid_diagnosis_date)
        ),

    #When matching, anyone with eGFR <15 at covid_diagnosis_date_minus_2_years will need to be excluded
    #If not possible, will need to extract monthly creatinine measurements from August 2016 to January 2020
    #covid_diagnosis_date_minus_2_years is defined in match_historical

    #Baseline creatinine
    #NB missing floats/integers will be returned as 0 by default
    baseline_creatinine=patients.most_recent_creatinine(
        on_or_before="covid_diagnosis_date_minus_2_years - 14 days"
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "covid_diagnosis_date_minus_2_years - 18 months", "latest": "covid_diagnosis_date_minus_2_years - 14 days"},
            "float": {"distribution": "normal", "mean": 80, "stdev": 40},
            "incidence": 0.60,
        }
    )
    #CKD-EPI (2009) eGFR equation (Levey et al)
    if sex = "F" and baseline_creatinine <= 62 > 0 #Is this the correct way of specifying 0<SCr<=62?
        baseline_egfr = round(144*(baseline_creatinine/0.7)**(-0.329) * (0.993)**(age))
            include_measurement_date=True, #Is this the correct way of importing the date from baseline_creatinine?
            date_format="YYYY-MM-DD"
    if sex = "F" and baseline_creatinine > 62
        baseline_egfr = round(144*(baseline_creatinine/0.7)**(-1.209) * (0.993)**(age))
            include_measurement_date=True,
            date_format="YYYY-MM-DD"
    if sex = "M" and baseline_creatinine <= 80 > 0
        baseline_egfr = round(141*(baseline_creatinine/0.9)**(-0.411) * (0.993)**(age))
            include_measurement_date=True,
            date_format="YYYY-MM-DD"
    if sex = "M" and baseline_creatinine > 80
        baseline_egfr = round(141*(baseline_creatinine/0.9)**(-1.209) * (0.993)**(age))
            include_measurement_date=True,
            date_format="YYYY-MM-DD"
    if baseline_creatinine = 0
        baseline_egfr = 0 #I.e. if no available baseline creatinine, no eGFR
            include_measurement_date=False 

    baseline_egfr_below_15=patients.satisfying(
        ""
            baseline_egfr <15
        AND NOT baseline_egfr = "0"
        ""
        include_measurement_date=True
        return_expectations={
            "incidence": 0.01,}
    ),