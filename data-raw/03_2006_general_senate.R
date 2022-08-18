# Set up ----
year <- 2006
office <- "Senate"
county_table_updates <- NULL

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Robert Menendez",             "Democratic",
  "Thomas H. Kean, Jr.",         "Republican",
  "Len Flynn",                   "Libertarian Party",
  "Edward Forchion",             "Legalize Marijuana (G.R.I.P.)",
  "J. M. Carter",                "God We Trust",
  "N. Leonard Smith",            "Solidarity, Defend Life",
  "Daryl Mikell Brooks",         "Poor People's Campaign",
  "Angela L. Lariscy",           "Socialist Workers Party",
  "Gregory Pason",               "Socialist Party USA",
)

column_repair_table <- NULL
file_name_base_template <- "{year}-senate-{county}-final"
additional_municipal_corrections <- NULL
additional_data <- NULL
vote_corrections <- tribble(
  ~county,             ~municipality,            ~candidate,          ~vote,
  "Burlington County", "Southampton township",  "N. Leonard Smith",    9,
  "Burlington County", "Southampton township",  "Daryl Mikell Brooks", 5,
  "Burlington County", "Southampton township",  "Angela L. Lariscy",   3,
  "Burlington County", "Southampton township",  "Gregory Pason",       1,
  "Burlington County", "Springfield township",  "N. Leonard Smith",    1,
  "Burlington County", "Tabernacle township",   "N. Leonard Smith",    5,
  "Burlington County", "Washington township",   "N. Leonard Smith",    0,
  "Burlington County", "Westampton township",   "N. Leonard Smith",    1,
  "Burlington County", "Willingboro township",  "N. Leonard Smith",    25,
  "Burlington County", "Woodland township",     "N. Leonard Smith",    2,
  "Burlington County", "Wrightstown borough",   "N. Leonard Smith",    1,
)


# Go ----
county_table <- get_county_table(county_table_updates)

# The candidate list is permuted, but only for hunterdon county.  Rather than rely
# on a order directory, let's just do it manually.
candidate_table_hunterdon <- tribble(
  ~name, ~party,
  "Robert Menendez",             "Democratic",
  "Thomas H. Kean, Jr.",         "Republican",
  "Len Flynn",                   "Libertarian Party",
  "Edward Forchion",             "Legalize Marijuana (G.R.I.P.)",
  "N. Leonard Smith",            "Solidarity, Defend Life",
  "Daryl Mikell Brooks",         "Poor People's Campaign",
  "J. M. Carter",                "God We Trust",
  "Gregory Pason",               "Socialist Party USA",
  "Angela L. Lariscy",           "Socialist Workers Party",
)
candidate_table <- replicate(length(county_table$county),
                             candidate_table,
                             simplify = FALSE)
names(candidate_table) <- county_table$county
candidate_table$hunterdon <- candidate_table_hunterdon

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

