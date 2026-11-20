import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

/// Welcome screen showing TallyKhata Gold trial activation with animated confetti.
/// and animated colorful confetti paper pieces & ribbon celebration.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.tallypayIntro);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Main centered content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _GoldCrown(size: 76),
                const SizedBox(height: 18),
                const Text(
                  'টালিখাতায় অভিনন্দন!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    children: [
                      TextSpan(text: 'আপনি টালিখাতা '),
                      TextSpan(
                        text: 'গোল্ড',
                        style: TextStyle(
                          color: Color(0xFFD99B16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' (৩০ দিন ট্রায়াল) পেয়েছেন।'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Animated colorful confetti burst on top
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, _) => CustomPaint(
                  size: const Size(260, 220),
                  painter: _ConfettiPainter(_confettiCtrl.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldCrown extends StatelessWidget {
  final double size;
  const _GoldCrown({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.72),
      painter: _CrownPainter(),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.10, h * 0.92)
      ..lineTo(0, h * 0.25)
      ..lineTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.50, h * 0.04)
      ..lineTo(w * 0.72, h * 0.52)
      ..lineTo(w, h * 0.25)
      ..lineTo(w * 0.90, h * 0.92)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFB38728),
          Color(0xFFE5C158),
          Color(0xFFC59B38),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiPiece {
  final double angle;
  final double dist;
  final double size;
  final Color color;
  final bool isCircle;
  final double spin;
  const _ConfettiPiece(
      this.angle, this.dist, this.size, this.color, this.isCircle, this.spin);
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  static const _pieces = [
    _ConfettiPiece(-2.5, 78, 5, Color(0xFF2196F3), true, 1.2),
    _ConfettiPiece(-1.9, 92, 6, Color(0xFFFF9800), true, -1.5),
    _ConfettiPiece(-0.8, 86, 8, Color(0xFFC62828), true, 1.0),
    _ConfettiPiece(-0.2, 102, 7, Color(0xFF4CAF50), true, -1.8),
    _ConfettiPiece(0.4, 88, 6, Color(0xFF2196F3), false, 2.2),
    _ConfettiPiece(0.9, 95, 8, Color(0xFFE53935), false, -2.0),
    _ConfettiPiece(1.5, 72, 7, Color(0xFF4CAF50), false, 1.6),
    _ConfettiPiece(2.1, 82, 6, Color(0xFFFFC107), true, -1.4),
    _ConfettiPiece(2.7, 90, 7, Color(0xFF66BB6A), false, 1.9),
    _ConfettiPiece(3.0, 68, 8, Color(0xFFFFCA28), true, 1.1),
    _ConfettiPiece(-1.2, 60, 6, Color(0xFFE91E63), false, -2.3),
    _ConfettiPiece(0.1, 56, 7, Color(0xFF43A047), true, 1.5),
    _ConfettiPiece(1.2, 108, 6, Color(0xFFFF5722), false, -1.7),
    _ConfettiPiece(2.4, 104, 5, Color(0xFF29B6F6), true, 2.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final ease = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    final gravity = t * t * 38;
    final opacity = t > 0.8 ? (1.0 - (t - 0.8) / 0.2).clamp(0.0, 1.0) : 1.0;

    // Curved blue ribbon arc
    final ribbonPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final arcRect = Rect.fromCenter(
      center: Offset(cx + 8 * ease, cy - 6 + gravity * 0.35),
      width: 96 * ease + 20,
      height: 82 * ease + 16,
    );
    canvas.drawArc(arcRect, 0.1, 1.45 * ease, false, ribbonPaint);

    // Colorful paper confetti pieces
    for (final p in _pieces) {
      final dx = cx + math.cos(p.angle) * p.dist * ease;
      final dy = cy + math.sin(p.angle) * p.dist * ease + gravity;
      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * t * math.pi);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.55, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size * 1.3, height: p.size * 0.7),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
