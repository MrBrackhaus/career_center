import 'dart:collection';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class SpellChecker {
  static HashSet<String> _dictionary = HashSet<String>();
  static Map<int, List<String>> _dictByLength = {};
  static bool _isLoaded = false;
  static String _currentLanguage = 'de';
  static final HashSet<String> _userDictionary = HashSet<String>();

  /// Available languages with display names
  static const Map<String, String> availableLanguages = {
    'de': 'Deutsch',
    'en': 'English',
    'fr': 'Fran\u00e7ais',
    'es': 'Espa\u00f1ol',
    'it': 'Italiano',
    'pt': 'Portugu\u00eas',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'tr': 'T\u00fcrk\u00e7e',
    'ro': 'Rom\u00e2n\u0103',
    'hr': 'Hrvatski',
    'sr': 'Srpski',
    'ru': '\u0420\u0443\u0441\u0441\u043a\u0438\u0439',
    'ar': '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
  };

  /// Common German suffixes for stripping (longest first)
  static const List<String> _germanSuffixes = [
    'ischen',
    'ischen',
    'ungen',
    'heit',
    'keit',
    'lich',
    'isch',
    'igen',
    'iges',
    'igem',
    'iger',
    'enen',
    'enem',
    'ener',
    'enes',
    'ige',
    'ten',
    'tes',
    'tem',
    'ter',
    'ene',
    'en',
    'er',
    'es',
    'em',
    'te',
    'ig',
    'e',
    's',
    'n',
  ];

  static String get currentLanguage => _currentLanguage;

  static Future<void> loadDictionary({String language = 'de'}) async {
    if (_isLoaded && _currentLanguage == language) return;

    _currentLanguage = language;
    _isLoaded = false;

    try {
      final primaryDict = await rootBundle.loadString(
        'assets/dictionaries/$language.txt',
      );

      // Parse in isolate to avoid UI jank
      final result = await compute(_parseDictionary, primaryDict);
      _dictionary = result['dict'];
      _dictByLength = result['byLength'];

      _isLoaded = true;
      debugPrint('Dictionary loaded ($language): ${_dictionary.length} words');
    } catch (e) {
      debugPrint('Error loading dictionary ($language): $e');
      _isLoaded = true; // Mark as loaded to prevent infinite retry
    }
  }

  static Map<String, dynamic> _parseDictionary(String data) {
    final dict = HashSet<String>();
    final byLength = <int, List<String>>{};
    final lines = data.split('\n');
    for (var line in lines) {
      final parts = line.trim().split(' ');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        final w = parts[0].toLowerCase();
        dict.add(w);
        byLength.putIfAbsent(w.length, () => []).add(w);
      }
    }
    return {'dict': dict, 'byLength': byLength};
  }

  static void ignoreWord(String word) {
    _userDictionary.add(word.toLowerCase());
  }

  /// Check if a word is valid, including suffix stripping and compound splitting for German
  static bool _isWordValid(String word) {
    final lower = word.toLowerCase();

    // Direct lookup
    if (_dictionary.contains(lower)) return true;
    if (_userDictionary.contains(lower)) return true;

    // Only do advanced checks for German
    if (_currentLanguage == 'de') {
      // Suffix stripping
      if (_checkWithSuffixStripping(lower)) return true;

      // Compound word splitting (only for longer words)
      if (lower.length >= 8 && _checkCompoundWord(lower)) return true;
    }

    return false;
  }

  /// Try removing common German suffixes and check if the stem exists
  static bool _checkWithSuffixStripping(String word) {
    for (final suffix in _germanSuffixes) {
      if (word.length > suffix.length + 2 && word.endsWith(suffix)) {
        final stem = word.substring(0, word.length - suffix.length);
        if (_dictionary.contains(stem)) return true;
        // Also try with common connecting letters
        if (_dictionary.contains('${stem}e')) return true;
        if (_dictionary.contains('${stem}en')) return true;
      }
    }
    return false;
  }

  /// Try splitting a compound word and check if both parts exist
  static bool _checkCompoundWord(String word) {
    // Try splitting at each position
    for (int i = 3; i < word.length - 3; i++) {
      final left = word.substring(0, i);
      final right = word.substring(i);

      // Check if left part is valid
      final leftValid =
          _dictionary.contains(left) || _checkWithSuffixStripping(left);
      if (!leftValid) continue;

      // Check if right part is valid (directly or with suffix stripping)
      if (_dictionary.contains(right) || _checkWithSuffixStripping(right)) {
        return true;
      }

      // Try with Fugen-s (e.g., Arbeit-s-platz)
      if (right.startsWith('s') && right.length > 4) {
        final rightWithoutS = right.substring(1);
        if (_dictionary.contains(rightWithoutS) ||
            _checkWithSuffixStripping(rightWithoutS)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns a list of suggested corrections using a fast Levenshtein distance subset search.
  static Future<List<String>> getSuggestions(String originalWord) async {
    if (!_isLoaded || _dictionary.isEmpty) return [];
    final lower = originalWord.toLowerCase();
    final targetLens = [lower.length - 2, lower.length - 1, lower.length, lower.length + 1, lower.length + 2];
    final filteredDict = <String>[];
    for (var len in targetLens) {
      if (_dictByLength.containsKey(len)) {
        filteredDict.addAll(_dictByLength[len]!);
      }
    }

    return await compute(_calculateSuggestions, {
      'word': lower,
      'originalWord': originalWord,
      'dict': filteredDict,
    });
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i <= t.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        int min = v1[j] + 1;
        int b = v0[j + 1] + 1;
        int c = v0[j] + cost;
        if (b < min) min = b;
        if (c < min) min = c;
        v1[j + 1] = min;
      }

      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  static Future<List<Map<String, dynamic>>> checkText(String text) async {
    if (!_isLoaded) await loadDictionary(language: _currentLanguage);
    if (text.trim().isEmpty) return [];

    final List<Map<String, dynamic>> warnings = [];

    // Unicode-aware regex for word matching
    final RegExp wordRegex = RegExp(r'[\p{L}]+', unicode: true);
    final matches = wordRegex.allMatches(text);

    for (var match in matches) {
      final word = match.group(0)!;
      if (word.length <= 1) continue;

      if (!_isWordValid(word)) {
        warnings.add({
          'title': word,
          'subtitle': 'M\u00f6glicher Rechtschreibfehler',
          'offset': match.start,
          'length': word.length,
          'replacements': <String>[],
        });
      }
    }

    return warnings;
  }
}

List<String> _calculateSuggestions(Map<String, dynamic> args) {
  final String word = args['word'];
  final String originalWord = args['originalWord'];
  final List<String> dict = args['dict'];
  
  final List<MapEntry<String, int>> matchEntries = [];
  final startChar = word.isEmpty ? '' : word[0];

  int index = 0;
  for (final dictWord in dict) {
    index++;
    if (dictWord.isEmpty) continue;

    final lenDiff = (dictWord.length - word.length).abs();
    if (lenDiff > 2) continue;

    if (dictWord[0] != startChar && lenDiff != 0) continue;

    final dist = SpellChecker._levenshtein(dictWord, word);
    if (dist <= 2) {
      // Frequency proxy: shorter words are not always better. 
      // We prioritize exact length match, then frequency (if we had it).
      // Let's use Levenshtein distance as primary, and length difference as secondary.
      int lengthDiffScore = (dictWord.length - word.length).abs();
      matchEntries.add(
        MapEntry(dictWord, (dist * 1000000) + (lengthDiffScore * 1000) + index),
      );
    }
  }

  matchEntries.sort((a, b) => a.value.compareTo(b.value));

  return matchEntries.take(5).map((entry) {
    final w = entry.key;
    if (originalWord.isNotEmpty &&
        originalWord[0] == originalWord[0].toUpperCase()) {
      return w[0].toUpperCase() + w.substring(1);
    }
    return w;
  }).toList();
}
