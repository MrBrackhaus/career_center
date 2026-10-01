import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/utils/keyword_extractor.dart';

void main() {
  group('KeywordExtractor - Technologie-Namen', () {
    test('C#, C++, .NET und Node.js bleiben ganze Tokens', () {
      const text =
          'Erfahrung mit C# und .NET, C++ sowie Node.js. Node.js und C# sind ein Plus. C++ ist gut.';
      final keywords = KeywordExtractor.extractKeywords(text, topN: 20);
      expect(keywords, containsAll(['c#', 'c++', '.net', 'node.js']));
      expect(keywords, isNot(contains('node')));
      expect(keywords, isNot(contains('net')));
    });

    test('findMatchingKeywords erkennt C# und Node.js am Satzende', () {
      final found = KeywordExtractor.findMatchingKeywords(
        'Wir nutzen C#. Außerdem Node.js.',
        ['c#', 'node.js', 'java'],
      );
      expect(found, {'c#', 'node.js'});
    });
  });
}
