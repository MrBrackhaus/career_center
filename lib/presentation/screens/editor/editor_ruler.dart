import 'package:flutter/material.dart';

class EditorRuler extends StatelessWidget {
  final bool isHorizontal;
  final double length;
  final double offset; // to account for margins

  const EditorRuler({
    super.key,
    required this.isHorizontal,
    required this.length,
    this.offset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? length : 24,
      height: isHorizontal ? 24 : length,
      child: CustomPaint(
        painter: RulerPainter(isHorizontal: isHorizontal, offset: offset),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final bool isHorizontal;
  final double offset;

  RulerPainter({required this.isHorizontal, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.0;
      
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // 1 cm is roughly 37.8 pixels at 96 DPI
    const double pixelsPerCm = 37.8;
    
    final length = isHorizontal ? size.width : size.height;
    
    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.grey.shade200);
    
    // Draw lines
    for (double i = 0; i < length; i += pixelsPerCm / 10) {
      // Calculate cm from the offset
      final cmPos = (i - offset) / pixelsPerCm;
      
      final isCm = (cmPos % 1).abs() < 0.05;
      final isHalfCm = (cmPos % 0.5).abs() < 0.05 && !isCm;
      
      double lineLength = 4;
      if (isCm) lineLength = 12;
      else if (isHalfCm) lineLength = 8;
      
      if (isHorizontal) {
        canvas.drawLine(Offset(i, size.height - lineLength), Offset(i, size.height), paint);
        
        if (isCm) {
          final cmValue = cmPos.round();
          textPainter.text = TextSpan(text: cmValue.toString(), style: const TextStyle(fontSize: 8, color: Colors.black54));
          textPainter.layout();
          textPainter.paint(canvas, Offset(i + 2, 2));
        }
      } else {
        canvas.drawLine(Offset(size.width - lineLength, i), Offset(size.width, i), paint);
        
        if (isCm) {
          final cmValue = cmPos.round();
          textPainter.text = TextSpan(text: cmValue.toString(), style: const TextStyle(fontSize: 8, color: Colors.black54));
          textPainter.layout();
          textPainter.paint(canvas, Offset(2, i + 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
