<<<<<<< HEAD
// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Greeting Screen (Onboarding Step 1)
// Schnellere Animationen + Farbiger Weiter-Button
// ═══════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
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

  // Ambient Glow Animation
  late final AnimationController _ambientGlowController;
  late final Animation<double> _ambientGlowAnimation;

  // Subtle floating orb
  late final AnimationController _orbController;
  late final Animation<Alignment> _orbAlignmentAnimation;
  late final Animation<double> _orbOpacityAnimation;

  // Button Glow
  late final AnimationController _buttonGlowController;

  // ─── Timing — Schneller & gleichmäßiger ─────────────────────

  static const _animDuration = Duration(milliseconds: 400);
  static const _line1Delay = Duration(milliseconds: 400);
  static const _line2Delay = Duration(milliseconds: 1000);
  static const _line3Delay = Duration(milliseconds: 1600);
  static const _buttonDelay = Duration(milliseconds: 2200);
  static const _curve = Curves.easeOutCubic;
  static const _springCurve = Curves.easeOutBack;

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
      duration: const Duration(milliseconds: 500),
    );

    // Ambient Glow – sanftes Atmen
    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _ambientGlowAnimation = Tween<double>(
      begin: 0.03,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _ambientGlowController,
      curve: Curves.easeInOut,
    ));
    _ambientGlowController.repeat(reverse: true);

    // Floating Orb
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _orbAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.8, -0.6),
          end: const Alignment(0.6, -0.3),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.6, -0.3),
          end: const Alignment(-0.4, -0.8),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.4, -0.8),
          end: const Alignment(-0.8, -0.6),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_orbController);
    _orbOpacityAnimation = Tween<double>(
      begin: 0.04,
      end: 0.12,
    ).animate(CurvedAnimation(
      parent: _orbController,
      curve: Curves.easeInOut,
    ));
    _orbController.repeat();

    // Button Glow
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

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
    _ambientGlowController.dispose();
    _orbController.dispose();
    _buttonGlowController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Haptics.buttonTap();
    AppRouter.onboardingGreetingDone(context);
  }

  Widget _buildAnimatedLine({
    required AnimationController controller,
    required Widget child,
    bool useSpring = false,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: useSpring ? _springCurve : _curve,
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
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
        child: AnimatedBuilder(
          animation: Listenable.merge([_ambientGlowController, _orbController]),
          builder: (context, child) {
            return Stack(
              children: [
                // ── Floating Ambient Orb ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: _orbAlignmentAnimation.value,
                        radius: 1.0,
                        colors: [
                          AppColors.electricBlue
                              .withValues(alpha: _orbOpacityAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Subtle Center Glow ──
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue
                              .withValues(alpha: _ambientGlowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                child!,
              ],
            );
          },
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
                  horizontal: AppSpacing.screenPadding + 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 3),

                    // ── Line 1 ──
                    _buildAnimatedLine(
                      controller: _line1Controller,
                      child: Text(
                        AppStrings.greetingLine1,
                        style: AppTypography.greetingPrimary.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.smd + 2),

                    // ── Line 2 ──
                    _buildAnimatedLine(
                      controller: _line2Controller,
                      child: Text(
                        AppStrings.greetingLine2,
                        style: AppTypography.greetingSecondary.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg + 4),

                    // ── Line 3 mit Glass-Container ──
                    _buildAnimatedLine(
                      controller: _line3Controller,
                      child: _buildGlassQuote(),
                    ),

                    const Spacer(flex: 4),

                    // ── Farbiger Weiter-Button ──
                    _buildAnimatedLine(
                      controller: _buttonController,
                      useSpring: true,
                      child: _buildWeiterButton(),
                    ),

                    SizedBox(height: AppSpacing.xxl + 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // FARBIGER WEITER-BUTTON
  // ───────────────────────────────────────────────

  Widget _buildWeiterButton() {
    return AnimatedBuilder(
      animation: _buttonGlowController,
      builder: (context, _) {
        final glowVal = _buttonGlowController.value;

        return GestureDetector(
          onTap: _onContinue,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0.85),
                  AppColors.electricBlue.withValues(alpha: 0.65),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue
                      .withValues(alpha: 0.25 + glowVal * 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                // Top highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Weiter',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // GLASS QUOTE CONTAINER
  // ───────────────────────────────────────────────

  Widget _buildGlassQuote() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top Reflection Line
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Quote Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent Line
                  Container(
                    width: 2,
                    height: 40,
                    margin: EdgeInsets.only(right: AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.electricBlue.withValues(alpha: 0.8),
                          AppColors.electricBlue.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.greetingLine3,
                      style: AppTypography.greetingTertiary.copyWith(
                        color: AppColors.white80.withValues(alpha: 0.55),
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
=======
// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Greeting Screen (Onboarding Step 1)
// Schnellere Animationen + Farbiger Weiter-Button
// ═══════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
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

  // Ambient Glow Animation
  late final AnimationController _ambientGlowController;
  late final Animation<double> _ambientGlowAnimation;

  // Subtle floating orb
  late final AnimationController _orbController;
  late final Animation<Alignment> _orbAlignmentAnimation;
  late final Animation<double> _orbOpacityAnimation;

  // Button Glow
  late final AnimationController _buttonGlowController;

  // ─── Timing — Schneller & gleichmäßiger ─────────────────────

  static const _animDuration = Duration(milliseconds: 400);
  static const _line1Delay = Duration(milliseconds: 400);
  static const _line2Delay = Duration(milliseconds: 1000);
  static const _line3Delay = Duration(milliseconds: 1600);
  static const _buttonDelay = Duration(milliseconds: 2200);
  static const _curve = Curves.easeOutCubic;
  static const _springCurve = Curves.easeOutBack;

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
      duration: const Duration(milliseconds: 500),
    );

    // Ambient Glow – sanftes Atmen
    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _ambientGlowAnimation = Tween<double>(
      begin: 0.03,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _ambientGlowController,
      curve: Curves.easeInOut,
    ));
    _ambientGlowController.repeat(reverse: true);

    // Floating Orb
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _orbAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.8, -0.6),
          end: const Alignment(0.6, -0.3),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.6, -0.3),
          end: const Alignment(-0.4, -0.8),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.4, -0.8),
          end: const Alignment(-0.8, -0.6),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_orbController);
    _orbOpacityAnimation = Tween<double>(
      begin: 0.04,
      end: 0.12,
    ).animate(CurvedAnimation(
      parent: _orbController,
      curve: Curves.easeInOut,
    ));
    _orbController.repeat();

    // Button Glow
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

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
    _ambientGlowController.dispose();
    _orbController.dispose();
    _buttonGlowController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Haptics.buttonTap();
    AppRouter.onboardingGreetingDone(context);
  }

  Widget _buildAnimatedLine({
    required AnimationController controller,
    required Widget child,
    bool useSpring = false,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: useSpring ? _springCurve : _curve,
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
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
        child: AnimatedBuilder(
          animation: Listenable.merge([_ambientGlowController, _orbController]),
          builder: (context, child) {
            return Stack(
              children: [
                // ── Floating Ambient Orb ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: _orbAlignmentAnimation.value,
                        radius: 1.0,
                        colors: [
                          AppColors.electricBlue
                              .withValues(alpha: _orbOpacityAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Subtle Center Glow ──
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue
                              .withValues(alpha: _ambientGlowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                child!,
              ],
            );
          },
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
                  horizontal: AppSpacing.screenPadding + 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 3),

                    // ── Line 1 ──
                    _buildAnimatedLine(
                      controller: _line1Controller,
                      child: Text(
                        AppStrings.greetingLine1,
                        style: AppTypography.greetingPrimary.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.smd + 2),

                    // ── Line 2 ──
                    _buildAnimatedLine(
                      controller: _line2Controller,
                      child: Text(
                        AppStrings.greetingLine2,
                        style: AppTypography.greetingSecondary.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg + 4),

                    // ── Line 3 mit Glass-Container ──
                    _buildAnimatedLine(
                      controller: _line3Controller,
                      child: _buildGlassQuote(),
                    ),

                    const Spacer(flex: 4),

                    // ── Farbiger Weiter-Button ──
                    _buildAnimatedLine(
                      controller: _buttonController,
                      useSpring: true,
                      child: _buildWeiterButton(),
                    ),

                    SizedBox(height: AppSpacing.xxl + 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // FARBIGER WEITER-BUTTON
  // ───────────────────────────────────────────────

  Widget _buildWeiterButton() {
    return AnimatedBuilder(
      animation: _buttonGlowController,
      builder: (context, _) {
        final glowVal = _buttonGlowController.value;

        return GestureDetector(
          onTap: _onContinue,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0.85),
                  AppColors.electricBlue.withValues(alpha: 0.65),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue
                      .withValues(alpha: 0.25 + glowVal * 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                // Top highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Weiter',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // GLASS QUOTE CONTAINER
  // ───────────────────────────────────────────────

  Widget _buildGlassQuote() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top Reflection Line
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Quote Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent Line
                  Container(
                    width: 2,
                    height: 40,
                    margin: EdgeInsets.only(right: AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.electricBlue.withValues(alpha: 0.8),
                          AppColors.electricBlue.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.greetingLine3,
                      style: AppTypography.greetingTertiary.copyWith(
                        color: AppColors.white80.withValues(alpha: 0.55),
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
>>>>>>> 8770aee841e28e8789bd5095c9bfa14c90ff6498
}