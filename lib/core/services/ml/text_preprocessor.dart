/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
class TextPreprocessor {
  static final Set<String> _stopWords = Set.of([
    'der',
    'die',
    'das',
    'ein',
    'eine',
    'und',
    'oder',
    'aber',
    'in',
    'im',
    'an',
    'am',
    'auf',
    'aus',
    'bei',
    'mit',
    'nach',
    'seit',
    'von',
    'vor',
    'zu',
    'zum',
    'zur',
    'den',
    'dem',
    'des',
    'er',
    'sie',
    'es',
    'wir',
    'ihr',
    'ist',
    'sind',
    'war',
    'hat',
    'haben',
    'wird',
    'werden',
    'kann',
    'können',
    'ich',
    'mich',
    'mir',
    'uns',
    'für',
    'über',
    'unter',
    'nicht',
    'auch',
    'noch',
    'nur',
    'sehr',
    'so',
    'wie',
    'als',
    'wenn',
    'dass',
    'da',
    'hier',
    'dort',
    'schon',
    'doch',
    'ja',
    'nein',
    'bitte',
    'vielen',
    'dank',
    'gerne',
    'freundlich',
    'freundlichen',
    'grüße',
    'grüßen',
    'etc',
    // English stop words (common in IT jobs)
    'the', 'and', 'to', 'of', 'a', 'for', 'is', 'on', 'that', 'by', 'this', 'with', 
    'you', 'it', 'not', 'be', 'are', 'from', 'at', 'as', 'your', 'all', 'have', 'new', 
    'more', 'an', 'was', 'we', 'will', 'can', 'us', 'about', 'if', 'my', 'has', 'but', 
    'our', 'one', 'other', 'do', 'no', 'they', 'he', 'up', 'may', 'what', 'which', 
    'their', 'out', 'use', 'any', 'there', 'see', 'only', 'so', 'his', 'when', 'who', 
    'also', 'now', 'get', 'am', 'been', 'would', 'how', 'were', 'me', 'some', 'these', 
    'its', 'like', 'than', 'just', 'over', 'two', 're', 'used', 'make', 'them', 'should', 
    'her', 'such', 'please', 'after', 'then', 'where', 'each', 'she', 'very', 'many', 
    'does', 'under'
  ]);

  /// Tokenizes and preprocesses German text for classification.
  static List<String> tokenize(String text) {
    if (text.isEmpty) return [];

    // 1. Lowercase
    String lower = text.toLowerCase();

    // Normalize umlauts for consistent matching (optional alternative form)
    lower = normalizeUmlauts(lower);

    // 2. Remove punctuation (keep hyphens in compound words)
    lower = lower.replaceAll(RegExp(r'[^a-z0-9äöüß-]'), ' ');

    // 3. Split into words
    List<String> rawTokens = lower.split(RegExp(r'\s+'));

    // 4. Remove German stop words
    List<String> tokens = [];
    for (String token in rawTokens) {
      // Remove trailing/leading hyphens
      token = token.replaceAll(RegExp(r'^-+|-+$'), '');
      if (token.length > 1 && !_stopWords.contains(token)) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  /// 5. Generate bigrams for key phrases
  static List<String> generateBigrams(List<String> tokens) {
    List<String> bigrams = [];
    for (int i = 0; i < tokens.length - 1; i++) {
      bigrams.add('${tokens[i]}_${tokens[i + 1]}');
    }
    return bigrams;
  }

  /// Normalizes umlauts (ä→ae etc.)
  static String normalizeUmlauts(String text) {
    return text
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
  }
}
