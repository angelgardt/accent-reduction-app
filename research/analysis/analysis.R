library(tidyverse)
theme_set(theme_bw())

# reading data
folder <- "../../data/features/"
ids <- folder |> dir()
recs <- folder |> paste0(ids[1], "/") |> dir()
tibble(phoneme = c("ɐ", "o", "a", "ə", "ə̝",  "ɪ",  "i",  "ʊ", "u",  "e",  "ɨ̞",  "ɨ",  "əᶷ", "ə̝ᶷ"),
       reduction = c(2, 1, 1, 3, 3, 2, 1, 2, 1, 1, 2, 1, 3, 3)) -> reduction

reduction |> write.csv("reduction.csv", fileEncoding = "UTF-16")

features <- tibble()

for (rec in 1:length(recs)) {
  print(rec)
  paste0(folder, ids[1], "/", recs[rec]) |>
    read.csv(fileEncoding = "UTF-16") |>
    mutate_all(as.character) |>
    mutate(id = ids[1],
           rec = recs[rec] |> str_remove_all(".csv"),
           phoneme = str_remove_all(phoneme, " "),
           numphoneme = as.numeric(numphoneme) - 1) |>
    drop_na() |>
    filter(phoneme != "") |>
    left_join(reduction, by = c("phoneme")) |>
    replace_na(list(reduction = 0))|>
    bind_rows(features) -> features
}

for (id in 2:length(ids)) {
  print(id)
  for (rec in 1:length(recs)) {
    print(rec)
    paste0(folder, ids[id], "/", recs[rec]) |>
      read.csv(fileEncoding = "UTF-16") |>
      mutate_all(as.character) |>
      mutate(id = ids[id],
             rec = recs[rec] |> str_remove_all(".csv"),
             phoneme = str_remove_all(phoneme, " "),
             numphoneme = as.numeric(numphoneme) - 1) |>
      drop_na() |>
      filter(phoneme != "") |>
      left_join(reduction, by = c("phoneme")) |>
      replace_na(list(reduction = 0)) |>
      bind_rows(features) -> features
  }
}

str(features)

features |> write_csv("features.csv")

features <- read_csv("features.csv")

features |> View()

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
  select(-stress) |>
  filter(reduction %in% 1:3) -> vowels

vowels |> write_csv("vowels-features.csv")

# features |> filter(phoneme == "əᶦ")

read_csv("vowels-features.csv") |>
  mutate(reduction = factor(reduction, ordered = TRUE, levels = 1:3)) -> vowels

vowels |>
  filter(reduction == 1) |>
  select(duration, rec, id) |>
  rename("stressed_duration" = duration) |>
  right_join(vowels, by = c("rec", "id")) |>
  mutate(rel_duration = duration / stressed_duration) |>
  select(-stressed_duration) -> vowels

vowels$stress

vowels |>
  ggplot(aes(reduction, rel_duration, color = id)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "pointrange")

vowels |>
  ggplot(aes(reduction, rel_duration, color = id)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "pointrange") +
  facet_wrap(~ rec)


ez::ezANOVA(vowels, dv = duration, between = stress, wid = rec)

vowels |>
  select(reduction, intensity, intensitymax, rec) |>
  pivot_longer(cols = -c('rec', 'reduction')) |>
  ggplot(aes(reduction, value, color = name)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "pointrange",
               position = position_dodge(.3))

vowels |>
  select(reduction, f0, f0max, f0min, rec) |>
  pivot_longer(cols = -c('rec', 'reduction')) |>
  ggplot(aes(reduction, value, color = name)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "pointrange",
               position = position_dodge(.3))


vowels |>
  aggregate(cbind(f1, f2) ~ phoneme, median) |>
  as_tibble() |>
  right_join(vowels |> select(phoneme, reduction)) -> centroids

vowels |>
  ggplot(aes(f2, f1,
             label = phoneme, color = phoneme)) +
  geom_text() +
  stat_ellipse() +
  geom_point(data = centroids, aes(f2, f1, color = phoneme), size = 2) +
  scale_x_reverse(position = "top") +
  scale_y_reverse(position="right") +
  facet_wrap(~ reduction) +
  guides(color = "none") +
  scale_color_manual(
    values = c(
      "a" = "coral3",
      "o" = "orange3",
      "e" = "springgreen3",
      "ɨ" = "green4",
      "u" = "royalblue4",
      "ɐ" = "salmon3",
      "ɨ̞" = "seagreen",
      "ʊ" = "blue4",
      "ə" = "gray20",
      "əᶷ" = "slateblue2",
      "i" = "red3",
      "ɪ" = "gold3",
      "ə̝" = "gray40",
      "ə̝ᶷ" = "lightblue4"
    ))

vowels$phoneme |> table()

vowels |>
  select(f1, f2) |>
  pivot_longer(cols = everything(), names_to = "formant") |>
  group_by(formant) |>
  summarise(
    mean = mean(value),
    max = max(value),
    min = min(value),
    quin1 = quantile(value, 1 / 5),
    quin4 = quantile(value, 4 / 5)
  )

# freq bins
frame_size = as.integer(round(0.005 * 44100))
freqs = seq(0, 1 + frame_size / 2) * 44100 / frame_size

vowels |>
  group_by(stress) |>
  summarise(min = min(duration),
            max = max(duration))
