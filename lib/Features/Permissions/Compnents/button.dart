import 'package:flutter/material.dart';
import '../../../core/constants.dart';
class AppButtonStyles {
  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: kSpecialColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }
}
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = spectialgreen;

    final Path path = Path()
      ..moveTo(0, size.height) 
      ..lineTo(size.width / 2, 0) 
      ..lineTo(size.width, size.height) 
      ..close(); 

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
