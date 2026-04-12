import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class GlowingIcon extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final double? glowRadius;
  final double? glowOpacity;
  final bool animate;

  const GlowingIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.glowRadius,
    this.glowOpacity,
    this.animate = true,
  });

  @override
  State<GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<GlowingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GlowingIcon oldWidget) {
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
    final iconSize = widget.size ?? AppSpacing.iconMd;
    final color = widget.color ?? AppColors.electricBlue;
    final glowR = widget.glowRadius ?? 20.0;
    final baseOpacity = widget.glowOpacity ?? 0.45;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final p = _pulse.value;
        return SizedBox(
          width: iconSize + glowR * 2,
          height: iconSize + glowR * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: iconSize + glowR * 2 * p,
                height: iconSize + glowR * 2 * p,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: baseOpacity * p),
                      blurRadius: glowR + (10 * p),
                      spreadRadius: 2 * p,
                    ),
                  ],
                ),
              ),
              Container(
                width: iconSize * 2.2,
                height: iconSize * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.15 * p),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Icon(widget.icon, size: iconSize, color: color),
            ],
          ),
        );
      },
    );
  }
}