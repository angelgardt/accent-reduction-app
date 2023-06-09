import os.path
import librosa
import numpy as np
# import matplotlib.pyplot as plt

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
