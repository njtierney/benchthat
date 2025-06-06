# Template benchmark file
#
# 1. Set up test data
# 2. Run bench::mark()
# 3. Assign result to 'benchmark_result'

# Set up test data
test_data <- data.frame(
  x = rnorm(1000),
  y = rnorm(1000)
)

# Run benchmark - only put one function in here
benchmark_result <- bench::mark(
  your_function = your_function(test_data)
)
