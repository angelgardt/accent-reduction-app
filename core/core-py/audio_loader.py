import librosa
import matplotlib.pyplot as plt
import scipy.signal as sig

filename = '/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs/1-1.wav'
audio, sample_rate = librosa.load(filename, sr=None, mono=True)

print(sample_rate)
print(audio)
len(audio)

plt.plot(audio)
plt.show()

# librosa.effects.trim(y=audio, frame_length=8000, top_db=40)

# b = sig.firwin(9, 3500, fs=sample_rate)
# a = [1]
# filtered = sig.lfilter(b, a, audio)
# plt.plot(filtered)
# plt.show()


