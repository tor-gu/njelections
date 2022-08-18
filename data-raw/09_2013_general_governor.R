# Set up ----
year <- 2013
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
  "Chris Christie",          "Republican",
  "Barbara Buono",           "Democratic",
  "William Araujo",          "Peace and Freedom",
  "Jeff Boss",               "NSA DID 911",
  "Kenneth R. Kaplan",       "Libertarian Party",
  "Diane W. Sare",           "Glass-Steagall Now",
  "Hank Schroeder",          "Independent",
  "Steven Welzer",           "Green Party",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-general-election-results-governor-{county}"

additional_data <- list(
  burlington = '
V1   [,1]               [,2]     [,3]     [,4]  [,5] [,6]  [,7]  [,8]  [,9]
[1,] "MUNICIPALITIES"   ""       ""       ""    ""   ""    ""    ""    ""
[2,] "Tabernacle Twp."  "1,850"  "557"    "4"   "0"  "22"  "4"   "2"   "8"
[3,] "Washington Twp."  "156"    "61"     "0"   "0"  "8"   "0"   "0"   "2"
[4,] "Westampton Twp."  "1,410"  "1,187"  "5"   "2"  "16"  "0"   "6"   "4"
[5,] "Willingboro Twp." "2,453"  "6,513"  "11"  "5"  "15"  "6"   "2"   "12"
[6,] "Woodland Twp."    "310"    "107"    "1"   "0"  "4"   "2"   "0"   "2"
[7,] "Wrightstown Boro" "63"     "35"     "0"   "0"  "1"   "0"   "0"   "0"
  ',
  morris = '
 V1   [,1]                   [,2]     [,3]     [,4]  [,5]  [,6]    [,7]  [,8]  [,9]
 [1,] "MUNICIPALITIES"       ""       ""       ""    ""    ""      ""    ""    ""
 [2,] "Randolph Twp"         "4,838"  "2,065"  "5"   "5"   "52"    "6"   "13"  "40"
 [3,] "Riverdale Boro"       "795"    "329"    "0"   "0"   "10"    "0"   "0"   "2"
 [4,] "Rockaway Boro"        "1,146"  "476"    "2"   "2"   "9"     "4"   "8"   "11"
 [5,] "Rockaway Twp"         "5,071"  "2,396"  "8"   "5"   "59"    "15"  "17"  "33"
 [6,] "Roxbury Twp"          "4,996"  "1,996"  "3"   "5"   "72"    "15"  "31"  "28"
 [7,] "Victory Gardens Boro" "90"     "90"     "3"   "0"   "0"     "1"   "2"   "0"
 [8,] "Washington Twp"       "4,467"  "1,330"  "5"   "3"   "40"    "12"  "7"   "53"
 [9,] "Wharton Boro"         "892"    "434"    "1"   "1"   "12"    "2"   "3"   "8"
 '
)
additional_municipal_corrections <- NULL

vote_corrections <- tribble(
  ~county,            ~municipality,            ~candidate,          ~vote,
  "Hunterdon County", "West Amwell township",   "Jeff Boss",         0,
  "Hunterdon County", "West Amwell township",   "Kenneth R. Kaplan", 13,
  "Hunterdon County", "West Amwell township",   "Diane W. Sare",     4,
  "Hunterdon County", "West Amwell township",   "Hank Schroeder",    2,
  "Hunterdon County", "West Amwell township",   "Steven Welzer",     8,
  "Union County",     "Winfield township",      "Diane W. Sare",     0,
  "Union County",     "Winfield township",      "Hank Schroeder",    0,
  "Union County",     "Winfield township",      "Steven Welzer",     4,
)

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

