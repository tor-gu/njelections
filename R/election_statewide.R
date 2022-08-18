#' Statewide election results.
#'
#' @format A data frame with 135 rows and 6 columns
#' \describe{
#'   \item{year}{Election year}
#'   \item{type}{"General" or "Primary". (Currently all rows are "General")}
#'   \item{office}{"President", "Senate", or "Governor"}
#'   \item{candidate}{Candidate name}
#'   \item{party}{Candidate party}
#'   \item{vote}{Number of votes}
#' }
#' @source \url{https://nj.gov/state/elections/election-information-results.shtml}
"election_statewide"
