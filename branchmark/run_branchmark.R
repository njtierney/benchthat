# Load libraries
library(bench)
library(devtools)
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(ggbeeswarm)
library(stringr)

# Load package
load_all()

# Find benchmark scripts
scripts <- list.files(
  path = "branchmark",
  pattern = "branchmark_.*\\.R$",
  full.names = TRUE
)

functions <- scripts |>
  str_remove(".*branchmark_") |>
  str_remove("\\.R$")

# Run each benchmark script
results <- list()
for (i in seq_along(scripts)) {
  source(scripts[i], local = TRUE)

  # Load baseline if exists
  baseline_file <- paste0("branchmark/branchmark_main_", functions[i], ".rds")
  if (file.exists(baseline_file)) {
    baseline <- readr::read_rds(baseline_file)
    results[["main"]] <- baseline
  }

  results[["pr"]] <- benchmark_result
}

# Combine and analyze
combined <- results |>
  bind_rows(.id = "benchmark") |>
  mutate(
    expression = paste0(benchmark, "_", expression)
  ) |>
  select(
    -benchmark
  )

# Create and save plot
plot_obj <- plot(combined)
ggsave("benchmark_plot.png", plot_obj, width = 10, height = 6, dpi = 150)

# Create summary
cat("## Benchmark Results\n\n")
combined_relative <- summary(combined, relative = TRUE)
print(combined_relative)

# Create comparison table

combined

# Save results
results_text <- paste0(
  "## Benchmark Results\n\n",
  "| Function | Main Branch | PR Branch | Speedup |\n",
  "|----------|-------------|-----------|----------|\n"
)

for (i in 1:nrow(comparison)) {
  results_text <- paste0(
    results_text,
    "| ",
    comparison$expression[i],
    " | ",
    format(comparison$main[i], scientific = TRUE, digits = 3),
    " | ",
    format(comparison$pr[i], scientific = TRUE, digits = 3),
    " | ",
    comparison$speedup_text[i],
    " |\n"
  )
}

results_text <- paste0(results_text, "\n![Benchmark Plot](benchmark_plot.png)")

writeLines(results_text, "results.md")
