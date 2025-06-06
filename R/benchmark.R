#' Define a benchmark for a single function
#'
#' Creates a benchmark that tests a single function against its baseline.
#'
#' @param name Name of the function being benchmarked
#' @param code Code block containing the benchmark setup and execution
#' @param iterations Number of iterations for the benchmark
#' @export
branchmark <- function(name, code, iterations = 50) {
  # Validate single function constraint
  validate_single_function_benchmark(substitute(code))

  # Execute the benchmark code
  env <- parent.frame()
  result <- eval(substitute(code), envir = env)

  # Store metadata
  attr(result, "branchmark_name") <- name
  attr(result, "branchmark_timestamp") <- Sys.time()
  attr(result, "branchmark_environment") <- capture_environment()

  result
}

#' Create a snapshot of current benchmark results
#'
#' @param name Function name to snapshot
#' @export
branchmark_snapshot <- function(name = NULL) {
  if (is.null(name)) {
    snapshot_all_benchmarks()
  } else {
    snapshot_benchmark(name)
  }
}

#' Snapshot all benchmarks
#' @keywords internal
snapshot_all_benchmarks <- function() {
  benchmark_files <- find_branchmark_files()
  benchmark_names <- fs::path_ext_remove(fs::path_file(benchmark_files))
  benchmark_names <- stringr::str_remove(benchmark_names, "^benchmark_")

  purrr::walk(benchmark_names, snapshot_benchmark)
}

#' Snapshot a single benchmark
#' @keywords internal
snapshot_benchmark <- function(name) {
  cli::cli_progress_step("Snapshotting {.field {name}}")

  result <- run_single_benchmark(name)
  save_baseline(name, result)

  cli::cli_alert_success("Snapshot created for {.field {name}}")
}
