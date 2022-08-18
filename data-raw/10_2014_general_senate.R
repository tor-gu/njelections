# Set up ----
year <- 2014
office <- "Senate"
county_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
order_dir <- fs::path("data-raw", "2014-Order")
candidate_table <- tribble(
  ~name, ~party,
  "Jeff Bell",               "Republican",
  "Cory Booker",             "Democratic",
  "Antonio N. Sabas",        "Independent",
  "Joseph Baratelli",        "Libertarian Party",
  "Jeff Boss",               "Independent",
  "Eugene Martin LaVergne",  "D-R Party",
  "Hank Schroeder",          "Economic Growth",
)
column_repair_table <- NULL

file_name_base_template <- "{year}-us-senate-gen-elec-results-by-county-{county}"

additional_data <- NULL
additional_municipal_corrections <- NULL
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)
candidate_table <- order_candidates(candidate_table, county_table, order_dir)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)


