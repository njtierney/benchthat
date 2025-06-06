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

#' @keywords internal
find_branchmark_file <- function(name) {
  fs::path("branchmark", paste0("benchmark_", name, ".R"))
}

#' @keywords internal
benchmark_names <- function(benchmark_files) {
  benchmark_files |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    stringr::str_remove("^benchmark_")
}
