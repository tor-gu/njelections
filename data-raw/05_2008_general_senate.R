# Set up ----
year <- 2008
office <- "Senate"

county_table_updates <- NULL
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Frank Lautenberg",             "Democratic",
  "Dick Zimmer",                  "Republican",
  "Jason Scheurer",               "Libertarian Party",
  "J. M. Carter",                 "God We Trust",
  "Daryl Mikell Brooks",          "Poor People's Campaign",
  "Jeff Boss",                    "Boss For Senate",
  "Sara J. Lobman",               "Socialist Workers Party",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-gen-elect-senate-{county}"

additional_data <- NULL
# Dover became Toms River in 2007.
additional_municipal_corrections <- tribble(
  ~county,        ~municipality,    ~corrected_name,
  "Ocean County", "Dover township", "Toms River township"
)

vote_corrections <- tribble(
  ~county,         ~municipality,            ~candidate,            ~vote,
  "Camden County", "Laurel Springs borough", "J. M. Carter",        0,
  "Camden County", "Laurel Springs borough", "Daryl Mikell Brooks", 1,
  "Camden County", "Laurel Springs borough", "Jeff Boss",           0,
  "Camden County", "Laurel Springs borough", "Sara J. Lobman",      5,
)


# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

