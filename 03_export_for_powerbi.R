# =========================================================
# Ski Resort Pricing Project — export for Power BI
# Run this after the corrected Analyze script (with the
# "Year-round" fix and the final model already in memory)
# =========================================================

library(tidyverse)
library(broom)

# 1. The full analysis-ready dataset, including the engineered
#    Vertical_drop and Season_length_months columns and the
#    Ownership tag. This is what Power BI will connect to for
#    most of the dashboard (maps, scatter plots, filters).
write_csv(resorts, "resorts_final.csv")

# 2. A tidy summary of the regression model itself, so Power BI
#    can build a "key drivers" chart without trying to recreate
#    the model. broom::tidy() turns the model into a clean,
#    one-row-per-factor table.
model_results <- tidy(model)
write_csv(model_results, "model_results.csv")

# Take a look before moving to Power BI
model_results
