# Set up ----
year <- 2008
office = "President"

county_table_updates <- tribble(
  ~standard_name, ~updated_name, ~updated_rev,
  "capemay",      "cape-may",    "",
  "mercer",       "mercer",      ".rev",
)
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Cape-May", "Cape May",
)

candidate_table <- tribble(
  ~name, ~party,
  "Barack Obama",             "Democratic",
  "John McCain",              "Republican",
  "Ralph Nader",              "Independent",
  "Bob Barr",                 "Libertarian Party",
  "Chuck Baldwin",            "Constitution Party",
  "Cynthia McKinney",         "Green Party",
  "Brian Moore",              "Socialist Party USA",
  "Jeff Boss",                "Vote Here",
  "Roger Calero",             "Socialist Workers Party",
  "Gloria La Riva",           "Socialism and Liberation",
)

column_repair_table <- NULL
file_name_base_template <- "{year}-gen-elect-presidential-results-{county}{rev}"
additional_data <- list(
  hunterdon = '
V1   [,1]                [,2]     [,3]     [,4]  [,5]  [,6] [,7]   [,8]        [,9] [,10] [,11]
[1,] "MUNICIPALITIES"    ""        ""       ""   ""    ""    ""    ""          ""   ""    ""
[2,] "Tewksbury Twp"     "1,403"  "2,280"  "10"  "22"  "2"  "5"    "0"         "0"  "0"   "0"
[3,] "Union Twp"         "1,030"  "1,568"  "17"  "13"  "2"  "2"    "0"         "0"  "1"   "0"
[4,] "West Amwell Twp"   "814"    "878"    "9"   "7"   "6"  "1"    "0"         "1"  "0"   "0"
  ',
  monmouth = '
V1   [,1]                [,2]     [,3]     [,4]  [,5]  [,6] [,7]   [,8]        [,9] [,10] [,11]
[1,] "MUNICIPALITIES"        ""        ""        ""      ""    ""    ""    ""   ""   ""    ""
[2,] "Upper Freehold Twp"    "1,461"   "2,337"   "15"    "19"  "2"   "4"   "0"  "0"  "0"   "0"
[3,] "Wall Twp"              "5,607"   "9,243"   "93"    "29"  "22"  "24"  "1"  "1"  "2"   "0"
[4,] "West Long Branch Boro" "1,524"   "2,208"   "28"    "12"  "2"   "3"   "1"  "0"  "1"   "0"
  '
)
additional_municipal_corrections <- NULL
vote_corrections <- tribble(
  ~county,             ~municipality,       ~candidate,       ~vote,
  "Gloucester County", "Woolwich township", "Gloria La Riva", 0,
)


# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

