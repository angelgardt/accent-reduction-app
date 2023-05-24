import os
import matplotlib.pyplot as plt
import librosa, librosa.display
# import IPython.display as ipd
import numpy as np
from scipy.signal import butter, lfilter, freqz, filtfilt


# BASE_FOLDER = "/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
BASE_FOLDER = "/home/angelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
file1 = "16-1.wav"
file2 = "16-2.wav"

signal, sr = librosa.load(os.path.join(BASE_FOLDER, file2), sr=None, mono=None)

print(sr)

plt.figure(figsize=(10, 10))
librosa.display.waveshow(signal, alpha = .5)
plt.show()

FRAME_LEN = .005 # seconds
FRAME_SIZE = int(round(FRAME_LEN * sr)) # samples
FRAME_STEP = FRAME_LEN / 4 # step in sec
HOP_SIZE = int(FRAME_STEP * sr)


# Filter requirements.
order = 2
cutoff = 5000  # desired cutoff frequency of the filter, Hz

def butter_lowpass(cutoff, fs, order=5):
    return butter(order, cutoff, fs=fs, btype='low', analog=False)

def butter_lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = filtfilt(b, a, data)
    return y

signal_filtered = butter_lowpass_filter(signal, cutoff, sr, order)
plt.figure(figsize=(10, 10))
librosa.display.waveshow(signal_filtered, alpha = .5)
plt.show()

signal_emph = librosa.effects.preemphasis(signal)

S_emph = librosa.amplitude_to_db(np.abs(librosa.stft(signal_emph, n_fft=FRAME_SIZE, hop_length=HOP_SIZE)), ref=np.max, top_db=70)
S_signal = librosa.amplitude_to_db(np.abs(librosa.stft(signal, n_fft=FRAME_SIZE, hop_length=HOP_SIZE)), ref=np.max, top_db=70)
S_filtered = librosa.amplitude_to_db(np.abs(librosa.stft(signal_filtered, n_fft=FRAME_SIZE, hop_length=HOP_SIZE)), ref=np.max, top_db=70)

plt.figure(figsize=(10, 5))
librosa.display.specshow(S_emph, 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r")
plt.colorbar(format="%+2.f")
plt.ylim([0, 5000])
plt.show()

plt.figure(figsize=(10, 5))
librosa.display.specshow(S_signal, 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r")
plt.colorbar(format="%+2.f")
plt.ylim([0, 5000])
plt.show()

plt.figure(figsize=(10, 5))
librosa.display.specshow(S_filtered, 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r")
plt.colorbar(format="%+2.f")
#plt.ylim([0, 5000])
plt.show()


fig, ax = plt.subplots(nrows=2, sharex=True, sharey=True)
librosa.display.specshow(S_signal, 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r",
                         ax=ax[0])
ax[0].set(title='Original signal')
ax[0].label_outer()
img = librosa.display.specshow(S_filtered, 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r",
                         ax=ax[1])
ax[1].set(title='Filtered signal')
fig.colorbar(img, ax=ax, format="%+2.f dB")
# plt.ylim([0, 5000])
plt.show()


S_signal = librosa.stft(signal, n_fft=FRAME_SIZE, hop_length=HOP_SIZE)
mag_signal = np.abs(S_signal)
pow_signal = mag_signal**2

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

S_signal.shape

plt.figure(figsize=(10, 5))
librosa.display.specshow(S_signal[:26, :], 
                         y_axis="linear", 
                         x_axis="time",
                         sr=sr,
                         hop_length=HOP_SIZE,
                         cmap="gray_r")
plt.colorbar(format="%+2.f")
#plt.ylim([0, 5000])
plt.show()

