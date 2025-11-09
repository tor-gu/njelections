# Set up ----
year <- 2009
office <- "Governor"

county_table_updates <- tribble(
  ~standard_name, ~updated_name, ~updated_rev,
  "capemay",      "cape-may",    "",
)

county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Cape-May", "Cape May",
)
order_dir <- fs::path("data-raw", "2009-Order")
candidate_table <- tribble(
  ~name, ~party,
  "Chris Christie",          "Republican",
  "Jon S. Corzine",          "Democratic",
  "Christopher J. Daggett",  "Independent for NJ",
  "Kostas Petris",           "For The People",
  "Kenneth R. Kaplan",       "Libertarian Party",
  "Jason Cullen",            "People Not Politics",
  "Gary Stein",              "Independent",
  "Gary T. Steele",          "Leadership, Independence, Vision",
  "Gregory Pason",           "Socialist Party USA",
  "David R. Meiswinkle",     "Middle Class Impowerment",
  "Joshua Leinsdorf",        "Fair Election Party",
  "Alvin Lindsay",           "Lindsay for Governor",
)

column_repair_table <- NULL

file_name_base_template <- "{year}-governor_results-{county}"
additional_data <- list(
  cumberland='
V1    [,1]                  [,2]     [,3]     [,4]    [,5]  [,6]  [,7]  [,8] [,9]   [,10] [,11] [,12] [,13]
 [1,] "MUNICIPALITIES"      ""       ""       ""      ""    ""    ""    ""   ""     ""    ""    ""    ""
 [2,] "Bridgeton City of"   "647"    "1806"   "118"   "11"  "10"  "9"   "3"  "6"    "4"   "1"   "0"   "0"
 [3,] "Commercial Twp"      "446"    "475"    "61"    "7"   "2"   "2"   "1"  "2"    "1"   "1"   "1"   "0"
 [4,] "Deerfield Twp"       "445"    "416"    "67"    "7"   "2"   "3"   "1"  "2"    "0"   "0"   "0"   "0"
 [5,] "Downe Twp"           "306"    "189"    "58"    "6"   "2"   "4"   "1"  "0"    "2"   "0"   "0"   "0"
 [6,] "Fairfield Twp"       "387"    "925"    "56"    "7"   "2"   "1"   "2"  "2"    "0"   "0"   "0"   "0"
 [7,] "Greenwich Twp"       "153"    "149"    "24"    "5"   "1"   "1"   "0"  "1"    "1"   "0"   "0"   "0"
 [8,] "Hopewell Twp"        "779"    "563"    "81"    "6"   "2"   "3"   "2"  "1"    "1"   "0"   "2"   "1"
 [9,] "Lawrence Twp"        "353"    "306"    "55"    "3"   "5"   "4"   "4"  "0"    "0"   "1"   "1"   "1"
[10,] "Maurice River Twp"   "533"    "467"    "94"    "16"  "8"   "2"   "5"  "1"    "1"   "0"   "0"   "1"
[11,] "Millville City"      "2675"   "3169"   "453"   "37"  "63"  "23"  "10" "12"   "7"   "2"   "4"   "0"
[12,] "Shiloh Boro"         "109"    "63"     "13"    "3"   "1"   "0"   "0"  "0"    "0"   "0"   "0"   "0"
[13,] "Stow Creek Twp"      "308"    "148"    "32"    "5"   "0"   "0"   "1"  "2"    "0"   "0"   "0"   "1"
[14,] "Upper Deerfield Twp" "1213"   "959"    "169"   "18"  "7"   "10"  "2"  "5"    "0"   "1"   "0"   "1"
[15,] "Vineland City"       "5725"   "7457"   "681"   "77"  "13"  "38"  "19" "15"   "13"  "6"   "2"   "2"
  ',
  bergen = '
V1   [,1]                  [,2]       [,3]      [,4]     [,5]  [,6]  [,7] [,8] [,9] [,10] [,11], [12], [13]
[1,] "MUNICIPALITIES"       ""        ""        ""       ""    ""    ""   ""   ""   ""    ""     ""    ""
[4,] "Westwood Boro"        "1905"    "1608"    "213"    "10"  "4"   "2"  "0"  "3"  "1"   "0"    "1"   "3"
[5,] "Woodcliff Lake Boro"  "1146"    "955"     "93"     "3"   "0"   "0"  "0"  "0"  "0"   "0"    "0"   "0"
[6,] "Wood-Ridge Boro"      "1362"    "1257"    "160"    "4"   "2"   "2"  "1"  "1"  "4"   "3"    "2"   "1"
[7,] "Wyckoff Twp"          "4288"    "2104"    "352"    "11"  "3"   "3"  "5"  "0"  "1"   "1"    "1"   "1"
  ',
  hudson = '
V1    [,1]                 [,2]     [,3]     [,4]    [,5]  [,6]  [,7] [,8] [,9], [,10], [,11], [,12] [,13]
 [1,] "MUNICIPALITIES"     ""       ""       ""      ""    ""    ""   ""   ""    ""     ""     ""    ""
 [2,] "Bayonne City"       "5333"   "7421"   "662"   "78"  "22"  "25" "16" "15"  "8"    "7"    "5"   "7"
 [3,] "East Newark Boro"   "71"     "234"    "13"    "0"   "0"   "0"  "0"  "0"   "0"    "0"    "0"   "0"
 [4,] "Guttenberg Town"    "447"    "1341"   "46"    "4"   "0"   "3"  "2"  "1"   "0"    "2"    "0"   "0"
 [5,] "Harrison Town"      "554"    "1542"   "87"    "12"  "4"   "2"  "4"  "1"   "2"    "3"    "1"   "1"
 [6,] "Hoboken City"       "4307"   "9095"   "673"   "32"  "28"  "19" "28" "16"  "4"    "1"    "5"   "5"
 [7,] "Jersey City"        "7336"   "29817"  "1263"  "133" "69"  "46" "45" "31"  "16"   "7"    "13"  "11"
 [8,] "Kearny Town"        "2790"   "3838"   "390"   "37"  "12"  "6"  "5"  "7"   "6"    "3"    "1"   "3"
 [9,] "North Bergen Town"  "2922"   "9680"   "200"   "79"  "20"  "16" "7"  "16"  "2"    "2"    "7"   "2"
[10,] "Secaucus Town"      "2096"   "2959"   "315"   "92"  "4"   "6"  "3"  "7"   "7"    "6"    "4"   "3"
[11,] "Union City"         "2265"   "8611"   "152"   "43"  "10"  "8"  "3"  "16"  "2"    "5"    "1"   "1"
[12,] "Weehawken Twp."     "792"    "2209"   "119"   "12"  "5"   "2"  "5"  "1"   "0"    "1"    "0"   "1"
[13,] "West New York Town" "1907"   "5328"   "97"    "34"  "12"  "9"  "4"  "5"   "0"    "2"    "1"   "0"
  ',
  hunterdon = '
V1   [,1]              [,2]     [,3]     [,4]    [,5]  [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13]
[1,] "MUNICIPALITIES"  ""       ""       ""      ""    ""   ""   ""   ""   ""    ""    ""    ""
[2,] "Raritan Twp"     "5440"   "2173"  "618"   "16"  "6"  "4"  "5"  "4"  "4"   "6"   "1"   "1"
[3,] "Readington Twp"  "4771"   "1395"  "495"   "9"   "7"  "7"  "7"  "3"  "4"   "3"   "4"   "2"
[4,] "Stockton Boro"   "122"    "116"    "22"    "0"   "0"  "1"  "1"  "1"  "0"   "0"   "2"   "0"
[5,] "Tewksbury Twp"   "1982"   "638"    "310"   "0"   "0"  "1"  "0"  "1"  "0"   "1"   "2"   "0"
[6,] "Union Twp"       "1303"   "366"    "139"   "4"   "1"  "1"  "1"  "0"  "0"   "0"   "0"   "0"
[7,] "West Amwell Twp" "764"    "462"    "89"    "1"   "0"  "0"  "0"  "2"  "1"   "1"   "0"   "1"
  ',
  monmouth = '
V1    [,1]                       [,2]      [,3]     [,4]     [,5]  [,6]  [,7] [,8] [,9] [,10] [,11] [,12] [,13]
 [1,] "MUNICIPALITIES"           ""        ""       ""       ""    ""    ""   ""   ""   ""    ""    ""    ""
 [2,] "Roosevelt Boro"           "126"     "215"    "22"     "0"   "3"   "0"  "0"  "1"  "0"   "0"   "0"   "0"
 [3,] "Rumson Boro"              "2019"    "644"    "138"    "6"   "2"   "1"  "0"  "0"  "1"   "0"   "1"   "0"
 [4,] "Sea Bright Boro"          "406"     "164"    "34"     "2"   "3"   "0"  "0"  "0"  "0"   "0"   "1"   "0"
 [5,] "Sea Girt Boro"            "765"     "185"    "47"     "0"   "2"   "0"  "0"  "0"  "0"   "0"   "0"   "1"
 [6,] "Shrewsbury Boro"          "1063"    "404"    "135"    "8"   "2"   "1"  "0"  "2"  "0"   "0"   "1"   "0"
 [7,] "Shrewsbury Twp"           "135"     "135"    "23"     "1"   "3"   "1"  "0"  "2"  "1"   "0"   "0"   "0"
 [8,] "Spring Lake Boro"         "1144"    "388"    "95"     "1"   "1"   "0"  "0"  "1"  "7"   "0"   "1"   "0"
 [9,] "Spring Lake Heights Boro" "1344"    "609"    "132"    "11"  "4"   "1"  "0"  "0"  "0"   "0"   "1"   "2"
[10,] "Tinton Falls Boro"        "3740"    "2307"   "437"    "28"  "6"   "8"  "3"  "2"  "2"   "1"   "1"   "0"
[11,] "Union Beach Boro"         "1152"    "432"    "136"    "7"   "10"  "6"  "1"  "3"  "2"   "0"   "1"   "0"
[12,] "Upper Freehold Twp"       "1972"    "676"    "153"    "2"   "6"   "3"  "1"  "0"  "0"   "3"   "5"   "0"
[13,] "Wall Twp"                 "7695"    "2542"   "604"    "22"  "24"  "19" "2"  "5"  "5"   "3"   "1"   "0"
[14,] "West Long Branch Boro"    "1732"    "794"    "176"    "8"   "4"   "3"  "0"  "1"  "2"   "0"   "0"   "0"
  ',
  ocean = '
V1   [,1]                        [,2]      [,3]     [,4]    [,5]  [,6]  [,7] [,8] [,9] [,10] [,11] [,12] [,13]
[1,] "MUNICIPALITIES"            ""        ""       ""      ""    ""    ""   ""   ""   ""    ""    ""    ""
[2,] "Pine Beach Boro"           "606"     "279"    "57"    "7"   "3"   "0"  "1"  "0"  "0"   "0"   "0"   "0"
[3,] "Plumsted Twp."             "1917"    "615"    "125"   "24"  "6"   "2"  "7"  "3"  "0"   "0"   "2"   "0"
[4,] "Point Pleasant Boro"       "4606"    "1977"   "421"   "17"  "15"  "15" "2"  "9"  "3"   "3"   "4"   "1"
[5,] "Point Pleasant Beach Boro" "1,280"   "546"    "105"   "4"   "3"   "2"  "0"  "1"  "0"   "0"   "0"   "0"
[6,] "Seaside Heights Boro"      "322"     "128"    "29"    "1"   "5"   "2"  "0"  "0"  "0"   "0"   "0"   "0"
[7,] "Seaside Park Boro"         "546"     "208"    "40"    "5"   "0"   "2"  "0"  "3"  "0"   "0"   "0"   "0"
[8,] "Ship Bottom Boro"          "349"     "161"    "32"    "2"   "0"   "0"  "2"  "0"  "0"   "0"   "1"   "0"
[9,] "South Toms River Boro"     "431"     "302"    "50"    "5"   "5"   "3"  "1"  "0"  "1"   "0"   "0"   "0"
[10,] "Stratford Twp."            "5746"    "2511"   "431"   "38"  "26"  "8"  "3"  "12" "5"   "4"   "3"   "3"
[11,] "Surf City Boro"            "417"     "211"    "40"    "0"   "2"   "0"  "0"  "0"  "0"   "0"   "0"   "0"
[12,] "Toms River Twp."           "19906"   "7948"   "1372" "111" "65"  "27" "25" "23" "13"  "8"   "8"   "3"
[13,] "Tuckerton  Boro"           "656"     "327"    "71"    "6"   "2"   "2"  "0"  "1"  "2"   "1"   "4"   "0"
  '
)

# Washington township became Robbinsville in 2008.
additional_municipal_corrections <- tribble(
  ~county,        ~municipality,    ~corrected_name,
  "Mercer County", "Washington township", "Robbinsville township"
)

vote_corrections <- tribble(
  ~county,         ~municipality,            ~candidate,            ~vote,
  "Atlantic County", "Estell Manor city",    "Alvin Lindsay",       0,
)


# Go ----
county_table <- get_county_table(county_table_updates)
candidate_table <- order_candidates(candidate_table, county_table, order_dir)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

