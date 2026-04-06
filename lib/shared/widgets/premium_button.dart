import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptic_utils.dart';

class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final double? height;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.height,
    this.icon,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _glowController;
  late final AnimationController _scaleController;

  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  static const _gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90F8), AppColors.electricBlue, Color(0xFF2060D0)],
  );

  static const _gradientPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A7DE8), Color(0xFF2868D8), Color(0xFF1850C0)],
  );

  static const _gradientDisabled = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x4D3478F6), Color(0x263478F6)],
  );

  static const _buttonTextStyle = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _glowController.forward(from: 0.0);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (!_isEnabled) return;
    Haptics.buttonTap();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final btnHeight = widget.height ?? AppSpacing.buttonHeight;
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _glowController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildGlowWrapper(btnHeight: btnHeight, child: _buildButton(btnHeight)),
        );
      },
    );
  }

  Widget _buildGlowWrapper({required double btnHeight, required Widget child}) {
    return Container(
      width: widget.isExpanded ? double.infinity : null,
      height: btnHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: _isEnabled ? 0.25 : 0.05),
            blurRadius: 20,
          ),
          if (_glowAnimation.value > 0)
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.5 * _glowAnimation.value),
              blurRadius: 30 + (20 * _glowAnimation.value),
              spreadRadius: 2 * _glowAnimation.value,
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildButton(double btnHeight) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.isExpanded ? double.infinity : null,
            height: btnHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              gradient: _isEnabled
                  ? (_isPressed ? _gradientPressed : _gradientPrimary)
                  : _gradientDisabled,
              border: Border.all(
                color: _isPressed ? const Color(0x40FFFFFF) : const Color(0x1FFFFFFF),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                if (_isEnabled) _buildShimmer(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: btnHeight * 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg),
                        topRight: Radius.circular(AppSpacing.radiusLg),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
                Center(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(_shimmerAnimation.value - 1, 0),
            end: Alignment(_shimmerAnimation.value, 0),
            colors: const [Color(0x00FFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: AppSpacing.iconMd,
        height: AppSpacing.iconMd,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xE6FFFFFF)),
        ),
      );
    }
    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: AppSpacing.iconMd, color: Colors.white));
      children.add(const SizedBox(width: AppSpacing.sm));
    }
    children.add(Text(widget.label, style: _buttonTextStyle));
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final double? height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isExpanded = true,
    this.height,
    this.icon,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _glowController;
  late final AnimationController _scaleController;

  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool get _isEnabled => widget.onPressed != null;

  static const _buttonTextStyle = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _glowController.forward(from: 0.0);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (!_isEnabled) return;
    Haptics.buttonTap();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final btnHeight = widget.height ?? AppSpacing.buttonHeight;
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _glowController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildGlowWrapper(btnHeight: btnHeight, child: _buildButton(btnHeight)),
        );
      },
    );
  }

  Widget _buildGlowWrapper({required double btnHeight, required Widget child}) {
    return Container(
      width: widget.isExpanded ? double.infinity : null,
      height: btnHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          if (_glowAnimation.value > 0)
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.3 * _glowAnimation.value),
              blurRadius: 24 + (16 * _glowAnimation.value),
              spreadRadius: 1 * _glowAnimation.value,
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildButton(double btnHeight) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.isExpanded ? double.infinity : null,
            height: btnHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              color: _isPressed ? const Color(0x1AFFFFFF) : const Color(0x0DFFFFFF),
              border: Border.all(
                color: _isPressed ? const Color(0x663478F6) : const Color(0x1AFFFFFF),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                if (_isEnabled) _buildShimmer(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: btnHeight * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg),
                        topRight: Radius.circular(AppSpacing.radiusLg),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x0FFFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
                Center(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(_shimmerAnimation.value - 1, 0),
            end: Alignment(_shimmerAnimation.value, 0),
            colors: const [Color(0x00FFFFFF), Color(0x0DFFFFFF), Color(0x00FFFFFF)],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textColor = _isEnabled ? const Color(0xE6FFFFFF) : const Color(0x4DFFFFFF);
    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: AppSpacing.iconMd, color: textColor));
      children.add(const SizedBox(width: AppSpacing.sm));
    }
    children.add(
      Text(widget.label, style: _buttonTextStyle.copyWith(color: textColor)),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}