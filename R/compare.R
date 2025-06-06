#' Compare current benchmarks with baselines
#'
#' @param name Optional function name to compare. If NULL, compares all.
#' @param threshold Performance degradation threshold (default 0.1 = 10%)
#' @export
branchmark_compare <- function(name = NULL, threshold = 0.1) {
  if (is.null(name)) {
    compare_all_benchmarks(threshold)
  } else {
    compare_single_benchmark(name, threshold)
  }
}

#' Generate a benchmark comparison report
#'
#' @param output_file Path to output markdown file
#' @param include_plots Whether to include performance plots
#' @export
branchmark_report <- function(
  output_file = "branchmark_report.md",
  include_plots = TRUE
) {
  results <- branchmark_compare()

  # Generate markdown report
  report_content <- generate_report_content(results, include_plots)
  readr::write_lines(report_content, output_file)

  cli::cli_alert_success("Report saved to {.path {output_file}}")
  invisible(output_file)
}

#' Compare all benchmarks with their baselines
#' @keywords internal
compare_all_benchmarks <- function(threshold) {
  benchmark_files <- find_branchmark_files()

  if (length(benchmark_files) == 0) {
    cli::cli_alert_warning("No benchmark files found in {.path branchmark/}")
    return(invisible(NULL))
  }

  benchmark_names <- benchmark_files |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    stringr::str_remove("^benchmark_")

  cli::cli_progress_bar("Comparing benchmarks", total = length(benchmark_names))

  results <- purrr::map(
    benchmark_names,
    ~ {
      cli::cli_progress_update()
      compare_single_benchmark(.x, threshold)
    }
  ) |>
    purrr::set_names(benchmark_names)

  cli::cli_progress_done()

  results
}

#' Compare a single benchmark with its baseline
#' @keywords internal
compare_single_benchmark <- function(name, threshold) {
  baseline_path <- get_baseline_path(name)

  if (!fs::file_exists(baseline_path)) {
    cli::cli_alert_warning(
      "No baseline found for {.field {name}}. Run {.code branchmark_baseline()} first."
    )
    return(invisible(NULL))
  }

  # Run current benchmark
  current_result <- run_single_benchmark(name)

  # Load baseline
  baseline_result <- readr::read_rds(baseline_path)

  # Compare results
  comparison <- calculate_performance_change(current_result, baseline_result)

  # Check for regression
  if (comparison$slowdown > threshold) {
    cli::cli_alert_danger(
      "{.field {name}} is {.val {scales::percent(comparison$slowdown)}} slower than baseline"
    )
  } else if (comparison$speedup > 0.05) {
    cli::cli_alert_success(
      "{.field {name}} is {.val {scales::percent(comparison$speedup)}} faster than baseline"
    )
  } else {
    cli::cli_alert_info("{.field {name}} performance is similar to baseline")
  }

  comparison
}
