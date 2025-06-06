#' Set up branchmark in a project
#'
#' Initialises the branchmark directory structure and configuration files.
#'
#' @export
use_branchmark <- function() {
  # Create branchmark directory
  fs::dir_create("branchmark", recurse = TRUE)
  fs::dir_create("branchmark/baselines")

  cli::cli_alert_success("Created {.path branchmark/} directory")

  usethis::use_git_ignore("branchmark/baselines/*.rds")
  usethis::use_build_ignore("branchmark")
}

#' Create a benchmark template for a function
#'
#' @param name Function name to create benchmark for
#' @param open Whether to open the file for editing
#' @export
use_benchmark <- function(name, open = rlang::is_interactive()) {
  # Ensure branchmark directory exists
  if (!fs::dir_exists("branchmark")) {
    cli::cli_abort(
      "branchmark directory must exist",
      "i" = "use {.code use_branchmark()} to get started"
    )
  }

  # Create benchmark file
  benchmark_file <- fs::path("branchmark", glue::glue("benchmark_{name}.R"))

  if (fs::file_exists(benchmark_file)) {
    if (!usethis::ui_yeah("Benchmark file exists. Overwrite?")) {
      return(invisible(FALSE))
    }
  }

  # Generate template
  template <- "# Benchmark for {{function_name}}()

# Set up test data
test_data <- list(
  # Add your test data here
)

# Run benchmark
# Only put one function in here
benchmark_result <- bench::mark(
  {{function_name}} = {{function_name}}(test_data)
)"

  content <- whisker::whisker.render(template, list(function_name = name))
  readr::write_lines(strsplit(content, "\n")[[1]], benchmark_file)

  cli::cli_alert_success("Created {.path {benchmark_file}}")

  if (open) {
    usethis::edit_file(benchmark_file)
  }

  invisible(benchmark_file)
}
