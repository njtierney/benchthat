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
