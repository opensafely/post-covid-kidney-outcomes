#Need to add:
    #dialysis_codes +/- haemofiltration_codes (ICD-10 & OPCS-4)
    #acute_kidney_injury_codes (ICD-10)
    #critical_care_codes (ICD-10)
    #kidney transplant (ICD-10)

#Note:
    #opensafely-kidney-transplant contains a glomerulonephritis code which needs to be removed
    #?system to define drug codelists

#Codelists from OpenCodelists in codelists.txt:
    #opensafely/antidiabetic-drugs
    #opensafely/atrial-fibrillation-or-flutter
    #opensafely/cancer-excluding-lung-and-haematological
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
    #opensafely/pneumonia-secondary-care
    #opensafely/sickle-cell-disease-snomed
    #opensafely/smoking-clear-snomed
    #opensafely/stroke-snomed
    #opensafely/warfarin
    #primis-covid19-vacc-uptake/bmi
    #primis-covid19-vacc-uptake/cld
    #primis-covid19-vacc-uptake/resp_cov

# Some covariates used in the study are created from codelists of clinical conditions or 
# numerical values available on a patient records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.

# Import code building blocks from cohort extractor package
from cohortextractor import (codelist, codelist_from_csv, combine_codelists)

covid_codes = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)
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
creatinine_codes = codelist(["XE2q5"], system="ctv3"
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
pneumonia_codelist = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
atrial_fibrillation_or_flutter_codes = codelist_from_csv(
    "codelists/opensafely-atrial-fibrillation-or-flutter.csv",
    system="ctv3",
    column="CTV3ID",
)
cancer_excluding_lung_and_haematological_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)
dementia_codes = codelist_from_csv(
    "codelists/opensafely-dementia-snomed.csv",
    system="snomed",
    column="code",
)
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv",
    system="snomed",
    column="code",
)
haematological_cancer_codes = codelist_from_csv(
    "codelists/haematological-cancer-snomed.csv",
    system="snomed",
    column="code",
)
heart_failure_codes = codelist_from_csv(
    "codelists/opensafely-heart_failure.csv",
    system="ctv3",
    column="CTV3ID",
)
hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv",
    system="ctv3",
    column="CTV3ID",
)
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv",
    system="snomed",
    column="code",
)
myocardial_infarction_codes = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction.csv",
    system="ctv3",
    column="CTV3ID",
)
other_neurological_conditions_codes = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions-snomed.csv",
    system="snomed",
    column="code",
)
sickle_cell_disease_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease-snomed.csv",
    system="snomed",
    column="code",
)
smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear-snomed.csv",
    system="snomed",
    column="code",
)
stroke_codes = codelist_from_csv(
    "codelists/opensafely-stroke-snomed.csv",
    system="snomed",
    column="code",
)
bmi_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv",
    system="snomed",
    column="code",
)
bmi_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv",
    system="snomed",
    column="code",
)
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv",
    system="snomed",
    column="code",
)
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv",
    system="snomed",
    column="code",
)
chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-resp_cov.csv",
    system="snomed",
    column="code",
)