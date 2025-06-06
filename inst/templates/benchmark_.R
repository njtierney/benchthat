# Template for a single-function benchmark
#
# This file should:
# 1. Set up any required data or dependencies
# 2. Define a single function benchmark using bench::mark()
# 3. Assign the result to 'benchmark_result'

# Load any required libraries
# library(specific_package)

# Set up test data for this function
# Replace with appropriate data for your function
test_data <- data.frame(
  x = rnorm(1000),
  y = rnorm(1000)
)

# Run benchmark for a single function
# Replace 'your_function_name' with the actual function
benchmark_result <- bench::mark(
  your_function_name = your_function(test_data),
  iterations = 50,
  check = FALSE
)
