bench_that("function", {
    # data set up
    # data <- magic_function_for_setup(...)
    expect_benchmark(
        x = function(data = data)
            speed_tolerance = 0.1 # 10% tolerance before failure
        speed_var = "median" # decide which variable(s) you want to benchmark on
    )
}
)
