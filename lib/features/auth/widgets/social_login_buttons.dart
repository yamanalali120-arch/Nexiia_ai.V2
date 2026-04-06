import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/haptic_utils.dart';

// ════════════════════════════════════════════════════════════════
// Social Login Buttons — UI Only (Sprint 1)
// Auth integration comes in a later sprint.
// ════════════════════════════════════════════════════════════════

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onApplePressed;
  final VoidCallback? onGooglePressed;

  const SocialLoginButtons({
    super.key,
    this.onApplePressed,
    this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Divider with "oder" ──
        _buildOrDivider(),
        const SizedBox(height: AppSpacing.lg),

        // ── Apple Button ──
        _SocialButton(
          label: AppStrings.continueWithApple,
          icon: Icons.apple_rounded,
          onPressed: onApplePressed,
        ),
        const SizedBox(height: AppSpacing.smd),

        // ── Google Button ──
        _SocialButton(
          label: AppStrings.continueWithGoogle,
          icon: Icons.g_mobiledata_rounded,
          iconSize: 28,
          onPressed: onGooglePressed,
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: AppGradients.dividerFade,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.orDivider,
            style: AppTypography.dividerText,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: AppGradients.dividerFade,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Individual Social Button
// ════════════════════════════════════════════════════════════════

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.iconSize = 22,
    this.onPressed,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    Haptics.light();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        transform: Matrix4.identity()
..scale(_isPressed ? 0.98 : 1.0, _isPressed ? 0.98 : 1.0),        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.white08 : AppColors.white05,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(
            color: _isPressed ? AppColors.white20 : AppColors.white10,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: AppColors.white80,
              size: widget.iconSize,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.label,
              style: AppTypography.labelButton.copyWith(
                color: AppColors.white80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}