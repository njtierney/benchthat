#' Set up branchmark in a project
#'
#' Initialises the branchmark directory structure and configuration files.
#'
#' @param path Path to the project directory. Defaults to current directory.
#' @param overwrite Logical. Whether to overwrite existing files.
#' @export
use_branchmark <- function(path = ".", overwrite = FALSE) {
  # Create branchmark directory
  branchmark_dir <- fs::path(path, "branchmark")
  if (!fs::dir_exists(branchmark_dir)) {
    fs::dir_create(branchmark_dir, recurse = TRUE)
    cli::cli_alert_success("Created {.path branchmark/} directory")
  }

  # Create subdirectories
  fs::dir_create(fs::path(branchmark_dir, "baselines"))

  # Create config file
  config_path <- fs::path(branchmark_dir, "config.yml")
  if (!fs::file_exists(config_path) || overwrite) {
    create_config_file(config_path)
    cli::cli_alert_success("Created {.path branchmark/config.yml}")
  }

  # Create example benchmark
  example_path <- fs::path(branchmark_dir, "benchmark_example.R")
  if (!fs::file_exists(example_path) || overwrite) {
    create_example_benchmark(example_path)
    cli::cli_alert_success(
      "Created example benchmark {.path branchmark/benchmark_example.R}"
    )
  }

  usethis::use_build_ignore("branchmark")
  use_branchmark_gitignore(path)

  invisible(TRUE)
}

#' Create a benchmark test for a function
#'
#' Creates a benchmark file for a specific function, similar to usethis::use_test().
#' The benchmark file will be created in the branchmark/ directory with appropriate
#' template code for testing the specified function.
#'
#' @param name Name of the function to benchmark. Can be quoted or unquoted.
#' @param open Whether to open the created file for editing
#' @export
#' @examples
#' \dontrun{
#' use_benchmark("my_function")
#' use_benchmark(another_function)
#' }
use_benchmark <- function(name, open = rlang::is_interactive()) {
  name <- as.character(substitute(name))

  # Ensure branchmark directory exists
  if (!fs::dir_exists("branchmark")) {
    cli::cli_alert_info(
      "No branchmark directory found. Running {.fun branchmark_setup}..."
    )
    branchmark_setup()
  }

  # Create benchmark file path
  benchmark_file <- fs::path("branchmark", paste0("benchmark_", name, ".R"))

  # Check if file already exists
  if (fs::file_exists(benchmark_file)) {
    cli::cli_alert_warning(
      "Benchmark file already exists: {.path {benchmark_file}}"
    )
    if (!usethis::ui_yeah("Overwrite existing file?")) {
      return(invisible(FALSE))
    }
  }

  # Generate template content
  template_content <- generate_benchmark_template(name)

  # Write the file
  readr::write_lines(template_content, benchmark_file)

  cli::cli_alert_success("Created benchmark file: {.path {benchmark_file}}")
  cli::cli_alert_info(
    "Edit the file to customize test data and parameters for {.fun {name}}"
  )

  # Open file if requested
  if (open) {
    usethis::edit_file(benchmark_file)
  }

  invisible(benchmark_file)
}

#' Generate benchmark template content for a specific function
#' @keywords internal
generate_benchmark_template <- function(function_name) {
  template <- "# Benchmark for {{function_name}}()
#
# This file benchmarks a single function against its baseline performance.
# Customize the test data and parameters below for your specific function.

# Load any required libraries
# library(specific_package)

# Set up test data for {{function_name}}()
# Replace with appropriate data for your function
test_data <- list(
  # Add your test data here
  # Example:
  # x = rnorm(1000),
  # y = runif(1000)
)

# Alternative: load real data
# test_data <- readr::read_csv(\"path/to/test_data.csv\")

# Run benchmark for a single function
# Customize the function call and parameters for {{function_name}}()
benchmark_result <- bench::mark(
  {{function_name}} = {{function_name}}(test_data),
  iterations = 50,
  check = FALSE
)

# Optional: Add memory profiling
# benchmark_result <- bench::mark(
#   {{function_name}} = {{function_name}}(test_data),
#   iterations = 50,
#   memory = TRUE,
#   check = FALSE
# )"

  data <- list(function_name = function_name)
  result <- whisker::whisker.render(template, data)

  strsplit(result, "\n")[[1]]
}


#' Create config file from template
#' @keywords internal
create_config_file <- function(config_path) {
  config_template <- system.file(
    "templates",
    "config.yml",
    package = "branchmark"
  )
  fs::file_copy(config_template, config_path)
}

#' Create example benchmark file
#' @keywords internal
create_example_benchmark <- function(example_path) {
  benchmark_template <- system.file(
    "templates",
    "benchmark_template.R",
    package = "branchmark"
  )
  fs::file_copy(benchmark_template, example_path)
}

#' Update .gitignore for branchmark
#' @keywords internal
use_branchmark_gitignore <- function(path) {
  gitignore_path <- fs::path(path, ".gitignore")
  gitignore_lines <- c(
    "",
    "# branchmark",
    "branchmark/baselines/*.rds"
  )

  if (fs::file_exists(gitignore_path)) {
    current_lines <- readr::read_lines(gitignore_path)
    if (!any(grepl("# branchmark", current_lines))) {
      readr::write_lines(c(current_lines, gitignore_lines), gitignore_path)
      cli::cli_alert_success("Updated {.path .gitignore}")
    }
  } else {
    readr::write_lines(gitignore_lines, gitignore_path)
    cli::cli_alert_success("Created {.path .gitignore}")
  }
}
