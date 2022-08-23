# Set up ----
year <- 2020
office <- "President"

county_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
column_repair_table <- NULL
file_name_base_template <- "{year}-official-general-results-president-{county}"

essex_corrections <- get_municipalities(2020) |>
  dplyr::filter(county == "Essex County") |>
  dplyr::rename(corrected_name = municipality) |>
  dplyr::mutate(municipality = stringr::str_remove(corrected_name, " \\w*$")) |>
  dplyr::select(-GEOID)
additional_municipal_corrections <- essex_corrections

additional_data <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections, tabulizer = TRUE)

