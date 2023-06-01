import os.path
import librosa
import numpy as np
import matplotlib.pyplot as plt

base_folder = "/Users/antonangelgardt/accent-reduction-app/data/recs/subj2/audio/"
file = "1-1.wav"

signal, sr = load_audio(file, base_folder)

signal
sr

frame = 0.025
d_step = 8

I, freqs = stft(signal, sr, frame, d_step)

I.shape
freqs.shape

plot_spectrum(I, sr, frame, d_step, xlim=None, ylim=(0, 5000), figsize=(10, 5))