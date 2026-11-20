import 'package:flutter/material.dart';

/// Red book logo with yellow "T" arc, drawn in code (no image asset needed).
/// Replace with Image.asset('assets/logo.png') if you have the real logo.
class TkLogo extends StatelessWidget {
  final double size;
  const TkLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    // yellow page edge
    final page = Paint()..color = const Color(0xFFFFC107);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.06, w * 0.62, h * 0.86),
        Radius.circular(w * 0.06),
      ),
      page,
    );

    // red book cover
    final cover = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE02B27), Color(0xFFA81C1C)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.68, h * 0.82),
        Radius.circular(w * 0.07),
      ),
      cover,
    );

    // yellow "T" (arc + stem)
    final stroke = Paint()
      ..color = const Color(0xFFFFC800)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.085;
    final c = Offset(w * 0.46, h * 0.46);
    final r = w * 0.2;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 3.14159, 3.14159,
        false, stroke);
    canvas.drawLine(c, Offset(c.dx, h * 0.76), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
