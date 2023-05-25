def vowel_duration(I,
                   freqs,
                   frame,
                   crop = 27,
                   intensity_threshold = -20,
                   low_freq = 200,
                   high_freq = 1000, 
                   gap = 3,
                   min_duration = 0.02):
    
    I_ = I[:crop, :]
    max_intensity_bins = np.argmax(I_, axis=0)
    max_intensity_freqs = np.array([freqs[i] for i in max_intensity_bins])
    bounded_freqs = (max_intensity_freqs > low_freq) & (max_intensity_freqs < high_freq)
    bounded_intensity = np.max(I_[(freqs[:crop] > low_freq) & (freqs[:27] < high_freq), :], axis=0) > intensity_threshold
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
            intervals.apppend(n)
    
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
    
    return np.array(duration_frames) * frame
