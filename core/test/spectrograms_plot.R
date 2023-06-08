library(tidyverse)
theme_set(theme_minimal())

path <- "results/test_pics/"

bounded_frames <- dir(path)[dir(path) |> str_detect("bounded-frames")]
I <- dir(path)[dir(path) |> str_detect("I")]

for (i in 1:length(I)) {
  I_ <- read_csv(paste0(path, I[i]), col_names = FALSE)
  bf <- read_csv(paste0(path, bounded_frames[i]), col_names = FALSE)
  rec <-I[i] |> str_extract("\\d+-\\d")

  I_ |>
    mutate(freq_bin = rownames(I_)) |>
    pivot_longer(cols = -freq_bin, names_to = "frame", values_to = "dB") |>
    mutate(freq_bin = as.integer(freq_bin),
           frame = str_replace_all(frame, "X", "") |> as.integer()) |>
    ggplot() +
    geom_tile(aes(frame, freq_bin, fill = dB)) +
    geom_point(data = bf |> mutate(frame = rownames(bf) |> as.integer()),
               aes(x = frame, y = 1, color = as_factor(X1)),
               size = .5) +
    scale_fill_continuous(high = "gray10", low = "gray90") +
    scale_color_manual(values = c("0" = "red", "1" = "green")) +
    guides(fill = "none", color = "none")
  ggsave(paste0(path, bounded_frames[i], ".jpeg"), width = 30, height = 20, units = "cm")
}

I1_ <- read_csv(paste0(path, "I_subj3_29-1.csv"), col_names = FALSE) |> mutate(id = "3_29-1",
                                                                               freq_bin = rownames(I1_))
I2_ <- read_csv(paste0(path, "I_subj3_29-2.csv"), col_names = FALSE) |> mutate(id = "3_29-2",
                                                                               freq_bin = rownames(I2_))
bf1 <- read_csv(paste0(path, "bounded-frames_subj3_29-1.csv"), col_names = FALSE) |> mutate(id = "3_29-1",
                                                                                            frame = rownames(bf1) |>
                                                                                              as.integer())
bf2 <- read_csv(paste0(path, "bounded-frames_subj3_29-2.csv"), col_names = FALSE) |> mutate(id = "3_29-2",
                                                                                            frame = rownames(bf2) |>
                                                                                              as.integer())

I1_ |> bind_rows(I2_) -> I_
bf1 |> bind_rows(bf2) -> bf
# rec <- I[i] |> str_extract("\\d+-\\d")

#frame_size = as.integer(round(0.025 * 44100))
#freqs = seq(0, 1 + frame_size / 2) * 44100 / frame_size
#(freqs < 2200) |> sum()

I_ |>
  pivot_longer(cols = -c("freq_bin", "id"), names_to = "frame", values_to = "dB") |>
  mutate(freq_bin = as.integer(freq_bin),
         frame = str_replace_all(frame, "X", "") |> as.integer()) |>
  ggplot() +
  geom_tile(aes(frame, freq_bin, fill = dB)) +
  geom_point(data = bf,
             aes(x = frame, y = 30, color = as_factor(X1)),
             size = 1) +
  facet_wrap(~ id,
             ncol = 1,
             labeller = labeller(id = c("3_29-1" = "/'parəm/",
                                        "3_29-2" = "/'pɐ'rom/"))) +
  scale_fill_continuous(high = "gray10", low = "gray90") +
  scale_color_manual(values = c("0" = "red", "1" = "green")) +
  guides(fill = "none", color = "none") +
  xlim(c(200, 700)) +
  labs(x = "Номер фрейма", y = "Номер диапазона частот") +
  theme(text = element_text(size = 18))

ggsave(paste0(path, "subj3_29.jpeg"), width = 30, height = 20, units = "cm")






I1_ <- read_csv(paste0(path, "I_subj4_16-1.csv"), col_names = FALSE) |> mutate(id = "4_16-1",
                                                                               freq_bin = rownames(I1_))
I2_ <- read_csv(paste0(path, "I_subj4_16-2.csv"), col_names = FALSE) |> mutate(id = "4_16-2",
                                                                               freq_bin = rownames(I2_))
bf1 <- read_csv(paste0(path, "bounded-frames_subj4_16-1.csv"), col_names = FALSE)
bf1 |> mutate(id = "4_16-1",
              frame = rownames(bf1) |>
                as.integer()) -> bf1
bf2 <- read_csv(paste0(path, "bounded-frames_subj4_16-2.csv"), col_names = FALSE)
bf2 |> mutate(id = "4_16-2",
              frame = rownames(bf2) |>
                as.integer()) -> bf2

I1_ |> bind_rows(I2_) -> I_
bf1 |> bind_rows(bf2) -> bf

I_ |>
  pivot_longer(cols = -c("freq_bin", "id"), names_to = "frame", values_to = "dB") |>
  mutate(freq_bin = as.integer(freq_bin),
         frame = str_replace_all(frame, "X", "") |> as.integer()) |>
  ggplot() +
  geom_tile(aes(frame, freq_bin, fill = dB)) +
  geom_point(data = bf,
             aes(x = frame, y = 30, color = as_factor(X1)),
             size = 1) +
  facet_wrap(~ id,
             ncol = 1,
             labeller = labeller(id = c("4_16-1" = "/'atləs/",
                                        "4_16-2" = "/'ɐt'las/"))) +
  scale_fill_continuous(high = "gray10", low = "gray90") +
  scale_color_manual(values = c("0" = "red", "1" = "green")) +
  guides(fill = "none", color = "none") +
  xlim(c(100, 600)) +
  labs(x = "Номер фрейма", y = "Номер диапазона частот") +
  theme(text = element_text(size = 18))

ggsave(paste0(path, "subj4_16.jpeg"), width = 30, height = 20, units = "cm")








I1_ <- read_csv(paste0(path, "I_subj2_3-1.csv"), col_names = FALSE) |> mutate(id = "2_3-1",
                                                                               freq_bin = rownames(I1_))
I2_ <- read_csv(paste0(path, "I_subj3_27-1.csv"), col_names = FALSE) |> mutate(id = "3_27-1",
                                                                               freq_bin = rownames(I2_))
bf1 <- read_csv(paste0(path, "bounded-frames_subj2_3-1.csv"), col_names = FALSE)
bf1 |> mutate(id = "2_3-1",
              frame = rownames(bf1) |>
                as.integer()) -> bf1
bf2 <- read_csv(paste0(path, "bounded-frames_subj3_27-1.csv"), col_names = FALSE)
bf2 |> mutate(id = "3_27-1",
              frame = rownames(bf2) |>
                as.integer()) -> bf2

I1_ |> bind_rows(I2_) -> I_
bf1 |> bind_rows(bf2) -> bf

I1_ |>
  pivot_longer(cols = -c("freq_bin", "id"), names_to = "frame", values_to = "dB") |>
  mutate(freq_bin = as.integer(freq_bin),
         frame = str_replace_all(frame, "X", "") |> as.integer()) |>
  ggplot() +
  geom_tile(aes(frame, freq_bin, fill = dB)) +
  geom_point(data = bf1,
             aes(x = frame, y = 30, color = as_factor(X1)),
             size = 1) +
  facet_wrap(~ id,
             ncol = 1,
             labeller = labeller(id = c("2_3-1" = "/'irʲə̝s/",
                                        "3_27-1" = "/'maɫə/")),
             scales = "free_x") +
  scale_fill_continuous(high = "gray10", low = "gray90") +
  scale_color_manual(values = c("0" = "red", "1" = "green")) +
  guides(fill = "none", color = "none") +
  labs(x = "Номер фрейма", y = "Номер диапазона частот") +
  xlim(c(50, 500)) +
  theme(text = element_text(size = 18))

ggsave(paste0(path, "subj2_3-1.jpeg"), width = 25, height = 20, units = "cm")



I2_ |>
  pivot_longer(cols = -c("freq_bin", "id"), names_to = "frame", values_to = "dB") |>
  mutate(freq_bin = as.integer(freq_bin),
         frame = str_replace_all(frame, "X", "") |> as.integer()) |>
  ggplot() +
  geom_tile(aes(frame, freq_bin, fill = dB)) +
  geom_point(data = bf2,
             aes(x = frame, y = 30, color = as_factor(X1)),
             size = 1) +
  facet_wrap(~ id,
             ncol = 1,
             labeller = labeller(id = c("2_3-1" = "/'irʲə̝s/",
                                        "3_27-1" = "/'maɫə/")),
             scales = "free_x") +
  scale_fill_continuous(high = "gray10", low = "gray90") +
  scale_color_manual(values = c("0" = "red", "1" = "green")) +
  guides(fill = "none", color = "none") +
  labs(x = "Номер фрейма", y = "Номер диапазона частот") +
  xlim(c(100, 700)) +
  theme(text = element_text(size = 18))

ggsave(paste0(path, "subj3_27-1.jpeg"), width = 25, height = 20, units = "cm")
