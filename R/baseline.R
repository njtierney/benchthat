#' Create or update performance baselines
#'
#' @param name Optional function name. If NULL, processes all benchmarks.
#' @param force Whether to overwrite existing baselines without confirmation
#' @export
branchmark_baseline <- function(name = NULL, force = FALSE) {
  if (is.null(name)) {
    create_all_baselines(force)
  } else {
    create_single_baseline(name, force)
  }
}

#' Update a specific baseline
#'
#' @param name Function name
#' @param force Whether to overwrite without confirmation
#' @export
update_baseline <- function(name, force = FALSE) {
  baseline_path <- get_baseline_path(name)

  if (fs::file_exists(baseline_path) && !force) {
    if (!usethis::ui_yeah("Overwrite existing baseline for {.field {name}}?")) {
      return(invisible(FALSE))
    }
  }

  # Run benchmark and save as baseline
  benchmark_result <- run_single_benchmark(name)
  save_baseline(name, benchmark_result)

  cli::cli_alert_success("Updated baseline for {.field {name}}")
  invisible(TRUE)
}

#' Create all baselines
#' @keywords internal
create_all_baselines <- function(force) {
  benchmark_files <- find_branchmark_files()

  if (length(benchmark_files) == 0) {
    cli::cli_alert_warning("No benchmark files found in {.path branchmark/}")
    return(invisible(NULL))
  }

  benchmark_names <- benchmark_files |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    stringr::str_remove("^benchmark_")

  cli::cli_progress_bar("Creating baselines", total = length(benchmark_names))

  purrr::walk(
    benchmark_names,
    ~ {
      cli::cli_progress_update()
      create_single_baseline(.x, force)
    }
  )

  cli::cli_progress_done()
  cli::cli_alert_success("Created {length(benchmark_names)} baseline{?s}")
}

#' Create a single baseline
#' @keywords internal
create_single_baseline <- function(name, force) {
  baseline_path <- get_baseline_path(name)

  if (fs::file_exists(baseline_path) && !force) {
    cli::cli_alert_info(
      text = c(
        "Baseline already exists for {.field {name}}.",
        "Use {.code force = TRUE} to overwrite."
      )
    )
    return(invisible(FALSE))
  }

  benchmark_result <- run_single_benchmark(name)
  save_baseline(name, benchmark_result)

  invisible(TRUE)
}

#' Get baseline file path for a function
#' @keywords internal
get_baseline_path <- function(name) {
  fs::path("branchmark", "baselines", paste0("baseline_", name, ".rds"))
}

#' Save baseline result
#' @keywords internal
save_baseline <- function(name, result) {
  baseline_path <- get_baseline_path(name)

  # Add metadata
  attr(result, "baseline_created") <- Sys.time()
  attr(result, "baseline_environment") <- capture_environment()

  # Ensure baselines directory exists
  fs::dir_create(fs::path_dir(baseline_path))

  readr::write_rds(result, baseline_path)
}
