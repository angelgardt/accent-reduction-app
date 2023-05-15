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
  ggplot(aes(f2, f1,
             label = phoneme, color = stress)) +
  geom_text() +
  stat_ellipse() +
  scale_x_reverse(position = "top") +
  scale_y_reverse(position="right") +
  theme(legend.position = "bottom")


features |>
  filter(stress %in% 1:3) |>
  mutate(stress = as_factor(stress)) |>
  ggplot(aes(stress, duration)) +
  stat_summary(fun.data = mean_cl_boot, geom = "pointrange")


