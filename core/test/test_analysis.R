library(tidyverse)

path <- "results/test5"

results_paths <- dir(path)[dir(path) |> str_detect("results")]
features <- read_csv("../../research/r-scripts/features.csv")

features |>
  filter(stress %in% 1:3) |>
  mutate(rec = str_replace_all(rec, ".csv", "")) |>
  group_by(rec) |>
  summarise(stressed = which(stress == 1)) -> stressed

results <- tibble()

for (i in 1:length(results_paths)) {

  read_csv(paste0(path, "/", results_paths[i]), col_names = FALSE) |>
    rename("rec" = X1,
           "res" = X2) |>
    mutate(rec = str_extract(rec, "\\d+-\\d"),
           subj = results_paths[i] |> str_extract("subj\\d+")) |>
    full_join(stressed, by = "rec") |>
    mutate(correct = ifelse(res == stressed, TRUE, FALSE)) |>
    bind_rows(results) -> results

}

mean(results$correct, na.rm = TRUE)

results |>
  group_by(subj) |>
  summarise(prop = mean(correct, na.rm = TRUE))

results |>
  group_by(rec) |>
  summarise(count = sum(correct))
