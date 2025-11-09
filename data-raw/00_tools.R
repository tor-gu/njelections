# Tools used for processing the municipal election data
# Internal functions, like 'read_pdf_raw_', end in '_'.

# Tables ----
# Table of common corrections to municipality names
common_municipality_corrections_ <- tribble(
  ~county,             ~municipality,            ~corrected_name,
  "Atlantic County",   "Atlantic city",          "Atlantic City city",
  "Atlantic County",   "Corbin city",            "Corbin City city",
  "Atlantic County",   "Egg Harbor city",        "Egg Harbor City city",
  "Atlantic County",   "Egg Harbor",             "Egg Harbor township",
  "Atlantic County",   "Hammonton",              "Hammonton town",
  "Atlantic County",   "Hammonton township",     "Hammonton town",
  "Atlantic County",   "Margate city",           "Margate City city",
  "Atlantic County",   "Margate",                "Margate City city",
  "Atlantic County",   "Northfield township",    "Northfield city",
  "Atlantic County",   "Port Republic",          "Port Republic city",
  "Atlantic County",   "Ventnor city",           "Ventnor City city",
  "Atlantic County",   "Ventnor",                "Ventnor City city",
  "Bergen County",     "ClosterBoro",            "Closter borough",
  "Bergen County",     "Elmwood Park city",      "Elmwood Park borough",
  "Bergen County",     "MaywoodBoro",            "Maywood borough",
  "Bergen County",     "TeaneckTwp",             "Teaneck township",
  "Bergen County",     "Teterboro",              "Teterboro borough",
  "Bergen County",     "Upper Saddle River",     "Upper Saddle River borough",
  "Burlington County", "Cinnnaminson township",  "Cinnaminson township",
  "Burlington County", "Easthampton township",   "Eastampton township",
  "Burlington County", "RiversideTwp.",          "Riverside township",
  "Camden County",     "Gloucester city",        "Gloucester City city",
  "Camden County",     "Gloucester Townshp",     "Gloucester township",
  "Camden County",     "Lindenwood borough",     "Lindenwold borough",
  "Camden County",     "Mount Ephrain borough",  "Mount Ephraim borough",
  "Camden County",     "Mount Ephriam borough",  "Mount Ephraim borough",
  "Camden County",     "Mt Ephraim borough",     "Mount Ephraim borough",
  "Camden County",     "Travistock borough",     "Tavistock borough",
  "Camden County",     "Voorhees borough",       "Voorhees township",
  "Camden County",     "WinslowTwp.",            "Winslow township",
  "Cape May County",   "Ocean city",             "Ocean City city",
  "Cape May County",   "Sea Isle city",          "Sea Isle City city",
  "Essex County",      "BellevilleTwp.",         "Belleville township",
  "Essex County",      "Essex Fells city",       "Essex Fells borough",
  "Essex County",      "Essex Falls city",       "Essex Fells borough",
  "Essex County",      "Orange",                 "City of Orange township",
  "Essex County",      "Orange city",            "City of Orange township",
  "Essex County",      "Orange City township",   "City of Orange township",
  "Essex County",      "South Orange",           "South Orange Village township",
  "Essex County",      "South Orange township",  "South Orange Village township",
  "Hudson County",     "Jersey city",            "Jersey City city",
  "Hudson County",     "North Bergen town",      "North Bergen township",
  "Hudson County",     "Union city",             "Union City city",
  "Mercer County",     "Twp. of Robbinsville",   "Robbinsville township",
  "Middlesex County",  "New Brunswick township", "New Brunswick city",
  "Middlesex County",  "Sayerville borough",     "Sayreville borough",
  "Monmouth County",   "Lake Como",              "Lake Como borough",
  "Morris County",     "Parsippany-Troy Hills",  "Parsippany-Troy Hills township",
  "Morris County",     "Parsippany Troy Hills",  "Parsippany-Troy Hills township",
  "Ocean County",      "Stratford township",     "Stafford township",
  "Passaic County",    "Little FallsTwp.",       "Little Falls township",
  "Passaic County",    "Woodland Park",          "Woodland Park borough",
  "Somerset County",   "Greenbrook",             "Green Brook township",
  "Somerset County",   "Peapack-Gladstone borough", "Peapack and Gladstone borough",
  "Sussex County",     "Franford township",      "Frankford township",
  "Warren County",     "Hacketstown town",       "Hackettstown town",
  "Sussex County",     "Ogdenburg borough",      "Ogdensburg borough",
  "Warren County",     "Phillpsburg town",       "Phillipsburg town",
)

# Standard county table. It may vary for some election cycles.
standard_county_table_ <- tribble(
  ~county,      ~rev,
  "atlantic",   "",
  "bergen",     "",
  "burlington", "",
  "camden",     "",
  "capemay",    "",
  "cumberland", "",
  "essex",      "",
  "gloucester", "",
  "hudson",     "",
  "hunterdon",  "",
  "mercer",     "",
  "middlesex",  "",
  "monmouth",   "",
  "morris",     "",
  "ocean",      "",
  "passaic",    "",
  "salem",      "",
  "somerset",   "",
  "sussex",     "",
  "union",      "",
  "warren",     "",
)

# Download PDF functions ----

# Wrapper around utils::download.file
download_if_missing <- function(url, file) {
  if (!fs::file_exists(file))
    utils::download.file(url, file)
}

# Download all county PDFs matching a template.
download_pdfs <- function(year, county_table, file_name_base_template) {
  county <- county_table$county
  rev <- county_table$rev

  file_name_pdf_template <- paste0(file_name_base_template, ".pdf")
  url_template <- paste0("https://nj.gov/state/elections/assets/pdf/election-results/{year}/", file_name_pdf_template)
  file_pdf_template <- file.path("data-raw", file_name_pdf_template)
  urls <- glue(url_template)
  files <- glue(file_pdf_template)

  walk2(urls, files, download_if_missing)

  files
}

# PDF-to-CSV conversion functions ----

## Tabulizer ----
# Conversion using tabulizer. This is the best case scenario.
# The output is a csv file.
convert_pdfs_tabulizer <- function(files) {
  walk(files, tabulapdf::extract_tables,
       output = "csv", outdir = "data-raw")
}

## Pdftools ----
# If we can't use tabulizer, we use pdftools::pdf_text and
# and then parse the results. This is more complicated and
# requires 'helper' data, such as the column names.

# Internal function to read a pdf file into a list of lines of text
read_pdf_raw_ <- function(pdf_fname) {
  tibble(
    line = pdftools::pdf_text(pdf_fname) |>
      str_split(pattern = "\n") |>
      unlist()
  )
}

# Internal function. Like as.integer, but with all non integers
# *silently* converted to NA
as.integer.or.na_ <- function(x) {
  suppressWarnings(as.integer(x))
}

# Internal function: Parse the lines returned form read_pdf_raw_
# into a table that
# looks something like this:
#   ~MUNICIPALITIES,  ~col_1, ~col_2, col_3, ...
#  "Thistown village", 349,   394,    34,    ...
#  "Othertown town"    34,    3443,   22,    ...
#  ...
parse_pdf_raw_ <- function(pdf_raw) {
  pdf_raw |>
    filter(str_starts(line, "\\s{0,7}[A-Z]")) |>
    mutate(id = row_number()) |>
    separate_rows(line, sep = "\\s+(?=\\d)") |>
    group_by(id) |>
    mutate(col = paste0("col_", row_number())) |>
    ungroup() |>
    pivot_wider(id_cols = id, names_from = col, values_from = line) |>
    mutate(across(where(is.character), str_trim)) |>
    rename(MUNICIPALITIES = col_1) |>
    filter(MUNICIPALITIES != "MUNICIPALITIES") |>
    mutate(across(starts_with("col_"), \(x) str_remove(x, ","))) |>
    mutate(across(starts_with("col_"), ~ if_else(.x == "", "0", .x))) |>
    mutate(across(starts_with("col_"), as.integer.or.na_)) |>
    select(-id)
}

# Internal function: After parsing the table with parse_pdf_raw_,
# replace the placeholder column names ('col_xxx') with candidates.
# The format of column name is
#    <candidate-name>\r<party-name>
# This mimics the format returned by tables that are parsed by
# tabulizer, so that we can do the same kind of post-processing.
assign_column_names_ <- function(tbl, candidate_table) {
  column_names <- candidate_table |>
    mutate(
      col_name = paste0("col_", row_number() + 1),
      new_col_name = paste0(name, "\r", party)
      ) |>
    select(col_name, new_col_name) |>
    deframe()
  tbl <- tbl |> select(MUNICIPALITIES, num_range("col_", 2:(1 + length(column_names))))
  tryCatch(
    expr = {
      tbl |>
        rename_with(~column_names, .cols = starts_with("col_"))
    },
    error = function(e){ tbl }
  )

}

# Convert the files using pdftools. The end-result should be
# compatible with the results of convert_pdfs_tabulizer, but we
# need to supply more helper data as input.
convert_pdfs_pdftools <- function(files, file_name_base_template,
                                  county_table, candidate_table) {
  county <- county_table$county
  rev <- county_table$rev
  if (is.data.frame(candidate_table)) {
    candidate_table <- replicate(length(county), candidate_table,
                                 simplify = FALSE)
  }
  file_name_csv <- fs::path("data-raw",
                            paste0(file_name_base_template, "-1.csv") |>
                              glue()
  )
  files |>
    map(read_pdf_raw_) |>
    map(parse_pdf_raw_) |>
    map2(candidate_table, assign_column_names_) |>
    walk2(file_name_csv, readr::write_csv)
}

## Additional CSVs

# Internal function for creating and writing a CSV file
# from a data.table style string
create_additional_csv_ <- function(data_str, county,
                                   county_table,
                                   candidate_table,
                                   file_name_base_template) {
  rev <- county_table %>%
    filter(county == .env$county) |>
    pull(rev)
  csv_file <- fs::path("data-raw",
                       paste0(glue(file_name_base_template),
                              "-add.csv"))
  if (!is.data.frame(candidate_table)) {
    candidate_table <- candidate_table[[county]]
  }

  tbl <- data.table::fread(data_str) |>
    as_tibble() |>
    select(-V1) |>
    rename(municipality = `[,1]`) |>
    filter(municipality != "MUNICIPALITIES") |>
    mutate(across(-municipality, ~str_remove(.x, ","))) |>
    mutate(across(-municipality, as.integer)) |>
    mutate(across(-municipality, ~replace_na(.x, 0)))
  nms <- candidate_table |>
    mutate(nm = str_c(name, "\r", party)) |> pull(nm)
  names(tbl) <- c("MUNICIPALITIES", nms)
  tbl |> readr::write_csv(csv_file)
}

# Create additional CSVs from data.table style strings.
# This is for data that required a bit of elbow-grease to
# generate -- for example, data that was manually repaired.
create_additional_csvs <- function(additional_data,
                                   county_table,
                                   candidate_table,
                                   file_name_base_template) {
  if (!is.null(additional_data)) {
    walk2(names(additional_data), additional_data, ~
            create_additional_csv_( .y, .x,
                                    county_table,
                                    candidate_table,
                                    file_name_base_template)
    )
  }
}


# Read from CSV ----

# Internal function to handle column repair info
repair_columns_ <- function(table, column_repair_table) {
  result <- table
  if (!is.null(column_repair_table)) {
    for(idx in 1:nrow(column_repair_table)) {
      value <- column_repair_table[idx,]$repaired_value
      starts <- column_repair_table[idx,]$starts_with
      result <- result |>
        rename_with(~ value, .cols = starts_with(starts))
    }
  }
  result
}

# Internal function to handle county repair info
repair_counties_ <- function(table, county_repair_table) {
  result <- table
  if (!is.null(county_repair_table)) {
    for(idx in 1:nrow(county_repair_table)) {
      old_name <- county_repair_table[idx,]$old_name
      new_name <- county_repair_table[idx,]$new_name
      result <- result |>
        mutate(county = str_replace(county, old_name, new_name))
    }
  }
  result
}

# Read the data from a CSV file
read_from_csv <- function(year, county_table,
                      file_name_base_template,
                      county_repair_table = NULL,
                      column_repair_table = NULL) {
  county <- county_table$county
  rev <- county_table$rev
  file_name_csv_pattern_template <- paste0(
    file_name_base_template, "-.*.csv"
  )
  file_name_pattern <- glue(file_name_csv_pattern_template)
  csv_files <- file_name_pattern |>
    map(
      ~ list.files("data-raw")[str_detect(list.files("data-raw"), .)]
    ) |>
    map(~ fs::path("data-raw", .))

  names(csv_files) <- county

  results <- csv_files |>
    map(function(x) {x |>
        map(readr::read_csv, show_col_types = FALSE) |>
        map(repair_columns_, column_repair_table) |>
        reduce(bind_rows)
    }) |>
    bind_rows(.id = "county")

  results |>
    mutate(across(3:length(results), as.numeric)) |>
    pivot_longer(cols = c(-county, -MUNICIPALITIES),
                 names_to = "candidate",
                 values_to = "vote") |>
    separate(candidate, into = c("candidate", "party"),
             sep = "\r",
             extra = "merge") |>
    mutate(county = str_c(str_to_title(county), " County")) |>
    repair_counties_(county_repair_table)
}

# Additional post-processing ----

# Repair the municipality column by filtering out non-municipal
# rows, normalizing the name, and applying all fixes in
# common_municipality_corrections_.  Optionally apply
# additional corrections supplied as an argument.
repair_municipalities <- function(table, additional_corrections = NULL) {
  result <- table |>
    rename(municipality = MUNICIPALITIES) |>
    filter(municipality != "Municipalities") |>
    filter(municipality != "COUNTY TOTAL") |>
    filter(municipality != "County Totals") |>
    filter(municipality != "Total") |>
    filter(municipality != "Residents Removed") |>
    filter(municipality != "Removed Residents") |>
    filter(municipality != "Federal Oversees") |>
    filter(municipality != "Federal Overseas") |>
    filter(municipality != "Federal/Overseas") |>
    filter(municipality != "Federal") |>
    filter(municipality != "Overseas") |>
    filter(municipality != "Hand Counts") |>
    filter(municipality != "Late Provisionals") |>
    filter(!str_detect(municipality, "NJDOE")) |>
    filter(!str_detect(municipality, "Based on additional")) |>
    mutate(municipality = str_replace(
      municipality, " of$", ""
    )) |>
    mutate(municipality = str_replace(
      municipality, " Boro$", " borough"
    )) |>
    mutate(municipality = str_replace(
      municipality, " Borough$", " borough"
    )) |>
    mutate(municipality = str_replace(
      municipality, " City$", " city"
    )) |>
    mutate(municipality = str_replace(
      municipality, " Twp.?$", " township"
    )) |>
    mutate(municipality = str_replace(
      municipality, " Township$", " township"
    )) |>
    mutate(municipality = str_replace(
      municipality, " Town$", " town"
    )) |>
    mutate(municipality = str_replace(
      municipality, " Village$", " village"
    )) |>
    mutate(municipality = str_squish(municipality)) |>
    mutate(municipality = str_remove(municipality, ",")) |>
    mutate(municipality = str_replace(municipality, "&", "and")) |>
    left_join(common_municipality_corrections_,
              by = c("county", "municipality")) |>
    mutate(municipality = if_else(is.na(corrected_name),
                                  municipality,
                                  corrected_name)) |>
    select(-corrected_name)

  if (!is.null(additional_corrections)) {
    result <- result |>
      left_join(additional_corrections,
                by = c("county", "municipality")) |>
      mutate(municipality = if_else(is.na(corrected_name),
                                    municipality,
                                    corrected_name)) |>
      select(-corrected_name)
  }
  result
}

# Apply corrections to vote totals
repair_votes <- function(table, vote_corrections = NULL) {
  if (is.null(vote_corrections)) {
    table
  } else {
    table |> rows_update(vote_corrections,
                         by = c("county", "municipality", "candidate"))
  }
}


# Order functions ---
# These functions are used by order_candidates

# Parse an order configuration file
parse_order_file_ <- function(lines) {
  list(county = lines[[1]], candidates = lines[-(1:2)])
}

# Create a permutation vector
permute_index_ <- function(ordering, name) {
  min(which(map_lgl(ordering, ~str_detect(name, .x))))
}

# Add an order column and sort
permute_table_ <- function(table, ordering) {
  table$ord <- map_int(table$name, ~permute_index_(ordering, .x))
  table |> arrange(ord)
}

# Top level ----

# Return either the standard county table, or the standard
# county table with updates applied.
get_county_table <- function(updates) {
  if (is.null(updates)) {
    standard_county_table_
  } else {
    standard_county_table_ |>
      left_join(updates, by = c("county" = "standard_name")) |>
      mutate(county = if_else(is.na(updated_name), county, updated_name),
             rev = if_else(is.na(updated_rev), rev, updated_rev)) |>
      select(county, rev)
  }
}

# In most cases, every county PDF uses the same column order, but
# in a few cases, the columns are permuted. This function will
# produce a named list of candidate tables, based on configuration
# files in an 'order directory'
order_candidates <- function(candidate_table, county_table, order_dir) {
  if (is.null(order_dir)) {
    candidate_table
  } else {
    orderings <- fs::dir_ls(order_dir) |>
      map(readr::read_lines) |>
      map(parse_order_file_) |>
      map(enframe) |>
      map_df(pivot_wider) |>
      unnest(county) |>
      arrange(county) |>
      pull(candidates)
    result <-
      replicate(length(orderings), candidate_table, simplify = FALSE)
    names(result) <- county_table |> pull(county)
    result |> map2(orderings, permute_table_)
  }
}


# Execute all steps:
# * Download the PDFS
# * Convert them to CSV
# * Read the CSV and do post-processing
# * Update the election table and return the updated table.
go <- function(election, year, office, county_table, candidate_table,
               file_name_base_template, pdf_files,
               additional_data, additional_municipal_corrections,
               vote_corrections = null, municipality_year = year,
               tabulizer = FALSE) {
  pdf_files <- download_pdfs(year,
                             county_table,
                             file_name_base_template)

  if (tabulizer) {
    convert_pdfs_tabulizer(pdf_files)
  } else {
    convert_pdfs_pdftools(pdf_files,
                          file_name_base_template,
                          county_table,
                          candidate_table)
  }

  create_additional_csvs(additional_data,
                         county_table,
                         candidate_table,
                         file_name_base_template)

  results <- read_from_csv(
    year, county_table, file_name_base_template, county_repair_table,
    column_repair_table) |>
    mutate(vote = as.integer(vote), year = as.integer(year)) |>
    repair_municipalities(additional_municipal_corrections) |>
    repair_votes(vote_corrections) |>
    filter(!str_starts(candidate, "\\.\\.\\."))

  results <- results |>
    mutate(year = year, type = "General", office = office) |>
    left_join(get_municipalities(municipality_year),
              by = c("county", "municipality"))

  election |>
    filter(year != .env$year | office != .env$office) |>
    bind_rows(results)
}

