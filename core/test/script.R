library(tidyverse)
library(warbleR)

tibble(sound.files = dir("stims"),
       selec = 1,
       start = 0,
       end = duration_wavs(paste0("stims/", 
                                  dir("stims")))$duration) -> st

info_wavs(paste0("stims/", 
                 dir("stims")))

View(select_table)
warbleR_options(flim = c(1, 10), wl = 200, ovlp = 90, bp = c(0, 5))

sp <- specan(st)
sp

xcor <- xcorr(X = st)
xcor

dtw <- df_DTW(st)
dtw %>% View
