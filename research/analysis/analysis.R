library(tidyverse)
theme_set(theme_bw())
library(lme4)
library(lmerTest)

# filter vowels
read_csv("features.csv") -> features

# filter vowels
features |>
  filter(reduction %in% 1:3) |>
  mutate(reduction = factor(reduction)) -> vowels

### DURATION -----
# plot absolute duration of vowels different reduction
vowels |>
  ggplot(aes(reduction, duration)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2) +
  labs(x = "Степень редукции",
       y = "Абсолютная длительность, с")
ggsave("graphs/absolute_duration.jpeg", width = 210, units = "mm")


# add id to prev graph
pd <- position_dodge(.3)
# vowels |>
#   ggplot(aes(reduction, duration, color = id)) +
#   stat_summary(fun.data = mean_cl_boot,
#                geom = "errorbar",
#                width = .5,
#                position = pd) +
#   stat_summary(fun = mean,
#                geom = "point",
#                size = 2,
#                position = pd) +
#   labs(x = "Степень редукции",
#        y = "Абсолютная длительность, с") +
#   theme(legend.position = "bottom")

# add vowel position in the word to first graph
vowels |>
  ggplot(aes(reduction, duration, color = position)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  labs(x = "Степень редукции",
       y = "Абсолютная длительность, c",
       color = "Позиция в слове") +
  theme(legend.position = "bottom")
ggsave("graphs/absolute_duration_position.jpeg", width = 210, units = "mm")


# check is there any bugs
# vowels |> filter(reduction == 1 & position == "F") |>
#   select(numphoneme, phoneme, reduction, position, rec, id)
## no bugs

## calculate relative duration, ref --- word duration
vowels |>
  group_by(id, rec) |>
  summarise(word_duration = sum(duration)) |>
  right_join(vowels, by = c("rec", "id")) |>
  mutate(rel_duration = duration / word_duration) -> vowels

# plot absolute duration of vowels different reduction
vowels |>
  ggplot(aes(reduction, rel_duration)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2) +
  labs(x = "Степень редукции",
       y = "Относительная длительность")
ggsave("graphs/relative_duration.jpeg", width = 210, units = "mm")

# add vowel position in the word to prev graph
vowels |>
  ggplot(aes(reduction, rel_duration, color = position)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  labs(x = "Степень редукции",
       y = "Относительная длительность",
       color = "Позиция в слове") +
  theme(legend.position = "bottom")
ggsave("graphs/relative_duration_position.jpeg", width = 210, units = "mm")




### INTENSITY -----

# plot relative intensity of vowels different reduction
vowels |>
  select(reduction, intensity, intensitymax, rec) |>
  pivot_longer(cols = -c('rec', 'reduction')) |>
  ggplot(aes(reduction, value)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  facet_grid(name ~ .,
             labeller = labeller(name = c(
               intensity = "Средняя интенсивность",
               intensitymax = "Максимальная интенсивность"
               )
             )) +
  labs(x = "Степень редукции",
       y = "Интенсивность, дБ")
ggsave("graphs/intensity.jpeg", width = 210, units = "mm")

# add vowel position in the word to previous graph
vowels |>
  select(reduction, intensity, intensitymax, rec, position) |>
  pivot_longer(cols = c('intensity', 'intensitymax')) |>
  ggplot(aes(reduction, value, color = position)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  facet_grid(name ~ .,
             labeller = labeller(name = c(
               intensity = "Средняя интенсивность",
               intensitymax = "Максимальная интенсивность"
             )
             )) +
  labs(x = "Степень редукции",
       y = "Интенсивность, дБ",
       color = "Позиция в слове") +
  theme(legend.position = "bottom")
ggsave("graphs/intensity_position.jpeg", width = 210, units = "mm")

## do statistics
model_intensity_null <- lmer(intensity ~ 1 + (1|id),
                        data = vowels, REML = FALSE)
model_intensity <- lmer(intensity ~ reduction + (1|id),
                        data = vowels, REML = FALSE)
summary(model_intensity)
anova(model_intensity_null, model_intensity)

model_intensity_position <- lmer(intensity ~ position + (1|id),
                        data = vowels, REML = FALSE)
summary(model_intensity_position)

model_intensitymax_null <- lmer(intensitymax ~ 1 + (1|id),
                           data = vowels, REML = FALSE)

model_intensitymax <- lmer(intensitymax ~ reduction + (1|id),
                        data = vowels, REML = FALSE)
summary(model_intensitymax)

model_intensitymax_position <- lmer(intensitymax ~ position + (1|id),
                                 data = vowels, REML = FALSE)
summary(model_intensitymax_position)

## save results
sink("results/intensity_lmer.txt")
anova(model_intensity_null, model_intensity)
summary(model_intensity); print("##################################################")
anova(model_intensity_null, model_intensity_position)
summary(model_intensity_position); print("##################################################")
anova(model_intensitymax_null, model_intensitymax)
summary(model_intensitymax); print("##################################################")
anova(model_intensitymax_null, model_intensitymax_position)
summary(model_intensitymax_position); print("##################################################")
sink()



### PITCH ----
# plot pitch of vowels different reduction
vowels |>
  select(reduction, f0, f0max, f0min, rec) |>
  pivot_longer(cols = c('f0', 'f0max', 'f0min')) |>
  ggplot(aes(reduction, value)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  facet_grid(name ~ .,
             labeller = labeller(
               name = c(
                 f0 = "Средняя частота\nосновного тона",
                 f0max = "Максимальная частота\nосновного тона",
                 f0min = "Минимальная частота\nосновного тона"
               ))) +
  labs(x = "Степень редукции",
       y = "Частота, Гц")
ggsave("graphs/pitch.jpeg", width = 210, units = "mm")

# add vowel position in the word to previous graph
vowels |>
  select(reduction, f0, f0max, f0min, rec, position) |>
  pivot_longer(cols = c('f0', 'f0max', 'f0min')) |>
  ggplot(aes(reduction, value, color = position)) +
  stat_summary(fun.data = mean_cl_boot,
               geom = "errorbar",
               width = .3,
               position = pd) +
  stat_summary(fun = mean,
               geom = "point",
               size = 2,
               position = pd) +
  facet_grid(name ~ .,
             labeller = labeller(
               name = c(
                 f0 = "Средняя частота\nосновного тона",
                 f0max = "Максимальная частота\nосновного тона",
                 f0min = "Минимальная частота\nосновного тона"
               ))) +
  labs(x = "Степень редукции",
       y = "Частота, Гц",
       color = "Позиция в слове") +
  theme(legend.position = "bottom")
ggsave("graphs/pitch_position.jpeg", width = 210, units = "mm")

## do statistics
model_pitch <- lmer(f0 ~ as.character(reduction) + (1|id),
                        data = vowels)
summary(model_pitch)
model_pitchmin <- lmer(f0min ~ as.character(reduction) + (1|id),
                    data = vowels)
summary(model_pitchmin)
model_pitchmax <- lmer(f0max ~ as.character(reduction) + (1|id),
                       data = vowels)
summary(model_pitchmax)

model_pitch_position <- lmer(f0 ~ position + (1|id),
                    data = vowels)
summary(model_pitch_position)
model_pitchmin_position <- lmer(f0min ~ position + (1|id),
                       data = vowels)
summary(model_pitchmin_position)
model_pitchmax_position <- lmer(f0max ~ position + (1|id),
                       data = vowels)
summary(model_pitchmax_position)

sink("results/pitch_lmer.txt")
summary(model_pitch); print("##################################################")
summary(model_pitchmin); print("##################################################")
summary(model_pitchmax); print("##################################################")
summary(model_pitch_position); print("##################################################")
summary(model_pitchmin_position); print("##################################################")
summary(model_pitchmax_position); print("##################################################")
sink()



### FORMANTS -----

# calculate centroids
vowels |>
  aggregate(cbind(f1, f2) ~ phoneme, median) |>
  as_tibble() |>
  right_join(vowels |> select(phoneme, reduction)) -> centroids

# plot formants
vowels |>
  filter(f1 < 1000) |>
  ggplot(aes(f2, f1,
             label = phoneme, color = phoneme)) +
  geom_text(alpha = .5) +
  stat_ellipse(level = .8) +
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
    )) +
  labs(x = "F2",
       y = "F1")
ggsave("graphs/formants.jpeg", width = 210, units = "mm")

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
