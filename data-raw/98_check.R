# Check the tables before saving them.

check_same_candidates <- function(tbl, key) {
  exceptions <- tbl |>
    select(-party) |>
    pivot_wider(names_from="candidate", values_from=vote) |>
    filter(if_any(everything(), is.na))
  if (nrow(exceptions) > 0) {
    message("Inconsistent candidate list")
    print(key)
    print(exceptions)
  }
}

check_municipalities <- function(tbl, key) {
  year <- key$year
  # For 2012, we have to use the year municipal list of 2013.
  if (year == 2012) year = 2013

  municipalities <- get_municipalities(year)
  election_municipalities <- tbl |> select(county, municipality, GEOID) |>
    unique()
  missing <- anti_join(municipalities, election_municipalities,
                       by=names(municipalities))
  extra <- anti_join(election_municipalities, municipalities,
                     by=names(municipalities))
  if (nrow(missing) > 0) {
    message("Missing municipalities")
    print(key)
    print(missing)
  }
  if (nrow(extra) > 0) {
    message("Extra municipalities")
    print(key)
    print(extra)
  }
}
# Check that every election has the same candidates in each municipality
election_by_municipality |>
  group_by(year, type, office) |>
  group_walk(check_same_candidates)

# Check that every municipality is represented for every election
election_by_municipality |>
  group_by(year, type, office) |>
  group_walk(check_municipalities)

# Check that every election has the same candidates at the
# municipal, county, and state levels
municipal_candidates <- election_by_municipality |>
  select(year, type, office, county, candidate) |>
  unique()
county_candidates <- election_by_county |>
  select(year, type, office, county, candidate)
statewide_candidates <- election_statewide |>
  select(year, type, office, candidate) |>
  unique()
missing_county <- anti_join(municipal_candidates, county_candidates,
                            by=c("year", "type", "office", "county", "candidate"))
extra_county <- anti_join(county_candidates, municipal_candidates,
                          by=c("year", "type", "office", "county", "candidate"))
missing_state <- anti_join(county_candidates, statewide_candidates,
                           by=c("year", "type", "office", "candidate"))
extra_state <- anti_join(statewide_candidates, county_candidates,
                         by=c("year", "type", "office", "candidate"))
if (nrow(missing_county) > 0) {
  message("Missing county candidates")
  print(missing_county)
}
if (nrow(extra_county) > 0) {
  message("Extra county candidates")
  print(extra_county)
}
if (nrow(missing_state) > 0) {
  message("Missing state candidates")
  print(missing_state)
}
if (nrow(extra_state) > 0) {
  message("Extra state candidates")
  print(extra_state)
}

# Check the state totals match the county totals
state_county_delta <- election_by_county |>
  group_by(year, type, office, candidate) |>
  summarize(county_vote=sum(vote), .groups="drop") |>
  left_join(election_statewide,
             by=c("year", "type", "office", "candidate")) |>
  filter(vote != county_vote)
if (nrow(state_county_delta)) {
  message("Statewide count doesn't match sum of county totals")
  print(state_county_delta)
}

# Check that county totals are within known or acceptable bounds
# of municipal totals
# County totals do not always exactly match the municipal totals
# We check that every discrepancy is either:
#  -- between -1 and 5 votes; or
#  -- between 0 and 0.2%; or
#  -- on a list of known, larger discrepancies
known_deltas <- tribble(
  ~year, ~office,    ~county,            ~candidate,          ~delta,
  2004, "President", "Monmouth County",  "John F. Kerry",     275,
  2004, "President", "Morris County",    "John F. Kerry",     491,
  2004, "President", "Morris County",    "Ralph Nader",       9,
  2004, "President", "Sussex County",    "John F. Kerry",     71,
  2008, "President", "Morris County",    "Barack Obama",      335,
  2008, "Senate",    "Morris County",    "Frank Lautenberg",  286,
  2009, "Governor",  "Burlington County","Kenneth R. Kaplan", 8,
  2012, "President", "Atlantic County",  "Barack Obama",      320,
  2012, "President", "Atlantic County",  "Mitt Romney",       172,
  2012, "President", "Warren County",    "Barack Obama",      135,
  2012, "President", "Warren County",    "Mitt Romney",       90,
  2012, "Senate",    "Atlantic County",  "Robert Menendez",   282,
  2012, "Senate",    "Atlantic County",  "Joe Kyrillos",      136,
  2012, "Senate",    "Hudson County",    "Ken Wolski",        6,
  2012, "Senate",    "Warren County",    "Robert Menendez",   111,
  2012, "Senate",    "Warren County",    "Joe Kyrillos",      76,
  2016, "President", "Cape May County",  "Hillary Rodham Clinton", 51,
  2016, "President", "Essex County",     "Gary Johnson",      18,
  2016, "President", "Essex County",     "Hillary Rodham Clinton", 904,
  2016, "President", "Essex County",     "Jill Stein",        10,
  2016, "President", "Hudson County",    "Gary Johnson",      8,
  2016, "President", "Hudson County",    "Hillary Rodham Clinton", 588,
  2016, "President", "Hudson County",    "Jill Stein",        14,
  2016, "President", "Monmouth County",  "Hillary Rodham Clinton", 386,
  2016, "President", "Monmouth County",  "Jill Stein",        9,
  2016, "President", "Morris County",    "Hillary Rodham Clinton", 539,
  2016, "President", "Morris County",    "Jill Stein",        10,
  2016, "President", "Sussex County",    "Hillary Rodham Clinton", 91,
  2018, "Senate",    "Hudson County",    "Madelyn R. Hoffman", 6,
  2020, "President", "Cape May County",  "Joseph R. Biden",    105,
  2020, "President", "Monmouth County",  "Joseph R. Biden",    751,
  2020, "President", "Morris County",    "Jo Jorgensen",       7,
  2020, "President", "Morris County",    "Joseph R. Biden",    986,
  2020, "President", "Sussex County",    "Joseph R. Biden",    148,
  2020, "Senate",    "Cape May County",  "Cory Booker",        96,
  2020, "Senate",    "Monmouth County",  "Cory Booker",        705,
  2020, "Senate",    "Monmouth County",  "Madelyn R. Hoffman", 16,
  2020, "Senate",    "Morris County",    "Cory Booker",        917,
  2020, "Senate",    "Morris County",    "Madelyn R. Hoffman", 13,
  2020, "Senate",    "Sussex County",    "Cory Booker",        140,
)

municipal_county_delta <- election_by_municipality |>
  group_by(year, office, county, candidate) |>
  summarize(municipal_vote=sum(vote), .groups="drop") |>
  left_join(election_by_county, by=c("year", "office", "county", "candidate")) |>
  mutate(delta = vote - municipal_vote) |>
  filter(!between(delta, -1, 5)) |>
  filter(!between(delta/vote, 0.0, .002)) |>
  anti_join(known_deltas,
            by=c("year", "office", "county", "candidate", "delta"))

if (nrow(municipal_county_delta) > 0) {
  message("Discrepancies between municipal and county totals")
  print(municipal_county_delta)
}
