import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AiBadge extends StatelessWidget {
  const AiBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.electricBlue.withOpacity(0.15),
        border: Border.all(
            color: AppColors.electricBlue.withOpacity(0.30), width: 0.5),
      ),
      child: const Text(
        'KI',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.electricBlueLight,
        ),
      ),
    );
  }
}

class EnergyBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const EnergyBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.60))),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.65)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${(value * 100).round()}%',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 9,
                color: color.withOpacity(0.50))),
      ],
    );
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const GlassButton({
    super.key,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.70), color.withOpacity(0.50)],
                )
              : null,
          color: filled ? null : Colors.white.withOpacity(0.06),
          border: Border.all(
            color: filled
                ? color.withOpacity(0.50)
                : Colors.white.withOpacity(0.12),
            width: 0.5,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -4)
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : Colors.white.withOpacity(0.45),
          ),
        ),
      ),
    );
  }
}
