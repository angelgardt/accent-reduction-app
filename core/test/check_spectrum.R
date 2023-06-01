library(tidyverse)
theme_set(theme_minimal())

I <- read_csv("../../I.csv", col_names = FALSE)



I |>
  mutate(freq_bin = rownames(I)) |>
  pivot_longer(cols = -freq_bin, names_to = "frame", values_to = "dB") |>
  mutate(freq_bin = as.integer(freq_bin),
         frame = str_replace_all(frame, "X", "") |> as.integer()) |>
  ggplot() +
  geom_tile(aes(frame, freq_bin, fill = dB)) +
  # geom_point(data = bf |> mutate(frame = rownames(bf) |> as.integer()),
  #            aes(x = frame, y = 1, color = as_factor(X1)),
  #            size = .5) +
  # scale_color_manual(values = c("0" = "red", "1" = "green")) +
  scale_fill_continuous(high = "gray10", low = "gray90") +
  guides(fill = "none", color = "none") +
  ylim(c(0, 125))

