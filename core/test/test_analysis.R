library(tidyverse)

path <- "results/"
results_paths <- dir(path)[dir(path) |> str_detect("test\\d+")]

results <- tibble()

for (i in 1:length(results_paths)) {
  files_results <- dir(paste0(path, results_paths[i]))
  for (j in 2:length(files_results)) {
    read_csv(paste0(path, results_paths[i], "/", files_results[j]),
             col_names = FALSE, show_col_types = FALSE) |>
      mutate(params = i) |>
      bind_rows(results) -> results
  }
}

# results |> write_csv("results_binded.csv")
read_csv("results_binded.csv") -> results

stress <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1wYrxpNZVWv58IGZbC7p-bQV8_gXoTc1P57GCLMi2fpc/edit#gid=194389716",
                                    "stress") |>
  select(3:4) |>
  filter(position != "C") |>
  group_by(rec) |>
  summarize(stressed = which(position == "S"))

results |>
  rename("res" = X2) |>
  separate(X1, into = c("subj", "rec"), sep = "_") |>
  left_join(stress, by = "rec") |>
  replace_na(list("res" = 0)) |>
  mutate(correct = ifelse(res == stressed, TRUE, FALSE)) |>
  group_by(params) |>
  summarise(accuracy = mean(correct)) -> accuracy

accuracy |> write_csv("accuracy.csv")

accuracy |>
  arrange(desc(accuracy)) |>
  slice(1:10)

read_csv("results/test3375/params.csv")

results |>
  group_by(subj) |>
  summarise(prop = mean(correct, na.rm = TRUE))

results |>
  group_by(rec) |>
  summarise(count = sum(correct))

# freq bins
frame_size = as.integer(round(0.005 * 44100))
freqs = seq(0, 1 + frame_size / 2) * 44100 / frame_size

vowels |>
  group_by(stress) |>
  summarise(min = min(duration),
            max = max(duration))

params <- tibble()

for (i in 1:length(results_paths)) {
    read_csv(paste0(path, results_paths[i], "/params.csv"),
             show_col_types = FALSE) |>
    rename("n" = `# n`) |>
    mutate(n = as.character(n)) |>
    bind_rows(params) -> params
}

params |> View()

path <- "../../"
read_csv(paste0(path, "params.csv"))

accuracy |>
  rename("n" = params) |>
  mutate(n = as.character(n)) |>
  left_join(params, by = "n") |>
  arrange(desc(accuracy)) |>
  slice(1:30) |>
  select(-n, -high_crop) |>
  write_csv("accuracy_top30.csv")
