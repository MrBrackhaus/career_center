import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/domain/models/extraction_result.dart';

/// Ein reines Widget das ein FieldResult mit Konfidenz-Farbe anzeigt.
/// Wir testen hier, ob die Konfidenz-Logik korrekt in Farben gemappt wird.
class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final String label;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    required this.label,
  });

  Color get color {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String get confidenceText => '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label ($confidenceText)'),
      backgroundColor: color.withValues(alpha: 0.2),
      avatar: Icon(
        confidence >= 0.8
            ? Icons.check_circle
            : confidence >= 0.5
                ? Icons.warning
                : Icons.error,
        color: color,
        size: 18,
      ),
    );
  }
}

void main() {
  group('ConfidenceBadge - Widget Test', () {
    testWidgets('Zeigt grünes Badge bei hoher Konfidenz (>= 80%)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: 0.95, label: 'Firma'),
          ),
        ),
      );

      expect(find.text('Firma (95%)'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Zeigt oranges Badge bei mittlerer Konfidenz (50-79%)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: 0.6, label: 'Position'),
          ),
        ),
      );

      expect(find.text('Position (60%)'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('Zeigt rotes Badge bei niedriger Konfidenz (< 50%)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: 0.2, label: 'Adresse'),
          ),
        ),
      );

      expect(find.text('Adresse (20%)'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('Zeigt 0% und 100% korrekt an', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ConfidenceBadge(confidence: 0.0, label: 'Leer'),
                ConfidenceBadge(confidence: 1.0, label: 'Perfekt'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Leer (0%)'), findsOneWidget);
      expect(find.text('Perfekt (100%)'), findsOneWidget);
    });
  });

  group('ExtractedFields - Confidence Mapping', () {
    test('Alle Konfidenz-Grenzen werden korrekt gemappt', () {
      // 0.0 - 0.49 = Rot
      expect(const ConfidenceBadge(confidence: 0.0, label: 't').color, Colors.red);
      expect(const ConfidenceBadge(confidence: 0.49, label: 't').color, Colors.red);
      // 0.5 - 0.79 = Orange
      expect(const ConfidenceBadge(confidence: 0.5, label: 't').color, Colors.orange);
      expect(const ConfidenceBadge(confidence: 0.79, label: 't').color, Colors.orange);
      // 0.8 - 1.0 = Grün
      expect(const ConfidenceBadge(confidence: 0.8, label: 't').color, Colors.green);
      expect(const ConfidenceBadge(confidence: 1.0, label: 't').color, Colors.green);
    });
  });
}
