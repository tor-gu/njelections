# Set up ----
year <- 2025
office <- "Governor"

county_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Mikie Sherrill",            "Democratic",
  "Jack Ciattarelli",          "Republican",
  "Vic Kaplan",                "Libertarian Party",
  "Joanne Kuniansky",          "Socialist Workers Party",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-official-general-results-governor-{county}"

additional_data <- NULL
additional_municipal_corrections <- NULL
vote_corrections <- NULL

# Go ---
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

