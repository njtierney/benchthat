#' Run benchmarks and save results
#'
#' @param name Optional function name. If NULL, runs all benchmarks.
#' @export
benchmark <- function(name = NULL) {
  if (is.null(name)) {
    run_all_benchmarks()
  } else {
    run_single_benchmark(name)
  }
}

#' Run benchmarks and compare with other branch
#'
#' @param name Optional function name. If NULL, compares all benchmarks.
#' @export
branchmark <- function(name = NULL) {
  if (is.null(name)) {
    compare_all_branches()
  } else {
    compare_single_branch(name)
  }
}
