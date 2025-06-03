# Load libraries
library(bench)
library(devtools)
library(readr)
library(stringr)

# Load package
load_all()

cat("Generating baseline benchmarks...\n")

# Find benchmark scripts
scripts <- list.files(
  "branchmark",
  pattern = "branchmark_.*\\.R$",
  full.names = TRUE
)

# get the function name based on the file
functions <- str_extract(scripts, "(?<=branchmark_).*(?=\\.R)")

cat(
  "Found benchmark scripts for functions:",
  paste(functions, collapse = ", "),
  "\n"
)

# Run each benchmark script and save as baseline
for (i in seq_along(scripts)) {
  func_name <- functions[i]
  script_path <- scripts[i]

  cat("Generating baseline for:", func_name, "\n")

  tryCatch(
    {
      # Source the benchmark script
      source(script_path, local = TRUE)

      # Save as baseline
      baseline_file <- paste0("branchmark/branchmark_main_", func_name, ".rds")
      readr::write_rds(benchmark_result, baseline_file)

      cat("✓ Saved baseline to:", baseline_file, "\n")

      # Clean up
      rm(benchmark_result)
    },
    error = function(e) {
      cat("✗ Error generating baseline for", func_name, ":", e$message, "\n")
    }
  )
}

cat("Baseline generation complete!\n")
