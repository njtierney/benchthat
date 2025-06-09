#' Combine two benchmarks into one
#'
#' @param current current benchmark
#' @param new new benchmark
#'
#' @returns benchmark object with names "current" and "new" appended to expression.
#' @export
#'
#' @examples
#' dat <- data.frame(x = runif(100, 1, 1000), y = runif(10, 1, 1000))
#' bm1 <- bench::mark(
#'     subset = dat[dat$x > 500, ]
#' )
#'
#' bm2 <- bench::mark(
#'     subset = dat[which(dat$x > 500), ]
#' )
#'
#' combined_bm <- bench_combine(
#'     bm1,
#'     bm2
#' )
bench_combine <- function(current, new) {
  # if ("memory" %in% names(new)){
  #   new <- new |> 
  #       dplyr::select(-memory)
  # }
  list(
    current = current,
    new = new
  ) |>
    dplyr::bind_rows(.id = "benchmark") |>
    dplyr::mutate(
      expression = paste0(benchmark, "_", expression)
    ) |>
    dplyr::select(
      -benchmark
    )
}

#' Compare benchmark results
#'
#' @param benchmark A benchmark.
#'
#' @returns 
#' A combined benchmark object.
#'
#' @export
bench_compare <- function(benchmark) {
  en_benchmark <- rlang::ensym(benchmark)

  bench_name <- rlang::as_string(en_benchmark)

  bench_current <- read_bench_rds(bench_name)

  bench_combined <- bench_combine(
    current = bench_current,
    new = benchmark
  )

  bench_combined
}
