#' Benchmark testing
#'
#' @description
#' Benchmark tests are designed to be similar in spirit to to unit tests,
#' specifically to [testthat::expect_snapshot()] tests. The benchmark is
#' stored in a separate file, managed by benchthat. Benchmark tests are useful
#' for when you want to evaluate the speed of your code, and want to be able to
#' freely change an existing implementation without going through the process
#' of copying a function to compare it's speed.
#'
#' `expect_benchmark()` takes a benchmark created by [bench::mark()], and
#' records the results of the time taken to execute the code.
#'
#' @section Workflow:
#' The first time you run a benchmark expectation it will take the `benchmark`
#' result and record them in `benchmarks/benchthat/_benches/{test}.rds`.
#' Each benchmark run gets its own benchmark file, i.e., one function per
#'   `expect_benchmark()`.
#'
#' It's important to review the benchmark files, and then commit them to git.
#' You can review a benchmark with [benchmark_review()]. This displays the
#' differences between a new implementation and the current one, and gives you
#' the capacity to accept a new benchmark code. You can also generate this
#' with [benchmark_report()].
#'
#' On subsequent runs, the result of `benchmark` will be compared to the
#' benchmark file stored on disk. If it's any different, the expectation will
#' fail,  and a new file `_benches/{test}.new.csv` will be created. If the
#' change was deliberate, you can approve the change with [benchmark_accept()].
#'
#' @param benchmark benchmark code to evaluate that has been created with
#'   [bench::mark()].
#' @export
expect_benchmark <- function(benchmark) {
  check_benchmark_named(benchmark)
  check_benchmark_single(benchmark)

  # if it doesn't exist yet
  benchmark_name <- benchmark_name(benchmark)
  benchmark_exists <- benchmark_already_exists(benchmark_name)

  if (!benchmark_exists) {
    write_benchmark_csv(benchmark)
    write_benchmark_rds(benchmark)
    return(invisible(NULL))
  }

  # else the benchmark exists so we read it in
  benchmark_current <- read_benchmark_rds(benchmark_name)
  benchmark_new <- benchmark

  benchmarks <- bench_combine(
    current = current_benchmark,
    new = new_benchmark
  )

  benchmarks_compared <- bench_compare(benchmarks)
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
