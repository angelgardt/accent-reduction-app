import numpy as np
import scipy.signal as sig
import scipy.io.wavfile as wavfile


rate, signal = wavfile.read("./data/recs/v1/subj1/homographs/1-1.wav") # read file
rate
signal
lower_freq=500
upper_freq=3000
min_duration=0.1


# calculating formants function
## set filter parameters
pre_emph = [1.0, -0.95] # preliminary amplification
frame_len = 0.025 # frame length (sec)
frame_step = 0.01 # frame step (sec)
n_filt = 2 # number of filters

## filter the signal
b = sig.firwin(9, 1.0 - 50.0 / (rate / 2.0))
a = [1]
signal = sig.lfilter(b, a, signal)
signal = sig.lfilter(pre_emph, 1, signal)

## separate signal to frames
n_samples = len(signal)
frame_len = int(round(frame_len * rate))
frame_step = int(round(frame_step * rate))
n_frames = 1 + int(np.floor((n_samples - frame_len) / frame_step))
pad_len = n_frames * frame_step + frame_len - n_samples
signal = np.append(signal, np.zeros(pad_len))
indices = np.tile(np.arange(0, frame_len), (n_frames, 1)) + np.tile(np.arange(0, n_frames * frame_step, frame_step), (frame_len, 1)).T
frames = signal[indices.astype(np.int32, copy=False)]

## get sound spectrum with Fourier transform
mag_frames = np.abs(np.fft.rfft(frames, n_filt))
pow_frames = ((1.0 / n_filt) * ((mag_frames) ** 2))
freq_axis = np.fft.rfftfreq(n_filt, 1.0 / rate)

## find formants
max_indices = np.argmax(pow_frames, axis=1)
max_freqs = freq_axis[max_indices]

### calculating formants
formant_frqs = max_freqs

## measure vowel duration
indices = np.where((formant_frqs > lower_freq) & (formant_frqs < upper_freq))[0]
silence_threshold = 0.1 * np.max(np.abs(signal))
intervals = []
start = None
for i in indices:
    if start is None:
        start = i
    elif i - indices[np.where(indices == start)[0][0]] > 1:
        interval = (start, i)
        if signal[start:i].max() > silence_threshold:
            intervals.append(interval)
        start = i
intervals.append((start, indices[-1]))

intenvals = [interval for interval in intervals if interval[1] - interval[0] >= int(min_duration * rate)]






# use functions to measure vowels duration in WAV file
for interval in intervals:
    duration = (interval[1] - interval[0]) / rate
    print("Vowel duration:", duration)
