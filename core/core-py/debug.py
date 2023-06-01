base_folder = "/home/angelgardt/accent-reduction-app/data/recs/subj1/audio"
file = "1-1.wav"
frame = 0.025
d_step = 8
low_crop = 0
high_crop = 5000
intensity_threshold = -30
low_freq = 200
high_freq = 1000
gap = 3
min_duration = 0.02
suffix = "subj1_1-1"
sr=None
mono=None
save=True

signal, sr = load_audio(file = file,
                        base_folder=base_folder,
                        sr=sr,
                        mono=mono)

I, freqs = stft(signal, sr, frame=frame, d_step=d_step)

low_bin = sum(freqs < low_crop)
high_bin = sum(freqs < high_crop)
I_ = I[low_bin:high_bin, :]
max_intensity_bins = np.argmax(I_, axis=0)
max_intensity_freqs = np.array([freqs[i] for i in max_intensity_bins])
bounded_freqs = (max_intensity_freqs > low_freq) & (max_intensity_freqs < high_freq)
bounded_intensity = np.max(I_[(freqs[low_bin:high_bin] > low_freq) & (freqs[low_bin:high_bin] < high_freq), :], axis=0) > intensity_threshold
bounded_frames = bounded_freqs & bounded_intensity

intervals = []
n = 0
for i in range(len(bounded_frames)):
    if bounded_frames[i]:
        n += 1
    if not bounded_frames[i]:
        n -= 1
    try:
        if bounded_frames[i] != bounded_frames[i+1]:
            intervals.append(n)
            n = 0
    except IndexError:
        intervals.append(n)
    
duration_frames = []
l = 0
j = 0

while j < len(intervals):
    if intervals[j] < -gap:
        if l > 0:
            duration_frames.append(l)
            l = 0
            j += 1
        else:
            j += 1
    elif intervals[j] > 0:
        l = intervals[j]
        j += 1
    elif intervals[j] >= -gap and intervals[j] < 0:
        l += intervals[j+1]
        j += 2
    
duration_time = np.array(duration_frames) * frame
duration_time_ = duration_time[duration_time > min_duration]

if save:
    if suffix is None:
        print("Please specify suffix")
        # return None
    np.savetxt("I"+suffix+".csv", I_, delimiter=",")
    # np.savetxt("freqs"+suffix+".csv", freqs, delimiter=",")
    np.savetxt("bounded-frames"+suffix+".csv", bounded_frames, delimiter=",")
    np.savetxt("duration-time"+suffix+".csv", duration_time_, delimiter=",")
    
duration = duration_time_


stressed_vowel(duration)
