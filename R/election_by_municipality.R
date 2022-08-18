#' Election results by municipality
#'
#' @format A data fram with 76,332 rows and 9 columns
#' \describe{
#'   \item{year}{Election year}
#'   \item{type}{"General" or "Primary". (Currently all rows are "General")}
#'   \item{office}{"President", "Senate", or "Governor"}
#'   \item{GEOID}{US Census GEOID for the municipality}
#'   \item{county}{County of the municipality}
#'   \item{municipality}{Municipality name}
#'   \item{candidate}{Candidate name}
#'   \item{party}{Candidate party}
#'   \item{vote}{Number of votes}
#' }
#' @source \url{https://nj.gov/state/elections/election-information-results.shtml}
"election_by_municipality"
