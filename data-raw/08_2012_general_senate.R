# Set up ----
year <- 2012
office <- "Senate"

county_table_updates <- NULL
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Robert Menendez",             "Democratic",
  "Joe Kyrillos",                "Republican",
  "Kenneth R. Kaplan",           "Libertarian Party",
  "Ken Wolski",                  "Green Party",
  "Gwen Diakos",                 "Jersey Strong Independents",
  "J. David Dranikoff",          "Totally Independent Candidate",
  "Inder \"Andy\" Soni",         "America First",
  "Robert \"Turk\" Turkavage",   "Responsibility Fairness Integrity",
  "Gregory Pason",               "Socialist Party USA",
  "Eugene Martin LaVergne",      "Independent",
  "Daryl Mikell Brooks",         "Reform Nation",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-county-us-senate-{county}"
additional_data <- NULL
additional_municipal_corrections <- NULL
vote_corrections <- tribble(
  ~county,        ~municipality,       ~candidate,            ~vote,
  "Ocean County", "Tuckerton borough", "Daryl Mikell Brooks", 0,
)

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

