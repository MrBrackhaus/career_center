/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
class TextPreprocessor {
  static const Set<String> _stopWords = {
    'der', 'die', 'das', 'ein', 'eine', 'und', 'oder', 'aber', 'in', 'im', 'an', 'am', 'auf', 'aus', 'bei', 'mit', 'nach', 'seit', 'von', 'vor', 'zu', 'zum', 'zur', 'den', 'dem', 'des', 'er', 'sie', 'es', 'wir', 'ihr', 'ist', 'sind', 'war', 'hat', 'haben', 'wird', 'werden', 'kann', 'können', 'ich', 'mich', 'mir', 'uns', 'für', 'über', 'unter', 'nicht', 'auch', 'noch', 'nur', 'sehr', 'so', 'wie', 'als', 'wenn', 'dass', 'da', 'hier', 'dort', 'schon', 'doch', 'ja', 'nein', 'bitte', 'vielen', 'dank', 'gerne', 'freundlich', 'freundlichen', 'grüße', 'grüßen', 'etc',
  };

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
      bigrams.add('${tokens[i]}_${tokens[i+1]}');
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

