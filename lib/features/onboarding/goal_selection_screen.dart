// ============================================================================
// NEXIIA — Goal Selection Screen (Onboarding Step 1 - New Flow)
// Purpose: Let users pick an immediate intention and jump straight to value.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/services/user_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/glass_card.dart';
import '../home/home_screen.dart';
import '../../navigation/app_router.dart';

enum _Goal {
  dayPlan,
  solve,
  talk,
  focus,
}

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  Future<void> _select(BuildContext context, _Goal goal) async {
    Haptics.buttonTap();

    // Mark onboarding complete as soon as the user meaningfully enters the app.
    await UserPreferences.setOnboardingComplete();

    if (!context.mounted) return;

    switch (goal) {
      case _Goal.dayPlan:
        AppRouter.replaceAllFade(
          context,
          const HomeScreen(
            initialTabIndex: 1,
            initialChatPrompt: 'Hilf mir, meinen Tag zu planen.',
          ),
        );
        return;
      case _Goal.solve:
        AppRouter.replaceAllFade(
          context,
          const HomeScreen(initialTabIndex: 2),
        );
        return;
      case _Goal.talk:
        AppRouter.replaceAllFade(
          context,
          const HomeScreen(initialTabIndex: 1),
        );
        return;
      case _Goal.focus:
        AppRouter.replaceAllFade(
          context,
          const HomeScreen(initialTabIndex: 4),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedGradientBg(
        gradient: AppGradients.backgroundOnboarding,
        child: SafeArea(
          bottom: true,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            children: [
              Text(
                'Was moechtest du gerade tun?',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Nexiia hilft dir, deinen Tag zu planen, Probleme zu sortieren oder einfach klarer zu denken.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 22),
              _GoalCard(
                title: 'Tag planen',
                description: 'Erstelle in Sekunden einen klaren Tagesplan.',
                icon: Icons.event_available_rounded,
                glow: AppColors.electricBlue,
                onTap: () => _select(context, _Goal.dayPlan),
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Problem loesen',
                description: 'Sortiere Gedanken und finde naechste Schritte.',
                icon: Icons.account_tree_rounded,
                glow: const Color(0xFF34C759),
                onTap: () => _select(context, _Goal.solve),
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Einfach reden',
                description: 'Sprich aus, was dich gerade beschaeftigt.',
                icon: Icons.forum_rounded,
                glow: const Color(0xFFF472B6),
                onTap: () => _select(context, _Goal.talk),
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Fokus starten',
                description: 'Starte eine ruhige Fokus-Session.',
                icon: Icons.hexagon_rounded,
                glow: const Color(0xFFB39DDB),
                onTap: () => _select(context, _Goal.focus),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Du kannst das spaeter jederzeit aendern.',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white30,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color glow;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: 22,
      blurAmount: 28,
      backgroundColor: const Color(0x0DFFFFFF),
      borderColor: const Color(0x14FFFFFF),
      glowColor: glow,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glow.withValues(alpha: 0.22),
                  glow.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: AppColors.white10,
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: glow.withValues(alpha: 0.95), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white95,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.white20,
            size: 20,
          ),
        ],
      ),
    );
  }
}
