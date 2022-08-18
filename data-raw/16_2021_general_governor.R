# Set up ----
year <- 2021
office <- "Governor"

county_table_updates <- tribble(
  ~standard_name, ~updated_name, ~updated_rev,
  "capemay",      "cape-may",    "",
)

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Cape-May", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Philip Murphy",             "Democratic",
  "Jack Ciattarelli",          "Republican",
  "Madelyn R. Hoffman",        "Green Party",
  "Gregg Mele",                "Libertarian Party",
  "Joanne Kuniansky",          "Socialist Workers Party",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-general-election-results-governor-{county}"

additional_data <- NULL
additional_municipal_corrections <- NULL

# Go ---
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

