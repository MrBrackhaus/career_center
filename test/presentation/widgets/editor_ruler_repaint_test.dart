import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/presentation/screens/editor/editor_ruler.dart';

void main() {
  test('RulerPainter zeichnet neu, wenn sich der Seitenrand ändert', () {
    final a = RulerPainter(isHorizontal: true, offset: 94);
    expect(a.shouldRepaint(RulerPainter(isHorizontal: true, offset: 94)), isFalse);
    expect(a.shouldRepaint(RulerPainter(isHorizontal: true, offset: 120)), isTrue);
  });
}
