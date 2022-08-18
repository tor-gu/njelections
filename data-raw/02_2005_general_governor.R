# Set up ----
year <- 2005
office <- "Governor"

county_table_updates <- NULL
county_repair_table <- tribble(
  ~old_name,  ~new_name,
  "Capemay", "Cape May",
)
candidate_table <- tribble(
  ~name, ~party,
  "Jon S. Corzine",           "Democratic",
  "Doug Forrester",           "Republican",
  "Hector L. Castillo",       "Education Not Corruption",
  "Jeffrey Pawlowski",        "Libertarian Party",
  "Matthew J. Thieke",        "Green Party",
  "Edward Forchion",          "Legalize Marijuana (G.R.I.P.)",
  "Michael Latigona",         "One New Jersey",
  "Wesley K. (Wes) Bell",     "Independent",
  "Angela L. Lariscy",        "Socialist Workers Party",
  "Constantino Rozzo",        "Socialist Party USA",
)

column_repair_table <- NULL

file_name_base_template <- "{year}governor's_results-{county}"

# pdftools will miss Page 2 of
# 2005governor's_results-hunterdon.pdf will will be missed
additional_data <- list(
  hunterdon = '
V1   [,1]              [,2]     [,3]     [,4]  [,5]  [,6]  [,7] [,8] [,9]  [,10] [,11]
[1,] "MUNICIPALITIES"  ""       ""       ""    ""    ""    ""   ""   ""    ""    ""
[2,] "Raritan Twp"     "2,477"  "4,453"  "154" "51"  "44"  "28" "12" "22"  "2"   "2"
[3,] "Readington Twp"  "1,808"  "4,163"  "128" "50"  "26"  "23" "4"  "9"   "4"   "3"
[4,] "Stockton Boro"   "138"    "108"    "9"   "1"   "2"   "1"  "0"  "0"   "0"   "0"
[5,] "Tewksbury Twp"   "637"    "1,611"  "16"  "10"  "10"  "4"  "4"  "3"   "0"   "0"
[6,] "Union Twp"       "443"    "1,046"  "48"  "11"  "13"  "8"  "0"  "5"   "3"   "1"
[7,] "West Amwell Twp" "521"    "667"    "13"  "8"   "11"  "5"  "3"  "5"   "0"   "1"
')
additional_municipal_corrections <- NULL

vote_corrections <- tribble(
  ~county,         ~municipality,               ~candidate,             ~vote,
  "Bergen County", "Alpine borough",            "Hector L. Castillo",   0,
  "Bergen County", "Alpine borough",            "Jeffrey Pawlowski",    1,
  "Bergen County", "Alpine borough",            "Matthew J. Thieke",    1,
  "Bergen County", "Alpine borough",            "Edward Forchion",      0,
  "Bergen County", "Alpine borough",            "Michael Latigona",     0,
  "Bergen County", "Alpine borough",            "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Alpine borough",            "Angela L. Lariscy",    1,
  "Bergen County", "Alpine borough",            "Constantino Rozzo",    0,
  "Bergen County", "Bergenfield borough",       "Constantino Rozzo",    0,
  "Bergen County", "Bogota borough",            "Constantino Rozzo",    0,
  "Bergen County", "Closter borough",           "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Closter borough",           "Angela L. Lariscy",    5,
  "Bergen County", "Closter borough",           "Constantino Rozzo",    2,
  "Bergen County", "Demarest borough",          "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Demarest borough",          "Angela L. Lariscy",    2,
  "Bergen County", "Demarest borough",          "Constantino Rozzo",    4,
  "Bergen County", "East Rutherford borough",   "Wesley K. (Wes) Bell", 0,
  "Bergen County", "East Rutherford borough",   "Angela L. Lariscy",    7,
  "Bergen County", "East Rutherford borough",   "Constantino Rozzo",    1,
  "Bergen County", "Edgewater borough",         "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Edgewater borough",         "Angela L. Lariscy",    7,
  "Bergen County", "Edgewater borough",         "Constantino Rozzo",    3,
  "Bergen County", "Englewood Cliffs borough",  "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Englewood Cliffs borough",  "Angela L. Lariscy",    1,
  "Bergen County", "Englewood Cliffs borough",  "Constantino Rozzo",    0,
  "Bergen County", "Fair Lawn borough",         "Constantino Rozzo",    0,
  "Bergen County", "Fairview borough",          "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Fairview borough",          "Angela L. Lariscy",    8,
  "Bergen County", "Fairview borough",          "Constantino Rozzo",    9,
  "Bergen County", "Franklin Lakes borough",    "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Franklin Lakes borough",    "Angela L. Lariscy",    3,
  "Bergen County", "Franklin Lakes borough",    "Constantino Rozzo",    3,
  "Bergen County", "Garfield city",             "Constantino Rozzo",    0,
  "Bergen County", "Haworth borough",           "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Haworth borough",           "Angela L. Lariscy",    4,
  "Bergen County", "Haworth borough",           "Constantino Rozzo",    3,
  "Bergen County", "Ho-Ho-Kus borough",         "Michael Latigona",     0,
  "Bergen County", "Ho-Ho-Kus borough",         "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Ho-Ho-Kus borough",         "Angela L. Lariscy",    5,
  "Bergen County", "Ho-Ho-Kus borough",         "Constantino Rozzo",    0,
  "Bergen County", "Midland Park borough",      "Constantino Rozzo",    0,
  "Bergen County", "Montvale borough",          "Constantino Rozzo",    0,
  "Bergen County", "Moonachie borough",         "Edward Forchion",      0,
  "Bergen County", "Moonachie borough",         "Michael Latigona",     2,
  "Bergen County", "Moonachie borough",         "Wesley K. (Wes) Bell", 1,
  "Bergen County", "Moonachie borough",         "Angela L. Lariscy",    2,
  "Bergen County", "Moonachie borough",         "Constantino Rozzo",    0,
  "Bergen County", "Old Tappan borough",        "Michael Latigona",     0,
  "Bergen County", "Old Tappan borough",        "Wesley K. (Wes) Bell", 2,
  "Bergen County", "Old Tappan borough",        "Angela L. Lariscy",    3,
  "Bergen County", "Old Tappan borough",        "Constantino Rozzo",    0,
  "Bergen County", "Oradell borough",           "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Oradell borough",           "Angela L. Lariscy",    6,
  "Bergen County", "Oradell borough",           "Constantino Rozzo",    0,
  "Bergen County", "Palisades Park borough",    "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Palisades Park borough",    "Angela L. Lariscy",    4,
  "Bergen County", "Palisades Park borough",    "Constantino Rozzo",    7,
  "Bergen County", "Rochelle Park township",    "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Rochelle Park township",    "Angela L. Lariscy",    4,
  "Bergen County", "Rochelle Park township",    "Constantino Rozzo",    1,
  "Bergen County", "Rockleigh borough",         "Hector L. Castillo",   0,
  "Bergen County", "Rockleigh borough",         "Jeffrey Pawlowski",    0,
  "Bergen County", "Rockleigh borough",         "Matthew J. Thieke",     0,
  "Bergen County", "Rockleigh borough",         "Edward Forchion",      0,
  "Bergen County", "Rockleigh borough",         "Michael Latigona",     0,
  "Bergen County", "Rockleigh borough",         "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Rockleigh borough",         "Angela L. Lariscy",    0,
  "Bergen County", "Rockleigh borough",         "Constantino Rozzo",    0,
  "Bergen County", "Saddle River borough",      "Hector L. Castillo",   0,
  "Bergen County", "Saddle River borough",      "Jeffrey Pawlowski",    4,
  "Bergen County", "Saddle River borough",      "Matthew J. Thieke",     1,
  "Bergen County", "Saddle River borough",      "Edward Forchion",      0,
  "Bergen County", "Saddle River borough",      "Michael Latigona",     1,
  "Bergen County", "Saddle River borough",      "Wesley K. (Wes) Bell", 1,
  "Bergen County", "Saddle River borough",      "Angela L. Lariscy",    0,
  "Bergen County", "Saddle River borough",      "Constantino Rozzo",    0,
  "Bergen County", "South Hackensack township", "Matthew J. Thieke",     0,
  "Bergen County", "South Hackensack township", "Edward Forchion",      0,
  "Bergen County", "South Hackensack township", "Michael Latigona",     0,
  "Bergen County", "South Hackensack township", "Wesley K. (Wes) Bell", 0,
  "Bergen County", "South Hackensack township", "Angela L. Lariscy",    3,
  "Bergen County", "South Hackensack township", "Constantino Rozzo",    0,
  "Bergen County", "Teterboro borough",         "Matthew J. Thieke",     0,
  "Bergen County", "Teterboro borough",         "Edward Forchion",      0,
  "Bergen County", "Teterboro borough",         "Michael Latigona",     0,
  "Bergen County", "Teterboro borough",         "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Teterboro borough",         "Angela L. Lariscy",    1,
  "Bergen County", "Teterboro borough",         "Constantino Rozzo",    0,
  "Bergen County", "Washington township",       "Constantino Rozzo",    0,
  "Bergen County", "Woodcliff Lake borough",    "Wesley K. (Wes) Bell", 0,
  "Bergen County", "Woodcliff Lake borough",    "Angela L. Lariscy",    1,
  "Bergen County", "Woodcliff Lake borough",    "Constantino Rozzo",    0,
  "Cumberland County", "Vineland city",         "Matthew J. Thieke",     0,
  "Cumberland County", "Vineland city",         "Edward Forchion",      26,
  "Cumberland County", "Vineland city",         "Michael Latigona",     64,
  "Cumberland County", "Vineland city",         "Wesley K. (Wes) Bell", 21,
  "Cumberland County", "Vineland city",         "Angela L. Lariscy",    13,
  "Cumberland County", "Vineland city",         "Constantino Rozzo",    19,
)

# Go ----
county_table <- get_county_table(county_table_updates)

election_by_municipality <- go(
  election_by_municipality, year, office, county_table,
  candidate_table, file_name_base_template, pdf_files,
  additional_data, additional_municipal_corrections,
  vote_corrections)

