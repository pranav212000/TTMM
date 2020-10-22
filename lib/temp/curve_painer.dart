import 'package:flutter/material.dart';
import 'package:ttmm/shared/hex_color.dart';

class CurvePainter extends CustomPainter {
  final Path path;

  CurvePainter({this.path});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Color.fromRGBO(243, 28, 41, 1), HexColor('#C471ED')],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width, size.height),
        radius: 1900,
      ));

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [Color.fromRGBO(243, 28, 41, 0.77), Color.fromRGBO(196,113,237, 0.7)],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.75, 0),
        radius: 700,
      ));
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();
    var path2 = Path();

    path.moveTo(0, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.35, size.height * 0.95, size.width, size.height * 0.95);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    path2.moveTo(0, size.height * 0.65);
    path2.quadraticBezierTo(
        size.width * 0.15, size.height * 0.95, size.width * 0.6, size.height);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
