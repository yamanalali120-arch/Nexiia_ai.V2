// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Greeting Screen (Onboarding Step 1)
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/premium_button.dart';
import '../../navigation/app_router.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({super.key});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ──────────────────────────────────

  late final AnimationController _line1Controller;
  late final AnimationController _line2Controller;
  late final AnimationController _line3Controller;
  late final AnimationController _buttonController;

  // ─── Timing-Konstanten ──────────────────────────────────────

  static const _animDuration = Duration(milliseconds: 500);
  static const _line1Delay = Duration(milliseconds: 600);
  static const _line2Delay = Duration(milliseconds: 1800);
  static const _line3Delay = Duration(milliseconds: 3000);
  static const _buttonDelay = Duration(milliseconds: 4200);
  static const _curve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();

    _line1Controller = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _line2Controller = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _line3Controller = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: _animDuration,
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(_line1Delay);
    if (!mounted) return;
    _line1Controller.forward();

    await Future.delayed(_line2Delay - _line1Delay);
    if (!mounted) return;
    _line2Controller.forward();

    await Future.delayed(_line3Delay - _line2Delay);
    if (!mounted) return;
    _line3Controller.forward();

    await Future.delayed(_buttonDelay - _line3Delay);
    if (!mounted) return;
    _buttonController.forward();
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Haptics.buttonTap();
    AppRouter.onboardingGreetingDone(context);
  }

  Widget _buildAnimatedLine({
    required AnimationController controller,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: _curve,
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedGradientBg(
        gradient: AppGradients.backgroundOnboarding,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (_buttonController.isCompleted) {
                _onContinue();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  _buildAnimatedLine(
                    controller: _line1Controller,
                    child: Text(
                      AppStrings.greetingLine1,
                      style: AppTypography.greetingPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.smd),
                  _buildAnimatedLine(
                    controller: _line2Controller,
                    child: Text(
                      AppStrings.greetingLine2,
                      style: AppTypography.greetingSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _buildAnimatedLine(
                    controller: _line3Controller,
                    child: Text(
                      AppStrings.greetingLine3,
                      style: AppTypography.greetingTertiary,
                    ),
                  ),
                  const Spacer(flex: 4),
                  _buildAnimatedLine(
                    controller: _buttonController,
                    child: PremiumButton(
                      label: AppStrings.greetingContinue,
                      onPressed: _onContinue,
                      isExpanded: true,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}