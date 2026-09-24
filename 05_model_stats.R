model_stats <- tibble(
  Metric = c("R-squared", "Resorts Included"),
  Value  = c(round(summary(model)$r.squared, 3), nobs(model))
)

model_stats

write_csv(model_stats, "model_stats.csv")
