# branchmark/branchmark_<function>.R

# load libraries
# library(<pkgs>)

# other setup
# data manip etc

# Run benchmark (must assign to `benchmark_result``)
benchmark_result <- bench::mark(
  fun = fun(your_test_data)
)
