# Set up ----
year <- 2004
office <- "President"

county_table_updates <- tribble(
  ~standard_name, ~updated_name, ~updated_rev,
  "ocean",        "ocean",       "_1.26.05",
)
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "John F. Kerry",             "Democratic",
  "George W. Bush",            "Republican",
  "Ralph Nader",               "Independent",
  "Michael Badnarik",          "Libertarian Party",
  "Michael A. Peroutka",       "Constitution Party",
  "David Cobb",                "Green Party",
  "Bill Van Auken",            "Socialist Equity Party",
  "Walter Brown",              "Socialist Party USA",
  "Roger Calero",              "Socialist Workers Party",
)
column_repair_table <- NULL
file_name_base_template <- "{year}-presidential_{county}_co_{year}{rev}"

additional_data <- NULL

# All the Atlantic County municipalities have their town/borough/city/etc
# suffixes stripped. We need to add them as corrections.
atlantic_corrections <- get_municipalities(2004) |>
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
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)
