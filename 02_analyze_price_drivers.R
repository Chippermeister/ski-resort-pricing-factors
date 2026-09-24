# =========================================================
# Ski Resort Pricing Project — Analyze phase
# Engineer features, then find the largest driver of Price
# =========================================================

library(tidyverse)

resorts <- read_csv("resorts_clean.csv", locale = locale(encoding = "ISO-8859-1"))

# -----------------------------------------------------------
# 1. DATA QUALITY CHECK — Price
# A ski pass costing 0 isn't realistic, it's almost certainly
# a placeholder for "unknown," not a genuinely free resort.
# Check how many rows this affects before deciding to exclude.
# -----------------------------------------------------------
resorts %>% filter(Price <= 0)

# If that's a small number of rows (a handful, not dozens),
# it's reasonable to drop them so they don't distort the model.
resorts <- resorts %>% filter(Price > 0)

# -----------------------------------------------------------
# 2. FEATURE ENGINEERING
# -----------------------------------------------------------

# Vertical drop: the actual skiable elevation range, a more
# meaningful "elevation" measure than either point alone.
resorts <- resorts %>%
  mutate(Vertical_drop = `Highest point` - `Lowest point`)

# Season length in months, parsed from a text field like
# "November - May". Handles the wraparound across the new year,
# and for resorts with two listed seasons (e.g. a summer glacier
# season), only the first/main season is used, worth noting as
# a simplification if this comes up in the write-up later.
parse_season_months <- function(season) {
  first_part <- str_split(season, ",")[[1]][1] %>% str_trim()
  parts <- str_split(first_part, "\\s*-\\s*")[[1]] %>% str_trim()
  start_month <- match(parts[1], month.name)
  end_month   <- match(parts[2], month.name)
  if (is.na(start_month) || is.na(end_month)) return(NA_real_)
  ((end_month - start_month) %% 12) + 1
}

resorts <- resorts %>%
  mutate(Season_length_months = map_dbl(Season, parse_season_months))

# Quick sanity check, are there any seasons that failed to parse?
resorts %>% filter(is.na(Season_length_months)) %>% select(Resort, Season)

# -----------------------------------------------------------
# 3. CORRELATIONS WITH PRICE (numeric factors only, for a
# quick first read before the fuller model below)
# -----------------------------------------------------------
resorts %>%
  select(Price, Vertical_drop, Season_length_months,
         `Total slopes`, `Total lifts`, `Snow cannons`, `Lift capacity`) %>%
  cor(use = "pairwise.complete.obs") %>%
  as.data.frame() %>%
  select(Price) %>%
  arrange(desc(abs(Price)))

# -----------------------------------------------------------
# 4. THE MODEL
# Numeric predictors are standardized with scale() so every
# coefficient is on the same footing (effect per 1 standard
# deviation), which makes them directly comparable to each
# other, that comparability is the whole point, since the
# question is which factor matters MOST, not just which ones
# are statistically significant.
# -----------------------------------------------------------
model <- lm(
  Price ~ scale(Vertical_drop) + scale(Season_length_months) +
    scale(`Snow cannons`) + scale(`Total lifts`) +
    `Child friendly` + Snowparks + Nightskiing + `Summer skiing` +
    Continent + Ownership,
  data = resorts
)

summary(model)
