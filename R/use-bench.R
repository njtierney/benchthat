use_bench <- function(name = NULL, open = rlang::is_interactive()) {
  if (!uses_benchthat()) {
    use_benchthat_impl()
  }

  path <- fs::path(
    "benchmarks",
    "benchthat",
    paste0("bench-", compute_name(name))
  )
  if (!fs::file_exists(path)) {
    usethis::use_template("bench-example.R", save_as = path)
  }
  usethis::edit_file(usethis::proj_path(path), open = open)

  invisible(TRUE)
}
