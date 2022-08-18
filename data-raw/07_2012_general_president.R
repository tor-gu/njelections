# Set up ----
year <- 2012
office <- "President"

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
  "Barack Obama",             "Democratic",
  "Mitt Romney",              "Republican",
  "Gary Johnson",             "Libertarian Party",
  "Jill Stein",               "Green Party",
  "Virgil Goode",             "Constitution Party",
  "Ross C. (Rocky) Anderson", "NJ Justice Party",
  "Jeff Boss",                "NSA DID 911",
  "James Harris",             "Socialist Workers Party",
  "Merlin Miller",            "American Third Position",
  "Peta Lindsay",             "Socialism and Liberation"
)
column_repair_table <- NULL

file_name_base_template <- "{year}-presidential-{county}"
additional_data <- NULL
additional_municipal_corrections < NULL
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

# In 2012, the Princetons did not report their totals separately,
# even though the towns were not merged until January 2013.
# As a result, we are force to use the 2013 municipality list
# for 2012. (The Princeton merger is the only change from 2012 to 2013,
# fortunately.)
election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections, municipality_year = 2013)




