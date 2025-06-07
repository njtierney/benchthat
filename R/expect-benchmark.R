expect_benchmark <- function(
  benchmark,
  time_tolerance = 0.2, # as a percentage difference
  time_var = "median"
) {
  bm <- benchmark

  # expect only one row - we can only take in one function at a time
  # do we need to check if the name exists?
  # if it doesn't exist yet
  ## save the file as csv
  ## save the file as RDS
  # if it does exist
  ## read file in
  ## read_benchmark somehow needs to know which correct file to read in
  ## hopefully by the name of the benchmark?
  ## current_bm <- read_benchmark()
  ## compare benchmarks
  bm_compared <- bench_combine(
    current = current_bm,
    new = new_bm
  )

  bench_compare(
    benchmark = bm_compared,
    time_tolerance = time_tolerance,
    time_var = time_var
  )
}

# bench_that("function_name", {
#     # data set up
#     # data <- magic_function_for_setup(...)
#     expect_benchmark(
#         benchmark = bench::mark(function_name(data = data)
#         speed_tolerance = 0.1 # 10% tolerance before failure
#         speed_var = "median" # decide which variable(s) you want to benchmark on
#     )
# }
# )
