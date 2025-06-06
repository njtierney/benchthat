#' Check current environment and compare with baseline
#'
#' @param warn Whether to issue warnings for significant changes
#' @export
check_environment <- function(warn = TRUE) {
  current_env <- capture_environment()
  baseline_env <- load_baseline_environment()

  if (is.null(baseline_env)) {
    if (warn) {
      cli::cli_alert_warning(
        "No baseline environment found. Run {.code branchmark_baseline()} first."
      )
    }
    return(invisible(current_env))
  }

  changes <- compare_environments(current_env, baseline_env)

  if (warn && length(changes) > 0) {
    warn_system_changes(changes)
  }

  invisible(list(
    current = current_env,
    baseline = baseline_env,
    changes = changes
  ))
}

#' Warn about system changes that might affect benchmarks
#'
#' @param changes List of environment changes
warn_system_changes <- function(changes) {
  if (length(changes) == 0) {
    return(invisible())
  }

  cli::cli_alert_warning(
    "System changes detected that might affect benchmark results:"
  )
  purrr::walk(changes, \(x) cli::cli_li(x))
  cli::cli_alert_info(
    "Consider updating baselines if these changes are intentional."
  )
}

#' Compare two environment snapshots
#' @keywords internal
compare_environments <- function(current, baseline) {
  changes <- character()

  # Check R version
  if (current$r_version != baseline$r_version) {
    changes <- c(
      changes,
      glue::glue("R version: {baseline$r_version} -> {current$r_version}")
    )
  }

  # Check platform
  if (current$platform != baseline$platform) {
    changes <- c(
      changes,
      glue::glue("Platform: {baseline$platform} -> {current$platform}")
    )
  }

  # Check CPU cores
  if (current$cpu_cores != baseline$cpu_cores) {
    changes <- c(
      changes,
      glue::glue("CPU cores: {baseline$cpu_cores} -> {current$cpu_cores}")
    )
  }

  # Check memory (allow 10% variance)
  memory_change <- abs(current$memory_gb - baseline$memory_gb) /
    baseline$memory_gb
  if (memory_change > 0.1) {
    changes <- c(
      changes,
      glue::glue("Memory: {baseline$memory_gb}GB -> {current$memory_gb}GB")
    )
  }

  changes
}

#' Load baseline environment if available
#' @keywords internal
load_baseline_environment <- function() {
  baseline_files <- fs::dir_ls("branchmark/baselines", glob = "*.rds")

  if (length(baseline_files) == 0) {
    return(NULL)
  }

  # Load the most recent baseline environment
  latest_baseline <- baseline_files |>
    purrr::map_dfr(
      ~ {
        result <- readr::read_rds(.x)
        tibble::tibble(
          file = .x,
          created = attr(result, "baseline_created") %||%
            as.POSIXct("1970-01-01")
        )
      }
    ) |>
    dplyr::slice_max(created, n = 1) |>
    dplyr::pull(file)

  baseline_result <- readr::read_rds(latest_baseline)
  attr(baseline_result, "baseline_environment")
}
