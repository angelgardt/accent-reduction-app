import librosa
import matplotlib.pyplot as plt
import scipy.signal as sig
import numpy as np

filename = '/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs/1-1.wav'
# reading audio
audio, sample_rate = librosa.load(filename, sr=None, mono=True)

print(sample_rate)
print(audio)
len(audio)

# plot audio to check
plt.plot(audio)
plt.show()

# set option for spliting to frames
frame_len_sec = 0.025 # window in sec
frame_step_sec = frame_len_sec / 4 # step in sec
n_filt = 2 # number of filters

n_samples = len(audio)
frame_len = int(round(frame_len_sec * sample_rate))
frame_step = int(round(frame_step_sec * sample_rate))

n_frames = 1 + int(np.floor((n_samples - frame_len) / frame_step))




# librosa.effects.trim(y=audio, frame_length=8000, top_db=40)

# b = sig.firwin(9, 3500, fs=sample_rate)
# a = [1]
# filtered = sig.lfilter(b, a, audio)
# plt.plot(filtered)
# plt.show()


