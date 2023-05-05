# pkgs <- c("tidyverse", "warbleR")
# install.packages(pkgs)

library(tidyverse)
library(warbleR)

getwd()

# dir("../data/recs/v1/subj1/homographs/")
subjs <- dir("../data/recs/v1/")
subjs |> 
  map(\(x) sprintf("../data/recs/v1/%s/homographs/", x)) |> 
  unlist() -> sound_paths_homographs
sound_paths_homographs |> 
  map(dir, full.names=TRUE) |> 
  unlist() -> sound_files_homographs

tibble(sound.files = sound_files_homographs,
       selec = 1,
       start = 0,
       end = duration_wavs(sound_files_homographs)$duration) -> homographs

info_wavs(sound_files_homographs)

View(homographs)
warbleR_options(flim = c(1, 10), wl = 200, ovlp = 90, bp = c(0, 5))

sp <- specan(homographs)
sp

xcor <- xcorr(X = homographs)
xcor

dtw <- df_DTW(homographs)
dtw
