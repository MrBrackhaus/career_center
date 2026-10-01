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
      if (!_stopWords.contains(word) && _isRelevant(word)) {
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

    final wordSet = words.toSet();
    for (final keyword in requiredKeywords) {
      if (wordSet.contains(keyword.toLowerCase())) {
        found.add(keyword);
      }
    }

    return found;
  }

  /// Kurze Tokens sind nur relevant, wenn sie Technologie-Zeichen enthalten
  /// (z.B. "c#", "c++", ".net").
  static bool _isRelevant(String word) =>
      word.length > 2 || (word.length == 2 && RegExp(r'[#+]').hasMatch(word));

  /// Tokenizes text into lowercase words, stripping punctuation.
  ///
  /// `#` und `+` sowie Punkte innerhalb eines Wortes bleiben erhalten, damit
  /// Technologien wie "C#", "C++", ".NET" oder "Node.js" ganze Tokens bleiben.
  static List<String> _tokenize(String text) {
    final cleanText = text.toLowerCase().replaceAll(
      RegExp(r'[^\w\säöüß#+.]'),
      ' ',
    );
    final tokens = <String>[];
    for (var token in cleanText.split(RegExp(r'\s+'))) {
      // Satzzeichen-Punkte am Ende entfernen ("Node.js." → "node.js")
      token = token.replaceAll(RegExp(r'\.+$'), '');
      // Führende Punkte nur behalten, wenn es ein einzelner vor einem
      // Buchstaben ist (".net"), sonst entfernen ("...weiter" → "weiter")
      if (!RegExp(r'^\.[a-zäöüß]').hasMatch(token)) {
        token = token.replaceAll(RegExp(r'^\.+'), '');
      }
      // Reine Symbol-Tokens ("+", "#") verwerfen
      if (token.isEmpty || !RegExp(r'[\wäöüß]').hasMatch(token)) continue;
      // Abkürzungen ("z.b", "d.h") und Zahlen mit Punkt ("60.000") verwerfen
      if (RegExp(r'^(?:[a-zäöü]\.)+[a-zäöü]$').hasMatch(token) ||
          RegExp(r'^[\d.]*\.[\d.]*$').hasMatch(token)) {
        continue;
      }
      tokens.add(token);
    }
    return tokens;
  }
}
