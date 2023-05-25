def load_audio(file, base_folder, sr=None, mono=None):
    path = os.path.join(base_folder, file)
    return librosa.load(path, sr=sr, mono=mono)
