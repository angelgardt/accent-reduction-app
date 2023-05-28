library(tidyverse)
library(googlesheets4)

# creating rquired constants
folder <- "../../data/features/"
ids <- folder |> dir()
recs <- folder |> paste0(ids[1], "/") |> dir()

## check the number of records
length(recs)

# read tables with phonemes info
reduction <- read_sheet("https://docs.google.com/spreadsheets/d/1wYrxpNZVWv58IGZbC7p-bQV8_gXoTc1P57GCLMi2fpc/edit#gid=194389716",
                        "reduction") |> select(-color)
stress <- read_sheet("https://docs.google.com/spreadsheets/d/1wYrxpNZVWv58IGZbC7p-bQV8_gXoTc1P57GCLMi2fpc/edit#gid=194389716",
                     "stress") |> select(1:4)
consonants <- read_sheet("https://docs.google.com/spreadsheets/d/1wYrxpNZVWv58IGZbC7p-bQV8_gXoTc1P57GCLMi2fpc/edit#gid=194389716",
                         "consonants") |> select(1:5)

# create empty tibble for reading data
features <- tibble()

# reading data
for (id in 1:length(ids)) {
  print(paste("subj", id))
  for (rec in 1:length(recs)) {
    print(paste("rec", rec))
    paste0(folder, ids[id], "/", recs[rec]) |>
      read.csv(fileEncoding = "UTF-16") |>
      mutate_all(as.character) |>
      mutate(id = ids[id],
             rec = recs[rec] |> str_remove_all(".csv"),
             phoneme = str_remove_all(phoneme, " ") |> str_replace_all("e̝", "ə̝"),
             numphoneme = as.numeric(numphoneme) - 1) |>
      drop_na() |>
      filter(phoneme != "") |>
      left_join(reduction, by = "phoneme") |>
      replace_na(list(reduction = 0)) |>
      left_join(stress |>
                  mutate(numphoneme = as.numeric(numphoneme)),
                by = c("rec", "numphoneme", "phoneme")) |>
      left_join(consonants,
                by = "phoneme") |>
      bind_rows(features) -> features
  }
}

# check NAs
features |>
  select(-stress) |>
  sapply(function(x) x |> is.na() |> sum())

# fix annotation mistakes
features |>
  select(-stress) |>
  filter(is.na(position)) |>
  mutate(phoneme = c("e", "ə"),
         position = c("S", "T"),
         reduction = c(1, 3)) |>
  bind_rows(
    features |>
      filter(!(id == "subj1" & rec == "11-1" & numphoneme %in% c(2, 5)))
  ) |>
  arrange(id, rec, numphoneme) -> features

# write preprocessed data
features |> write_csv("features.csv")
