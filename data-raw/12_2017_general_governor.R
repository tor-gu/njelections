# Set up ----
year <- 2017
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
  "Kim Guadagno",              "Republican",
  "Gina Genovese",             "Reduce Property Taxes",
  "Peter J. Rohrman",          "Libertarian Party",
  "Seth Kaper-Dale",           "Green Party",
  "Matthew Riccardi",          "Constitution Party",
  "Vincent Ross",              "We The People",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-general-election-results-governor-{county}"

additional_data <- list(
  morris = '
V1  [,1]                   [,2]    [,3]    [,4] [,5] [,6] [,7] [,8]
[1,] "Randolph Twp"         "3,530" "3,558" "32" "33" "32" "14" "17"
[2,] "Riverdale Boro"       "479"   "683"   "7"  "10" "6"  "3"  "2"
[3,] "Rockaway Boro"        "783"   "993"   "7"  "6"  "5"  "9"  "7"
[4,] "Rockaway Twp"         "3,657" "4,025" "30" "50" "27" "21" "30"
[5,] "Roxbury Twp"          "2,557" "4,285" "35" "51" "19" "14" "22"
[6,] "Victory Gardens Boro" "136"   "42"    "1"  "1"  "0"  "0"  "3"
[7,] "Washington Twp"       "2,282" "3,814" "13" "26" "26" "10" "14"
[8,] "Wharton Boro"         "757"   "761"   "3"  "9"  "5"  "2"  "8"
  ',
  burlington = '
V1   [,1]               [,2]     [,3]     [,4]  [,5]  [,6]  [,7]  [,8]
[1,] "MUNICIPALITIES"   ""        ""      ""    ""    ""    ""    ""
[2,] "Tabernacle Twp."  "818"    "1,375"  "10"  "11"  "3"   "9"   "0"
[3,] "Washington Twp."  "85"     "111"    "1"   "3"   "0"   "0"   "0"
[4,] "Westampton Twp."  "1,770"  "1,038"  "7"   "14"  "7"   "12"  "0"
[5,] "Willingboro Twp." "8,011"  "794"    "23"  "13"  "17"  "30"  "8"
[6,] "Woodland Twp."    "136"    "227"    "5"   "5"   "2"   "5"   "2"
[7,] "Wrightstown Boro" "43"     "47"     "1"   "1"   "1"   "1"   "0"
[8,] "Total"            "70,453" "52,191" "465" "670" "384" "445" "106"
  '
)
additional_municipal_corrections <- NULL
vote_corrections <- NULL

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

