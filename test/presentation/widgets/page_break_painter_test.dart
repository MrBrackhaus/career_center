import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/presentation/screens/editor/page_break_painter.dart';

void main() {
  group('PageBreakPainter - Widget Test', () {
    testWidgets('Rendert ohne Absturz mit Standard-Seitenhöhe', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 800,
              child: CustomPaint(
                painter: PageBreakPainter(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Rendert mit benutzerdefinierter Seitenhöhe', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 2500,
              child: CustomPaint(
                painter: PageBreakPainter(pageHeight: 1000),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('shouldRepaint gibt immer true zurück', () {
      final painter = PageBreakPainter();
      expect(painter.shouldRepaint(PageBreakPainter()), isTrue);
    });

    test('Default pageHeight ist 1123 (A4 in Pixel)', () {
      final painter = PageBreakPainter();
      expect(painter.pageHeight, 1123.0);
    });
  });
}
