library(tidyverse)
theme_set(theme_minimal())

path <- "results/test1"

bounded_frames <- dir(path)[dir(path) |> str_detect("bounded-frames")]
I <- dir(path)[dir(path) |> str_detect("I")]

for (i in 1:length(I)) {
  I_ <- read_csv(paste0("data/", I[i]), col_names = FALSE)
  bf <- read_csv(paste0("data/", bounded_frames[i]), col_names = FALSE)
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
  ggsave(paste0(path, rec, ".jpeg"), width = 30, height = 20, units = "cm")
}
