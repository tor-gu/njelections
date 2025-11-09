# Set up ----
year <- 2024
office <- "President"

county_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
column_repair_table <- NULL
file_name_base_template <- "{year}-official-general-results-president-{county}"

essex_corrections <- get_municipalities(2024) |>
  dplyr::filter(county == "Essex County") |>
  dplyr::rename(corrected_name = municipality) |>
  dplyr::mutate(municipality = stringr::str_remove(corrected_name, " \\w*$")) |>
  dplyr::select(-GEOID)
additional_municipal_corrections <- essex_corrections

additional_data <- NULL
vote_corrections <- NULL
candidate_table <- tribble(
  ~name, ~party,
  "Kamala D. Harris",          "Democratic",
  "Donald J. Trump",           "Republican",
  "Jill Stein",                "Green Party",
  "Robert F. Kennedy Jr.",     "Independent",
  "Chase Oliver",              "Libertarian Party",
  "Claudia De la Cruz",        "Socialism and Liberation",
  "Randall A. Terry",          "U.S. Constitution Party",
  "Joseph Kishore",            "Socialist Equality",
  "Rachele Fruit",             "Socialist Workers Party",
)

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections, tabulizer = FALSE)


