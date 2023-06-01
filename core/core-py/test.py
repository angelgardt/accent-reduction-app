import os
import re
import librosa
import numpy as np
import csv

# for linux
base_folder = "/home/angelgardt/accent-reduction-app/data/recs/subj10/audio"

# for mac
# base_folder = "/Users/antonangelgardt/accent-reduction-app/data/recs/subj6/audio"

subj = re.findall("subj\d+", base_folder)[0]
files = os.listdir(base_folder)


frame = 0.005
d_step = 8
low_crop = 1
high_crop = 15
intensity_threshold = -30
low_freq = 200
high_freq = 1000
gap = 3
min_duration = 0.02

results = []

for file in files:
    suffix = subj + "_" + file.split(".")[0]
    r = core_stressed_vowel(file,
                            base_folder,
                            frame,
                            d_step,
                            low_crop,
                            high_crop,
                            intensity_threshold,
                            low_freq,
                            high_freq,
                            gap,
                            min_duration,
                            suffix="_" + suffix,
                            sr=None,
                            mono=None,
                            save=True)
    results.append([suffix, r])

print(results)

with open(subj + "_results.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(results)
