dat <- data.frame(x = runif(100, 1, 1000), y = runif(10, 1, 1000))
bm1 <- bench::mark(
  subset = dat[dat$x > 500, ]
)

bm2 <- bench::mark(
  subset = dat[which(dat$x > 500), ]
)

combined_bm <- bench_combine(
  bm1,
  bm2
)

relative_summary <- summary(combined_bm, relative = TRUE)

relative_summary$median
