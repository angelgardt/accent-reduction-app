import librosa
import numpy as np
import matplotlib.pyplot as plt

def stft(signal, sr, frame):
    
    """
    This function takes three arguments:
    signal is an array containing sequence of samples of a signal
    sr is the smaple rate
    frame is the frame size in seconds
    """

    frame_size = int(round(frame * sr)) # frame size in samples
    frame_step = frame / 4 # step in seconds
    hop_size = int(frame_step * sr) # hop size in samples

    # get spectral matrix
    S = librosa.stft(signal, n_fft=frame_size, hop_length=hop_size)
    # get amplitudes from spectral matrix
    A = np.abs(S)
    # get intensity in dB
    I = librosa.amplitude_to_db(A, ref=np.max, top_db=70)

    return I

def plot_spectrum(I, sr, frame, xlim=None, ylim=None, figsize=(10, 5)):
    
    frame_step = frame / 4 # step in seconds
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
