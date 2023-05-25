
I_ = I[:27, :]
max_intensity_bins = np.argmax(I_, axis=0)
# max_intensity
I_

max_intensity_freqs = np.array([freqs[i] for i in max_intensity_bins])

intensity_threshold = np.max(I_[(freqs[:27] > 200) & (freqs[:27] < 1000), :], axis=0) > -20
bound_freqs = (max_intensity_freqs > 200) & (max_intensity_freqs < 1000) & intensity_threshold

#np.savetxt("I.csv", I_, delimiter=",")
#np.savetxt("bound_freqs.csv", bound_freqs, delimiter=",")

intervals = []
n = 0
for i in range(len(bound_freqs)):
    if i == len(bound_freqs):
        pass
    if bound_freqs[i]:
        n += 1
    if not bound_freqs[i]:
        n -= 1
    try:
        if bound_freqs[i] != bound_freqs[i+1]:
            intervals.append(n)
            n = 0
    except IndexError:
        intervals.append(n)

intervals

duration_frames = []
l = 0
j = 0

while j < len(intervals):
    if intervals[j] < -3:
        if l > 0:
            duration_frames.append(l)
            l = 0
            j += 1
        else:
            j += 1
    elif intervals[j] > 0:
        l = intervals[j]
        j += 1
    elif intervals[j] >= -3 and intervals[j] < 0:
        l += intervals[j+1]
        j += 2

duration_frames

duration_time = np.array(duration_frames) * 0.005
duration_time
np.argmax(duration_time[duration_time > 0.02]) + 1

