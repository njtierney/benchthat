#' Compare all benchmarks between branches
#' @keywords internal
compare_all_branches <- function() {
  benchmark_files <- find_branchmark_files()

  if (length(benchmark_files) == 0) {
    cli::cli_alert_warning("No benchmark files found")
    return(invisible(NULL))
  }

  benchmark_names <- benchmark_names(benchmark_files)

  cli::cli_progress_bar("Comparing benchmarks", total = length(benchmark_names))

  results <- purrr::map(
    .x = cli::progress_along(benchmark_names),
    .f = function(x) {
      compare_single_branch(x)
    }
  ) |>
    purrr::set_names(benchmark_names)

  cli::cli_progress_done()

  # Summary
  regressions <- purrr::keep(results, \(x) !is.null(x) && x$is_slower)
  improvements <- purrr::keep(results, \(x) !is.null(x) && x$is_faster)

  if (length(regressions) > 0) {
    cli::cli_alert_danger("{length(regressions)} function{?s} got slower")
  }

  if (length(improvements) > 0) {
    cli::cli_alert_success("{length(improvements)} function{?s} got faster")
  }

  if (length(regressions) == 0 && length(improvements) == 0) {
    cli::cli_alert_info("No significant performance changes detected")
  }

  invisible(results)
}

#' Compare a single benchmark between branches
#' @keywords internal
compare_single_branch <- function(name) {
  baseline_file <- fs::path("branchmark", "baselines", paste0(name, ".rds"))

  if (!fs::file_exists(baseline_file)) {
    cli::cli_alert_warning(
      "No baseline for {.field {name}}. Run {.code benchmark(\"{name}\")} first."
    )
    return(invisible(NULL))
  }

  # Run current benchmark
  current_result <- run_current_benchmark(name)

  # Load baseline
  baseline_result <- readr::read_rds(baseline_file)

  # Compare
  current_time <- as.numeric(current_result$median)
  baseline_time <- as.numeric(baseline_result$median)

  ratio <- baseline_time / current_time
  threshold <- 0.1 # 10%

  is_faster <- ratio > (1 + threshold)
  is_slower <- ratio < (1 - threshold)

  if (is_slower) {
    slowdown <- (1 / ratio - 1) * 100
    cli::cli_alert_danger(
      "{.field {name}} is {.val {round(slowdown, 1)}%} slower"
    )
  } else if (is_faster) {
    speedup <- (ratio - 1) * 100
    cli::cli_alert_success(
      "{.field {name}} is {.val {round(speedup, 1)}%} faster"
    )
  } else {
    cli::cli_alert_info("{.field {name}} performance is similar")
  }

  invisible(list(
    name = name,
    ratio = ratio,
    is_faster = is_faster,
    is_slower = is_slower,
    current_time = current_time,
    baseline_time = baseline_time
  ))
}

#' Run current benchmark without saving
#' @keywords internal
run_current_benchmark <- function(name) {
  benchmark_file <- fs::path("branchmark", paste0("benchmark_", name, ".R"))

  env <- new.env()
  source(benchmark_file, local = env)

  env$benchmark_result
}
