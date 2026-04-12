import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double? maxScale;
  final double? glowRadius;
  final bool animate;
  final int pulseCount;
  final Duration? duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.color,
    this.maxScale,
    this.glowRadius,
    this.animate = true,
    this.pulseCount = 2,
    this.duration,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 2000),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.electricBlue;
    final count = widget.pulseCount.clamp(1, 3);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < count; i++)
              _PulseRing(
                progress: _controller.value,
                delay: i / count,
                color: color,
                glowRadius: widget.glowRadius ?? 40.0,
                maxScale: widget.maxScale ?? 1.8,
              ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final double delay;
  final Color color;
  final double glowRadius;
  final double maxScale;

  const _PulseRing({
    required this.progress,
    required this.delay,
    required this.color,
    required this.glowRadius,
    required this.maxScale,
  });

  @override
  Widget build(BuildContext context) {
    final p = (progress + delay) % 1.0;
    final curved = Curves.easeOut.transform(p);
    final scale = 1.0 + (maxScale - 1.0) * curved;
    final opacity = (1.0 - curved) * 0.5;

    if (opacity <= 0.01) return const SizedBox.shrink();

    return Transform.scale(
      scale: scale,
      child: Container(
        width: glowRadius * 2,
        height: glowRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 2.0 * (1.0 - curved * 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity * 0.6),
              blurRadius: 12 + 8 * curved,
              spreadRadius: 2 * curved,
            ),
          ],
        ),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final Color? color;
  final double size;
  final bool animate;

  const PulseDot({
    super.key,
    this.color,
    this.size = 8,
    this.animate = true,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.success;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: _opacity.value),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4 * _opacity.value),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BreathingGlow extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double? glowRadius;
  final bool animate;

  const BreathingGlow({
    super.key,
    required this.child,
    this.color,
    this.glowRadius,
    this.animate = true,
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _glow = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(BreathingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.5;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.electricBlue;
    final radius = widget.glowRadius ?? 20.0;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _glow.value),
                blurRadius: radius + (radius * 0.5 * _glow.value),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}