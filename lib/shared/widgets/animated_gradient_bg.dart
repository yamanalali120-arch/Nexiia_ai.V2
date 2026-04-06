import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? orbColor;

  const AnimatedGradientBg({
    super.key,
    required this.child,
    this.gradient,
    this.orbColor,
  });

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with TickerProviderStateMixin {
  late final AnimationController _orb1;
  late final AnimationController _orb2;
  late final AnimationController _orb3;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _orb1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _orb2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _orb3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orb1.dispose();
    _orb2.dispose();
    _orb3.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.orbColor ?? AppColors.electricBlue;

    return AnimatedBuilder(
      animation: Listenable.merge([_orb1, _orb2, _orb3, _breathe]),
      builder: (context, _) {
        final t1 = _orb1.value * 2 * math.pi;
        final t2 = _orb2.value * 2 * math.pi;
        final t3 = _orb3.value * 2 * math.pi;
        final b = 0.7 + 0.3 * _breathe.value;

        return Container(
          color: AppColors.background,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.gradient != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: widget.gradient),
                  ),
                ),
              Align(
                alignment: Alignment(
                  -0.5 + 0.7 * math.sin(t1),
                  -0.8 + 0.4 * math.cos(t1 * 0.7),
                ),
                child: _Orb(color: color, opacity: 0.18 * b, size: 380),
              ),
              Align(
                alignment: Alignment(
                  0.6 + 0.4 * math.cos(t2),
                  0.5 + 0.35 * math.sin(t2 * 0.8),
                ),
                child: _Orb(color: color, opacity: 0.12 * b, size: 320),
              ),
              Align(
                alignment: Alignment(
                  0.2 * math.sin(t3 + math.pi / 3),
                  -0.1 + 0.5 * math.cos(t3 * 0.6),
                ),
                child: _Orb(color: color, opacity: 0.09 * b, size: 300),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double opacity;
  final double size;

  const _Orb({
    required this.color,
    required this.opacity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.3),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}

class GradientBg extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBg({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: gradient,
      ),
      child: child,
    );
  }
}