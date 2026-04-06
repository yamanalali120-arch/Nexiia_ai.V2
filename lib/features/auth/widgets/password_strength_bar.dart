import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({
    super.key,
    required this.password,
  });

  Color _colorForStrength(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.strengthWeak;
      case PasswordStrength.fair:
        return AppColors.strengthFair;
      case PasswordStrength.strong:
        return AppColors.strengthStrong;
      case PasswordStrength.veryStrong:
        return AppColors.strengthVeryStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = Validators.passwordStrength(password);
    final activeBars = Validators.strengthBars(strength);
    final label = Validators.strengthLabel(strength);
    final color = _colorForStrength(strength);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bars
          Row(
            children: List.generate(4, (index) {
              final isActive = index < activeBars;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index < 3 ? AppSpacing.xs : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : AppColors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              key: ValueKey(label),
              style: AppTypography.labelSmall.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}