import os
import re
import librosa
import numpy as np
import matplotlib.pyplot as plt
import csv

### FUNCTIONS ###

def stft(signal, sr, frame, d_step):
    
    """
    This function takes three arguments:
    signal is an array containing sequence of samples of a signal
    sr is the smaple rate
    frame is the frame size in seconds
    d_step is a denominator for hop size calculation
    """

    frame_size = int(round(frame * sr)) # frame size in samples
    frame_step = frame / d_step # step in seconds
    hop_size = int(frame_step * sr) # hop size in samples

    # get spectral matrix
    S = librosa.stft(signal, n_fft=frame_size, hop_length=hop_size)
    # get amplitudes from spectral matrix
    A = np.abs(S)
    # get intensity in dB
    I = librosa.amplitude_to_db(A, ref=np.max, top_db=70)

    # get frequencies array
    freqs = np.arange(0, 1 + frame_size / 2) * sr / frame_size

    return (I, freqs)

def plot_spectrum(I, sr, frame, d_step, xlim=None, ylim=None, figsize=(10, 5)):
    
    frame_step = frame / d_step # step in seconds
    hop_size = int(frame_step * sr) # hop size in samples

    plt.figure(figsize=figsize)
    librosa.display.specshow(I,
                             y_axis="linear",
                             x_axis="time",
                             sr=sr,
                             hop_length=hop_size,
                             cmap="gray_r")
    plt.colorbar(format="%+2.f")
    
    if xlim is not None:
        plt.xlim(xlim)
    
    if ylim is not None:
        plt.ylim(ylim)
    
    return plt.show()

def vowel_duration(I,
                   freqs,
                   frame,
                   low_crop = 0,
                   high_crop = 5000,
                   intensity_threshold = -20,
                   low_freq = 200,
                   high_freq = 1000, 
                   gap = 3,
                   min_duration = 0.02,
                   save=True,
                   output_folder=None,
                   suffix=None):
    
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
        try:
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
        except IndexError:
            break
    
    duration_time = np.array(duration_frames) * frame
    duration_time_ = duration_time[duration_time > min_duration]

    if save:
        if suffix is None:
            print("Please specify suffix")
            return None
        if output_folder is None:
            print("Please specify output folder")
            return None
        np.savetxt(output_folder+"I"+suffix+".csv", I_, delimiter=",")
        # np.savetxt(output_folder+"freqs"+suffix+".csv", freqs, delimiter=",")
        np.savetxt(output_folder+"bounded-frames"+suffix+".csv", bounded_frames, delimiter=",")
        np.savetxt(output_folder+"duration-time"+suffix+".csv", duration_time_, delimiter=",")
    
    return duration_time_

def stressed_vowel(duration):
    if duration.size > 0:
        return np.argmax(duration) + 1
    return None

def load_audio(file, base_folder, sr=None, mono=None):
    path = os.path.join(base_folder, file)
    return librosa.load(path, sr=sr, mono=mono)

def core_stressed_vowel(file,
                        base_folder,
                        frame,
                        d_step,
                        low_crop,
                        high_crop,
                        intensity_threshold,
                        low_freq,
                        high_freq,
                        gap,
                        min_duration,
                        suffix,
                        sr=None,
                        mono=None,
                        save=True,
                        output_folder = None):

    signal, sr = load_audio(file = file,
                            base_folder=base_folder,
                            sr=sr,
                            mono=mono)

    I, freqs = stft(signal, sr, frame=frame, d_step=d_step)

    # plot_spectrum(I, sr, frame=.005, ylim=[0, 5000])

    duration = vowel_duration(I,
                            freqs,
                            frame=frame,
                            low_crop=low_crop,
                            high_crop=high_crop,
                            intensity_threshold=intensity_threshold,
                            low_freq=low_freq,
                            high_freq=high_freq,
                            gap=gap,
                            min_duration=min_duration,
                            save=save,
                            output_folder=output_folder,
                            suffix=suffix)

    return stressed_vowel(duration)





### TEST FOR PARAMS ###

# set arrays of test values
## frames in secons
frames = [0.015, 0.025, 0.035, 0.045, 0.055]
## parameter of hop size, integer, frame step is calculated as frame / d_step
d_steps = [8, 16, 32]
# lower bound to crop spectral matrix, Hz
low_crops = [0, 50, 100, 150, 200, 250, 300]
# upper bound to crop spectral matrix, Hz
high_crops = [4000, 4200, 4400, 4600, 4800, 5000] # Hz
# threshold of relative intensity, negative integer
intensity_thresholds = [-10, -15, -20, -25, -30, -35, -40, -45, -50]
# lower bound to search intensity maxima, Hz
low_freqs = [300, 350, 400, 450, 500, 250, 200, 150, 100, 450, 400, 350, 300, 250, 200, 150, 100, 500, 450, 400, 350, 300, 550, 600, 650, 700, 700, 650, 600, 550, 500, 450, 400, 350, 300, 500, 450, 400, 350, 300, 250, 200, 150, 100]
# upper bound to search intensity maxima, Hz
high_freqs = [700, 750, 800, 850, 900, 650, 600, 550, 500, 550, 600, 650, 700, 750, 800, 850, 900, 2250, 2200, 2150, 2100, 2050, 2300, 2350, 2400, 2450, 2050, 2100, 2150, 2200, 2250, 2300, 2350, 2400, 2450, 2050, 2100, 2150, 2200, 2250, 2300, 2350, 2400, 2450]
# number of frames to ignore in calculating vowel durations, integer
gaps = [2, 3, 4, 5, 6, 7, 8, 9]
# minimal vowel duration, seconds
min_durations = [0.005, 0.01, 0.03, 0.05, 0.07, 0.09]

len(frames) * len(d_steps) * len(intensity_thresholds) * len(gaps) * len(min_durations) * len(low_crops) * len(high_crops) * len(low_freqs)

# set subjs
subjs = ["subj1", "subj2", "subj3", "subj4", "subj5"]
# set test counter
n = 0

# output folder
# output_folder = "/home/angelgardt/accent-reduction-app/core/test/results/"
output_folder = "/Users/antonangelgardt/accent-reduction-app/core/test/results/"
# input_folder = "/home/angelgardt/accent-reduction-app/data/recs/"
input_folder = "/Users/antonangelgardt/accent-reduction-app/data/recs/"

for high_crop in high_crops:
    for low_crop in low_crops:
        for i in range(len(low_freqs)):
            low_freq = low_freqs[i]
            high_freq = high_freqs[i]
            for frame in frames:
                for d_step in d_steps:
                    for intensity_threshold in intensity_thresholds:
                        for gap in gaps:
                            for min_duration in min_durations:
                                n += 1
                                os.mkdir(output_folder+"test"+str(n))
                                test_output_folder = output_folder+"test"+str(n)+"/"
                                params = np.array([[n, low_crop, high_crop, low_freq, high_freq, frame, d_step, intensity_threshold, gap, min_duration]])
                                
                                np.savetxt(test_output_folder+"params.csv", 
                                            params, 
                                            delimiter=",", 
                                            header="n,low_crop,high_crop,low_freq,high_freq,frame,d_step,intensity_threshold,gap,min_duration")
                                for subj in subjs:
                                    subj_audio_folder = input_folder + subj + "/audio/"
                                    audio_files = os.listdir(subj_audio_folder)
                                    results = []
                                    for file in audio_files:
                                        suffix = subj + "_" + file.split(".")[0]
                                        r = core_stressed_vowel(file,
                                                                subj_audio_folder,
                                                                frame,
                                                                d_step,
                                                                low_crop,
                                                                high_crop,
                                                                intensity_threshold,
                                                                low_freq,
                                                                high_freq,
                                                                gap,
                                                                min_duration,
                                                                suffix="_" + suffix,
                                                                sr=None,
                                                                mono=None,
                                                                save=False,
                                                                output_folder=test_output_folder)
                                        results.append([suffix, r])
                                    
                                    with open(test_output_folder+subj+"_results.csv", "w", newline="") as f:
                                        writer = csv.writer(f)
                                        writer.writerows(results)
