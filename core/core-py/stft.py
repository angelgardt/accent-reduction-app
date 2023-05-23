import os
import matplotlib.pyplot as plt
import librosa, librosa.display
# import IPython.display as ipd
import numpy as np

# BASE_FOLDER = "/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
BASE_FOLDER = "/home/angelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
file1 = "1-1.wav"
file2 = "1-2.wav"

signal, sr = librosa.load(os.path.join(BASE_FOLDER, file2), sr=None, mono=None)

print(sr)

plt.figure(figsize=(10, 10))
librosa.display.waveshow(signal, alpha = .5)
plt.show()

FRAME_LEN = .005 # seconds
FRAME_SIZE = int(round(FRAME_LEN * sr)) # samples
FRAME_STEP = FRAME_LEN / 4 # step in sec
HOP_SIZE = int(FRAME_STEP * sr)

S_signal = librosa.stft(signal, n_fft=FRAME_SIZE, hop_length=HOP_SIZE)
mag_signal = np.abs(S_signal)
pow_signal = mag_signal**2
freqs = np.arange(0, 1 + FRAME_SIZE / 2) * sr / FRAME_SIZE

max_pow = np.argmax(pow_signal, axis=0)
max_freq_bin = np.argmax(S_signal, axis=0)
# mag_signal.shape
# pow_signal.shape
# freqs.size
freqs
max_pow.size
max_freq_bin.size
max_freqs = np.array([freqs[i] for i in max_freq_bin])
max_freqs.size

LOWER_FREQ = 300
UPPER_FREQ = 3000

bound_freq = (max_freqs > LOWER_FREQ) & (max_freqs < UPPER_FREQ)
bound_freq

interval = False
intervals = []
frm = 0
for i in range(len(bound_freq)):
    if bound_freq[i]:
        frm += 1
    try:
        if not bound_freq[i+1]:
            intervals.append(frm)
            frm = 0
    except IndexError:
        break
intervals = np.array(intervals)
sum(intervals > 2)
intervals[intervals > 2]




indices = np.where((max_freqs > LOWER_FREQ) & (max_freqs < UPPER_FREQ))[0]
indices

intervals = []
start = None
silence_threshold = 0.1 * np.max(np.abs(signal))
min_duration=0.1

for i in indices:
    if start is None:
        start = i
    elif i - indices[np.where(indices == start)[0][0]] > 1:
        interval = (start, i)
        if signal[start:i].max() > silence_threshold:
            intervals.append(interval)
        start = i
intervals.append((start, indices[-1]))

[interval for interval in intervals if interval[1] - interval[0] >= int(min_duration * sr)]

plt.figure(figsize=(10, 5))
librosa.display.specshow(mag_signal,
                         sr=sr, 
                         hop_length=HOP_SIZE, 
                         cmap='gray_r',
                         x_axis="time", 
                         y_axis="linear")
plt.colorbar(format="%+2.f")
plt.ylim([0, 5000])
plt.show()

# print(S_signal)
# print(Y_signal)


