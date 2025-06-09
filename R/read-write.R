#' Get path to benchmark file
#'
#' 
#' @param benchmark A benchmark.
#'
#' @returns 
#' A file path string to the benchmark RDS file.
#'
#' @export
bench_path <- function(benchmark) {
  bench_sym <- rlang::ensym(benchmark)

  bench_name <- rlang::as_string(bench_sym)

  bench_filename <- fs::path(
    glue::glue(
      "benchmarks/benchthat/_benches/{bench_name}.rds"
    )
  )
}

#' Read benchmark RDS file
#'
#' @param benchmark A benchmark.
#'
#' @returns
#' The benchmark object loaded from the corresponding RDS file.
#'
#' @export
read_bench_rds <- function(benchmark) {
  en_benchmark <- rlang::enquo(benchmark)
  bench_path <- bench_path(!!en_benchmark)

  bench_current <- readr::read_rds(bench_filename)

  bench_current
}

#' Write benchmark to RDS
#'
#' 
#' @param benchmark A benchmark object.
#'
#' @returns 
#' No return value, called for side effects.
#'
#' @export
write_bench_rds <- function(benchmark) {
  en_benchmark <- rlang::enquo(benchmark)
  bench_path <- bench_path(!!en_benchmark)

  readr::write_rds(benchmark, bench_path)
}
