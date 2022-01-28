from cohortextractor import codelist_from_csv, StudyDefinition, patients

CONTROLS = "output/matched_contemporary_general_population.csv"
codelist = codelist_from_csv("codelists/codelist.csv")

study = StudyDefinition(
    index_date="2021-02-01",  # Ignored
    population=patients.which_exist_in_file(CONTROLS),
    case_index_date=patients.with_value_from_file(
        CONTROLS,
        returning="case_index_date",
        returning_type="date",
    ),
    has_event_in_codelist=patients.with_these_clinical_events(
        codelist,
        on_or_after="case_index_date",
    ),
)
