import os
import matplotlib.pyplot as plt
import librosa, librosa.display
# import IPython.display as ipd
import numpy as np

BASE_FOLDER = "/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
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
Y_signal = np.abs(S_signal)


plt.figure(figsize=(25, 10))
librosa.display.specshow(Y_signal,
                         sr=sr, 
                         hop_length=HOP_SIZE, 
                         x_axis="time", 
                         y_axis="linear")
plt.colorbar(format="%+2.f")
plt.ylim([0, 5000])
plt.show()
