#I don't think the following will work
#Is it possible to use "OR"?
#I.e. covid_codes AND kidney_replacement_therapy_icd_10 OR kidney_replacement_therapy_opcs_4
covid_hospitalised_dialysis=patients.admitted_to_hospital(
    with_these_diagnoses=covid_codes AND hospital_kidney_replacement_therapy_date,
    returning="date_admitted",
    between = ["covid_diagnosis_date", "covid_diagnosis_date + 28 days"],
    date_format="YYYY-MM-DD",
    find_first_match_in_period=True,
    return_expectations={"incidence": 0.005, "date": {"earliest": "index_date"}},
),    

unvaccinated_covid = patients.satisfying(
    ""
        sars_cov_2 = "SARS-COV-2"
    AND covid_vax_1_date = "0"
    ""
        between = ["2020-11-01", "covid_diagnosis_date - 7 days"]
        return_expectations={
            "incidence": 0.4,},
),
single_vaccinated_covid = patients.satisfying(
    ""
        sars_cov_2 = "SARS-COV-2"
    AND covid_vax_2_date = "0"
    ""
        between = ["2020-11-01", "covid_diagnosis_date - 7 days"]
        return_expectations={
            "incidence": 0.2,},
),
double_vaccinated_covid = patients.satisfying(
    ""
        sars_cov_2 = "SARS-COV-2"
    AND covid_vax_3_date = "0"
    ""
        between = ["2020-11-01", "covid_diagnosis_date - 7 days"]
        return_expectations={
            "incidence": 0.2,},
),
triple_vaccinated_covid = patients.satisfying(
    ""
        sars_cov_2 = "0"
    AND covid_vax_3_date < "covid_diagnosis_date - 7 days"
    ""
        return_expectations={
            "incidence": 0.2,},
),