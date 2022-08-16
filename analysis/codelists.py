#Outstanding - vasculitis codelist - being developed?

#Manual codelists:
#critical_care_opcs_4
    #NB - search terms: intensive, critical, intubation, ventilation, mechanical, invasive, haemofiltration,
        #vasopressor, inotrope, central, arterial, artery, pressure, flow, optiflow, nasal, high-flow,
        #paralysis, noradrenaline, norepinephrine, rocuronium, cardiac output, organ
#acute_kidney_injury_icd_10
#kidney_replacement_therapy_icd_10
    #NB - very few kidney transplant codes in icd_10
#kidney_replacement_therapy_opcs_4

# Some covariates used in the study are created from codelists of clinical conditions or 
# numerical values available on a patient records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.
# Import code building blocks from cohort extractor package
from cohortextractor import (codelist, codelist_from_csv, combine_codelists)

#Exposure/outcome codes
#Hospital COVID
covid_codes = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)
#Primary care COVID
covid_primary_care_positive_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3",
    column="CTV3ID",
)
covid_primary_care_code = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3",
    column="CTV3ID",
)
covid_primary_care_sequalae = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
)
any_covid_primary_care_code = combine_codelists(
    covid_primary_care_code,
    covid_primary_care_positive_test,
    covid_primary_care_sequalae,
)
#Creatinine
    #Measurements to be used for calculation of eGFR to:
        #1. Exclude people with eGFR <15 at the index date
        #2. 50% reduction in eGFR as a post-COVID outcome
        #3. Determine eGFR category as a covariable
creatinine_codes = codelist_from_csv(
    "codelists/user-bangzheng-creatinine-value.csv",
    system="snomed",
    column="code",
)
#Critical care 
    #OPCS-4 procedural codes to determine people hospitalised with COVID admitted to critical care
critical_care_codes = codelist_from_csv(
    "codelists/user-viyaasan-critical-care.csv",
    system="opcs4",
    column="code",
)
mechanical_ventilation_codes = codelist_from_csv(
    "codelists/user-viyaasan-mechanical-ventilation.csv",
    system="opcs4",
    column="code",
)
non_invasive_ventilation_codes = codelist_from_csv(
    "codelists/user-viyaasan-non-invasive-ventilation.csv",
    system="opcs4",
    column="code",
)
#Acute kidney injury
    #ICD-10 codes to determine:
        #1. People hospitalised with COVID with acute kidney injury
        #2. Acute kidney injury as a post-COVID outcome
acute_kidney_injury_codes = codelist_from_csv(
    "codelists/user-viyaasan-acute-kidney-injury.csv",
    system="icd10",
    column="code",
)
#Kidney replacement therapy
    #ICD-10 and OPCS-4 codes to determine:
        #1. People with COVID-19 who required acute kidney replacement therapy
        #2. End-stage renal disease as a post-COVID outcome
        #NB this includes acute and chronic kidney replacement therapy codes
kidney_replacement_therapy_icd_10_codes = codelist_from_csv(
    "codelists/user-viyaasan-kidney-replacement-therapy.csv",
    system="icd10",
    column="code",
)
kidney_replacement_therapy_opcs_4_codes = codelist_from_csv(
    "codelists/user-viyaasan-kidney-replacement-therapy-opcs-4.csv",
    system="opcs4",
    column="code",
)
dialysis_icd_10_codes = codelist_from_csv(
    "codelists/user-viyaasan-dialysis.csv",
    system="icd10",
    column="code",
)
dialysis_opcs_4_codes = codelist_from_csv(
    "codelists/user-viyaasan-dialysis-opcs-4.csv",
    system="opcs4",
    column="code",
)
dialysis_codes = codelist_from_csv(
    "codelists/opensafely-dialysis.csv",
    system="ctv3",
    column="CTV3ID"
)
kidney_transplant_codes = codelist_from_csv(
    "codelists/opensafely-kidney-transplant.csv",
    system="ctv3",
    column="CTV3ID"
)
kidney_replacement_therapy_primary_care_codes = combine_codelists(
    dialysis_codes,
    kidney_transplant_codes,
)
haemofiltration_opcs_4_codes = codelist_from_csv(
    "codelists/user-viyaasan-haemofiltration.csv",
    system="opcs4",
    column="code",
)
    #NB this codelist contains a glomerulonephritis code which needs to be removed
#Pneumonia
    #ICD-10 codes to restrict additional comparator population to people with hospitalised pneumonia in 2018-2019
pneumonia_codelist = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)

#Covariable codes

#Ethnicity
    #https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/codelists.py
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
#Atrial fibrillation
atrial_fibrillation_or_flutter_codes = codelist_from_csv(
    "codelists/opensafely-atrial-fibrillation-or-flutter.csv",
    system="ctv3",
    column="CTV3Code",
)
#Chronic liver disease
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv",
    system="snomed",
    column="code",
)
#Diabetes
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv",
    system="snomed",
    column="id",
)
#Haematological cancer
haematological_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer-snomed.csv",
    system="snomed",
    column="id",
)
#Heart failure
heart_failure_codes = codelist_from_csv(
    "codelists/opensafely-heart-failure.csv",
    system="ctv3",
    column="CTV3ID",
)
#HIV
hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv-snomed.csv",
    system="snomed",
    column="id",
)
#Hypertension
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv",
    system="snomed",
    column="id",
)
#Non-haematological cancer
cancer_excluding_lung_and_haematological_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological-snomed.csv",
    system="snomed",
    column="id",
)
lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer-snomed.csv",
    system="snomed",
    column="id",
)
non_haematological_cancer_codes = combine_codelists(
    cancer_excluding_lung_and_haematological_codes,
    lung_cancer_codes,
)
#Myocardial infarction
myocardial_infarction_codes = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction.csv",
    system="ctv3",
    column="CTV3ID",
)
#Peripheral vascular disease
peripheral_vascular_disease_codes = codelist_from_csv(
    "codelists/opensafely-peripheral-arterial-disease.csv",
    system="ctv3",
    column="code",
)
#Rheumatoid arthritis
rheumatoid_arthritis_codes = codelist_from_csv(
    "codelists/opensafely-rheumatoid-arthritis.csv",
    system="ctv3",
    column="CTV3ID",
)
#Stroke
stroke_codes = codelist_from_csv(
    "codelists/opensafely-stroke-snomed.csv",
    system="snomed",
    column="id",
)
#Systemic lupus erythematosus
systemic_lupus_erythematosus_codes = codelist_from_csv(
    "codelists/opensafely-systemic-lupus-erythematosus-sle.csv",
    system="ctv3",
    column="CTV3ID",
)
#Smoking
smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)
#Body mass index
body_mass_index_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv",
    system="snomed",
    column="code",
)
#Immunosuppression
    #This codelist does not appear to be signed off
    #NB snomed rather than dm+d
    #Alternatively: https://www.opencodelists.org/codelist/primis-covid19-vacc-uptake/immrx/v1/
immunosuppression_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression-snomed.csv",
    system="snomed",
    column="id",
)