#' Get path to benchmark file
#'
#' 
#' @param benchmark A benchmark.
#'
#' @returns 
#' A file path string to the benchmark RDS file.
#'
#' @export
bench_path <- function(bench_name) {
  bench_filename <- fs::path(
    glue::glue(
      "benchmarks/benchthat/_benches/{bench_name}.rds"
    )
  )
}

#' Read benchmark RDS file
#'
#' @param bench_name A benchmark.
#'
#' @returns
#' The benchmark object loaded from the corresponding RDS file.
#'
#' @export
read_bench_rds <- function(bench_name) {

  bench_path <- bench_path(bench_name)

  bench_current <- readr::read_rds(bench_path)

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
  en_benchmark <- rlang::ensym(benchmark)

  bench_name <- rlang::as_string(en_benchmark)
  bench_path <- bench_path(bench_name)

  benchmark |> 
    # drop the memory column to save space
    # dplyr::select(-memory) |> 
    readr::write_rds(bench_path, compress = "xz")
}
