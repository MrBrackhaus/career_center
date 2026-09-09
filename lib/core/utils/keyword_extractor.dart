class KeywordExtractor {
  // A simple list of German stop words
  static const _stopWords = {
    'der',
    'die',
    'das',
    'und',
    'in',
    'im',
    'zu',
    'für',
    'mit',
    'als',
    'von',
    'auf',
    'ist',
    'sind',
    'ein',
    'eine',
    'einer',
    'einen',
    'einem',
    'des',
    'dem',
    'den',
    'bei',
    'an',
    'sich',
    'auch',
    'dass',
    'wie',
    'wir',
    'oder',
    'nach',
    'werden',
    'wird',
    'aus',
    'kann',
    'nicht',
    'über',
    'es',
    'um',
    'sie',
    'uns',
    'unsere',
    'unser',
    'haben',
    'ihre',
    'ihr',
    'sowie',
    'durch',
    'zur',
    'zum',
    'diese',
    'dieser',
    'dieses',
    'diesen',
    'diesem',
  };

  /// Extracts the most important keywords from a job description using a simplified TF logic.
  /// Removes stop words and returns the top N keywords.
  static List<String> extractKeywords(String text, {int topN = 10}) {
    final words = _tokenize(text);
    final frequencies = <String, int>{};

    for (final word in words) {
      if (!_stopWords.contains(word) && word.length > 2) {
        frequencies[word] = (frequencies[word] ?? 0) + 1;
      }
    }

    // Sort by frequency descending
    final sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return the top N keywords
    return sortedEntries.take(topN).map((e) => e.key).toList();
  }

  /// Checks which of the [requiredKeywords] are present in the [text].
  static Set<String> findMatchingKeywords(
    String text,
    List<String> requiredKeywords,
  ) {
    final words = _tokenize(text);
    final found = <String>{};

    for (final keyword in requiredKeywords) {
      if (words.contains(keyword)) {
        found.add(keyword);
      }
    }

    return found;
  }

  /// Tokenizes text into lowercase words, stripping punctuation.
  static List<String> _tokenize(String text) {
    final cleanText = text.toLowerCase().replaceAll(
      RegExp(r'[^\w\säöüß]'),
      ' ',
    );
    return cleanText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }
}
