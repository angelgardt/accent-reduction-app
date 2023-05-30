library(tidyverse)
theme_set(theme_bw())
library(lme4)
library(lmerTest)
library(contrast)

# filter vowels
read_csv("features.csv") -> features

# filter vowels
features |>
  filter(reduction %in% 1:3) |>
  mutate(reduction = factor(reduction),
         position = factor(position,
                           ordered = TRUE,
                           levels = c("S", "I", "R", "T", "F", "O"))) -> vowels

# features$position |> unique()

pd <- position_dodge(.3)
pos_col <- c("S" = "red3",
             "I" = "orange3",
             "R" = "purple3",
             "T" = "green3",
             "F" = "blue3",
             "O" = "gold3")

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
  theme(legend.position = "bottom") +
  scale_color_manual(values = pos_col)
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
  theme(legend.position = "bottom") +
  scale_color_manual(values = pos_col)
ggsave("graphs/relative_duration_position.jpeg", width = 210, units = "mm")

## descriptives
vowels |>
  group_by(reduction) |>
  summarise(mean = mean(duration) |> round(3),
            sd = sd(duration) |> round(2),
            median = median(duration) |> round(3),
            min = min(duration) |> round(3),
            max = max(duration) |> round(3),
            skew = moments::skewness(duration) |> round(2),
            kurt = moments::kurtosis(duration) |> round(2)) |>
  write_csv("results/duration_reduction_desc.csv")

vowels |>
  group_by(position) |>
  summarise(mean = mean(duration) |> round(3),
            sd = sd(duration) |> round(2),
            median = median(duration) |> round(3),
            min = min(duration) |> round(3),
            max = max(duration) |> round(3),
            skew = moments::skewness(duration) |> round(2),
            kurt = moments::kurtosis(duration) |> round(2)) |>
  write_csv("results/duration_position_desc.csv")

vowels |>
  group_by(reduction) |>
  summarise(mean = mean(rel_duration) |> round(3),
            sd = sd(rel_duration) |> round(2),
            median = median(rel_duration) |> round(3),
            min = min(rel_duration) |> round(3),
            max = max(rel_duration) |> round(3),
            skew = moments::skewness(rel_duration) |> round(2),
            kurt = moments::kurtosis(rel_duration) |> round(2)) |>
  write_csv("results/rel_duration_reduction_desc.csv")

vowels |>
  group_by(position) |>
  summarise(mean = mean(rel_duration) |> round(3),
            sd = sd(rel_duration) |> round(2),
            median = median(rel_duration) |> round(3),
            min = min(rel_duration) |> round(3),
            max = max(rel_duration) |> round(3),
            skew = moments::skewness(rel_duration) |> round(2),
            kurt = moments::kurtosis(rel_duration) |> round(2)) |>
  write_csv("results/rel_duration_position_desc.csv")

## do statistics
model_duration_null <- lmer(duration ~ 1 + (1|id),
                             data = vowels, REML = FALSE)
model_duration <- lmer(duration ~ reduction + (1|id),
                        data = vowels, REML = FALSE)
anova(model_duration_null, model_duration)
summary(model_duration)

model_duration_position <- lmer(duration ~ position + (1|id),
                                 data = vowels, REML = FALSE,
                                contrasts = list(position="contr.treatment"))
anova(model_duration_null, model_duration_position)
summary(model_duration_position)

model_rel_duration_null <- lmer(rel_duration ~ 1 + (1|id),
                                data = vowels, REML = FALSE)
model_rel_duration <- lmer(rel_duration ~ reduction + (1|id),
                           data = vowels, REML = FALSE)
anova(model_rel_duration_null, model_rel_duration)
summary(model_rel_duration)

model_rel_duration_position <- lmer(rel_duration ~ position + (1|id),
                                    data = vowels, REML = FALSE,
                                    contrasts = list(position="contr.treatment"))
anova(model_rel_duration_null, model_rel_duration_position)
summary(model_intensitymax_position)

sink("results/duration_lmer.csv")
anova(model_duration_null, model_duration)
summary(model_duration); print("##################################################")
anova(model_duration_null, model_duration_position)
summary(model_duration_position); print("##################################################")
sink()

sink("results/rel_duration.csv")
anova(model_rel_duration_null, model_rel_duration)
summary(model_rel_duration); print("##################################################")
anova(model_rel_duration_null, model_rel_duration_position)
summary(model_intensitymax_position); print("##################################################")
sink()



### INTENSITY -----

# plot relative intensity of vowels different reduction
vowels |>
  select(reduction, intensity, intensitymax, rec) |>
  pivot_longer(cols = c('intensity', 'intensitymax')) |>
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
  theme(legend.position = "bottom") +
  scale_color_manual(values = pos_col)
ggsave("graphs/intensity_position.jpeg", width = 210, units = "mm")

## do statistics
model_intensity_null <- lmer(intensity ~ 1 + (1|id),
                        data = vowels, REML = FALSE)
model_intensity <- lmer(intensity ~ reduction + (1|id),
                        data = vowels, REML = FALSE,
                        contrasts = list(position="contr.treatment"))
summary(model_intensity)
anova(model_intensity_null, model_intensity)

model_intensity_position <- lmer(intensity ~ position + (1|id),
                        data = vowels, REML = FALSE)
summary(model_intensity_position)

model_intensitymax_null <- lmer(intensitymax ~ 1 + (1|id),
                           data = vowels, REML = FALSE,
                           contrasts = list(position="contr.treatment"))

model_intensitymax <- lmer(intensitymax ~ reduction + (1|id),
                        data = vowels, REML = FALSE)
summary(model_intensitymax)

model_intensitymax_position <- lmer(intensitymax ~ position + (1|id),
                                 data = vowels, REML = FALSE,
                                 contrasts = list(position="contr.treatment"))
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
model_pitch_null <- lmer(f0 ~ 1 + (1|id),
                    data = vowels, REML = FALSE)
model_pitchmin_null <- lmer(f0min ~ 1 + (1|id),
                         data = vowels, REML = FALSE)
model_pitchmax_null <- lmer(f0min ~ 1 + (1|id),
                         data = vowels, REML = FALSE)

model_pitch <- lmer(f0 ~ reduction + (1|id),
                        data = vowels, REML = FALSE)
anova(model_pitch_null, model_pitch)
summary(model_pitch)

model_pitchmin <- lmer(f0min ~ reduction + (1|id),
                    data = vowels, REML = FALSE)
anova(model_pitchmin_null, model_pitchmin)
summary(model_pitchmin)

model_pitchmax <- lmer(f0max ~ reduction + (1|id),
                       data = vowels, REML = FALSE)
anova(model_pitchmax_null, model_pitchmax)
summary(model_pitchmax)

model_pitch_position <- lmer(f0 ~ position + (1|id),
                    data = vowels, REML = FALSE,
                    contrasts = list(position="contr.treatment"))
anova(model_pitch_null, model_pitch_position)
summary(model_pitch_position)

model_pitchmin_position <- lmer(f0min ~ position + (1|id),
                       data = vowels, REML = FALSE,
                       contrasts = list(position="contr.treatment"))
anova(model_pitchmin_null, model_pitchmin_position)
summary(model_pitchmin_position)

model_pitchmax_position <- lmer(f0max ~ position + (1|id),
                       data = vowels, REML = FALSE,
                       contrasts = list(position="contr.treatment"))
anova(model_pitchmax_null, model_pitchmax_position)
summary(model_pitchmax_position)

sink("results/pitch_lmer.txt")
anova(model_pitch_null, model_pitch)
summary(model_pitch); print("##################################################")
anova(model_pitchmin_null, model_pitchmin)
summary(model_pitchmin); print("##################################################")
anova(model_pitchmax_null, model_pitchmax)
summary(model_pitchmax); print("##################################################")
anova(model_pitch_null, model_pitch_position)
summary(model_pitch_position); print("##################################################")
anova(model_pitchmin_null, model_pitchmin_position)
summary(model_pitchmin_position); print("##################################################")
anova(model_pitchmax_null, model_pitchmax_position)
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
  select(f0, f1, f2, f3, phoneme) |>
  mutate(f0 = ifelse(f0 == -1, NA, f0)) |>
  pivot_longer(cols = c("f0", "f1", "f2", "f3"),
               names_to = "formant") |>
  group_by(formant, phoneme) |>
  summarise(mean = mean(value, na.rm = TRUE) |> round(3),
            sd = sd(value, na.rm = TRUE) |> round(2),
            median = median(value, na.rm = TRUE) |> round(3),
            min = min(value, na.rm = TRUE) |> round(3),
            max = max(value, na.rm = TRUE) |> round(3),
            skew = moments::skewness(value, na.rm = TRUE) |> round(2),
            kurt = moments::kurtosis(value, na.rm = TRUE) |> round(2)) |>
  write_csv("results/formants_desc.csv")


vowels |>
  select(f0, f1, f2, f3) |>
  mutate(f0 = ifelse(f0 == -1, NA, f0)) |>
  pivot_longer(cols = c("f0", "f1", "f2", "f3"),
               names_to = "formant") |>
  group_by(formant) |>
  summarise(
    mean = mean(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    quar1 = quantile(value, .25, na.rm = TRUE),
    quar3 = quantile(value, .75, na.rm = TRUE),
    quin1 = quantile(value, 1/5, na.rm = TRUE),
    quin4 = quantile(value, 4/5, na.rm = TRUE)
  ) |>
  write_csv("results/formants_overall.csv")

