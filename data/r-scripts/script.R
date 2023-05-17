library(tidyverse)
theme_set(theme_bw())

folder = "../features/subj1/"
features <- tibble()
for (i in 1:length(dir(folder))) {
  read.csv(paste0(folder, dir(folder)[i]), fileEncoding="UTF-16") |>
    bind_rows(features) -> features
}

str(features)

features |>
  filter(stress %in% 1:3) |>
  mutate(stress = factor(stress, ordered = TRUE, levels = 1:3))-> vowels


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

