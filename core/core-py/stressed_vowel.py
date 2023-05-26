def stressed_vowel(duration):
    if duration.size > 0:
        return np.argmax(duration) + 1
    return None
