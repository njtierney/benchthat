#' Capture current system environment
#' @keywords internal
capture_environment <- function() {
  list(
    r_version = as.character(getRversion()),
    platform = R.version$platform,
    os = Sys.info()[["sysname"]],
    cpu_cores = parallel::detectCores(),
    memory_gb = get_system_memory(),
    git_branch = get_git_branch(),
    git_commit = get_git_commit(),
    package_versions = get_package_versions(),
    timestamp = Sys.time()
  )
}

#' Get system memory in GB
#' @keywords internal
get_system_memory <- function() {
  tryCatch(
    {
      if (Sys.info()[["sysname"]] == "Linux") {
        mem_info <- readr::read_lines("/proc/meminfo")
        mem_line <- mem_info[grepl("^MemTotal:", mem_info)]
        mem_kb <- as.numeric(stringr::str_extract(mem_line, "\\d+"))
        round(mem_kb / 1024 / 1024, 1)
      } else {
        NA_real_
      }
    },
    error = function(e) NA_real_
  )
}

#' Get current Git branch
#' @keywords internal
get_git_branch <- function() {
  maybe_current_git_branch <- purrr::possibly(
    .f = function() {
      processx::run("git", c("branch", "--show-current"))$stdout |>
        stringr::str_trim()
    },
    otherwise = "unknown"
  )
  maybe_current_git_branch()
}

#' Get current Git commit hash
#' @keywords internal
get_git_commit <- function() {
  ginfo <- gert::git_info()
  ginfo$commit
}

#' Get package versions for key packages
#' @keywords internal
get_package_versions <- function() {
  key_packages <- c("base", "bench", "dplyr", "ggplot2")
  maybe_pkgv <- purrr::possibly(
    .f = function(x) as.character(utils::packageVersion(x)),
    otherwise = "not installed"
  )
  versions <- purrr::map_chr(
    .x = key_packages,
    .f = maybe_pkgv
  )
  purrr::set_names(versions, key_packages)
}

#' Validate that benchmark tests only one function
#' @keywords internal
validate_single_function_benchmark <- function(code) {
  # Parse the code and check for single function constraint
  # Implementation would analyse the AST to ensure only one function is benchmarked
  # For now, just return TRUE - full implementation would be more complex
  TRUE
}

#' Run a single benchmark by name
#' @keywords internal
run_single_benchmark <- function(name) {
  benchmark_file <- fs::path("branchmark", paste0("benchmark_", name, ".R"))

  if (!fs::file_exists(benchmark_file)) {
    cli::cli_abort("Benchmark file not found: {.path {benchmark_file}}")
  }

  # Source the benchmark file and return result
  env <- new.env()
  source(benchmark_file, local = env)

  if (!exists("benchmark_result", envir = env)) {
    cli::cli_abort(
      "Benchmark file must assign result to {.code benchmark_result}"
    )
  }

  env$benchmark_result
}

#' Calculate performance change between current and baseline
#' @keywords internal
calculate_performance_change <- function(current, baseline) {
  current_median <- as.numeric(current$median)
  baseline_median <- as.numeric(baseline$median)

  ratio <- baseline_median / current_median

  list(
    ratio = ratio,
    speedup = if (ratio > 1) ratio - 1 else 0,
    slowdown = if (ratio < 1) 1 - ratio else 0,
    current_time = current_median,
    baseline_time = baseline_median
  )
}

#' Generate report content
#' @keywords internal
generate_report_content <- function(results, include_plots) {
  # Implementation would generate markdown content
  # For now, return a simple template
  c(
    "# Benchmark Report",
    "",
    glue::glue("Generated on {Sys.Date()}"),
    "",
    "## Results",
    "",
    "| Function | Status | Change |",
    "|----------|--------|--------|",
    # ... actual results would be populated here
    "",
    if (include_plots) "## Plots" else NULL,
    if (include_plots) "![Performance comparison](benchmark_plot.png)" else NULL
  )
}

#' @keywords internal
find_branchmark_files <- function() {
  fs::dir_ls(
    path = "branchmark",
    regexp = "benchmark_*",
    type = "file"
  )
}
