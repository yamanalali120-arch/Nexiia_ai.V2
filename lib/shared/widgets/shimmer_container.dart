import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

enum ShimmerDirection {
  leftToRight,
  diagonal,
}

class ShimmerContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? baseColor;
  final Color? shimmerColor;
  final Widget? child;
  final bool isLoading;
  final Duration? duration;
  final ShimmerDirection direction;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.shimmerColor,
    this.child,
    this.isLoading = true,
    this.duration,
    this.direction = ShimmerDirection.leftToRight,
  });

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 1800),
    );
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
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
    final radius = widget.borderRadius ?? AppSpacing.radiusMd;
    final base = widget.baseColor ?? const Color(0x0FFFFFFF);
    final shimmer = widget.shimmerColor ?? const Color(0x26FFFFFF);

    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final beginX = widget.direction == ShimmerDirection.diagonal
            ? _animation.value - 0.5
            : _animation.value;
        final endX = widget.direction == ShimmerDirection.diagonal
            ? _animation.value + 0.5
            : _animation.value + 0.8;
        final beginY = widget.direction == ShimmerDirection.diagonal
            ? _animation.value - 1.0
            : 0.0;
        final endY = widget.direction == ShimmerDirection.diagonal
            ? _animation.value
            : 0.0;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: base,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(beginX, beginY),
                        end: Alignment(endX, endY),
                        colors: [base, shimmer, base],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0x14FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppSpacing.radiusSm,
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final double? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? AppSpacing.radiusXl,
      baseColor: const Color(0x0AFFFFFF),
      shimmerColor: const Color(0x1AFFFFFF),
      direction: ShimmerDirection.diagonal,
    );
  }
}