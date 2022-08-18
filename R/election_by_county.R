#' Election results by county
#'
#' @format A data frame with 2,835 rows and 8 columns
#' \describe{
#'   \item{year}{Election year}
#'   \item{type}{"General" or "Primary". (Currently all rows are "General")}
#'   \item{office}{"President", "Senate", or "Governor"}
#'   \item{GEOID}{US Census GEOID for the county}
#'   \item{county}{County name}
#'   \item{candidate}{Candidate name}
#'   \item{party}{Candidate party}
#'   \item{vote}{Number of votes}
#' }
#' @source \url{https://nj.gov/state/elections/election-information-results.shtml}
"election_by_county"
