key_drivers <- model_results %>%
  filter(term %in% c(
    "scale(Vertical_drop)",
    "scale(Season_length_months)",
    "scale(`Snow cannons`)",
    "scale(`Total lifts`)"
  )) %>%
  mutate(Factor = case_when(
    term == "scale(Vertical_drop)"          ~ "Vertical Drop",
    term == "scale(Season_length_months)"   ~ "Season Length",
    term == "scale(`Snow cannons`)"         ~ "Snow Cannons",
    term == "scale(`Total lifts`)"          ~ "Total Lifts"
  )) %>%
  select(Factor, estimate, p.value)

key_drivers

write_csv(key_drivers, "key_drivers.csv")
