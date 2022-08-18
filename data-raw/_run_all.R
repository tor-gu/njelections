handle_script <- function(fname) {
  message("Processing ", fname)
  source(fname)
}
fs::dir_ls("data-raw", regexp=r"(\d\d_.*\.R)") |>
  sort() |>
  purrr::walk(handle_script)

