#Need to add:
    #dialysis_codes +/- haemofiltration_codes (ICD-10 & OPCS-4)
    #acute_kidney_injury_codes (ICD-10)
    #critical_care_codes (OPCS-4)
    #kidney transplant (ICD-10 & OPCS-4)

#Note:
    #opensafely-kidney-transplant contains a glomerulonephritis code which needs to be removed
    #?system to define drug codelists

#Codelists from OpenCodelists in codelists.txt:
    #opensafely/antidiabetic-drugs
    #opensafely/atrial-fibrillation-or-flutter
    #opensafely/cancer-excluding-lung-and-haematological-snomed
    #opensafely/covid-identification
    #opensafely/covid-identification-in-primary-care-probable-covid-positive-test
    #opensafely/covid-identification-in-primary-care-probable-covid-clinical-code
    #opensafely/covid-identification-in-primary-care-probable-covid-probable-covid-sequelae
    #opensafely/dementia-snomed
    #opensafely/diabetes-snomed
    #opensafely/dialysis
    #opensafely/direct-acting-oral-anticoagulants-doac
    #opensafely/ethnicity
    #opensafely/haematological-cancer-snomed
    #opensafely/heart-failure
    #opensafely/hiv-snomed
    #opensafely/hypertension-snomed
    #opensafely/insulin-medication
    #opensafely/kidney-transplant
    #opensafely/low-molecular-weight-heparins-dmd   
    #opensafely/myocardial-infarction
    #opensafely/other-neurological-conditions-snomed
    #opensafely/peripheral-arterial-disease
    #opensafely/pneumonia-secondary-care
    #opensafely/rheumatoid-arthritis
    #opensafely/sickle-cell-disease-snomed
    #opensafely/smoking-clear-snomed
    #opensafely/stroke-snomed
    #opensafely/systemic-lupus-erythematosis-sle
    #opensafely/warfarin
    #primis-covid19-vacc-uptake/bmi
    #primis-covid19-vacc-uptake/cld
    #primis-covid19-vacc-uptake/resp_cov

#Manual codelists:

#critical_care_opcs_4
    #NB - search terms: intensive, critical, intubation, ventilation, mechanical, invasive, haemofiltration,
        #vasopressor, inotrope, central, arterial, artery, pressure, flow, optiflow, nasal, high-flow,
        #paralysis, noradrenaline, norepinephrine, rocuronium, cardiac output, organ
#acute_kidney_injury_icd_10
#esrd_icd_10
    #NB - very few kidney transplant codes in icd_10 - is this correct?
#esrd_opcs_4

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
creatinine_codes = codelist(["XE2q5"], system="ctv3"
)
#Critical care 
    #OPCS-4 procedural codes to determine people hospitalised with COVID admitted to critical care
    #Need to clarify "column"
critical_care = codelist_from_csv(
    "codelists/critical_care_opcs_4",
    system="opcs4",
    column="????",
)
#Acute kidney injury
    #ICD-10 codes to determine:
        #1. People hospitalised with COVID with acute kidney injury
        #2. Acute kidney injury as a post-COVID outcome
acute_kidney_injury_icd_10 = codelist_from_csv(
    "codelists/acute_kidney_injury_icd_10",
    system="icd10",
    column="icd10_code",
)
#End-stage renal disease
    #ICD-10 and OPCS-4 codes to determine:
        #1. People with COVID-19 who required acute kidney replacement therapy
        #2. End-stage renal disease as a post-COVID outcome
        #NB this includes acute and chronic kidney replacement therapy codes
end_stage_renal_disease_icd_10 = codelist_from_csv(
    "codelists/end_stage_renal_disease_icd_10",
    system="icd10",
    column="icd10_code",
)
end_stage_renal_disease_opcs_4 = codelist_from_csv(
    "codelists/end_stage_renal_disease_icd_10",
    system="opcs4",
    column="????",
)
dialysis_codes = codelist_from_csv(
    "codelists/opensafely-dialysis.csv"
    system="ctv3"
    column="CTV3ID"
)
kidney_transplant_codes = codelist_from_csv(
    "codelists/opensafely-kidney-transplant.csv",
    system="ctv3",
    column="CTV3ID"
)
#Pneumonia
    #ICD-10 codes to restrict additional comparator population to people with hospitalised pneumonia in 2018-2019
pneumonia_codelist = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)

#Covariable codes
#Missing:
#vasculitis - UCL?
#Drugs
#Vaccines

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
    column="CTV3ID",
)
#Chronic liver disease
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv",
    system="snomed",
    column="code",
)
#Chronic respiratory disease
chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-resp_cov.csv",
    system="snomed",
    column="code",
)
#Dementia
dementia_codes = codelist_from_csv(
    "codelists/opensafely-dementia-snomed.csv",
    system="snomed",
    column="code",
)
#Diabetes
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv",
    system="snomed",
    column="code",
)
#Haematological cancer
haematological_cancer_codes = codelist_from_csv(
    "codelists/haematological-cancer-snomed.csv",
    system="snomed",
    column="code",
)
#Heart failure
heart_failure_codes = codelist_from_csv(
    "codelists/opensafely-heart_failure.csv",
    system="ctv3",
    column="CTV3ID",
)
#HIV
hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv-snomed.csv",
    system="snomed",
    column="code",
)
#Hypertension
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv",
    system="snomed",
    column="code",
)
#Non-haematological cancer
cancer_excluding_lung_and_haematological_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological-snomed.csv",
    system="snomed",
    column="code",
)
lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer-snomed.csv",
    system="snomed",
    column="code",
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
#Other neurological conditions
other_neurological_conditions_codes = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions-snomed.csv",
    system="snomed",
    column="code",
)
#Peripheral vascular disease
peripheral_vascular_disease_codes = codelist_from_csv(
    "codelists/opensafely-peripheral-arterial-disease.csv",
    system="ctv3",
    column="CTV3ID",
)
#Rheumatoid arthritis
rheumatoid_arthritis_codes = codelist_from_csv(
    "codelists/opensafely-rheumatoid_arthritis.csv",
    system="ctv3",
    column="CTV3ID",
)
#Sickle cell disease
sickle_cell_disease_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease-snomed.csv",
    system="snomed",
    column="code",
)
#Stroke
stroke_codes = codelist_from_csv(
    "codelists/opensafely-stroke-snomed.csv",
    system="snomed",
    column="code",
)
#Systemic lupus erythematosus
systemic_lupus_erythematosus_codes = codelist_from_csv(
    "codelists/opensafely-systemic-lupus-erythematosis-sle.csv",
    system="ctv3",
    column="CTV3ID",
)
#Smoking
smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear-snomed.csv",
    system="snomed",
    column="code",
)
#BMI
bmi_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv",
    system="snomed",
    column="code",
)
