library(tidyverse)

results <- read_csv("data/results.csv", col_names = FALSE)
features <- read_csv("../../research/r-scripts/features.csv")

features |>
  filter(stress %in% 1:3) |>
  mutate(rec = str_replace_all(rec, ".csv", "")) |>
  group_by(rec) |>
  summarise(stressed = which(stress == 1)) -> stressed

results |>
  rename("rec" = X1,
         "res" = X2) |>
  full_join(stressed, by = "rec") |>
  mutate(correct = ifelse(res == stressed, TRUE, FALSE)) |>
  summarise(prop = mean(correct))
