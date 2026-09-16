import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/presentation/screens/editor/editor_ruler.dart';

void main() {
  group('EditorRuler - Widget Test', () {
    testWidgets('Rendert horizontales Lineal mit korrekter Breite', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorRuler(
              isHorizontal: true,
              length: 500,
              offset: 0,
            ),
          ),
        ),
      );

      // Widget sollte existieren
      expect(find.byType(EditorRuler), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Rendert vertikales Lineal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorRuler(
              isHorizontal: false,
              length: 800,
              offset: 50,
            ),
          ),
        ),
      );

      expect(find.byType(EditorRuler), findsOneWidget);
    });

    testWidgets('Horizontales Lineal hat Höhe 24px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorRuler(
              isHorizontal: true,
              length: 400,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 24);
      expect(sizedBox.width, 400);
    });

    testWidgets('Vertikales Lineal hat Breite 24px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorRuler(
              isHorizontal: false,
              length: 600,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 24);
      expect(sizedBox.height, 600);
    });
  });
}
