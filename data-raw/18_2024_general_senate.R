# Set up ----
year <- 2024
office <- "Senate"

count_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)

column_repair_table <- tribble(
  ~starts_with, ~repaired_value,
  "Andy Kim", "Andy Kim\rDemocratic",
  "Curtis Bashaw", "Curtis Bashaw\rRepublican",
  "Christina Khalil", "Christina Khalil\rGreen Party",
  "Kenneth R. Kaplan", "Kenneth R. Kaplan\rLibertarian Party",
  "Patricia G. Mooneyham", "Patricia G. Mooneyham\rVote Better",
  "Joanne Kuniansky", "Joanne Kuniansky\rSocialist Workers Party"
)

file_name_base_template <- "{year}-official-general-results-us-senate-{county}"

additional_data <- NULL

essex_corrections <- get_municipalities(2020) |>
  dplyr::filter(county == "Essex County") |>
  dplyr::rename(corrected_name = municipality) |>
  dplyr::mutate(municipality = stringr::str_remove(corrected_name, " \\w*$")) |>
  dplyr::select(-GEOID)
additional_municipal_corrections <- essex_corrections

candidate_table <- tribble(
  ~name, ~party,
  "Andy Kim",                "Democratic",
  "Curtis Bashaw",           "Republican",
  "Christina Khalil",        "Green Party",
  "Kenneth R. Kaplan",       "Libertarian Party",
  "Patricia G. Mooneyham",   "Vote Better",
  "Joanne Kuniansky",        "Socialist Workers Party",
)

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections, tabulizer = FALSE)

