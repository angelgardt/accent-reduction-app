import os.path
import librosa

BASE_FOLDER = "/home/angelgardt/accent-reduction-app/data/recs/v1/subj1/homographs"
file1 = "16-1.wav"
file2 = "16-2.wav"

signal, sr = librosa.load(os.path.join(BASE_FOLDER, file2), sr=None, mono=None)

I, freqs = stft(signal, sr, frame=.005)
# plot_spectrum(I, sr, frame=.005, ylim=[0, 5000])

freqs.shape



