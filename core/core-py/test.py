import os
import re
import librosa
import numpy as np
import csv

base_folder = "/home/angelgardt/accent-reduction-app/data/recs/v1/subj1/homographs_audio"
#file = "24-1.wav"
# file = "24-2.wav"
files = os.listdir(base_folder)


frame = 0.005
crop = 27
intensity_threshold = -20
low_freq = 200
high_freq = 1000
gap = 3
min_duration = 0.02

results = []

for file in files:
    suffix = file.split(".")[0]
    r = core_stressed_vowel(file,
                            base_folder,
                            frame,
                            crop,
                            intensity_threshold,
                            low_freq,
                            high_freq,
                            gap,
                            min_duration,
                            suffix=suffix,
                            sr=None,
                            mono=None,
                            save=True)
    results.append([suffix, r])

with open("results.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(results)
