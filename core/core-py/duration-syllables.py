import sounddevice as sd
import scipy.signal as sig
import librosa

# функция для разбиения аудиозаписи на фрагменты звука, соответствующие каждому слогу
def split_audio(audio, syllables):
    sample_rate = 44100 # частота дискретизации
    audio_length = len(audio) / sample_rate # длительность аудиозаписи в секундах
    syllable_duration = audio_length / len(syllables) # длительность каждого слога в секундах
    syllable_lengths = [] # список длительностей слогов
    start = 0 # начальная позиция текущего фрагмента звука
    for syllable in syllables:
        # вычисление длительности текущего слога в сэмплах
        syllable_length_samples = int(syllable_duration * sample_rate)
        syllable_lengths.append(syllable_length_samples)
        # выделение фрагмента звука, соответствующего текущему слогу
        audio_slice = audio[start:start+syllable_length_samples]
        start += syllable_length_samples
        # TODO: дополнительная обработка фрагмента звука
    return syllable_lengths 

# загрузка аудиозаписи слова
filename = '/Users/antonangelgardt/accent-reduction-app/data/recs/v1/subj1/homographs/1-1.wav'
audio, sample_rate = librosa.load(filename, sr=None, mono=True)

# разделение слова на слоги
syllables = ["от", "но", "си", "тся"]

# разбиение аудиозаписи на фрагменты звука, соответствующие каждому слогу
syllable_lengths = split_audio(audio, syllables)

# вывод результатов
print("Syllables: ", syllables)
print("Lengths: ", syllable_lengths)
