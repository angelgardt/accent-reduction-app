
I_ = I[:27, :]
max_intensity_bins = np.argmax(I_, axis=0)
# max_intensity

max_intensity_freqs = np.array([freqs[i] for i in max_intensity_bins])

(max_intensity_freqs > 200) & (max_intensity_freqs < 1000)


freqs