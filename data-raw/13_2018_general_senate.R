# Set up ----
year <- 2018
office <- "Senate"

county_table_updates <- NULL
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Robert Menendez",             "Democratic",
  "Bob Hugin",                   "Republican",
  "Tricia Flanagan",             "New Day NJ",
  "Madelyn R. Hoffman",          "Green Party",
  "Kevin Kimple",                "Keep It Simple",
  "Natalie Lynn Rivera",         "For The People",
  "Murray Sabrin",               "Libertarian Party",
  "Hank Schroeder",              "Economic Growth",
)
column_repair_table <- NULL
file_name_base_template <- "{year}-general-election-results-us-senate-{county}"

additional_data <- NULL

essex_corrections <- get_municipalities(2020) |>
  dplyr::filter(county=="Essex County") |>
  dplyr::rename(corrected_name=municipality) |>
  dplyr::mutate(municipality = stringr::str_remove(corrected_name, " \\w*$")) |>
  dplyr::select(-GEOID)
additional_municipal_corrections <- essex_corrections
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

