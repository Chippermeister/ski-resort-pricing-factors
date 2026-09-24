# =========================================================
# Ski Resort Pricing Project — Process phase
# Load, clean, and tag resort ownership
# =========================================================

library(tidyverse)

# -----------------------------------------------------------
# 1. LOAD
# The raw CSVs from Maven Analytics are Latin-1 encoded, not
# UTF-8 (you'll see garbled characters like "Mont-Sainte-Anne"
# or "Andermatt" otherwise). Read with the correct encoding.
# -----------------------------------------------------------
resorts <- read_csv("resorts.csv", locale = locale(encoding = "ISO-8859-1"))
snow    <- read_csv("snow.csv",    locale = locale(encoding = "ISO-8859-1"))

glimpse(resorts)

# -----------------------------------------------------------
# 2. VERIFY DATA INTEGRITY
# -----------------------------------------------------------

# Check for duplicate resort names
resorts %>% count(Resort) %>% filter(n > 1)

# Check for missing values across all columns
colSums(is.na(resorts))

# Confirm row count matches what we expect from Prepare (499)
nrow(resorts)

# -----------------------------------------------------------
# 3. TAG OWNERSHIP
# Vail Resorts, Alterra Mountain Company, and POWDR Corp each
# publish their resort lists publicly. These vectors were built
# by cross-referencing every North American, Australian, and
# Swiss resort in THIS dataset against those public lists
# (checked as of the writing of this roadmap). Ownership can
# change (POWDR sold Killington in 2024, for example, then
# reversed course on selling Mt. Bachelor in 2025), so this
# should be re-verified if you revisit this project later.
# -----------------------------------------------------------

vail_owned <- c(
  "Vail", "Beaver Creek", "Breckenridge", "Keystone", "Crested Butte",
  "Northstar California Resort", "Kirkwood", "Heavenly", "Whistler",
  "Park City", "Mount Snow", "Hunter Mountain", "Okemo", "Stevens Pass",
  "Stowe", "Crans-Montana", "Perisher", "Falls Creek", "Nätschen-Andermatt"
)

alterra_owned <- c(
  "Squaw Valley", "Alpine Meadows", "Crystal Mountain-WA-", "Deer Valley",
  "Mammoth Mountain", "Schweitzer Mountain Resort", "Solitude", "Steamboat",
  "Stratton", "Sugarbush", "Mont Tremblant", "Winter Park Resort"
)

powdr_owned <- c(
  "Copper Mountain", "Eldora Mountain", "Mt. Bachelor", "Silver Star",
  "Snowbird"
)

resorts <- resorts %>%
  mutate(
    Ownership = case_when(
      Resort %in% vail_owned    ~ "Vail Resorts",
      Resort %in% alterra_owned ~ "Alterra Mountain Company",
      Resort %in% powdr_owned   ~ "POWDR Corp",
      TRUE                      ~ "Independent"
    )
  )

# Sanity check the counts
resorts %>% count(Ownership, sort = TRUE)

# -----------------------------------------------------------
# 4. SAVE THE CLEANED FILE
# This is what you'll bring into Power BI for the dashboard.
# -----------------------------------------------------------
write_csv(resorts, "resorts_clean.csv")
