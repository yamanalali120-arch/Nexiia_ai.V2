import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  final AnimationController ctrl;
  final Color pri;
  final Color priLight;

  const AmbientBackground({
    super.key,
    required this.ctrl,
    required this.pri,
    required this.priLight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        painter: _AmbientPainter(t: ctrl.value, pri: pri, priLight: priLight),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final double t;
  final Color pri;
  final Color priLight;

  const _AmbientPainter({
    required this.t,
    required this.pri,
    required this.priLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF070B1A), Color(0xFF0B0E1A), Color(0xFF080C1E)],
          ).createShader(r));

    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center:
                Alignment(-0.5 + t * 0.15, -0.5 + math.sin(t * math.pi) * 0.08),
            radius: 0.9,
            colors: [pri.withOpacity(0.16 + t * 0.07), Colors.transparent],
          ).createShader(r));

    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center:
                Alignment(0.65 + math.cos(t * math.pi) * 0.1, 0.6 + t * 0.06),
            radius: 0.7,
            colors: [priLight.withOpacity(0.12 + t * 0.05), Colors.transparent],
          ).createShader(r));

    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(0.4, -0.1 + math.sin(t * math.pi * 1.3) * 0.12),
            radius: 0.55,
            colors: [pri.withOpacity(0.08 + t * 0.04), Colors.transparent],
          ).createShader(r));

    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(-0.6, 0.75 + math.cos(t * math.pi * 0.8) * 0.06),
            radius: 0.5,
            colors: [priLight.withOpacity(0.06 + t * 0.03), Colors.transparent],
          ).createShader(r));

    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.7, -0.65),
            radius: 0.45,
            colors: [pri.withOpacity(0.05 + t * 0.03), Colors.transparent],
          ).createShader(r));

    final hy = size.height * 0.38 + math.sin(t * math.pi) * 6;
    canvas.drawLine(
      Offset(0, hy),
      Offset(size.width, hy),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            pri.withOpacity(0.28 + t * 0.14),
            pri.withOpacity(0.42 + t * 0.16),
            pri.withOpacity(0.28 + t * 0.14),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(0, hy - 1, size.width, 2))
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, hy - 80, size.width, 160),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            pri.withOpacity(0.05 + t * 0.03),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, hy - 80, size.width, 160)),
    );

    final rng = math.Random(42);
    final pColors = [
      priLight,
      pri,
      priLight.withOpacity(0.8),
      pri.withOpacity(0.7)
    ];
    for (int i = 0; i < 28; i++) {
      final px = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.12 + rng.nextDouble() * 0.4;
      var py = (baseY - t * size.height * speed) % size.height;
      if (py < 0) py += size.height;
      canvas.drawCircle(
        Offset(px, py),
        0.4 + rng.nextDouble() * 1.2,
        Paint()
          ..color = pColors[i % pColors.length]
              .withOpacity(0.04 + rng.nextDouble() * 0.09)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.t != t || old.pri != pri;
}
