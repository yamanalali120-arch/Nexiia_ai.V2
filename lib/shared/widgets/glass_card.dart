import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptic_utils.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? blurAmount;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.blurAmount,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _glowController;
  late final AnimationController _shimmerController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _shimmerAnimation;

  bool _isPressed = false;
  bool get _isTappable => widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_isTappable) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isTappable) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _glowController.forward(from: 0.0);
  }

  void _handleTapCancel() {
    if (!_isTappable) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (!_isTappable) return;
    Haptics.buttonTap();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppSpacing.radiusXl;
    final blur = widget.blurAmount ?? 24.0;
    final bgColor = widget.backgroundColor ?? const Color(0x0DFFFFFF);
    final border = widget.borderColor ?? const Color(0x14FFFFFF);
    final glow = widget.glowColor ?? AppColors.electricBlue;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _glowController, _shimmerController]),
      builder: (context, _) {
        return Transform.scale(
          scale: _isTappable ? _scaleAnimation.value : 1.0,
          child: _buildOuter(radius, blur, bgColor, border, glow),
        );
      },
    );
  }

  Widget _buildOuter(
    double radius,
    double blur,
    Color bgColor,
    Color borderColor,
    Color glowColor,
  ) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
          if (_isTappable && _glowAnimation.value > 0)
            BoxShadow(
              color: glowColor.withValues(alpha: 0.25 * _glowAnimation.value),
              blurRadius: 24 + (16 * _glowAnimation.value),
              spreadRadius: 2 * _glowAnimation.value,
            ),
        ],
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: _isPressed
                    ? Color.fromRGBO(bgColor.red, bgColor.green, bgColor.blue, bgColor.opacity + 0.03)
                    : bgColor,
                border: Border.all(
                  color: _isPressed ? const Color(0x2EFFFFFF) : borderColor,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  _buildInnerGlow(radius, glowColor),
                  _buildShimmer(radius),
                  _buildEdgeHighlight(radius),
                  Padding(
                    padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInnerGlow(double radius, Color glowColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              glowColor.withValues(alpha: 0.07),
              glowColor.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(double radius) {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(_shimmerAnimation.value - 1, -0.5),
            end: Alignment(_shimmerAnimation.value, 0.5),
            colors: const [
              Color(0x00FFFFFF),
              Color(0x08FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHighlight(double radius) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0x00FFFFFF),
              Color(0x26FFFFFF),
              Color(0x00FFFFFF),
            ],
          ),
        ),
      ),
    );
  }
}