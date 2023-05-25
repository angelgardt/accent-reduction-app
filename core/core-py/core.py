import os.path
import librosa
import numpy as np
# import matplotlib.pyplot as plt

base_folder = "/home/angelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
file1 = "24-1.wav"
file2 = "24-2.wav"

frame = 0.005
crop = 27
intensity_threshold = -20
low_freq = 200
high_freq = 1000
gap = 3
min_duration = 0.02

signal, sr = load_audio(file = file1,
                        base_folder=base_folder,
                        sr=None,
                        mono=None)

I, freqs = stft(signal, sr, frame=frame)

# plot_spectrum(I, sr, frame=.005, ylim=[0, 5000])

duration = vowel_duration(I,
                          freqs,
                          frame=frame,
                          crop=crop,
                          intensity_threshold=intensity_threshold,
                          low_freq=low_freq,
                          high_freq=high_freq,
                          gap=gap,
                          min_duration=min_duration)

stressed_vowel(duration)
