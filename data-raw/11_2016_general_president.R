# Set up ----
year <- 2016
office <- "President"
county_table <- NULL

county_table_updates <- tribble(
  ~standard_name, ~updated_name, ~updated_rev,
  "capemay",      "cape-may",    "",
)

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Cape-May", "Cape May",
)

column_repair_table <- tribble(
  ~starts_with, ~repaired_value,
  "Alyson Kennedy", "Alyson Kennedy\rSocialist Workers Party",
  "Gloria La Riva", "Gloria La Riva\rSocialism and Liberation",
  "Darrell Castle", "Darrell Castle\rConstitution Party",
)

file_name_base_template <- "{year}-gen-elect-presidential-results-{county}"
additional_data <- NULL

additional_municipal_corrections <- atlantic_corrections
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections, tabulizer = TRUE)

# Manually normalize name of Roque "Rocky" De la Fuente
# (De la Fuente runs again in 2020)
election_by_municipality <- election_by_municipality |>
  mutate(candidate = if_else(
    year == 2016 & office == "President" & str_detect(candidate, "Fuente"),
    'Roque "Rocky" De la Fuente', candidate
  ))

