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
