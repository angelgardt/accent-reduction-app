import librosa
import numpy as np
import matplotlib.pyplot as plt


def compute_stft(x, Fs, N, H, L, pad_mode='constant', center=True):
    X = librosa.stft(x, n_fft=L, hop_length=H, win_length=N, 
                     window='hann', pad_mode=pad_mode, center=center)
    Y = np.log(1 + 100 * np.abs(X) ** 2)
    F_coef = librosa.fft_frequencies(sr=Fs, n_fft=L)
    T_coef = librosa.frames_to_time(np.arange(X.shape[1]), sr=Fs, hop_length=H) 
    return Y, F_coef, T_coef

def plot_compute_spectrogram(x, Fs, N, H, L, color='gray_r'):
    Y, F_coef, T_coef = compute_stft(x, Fs, N, H, L)
    plt.imshow(Y, cmap=color, aspect='auto', origin='lower')
    plt.xlabel('Time (frames)')
    plt.ylabel('Frequency (bins)')
    plt.title('L=%d' % L)
    plt.colorbar()
    
N = FRAME_SIZE
H = HOP_SIZE
color = 'gray_r' 
plt.figure(figsize=(10, 4))

L = N
plt.subplot(1,3,1)
plot_compute_spectrogram(signal, sr, N, H, L)

L = 2 * N
plt.subplot(1,3,2)
plot_compute_spectrogram(signal, sr, N, H, L)

L = 4 * N
plt.subplot(1,3,3)
plot_compute_spectrogram(signal, sr, N, H, L)

plt.tight_layout()
plt.show()



def plot_compute_spectrogram_physical(x, Fs, N, H, L, ylim, color='gray_r'):
    Y, F_coef, T_coef = compute_stft(x, Fs, N, H, L)
    extent=[T_coef[0], T_coef[-1], F_coef[0], F_coef[-1]]
    plt.imshow(Y, cmap=color, aspect='auto', origin='lower', extent=extent)
    plt.xlabel('Time (seconds)')
    plt.ylabel('Frequency (Hz)')
    plt.title('L=%d' % L)
    plt.ylim(ylim)
    plt.colorbar()


#xlim_sec = [2, 3]
ylim_hz = [0, 5000]

plt.figure(figsize=(10, 4))

L = N
plt.subplot(1,3,1)
plot_compute_spectrogram_physical(signal, sr, N, H, L, ylim=ylim_hz)

L = 2 * N
plt.subplot(1,3,2)
plot_compute_spectrogram_physical(signal, sr, N, H, L, ylim=ylim_hz)

L = 4 * N
plt.subplot(1,3,3)
plot_compute_spectrogram_physical(signal, sr, N, H, L, ylim=ylim_hz)

plt.tight_layout()
plt.show()
