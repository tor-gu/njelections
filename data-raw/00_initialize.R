# Load the libraries we will be using repeatedly
library(dplyr)
library(tidyr)
library(glue)
library(purrr)
library(tibble)
library(stringr)
library(data.table)
library(njmunicipalities)

# Initialize the election_by_municipality table.
election_by_municipality <- tibble(
  year = integer(0),
  type = character(0),
  office = character(0),
  GEOID = character(),
  county = character(0),
  municipality = character(0),
  candidate = character(0),
  party = character(0),
  vote = integer(0)
)
