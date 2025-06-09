dat <- data.frame(x = runif(100, 1, 1000), y = runif(10, 1, 1000))
bm1 <- bench::mark(
  subset = dat[dat$x > 500, ]
)

bm2 <- bench::mark(
  subset = dat[which(dat$x > 500), ]
)

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


combined_bm <- bench_combine(
  bm1,
  bm2
)

bm_summary <- summary(combined_bm)
bm_summary_relative <- summary(combined_bm, relative = TRUE)

bm_summary_relative

as.numeric(bm_summary$min)
as.numeric(bm_summary$min) |> bench::as_bench_time()
