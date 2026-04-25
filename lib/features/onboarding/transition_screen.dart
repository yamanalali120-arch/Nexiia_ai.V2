<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Transition Screen (Onboarding Step 5)
// Kinematische Brücke zwischen Onboarding und Home — Schneller.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../navigation/app_router.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({super.key});

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;

  late final Animation<double> _dimAnimation;
  late final Animation<double> _contractAnimation;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeOutAnimation;

  // Schneller als vorher
  static const _totalDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    // Phase 1: Abdunkeln (0.0 → 0.3)
    _dimAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Phase 2: Licht kontrahiert (0.2 → 0.5)
    _contractAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInCubic),
      ),
    );

    // Phase 3: Licht expandiert (0.5 → 0.8)
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 4: Alles ausblenden (0.75 → 1.0)
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _masterController.forward();

    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        AppRouter.onboardingTransitionDone(context);
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _masterController,
        builder: (context, child) {
          final contractValue = _contractAnimation.value;
          final expandValue = _expandAnimation.value;
          final lightRadius = contractValue + expandValue;

          return Stack(
            children: [
              // ── Dunkler Hintergrund ────────────
              Container(color: AppColors.background),

              // ── Zentraler Lichteffekt ─────────
              Center(
                child: Opacity(
                  opacity: _fadeOutAnimation.value,
                  child: Container(
                    width: lightRadius * 300,
                    height: lightRadius * 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue.withValues(
                            alpha: 0.15 * _fadeOutAnimation.value,
                          ),
                          AppColors.electricBlue.withValues(
                            alpha: 0.05 * _fadeOutAnimation.value,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Dim Overlay ───────────────────
              Container(
                color: AppColors.background.withValues(
                  alpha: _dimAnimation.value * 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
=======
// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Transition Screen (Onboarding Step 5)
// Kinematische Brücke zwischen Onboarding und Home — Schneller.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../navigation/app_router.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({super.key});

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;

  late final Animation<double> _dimAnimation;
  late final Animation<double> _contractAnimation;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeOutAnimation;

  // Schneller als vorher
  static const _totalDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    // Phase 1: Abdunkeln (0.0 → 0.3)
    _dimAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Phase 2: Licht kontrahiert (0.2 → 0.5)
    _contractAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInCubic),
      ),
    );

    // Phase 3: Licht expandiert (0.5 → 0.8)
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 4: Alles ausblenden (0.75 → 1.0)
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _masterController.forward();

    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        AppRouter.onboardingTransitionDone(context);
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _masterController,
        builder: (context, child) {
          final contractValue = _contractAnimation.value;
          final expandValue = _expandAnimation.value;
          final lightRadius = contractValue + expandValue;

          return Stack(
            children: [
              // ── Dunkler Hintergrund ────────────
              Container(color: AppColors.background),

              // ── Zentraler Lichteffekt ─────────
              Center(
                child: Opacity(
                  opacity: _fadeOutAnimation.value,
                  child: Container(
                    width: lightRadius * 300,
                    height: lightRadius * 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue.withValues(
                            alpha: 0.15 * _fadeOutAnimation.value,
                          ),
                          AppColors.electricBlue.withValues(
                            alpha: 0.05 * _fadeOutAnimation.value,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Dim Overlay ───────────────────
              Container(
                color: AppColors.background.withValues(
                  alpha: _dimAnimation.value * 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
>>>>>>> 8770aee841e28e8789bd5095c9bfa14c90ff6498
}