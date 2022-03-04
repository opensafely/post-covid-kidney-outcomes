#study_definition_potential_historical_general_population will be matched to 
    #study_definition_covid_all_for_matching

#Only matching variables and exclusion variables need to be extracted at this stage

#Matching variables:
# - age
# - sex
# - stp
# - imd
# - covid_diagnosis_date_minus_2_years (from match_historical based on study_definition_covid_all_for_matching)

#Exclusion variables:
# - renal_replacement_therapy
# - baseline_egfr_below_15
# - died_before_patient_index_date_minus_two_years (using patient_died_date_gp)

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
    #covid_diagnosis_date_minus_2_years is defined in match_historical - will this interact with this study_defintion?

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
            date_format="YYYY-MM-DD"
            return_expectations={
                "incidence": 0.01,}
    ),