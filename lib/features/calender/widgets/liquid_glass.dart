import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blur;
  final double fillOpacity;
  final double borderOpacity;
  final Color? glowColor;
  final double glowOpacity;
  final bool showSpecularHighlight;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.blur = 28,
    this.fillOpacity = 0.07,
    this.borderOpacity = 0.16,
    this.glowColor,
    this.glowOpacity = 0.06,
    this.showSpecularHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final double cb = blur.clamp(0.0, 30.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: cb, sigmaY: cb),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(fillOpacity + 0.06),
                      Colors.white.withOpacity(fillOpacity),
                      Colors.white.withOpacity(fillOpacity * 0.45),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(borderOpacity),
                    width: 0.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -10,
                    ),
                    if (glowColor != null)
                      BoxShadow(
                        color: glowColor!.withOpacity(glowOpacity),
                        blurRadius: 34,
                        spreadRadius: -10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
              ),
            ),

            if (showSpecularHighlight)
              Positioned(
                top: 0,
                left: 1,
                right: 1,
                height: 1,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.00),
                          Colors.white.withOpacity(0.34),
                          Colors.white.withOpacity(0.62),
                          Colors.white.withOpacity(0.34),
                          Colors.white.withOpacity(0.00),
                        ],
                        stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            if (showSpecularHighlight)
              Positioned(
                top: 1,
                left: 10,
                right: 10,
                height: 0.6,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.00),
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.00),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}