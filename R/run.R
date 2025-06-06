#' Run all benchmarks
#' @keywords internal
run_all_benchmarks <- function() {
  benchmark_files <- find_branchmark_files()

  if (length(benchmark_files) == 0) {
    cli::cli_alert_warning("No benchmark files found")
    return(invisible(NULL))
  }

  benchmark_names <- benchmark_names(benchmark_files)

  cli::cli_progress_bar("Running benchmarks", total = length(benchmark_names))

  purrr::walk(
    .x = cli::cli_progress_along(benchmark_names),
    .f = function(x) {
      run_single_benchmark(x)
    }
  )

  cli::cli_progress_done()
  cli::cli_alert_success("Completed {length(benchmark_names)} benchmark{?s}")
}

#' Run a single benchmark
#' @keywords internal
run_single_benchmark <- function(name) {
  benchmark_file <- find_branchmark_file(name)

  if (!fs::file_exists(benchmark_file)) {
    cli::cli_abort("Benchmark file not found: {.path {benchmark_file}}")
  }

  cli::cli_alert_info("Running benchmark for {.field {name}}")

  # Source the benchmark
  env <- new.env()
  source(benchmark_file, local = env)

  if (!exists("benchmark_result", envir = env)) {
    cli::cli_abort("Benchmark must assign result to {.code benchmark_result}")
  }

  result <- env$benchmark_result

  # Save result
  output_file <- fs::path("branchmark", "baselines", glue::glue("{name}.rds"))
  fs::dir_create(fs::path_dir(output_file))
  readr::write_rds(result, output_file)

  # Create plot
  plot_file <- fs::path("branchmark", "baselines", paste0(name, "_plot.png"))
  plot_obj <- plot(result)
  ggplot2::ggsave(plot_file, plot_obj, width = 8, height = 6)

  cli::cli_alert_success("Saved results to {.path {output_file}}")
  cli::cli_alert_success("Saved plot to {.path {plot_file}}")

  invisible(result)
}
