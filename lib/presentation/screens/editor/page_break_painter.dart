import 'package:flutter/material.dart';

class PageBreakPainter extends CustomPainter {
  final double pageHeight;

  PageBreakPainter({this.pageHeight = 1123.0});

  @override
  void paint(Canvas canvas, Size size) {
    // We draw the grey background gap every [pageHeight] pixels
    final paint = Paint()
      ..color = const Color(0xFFE2E2E5) // Grey background color matches surfaceContainerHighest usually
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    int numGaps = (size.height / pageHeight).floor();
    for (int i = 1; i <= numGaps; i++) {
      double y = i * pageHeight;
      // Draw a 30px gap to simulate two pages
      canvas.drawRect(Rect.fromLTWH(-10, y - 15, size.width + 20, 30), paint);
      
      // Draw dashed red line in the middle of the gap
      double dashWidth = 5;
      double dashSpace = 5;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), linePaint);
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
