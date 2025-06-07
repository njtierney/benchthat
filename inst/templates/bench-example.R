bench_that("function", {
  # data set up
  # data <- magic_function_for_setup(...)
  expect_benchmark(
    benchmark = bench::mark(
      # ensure that this is only one expression
      my_fun = my_fun(data)
    ),
    speed_tolerance = 0.1, # 10% tolerance before failure
    speed_var = "median" # decide which variable(s) you want to benchmark on
  )
})
