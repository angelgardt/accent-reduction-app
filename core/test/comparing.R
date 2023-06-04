library(tidyverse)
library(phonfieldwork)
library(googlesheets4)

## read correct ans

read_sheet("https://docs.google.com/spreadsheets/d/1wYrxpNZVWv58IGZbC7p-bQV8_gXoTc1P57GCLMi2fpc/edit#gid=0",
           "words") |>
  select(-narrow) -> words

### VOWEL DETECTOR -----

vowel_detector <- tibble()
folder <- "vowel-detector/"
subjs <- dir(folder)
annotations <- dir(paste0(folder, subjs[1]))

for (i in 1:length(subjs)) {
  for (j in 1:length(annotations)) {
    textgrid_to_df(paste0(folder, subjs[i], "/", annotations[j])) |>
      rename("n" = id) |>
      mutate(id = subjs[i]) |>
      bind_rows(vowel_detector) -> vowel_detector
  }
}

vowel_detector |>
  mutate(source = str_remove_all(source, ".TextGrid") |> as.numeric(),
         phoneme_type = ifelse(n %% 2 == 0, "V", "C"),
         duration = time_end - time_start) |>
  filter(phoneme_type == "V") |>
  group_by(source, id) |>
  summarise(stress_detected = which.max(duration)) |>
  left_join(words, by = c("source" = "word_n")) |>
  mutate(correct = ifelse(stress == stress_detected, TRUE, FALSE)) -> vowel_detector_res

vowel_detector_res$correct |> mean()

### ALGORITHM -----

path <- "results/test_check"

results_paths <- dir(path)[dir(path) |> str_detect("results")]

results <- tibble()

for (i in 1:length(results_paths)) {

  read_csv(paste0(path, "/", results_paths[i]), col_names = FALSE) |>
    rename("rec" = X1,
           "res" = X2) |>
    mutate(rec = str_extract(rec, "_\\d+") |> str_remove_all("_") |> as.numeric(),
           subj = results_paths[i] |> str_extract("subj\\d+")) |>
    bind_rows(results) -> results

}

results |>
  left_join(words, by = c("rec" = "word_n")) |>
  mutate(correct = ifelse(res == stress, TRUE, FALSE)) -> alg_test_res

alg_test_res$correct |> is.na() |> sum()
alg_test_res$correct |> mean(na.rm = TRUE)


### WebMAUS ----

for (i in 1:length(words$orthographic)){
  words$orthographic[i] |>
    write.table(paste0(i, ".txt"),
                col.names = FALSE,
                row.names = FALSE,
                quote = FALSE)
}

webmaus <- tibble()
folder <- "results/webmaus/"
subjs <- dir(folder)
annotations <- dir(paste0(folder, subjs[1]))

for (i in 1:length(subjs)) {
  for (j in 1:length(annotations)) {
    textgrid_to_df(paste0(folder, subjs[i], "/", annotations[j])) |>
      rename("n" = id) |>
      mutate(id = subjs[i]) |>
      bind_rows(webmaus) -> webmaus
  }
}

# webmaus |> head()
# webmaus |> filter(tier == 3) |> select(content) |> unique()
# webmaus |> filter(source == "30.TextGrid")
# webmaus |> filter(content == 1)

webmaus |>
  filter(tier == 3 & content %in% c("o", "a", "u", "e", "1", "i")) |>
  mutate(source = str_remove_all(source, ".TextGrid") |> as.numeric(),
         duration = time_end - time_start) |>
  group_by(source, id) |>
  summarise(stress_detected = which.max(duration)) |>
  left_join(words, by = c("source" = "word_n")) |>
  mutate(correct = ifelse(stress == stress_detected, TRUE, FALSE)) -> webmaus_res

webmaus_res$correct |> is.na() |> sum()
webmaus_res$correct |> mean()

