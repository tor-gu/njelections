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
# Not used on the tabulizer path, but declared so the script is self-contained.
candidate_table <- NULL

# All the Atlantic County municipalities have their town/borough/city/etc
# suffixes stripped, exactly as in 01_2004_general_president.R. Defined locally
# so this script is self-contained (cf. essex_corrections in 14_/15_/18_).
# The 2004 and 2016 Atlantic County lists are identical, so the year is immaterial.
atlantic_corrections <- get_municipalities(2016) |>
  dplyr::filter(county == "Atlantic County") |>
  dplyr::rename(corrected_name = municipality) |>
  dplyr::mutate(municipality = stringr::str_remove(corrected_name, " \\w*$")) |>
  dplyr::select(-GEOID)
additional_municipal_corrections <- atlantic_corrections
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template,
  additional_data, additional_municipal_corrections,
  vote_corrections, tabulizer = TRUE)

# Manually normalize name of Roque "Rocky" De la Fuente
# (De la Fuente runs again in 2020)
election_by_municipality <- election_by_municipality |>
  mutate(candidate = if_else(
    year == 2016 & office == "President" & str_detect(candidate, "Fuente"),
    'Roque "Rocky" De la Fuente', candidate
  ))

