# This script is for assembling election_by_county and
# election_statewide tables.

# Download files ----
file_names <- tribble(
  ~year, ~office,     ~file_name,
  2004,  "President", "2004-official_2004_gen_pres_results.pdf",
  2005,  "Governor",  "2005_Official_General_Election-Governor_tallies.pdf",
  2006,  "Senate",    "2006_official-senate_tallies.pdf",
  2008,  "President", "2008-official-gen-elect-tallies-pres-120208.pdf",
  2008,  "Senate",    "2008-official-gen-elect-tallies-senate-120208.pdf",
  2009,  "Governor",  "2009-official-general-election-gov-lt-gov-tallies-120109.pdf",
  2012,  "President", "2012-official-general-results-president-020513.pdf",
  2012,  "Senate",    "2012-official-general-results-us-senate-020513.pdf",
  2013,  "Governor",  "2013-official-general-election-results-governor.pdf",
  2014,  "Senate",    "2014-official-general-results-us-senate.pdf",
  2016,  "President", "2016-official-general-results-president-1206b.pdf",
  2017,  "Governor",  "2017-official-general-election-results-governor.pdf",
  2018,  "Senate",    "2018-official-general-election-results-us-senate.pdf",
  2020,  "President", "2020-official-general-results-president.pdf",
  2020,  "Senate",    "2020-official-general-results-us-senate.pdf",
  2021,  "Governor",  "2021-official-general-results-governor.pdf",
)

url_pattern <- "https://nj.gov/state/elections/assets/pdf/election-results/{year}/{file_name}"
file_names <- file_names |> mutate(url=glue(url_pattern),
                     file=fs::path("data-raw", file_name))
walk2(file_names$url, file_names$file, download_if_missing)


# Read PDFs ----

# Read text from PDF files. This will be a list of list, with
# one block of text for each page of each PDF.
text <- file_names$file |> map(pdftools::pdf_text)
# For 2009, the PDF has two candidates per page.  We make
# ad ad-hoc adjustement here, by splitting on a double CR.
text[[6]] <- text[[6]] |> map(str_split, r"(\n\n)") |> unlist()

# Map candidates to PDF pages
candidates <- election_by_municipality |>
  select(year, office, candidate) |>
  unique() |>
  mutate(search_name = candidate) |>
  mutate(search_name = case_when(
    year == 2005 & candidate == "Wesley K. (Wes) Bell" ~ "Bell",
    year == 2006 & candidate == "Thomas H. Kean, Jr." ~ "Kean",
    year == 2006 & candidate == "J. M. Carter" ~ "J.M. Carter",
    year == 2008 & candidate == 'Jeffrey "Jeff" Boss' ~ "Boss",
    year == 2012 & candidate == "Ross C. (Rocky) Anderson" ~ "ANDERSON",
    year == 2016 & candidate == 'Rocky Roque De la Fuente' ~ "FUENTE",
    year == 2020 & candidate == 'Roque "Rocky" De la Fuente' ~ "FUENTE",
    year %in% 2012:2021 ~ str_to_upper(search_name),
    TRUE ~ search_name
  ))

get_candidate_page_map <- function(all_pages, candidates,
                                   year, office) {
  candidates <- candidates |>
    filter(year==.env$year, office==.env$office)
  search_names <- pull(candidates, search_name)
  map(all_pages, str_match, search_names) |>
    map(as_tibble, .name_repair="unique") |>
    map(filter, !is.na(`...1`)) |>
    map(pull, `...1`) |>
    enframe() |>
    unnest(value) |>
    rename(page=name, search_name=value) |>
    right_join(candidates, by="search_name")
}

get_vote_totals <- function(page, patterns) {
  stringi::stri_match(page,
                      regex=patterns,
                      opts_regex=list(case_insensitive=TRUE)) |>
    as_tibble(.name_repair = ~c("V1","V2","V3")) |>
    select(name=V2, vote=V3) |>
    mutate(vote=as.integer(str_remove_all(vote, ","))) |>
    mutate(name=str_to_title(name))
}


# Because of a font issue on one page of one PDF (page 1 of the
# 2016 presidential results), a portion of the page (but not the
# entire page!) is encoded incorrectly by ptftools::pdf_text. This
# function makes an adjustement to a subset of characters, by adding
# 29 to the byte value.
#
# Note that while this makes the incorrectly-encoded portion of the
# page parseable enough for our purposes, it ruins the *correctly*
# encoded portion of the page. So, depending on what part of
# the page we want to parse, we will have to use either the
# adjusted or the unadjusted version.
#
# This function makes the adjustment for space, comma, digits
# and capital letters.
adjust_for_font_issue <- function(page) {
  #                     " " "," "0":"9" "A":"Z"
  ascii_codes <- sort(c(32, 44, 48:57,  65:90), decreasing = TRUE)
  input_chars <- map(ascii_codes - 29, intToUtf8) |> unlist()
  output_chars <- map(ascii_codes, intToUtf8) |> unlist()
  reduce2(input_chars,
          output_chars,
          stringi::stri_replace_all_fixed,
          .init=page)
}


# We need to make two versions of the text list -- one with
# 2016 president page 1 adjusted, and one as-is.
# We will use the adjusted version to extract the candidate name
# and the county totals, and the unadjusted one to get the
# statewide total.
page_1_president_2016 <- text[[11]][[1]]
page_1_president_2016_adjusted <-
  adjust_for_font_issue(page_1_president_2016)
text_adjusted <- text
text_adjusted[[11]][[1]] <- page_1_president_2016_adjusted

# Get a map of candidate to PDF pages.  We use the 'adjusted'
# text for this one.
page_map <- pmap(
  list(all_pages = text_adjusted,
       year = file_names$year,
       office = file_names$office
  ),
  get_candidate_page_map,
  candidates = candidates
)

# Get the county totals from each page. We again use the
# 'adjusted' text
county_patterns <- counties |>
  mutate(patt=str_remove(county, " County")) |>
  mutate(patt = str_c(".{40,}", glue(r"(({patt}).+\s([0-9,]+\n))"))) |>
  pull(patt)

county_totals <- text_adjusted |> map(
  map, get_vote_totals, county_patterns
)

# Get the statewide totals from each page. This time we use
# the unadjusted text
total_pattern <- r"((Total)\s+([0-9,]+))"
state_totals <- text |> map(
  map, get_vote_totals, total_pattern
)

combine_totals <- function(page_map, totals) {
  page_map |> group_by(page) |>
    group_map(~left_join(.x, totals[[.y$page]], by=character())) |>
    bind_rows() |>
    select(year, office, candidate, name, vote)
}

combine_county_totals <- function(page_map, county_totals) {
  page_map |> group_by(page) |>
    group_map(~left_join(.x, county_totals[[.y$page]], by=character())) |>
    bind_rows() |>
    mutate(county = str_c(name, " County")) |>
    select(year, office, candidate, county, vote)
}
candidate_party <- election_by_municipality |>
  select(year, office, candidate, party) |>
  unique()

election_by_county <- map2_dfr(page_map,
                               county_totals,
                               combine_totals) |>
  filter(!is.na(vote)) |>
  mutate(county = str_c(name, " County")) |>
  left_join(counties, by="county") |>
  left_join(candidate_party, by=c("year", "office", "candidate")) |>
  mutate(type="General") |>
  select(year, type, office, GEOID, county, candidate, party, vote)

election_statewide <- map2_dfr(page_map, state_totals, combine_totals) |>
  left_join(candidate_party, by=c("year", "office", "candidate")) |>
  mutate(type="General") |>
  select(year, type, office, candidate, party, vote)



