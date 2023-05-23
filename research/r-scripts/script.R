library(tidyverse)
theme_set(theme_bw())

# reading data
folder <- "../../data/features/"
ids <- folder |> dir()
recs <- folder |> paste0(ids[1], "/") |> dir()
features <- tibble()

for (id in 1:length(ids)) {
  print(id)
  for (rec in 1:length(recs)) {
    print(rec)
    paste0(folder, ids[id], "/", recs[rec]) |>
      read.csv(fileEncoding = "UTF-16") |>
      mutate_all(as.character) |>
      mutate(id = ids[id],
             rec = recs[rec],
             stress = str_replace_all(stress, " ", "")) |>
      drop_na() |>
      bind_rows(features) -> features
  }
}

str(features)

features |>
  mutate_at(vars("duration",
                 "timef",
                 "f0",
                 "f0max",
                 "f0min",
                 "f1",
                 "f2",
                 "f3",
                 "intensity",
                 "intensitymax"), as.numeric) |>
  filter(stress %in% 1:3) |>
  mutate(stress = factor(stress, ordered = TRUE, levels = 1:3)) -> vowels

# features |> filter(phoneme == "əᶦ")

vowels |>
  ggplot(aes(stress, duration)) +
  stat_summary(fun.data = mean_cl_boot, geom = "pointrange")

vowels |>
  aggregate(cbind(f1, f2) ~ phoneme, median) |>
  as_tibble() |>
  right_join(vowels |> select(phoneme, stress)) -> centroids

vowels |>
  ggplot(aes(f2, f1,
             label = phoneme, color = phoneme)) +
  geom_text() +
  stat_ellipse() +
  geom_point(data = centroids, aes(f2, f1, color = phoneme), size = 2) +
  scale_x_reverse(position = "top") +
  scale_y_reverse(position="right") +
  facet_wrap(~ stress) +
  guides(color = "none")
