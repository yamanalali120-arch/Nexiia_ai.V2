// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Intro Sequence Screen (Onboarding Step 4)
// ═══════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/services/user_preferences.dart';
import '../../shared/models/atmosphere_model.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../navigation/app_router.dart';

class IntroSequenceScreen extends StatefulWidget {
  const IntroSequenceScreen({super.key});

  @override
  State<IntroSequenceScreen> createState() => _IntroSequenceScreenState();
}

class _IntroSequenceScreenState extends State<IntroSequenceScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _contentController;
  late final AnimationController _skipController;
  late final AnimationController _buttonController;
  late final AnimationController _glowController;

  // Atmosphäre — synchron
  late final AtmosphereModel _atmosphere;

  static const _curve = Curves.easeOutCubic;

  static const _pages = [
    _IntroPageData(
      headline: AppStrings.intro1Headline,
      body: AppStrings.intro1Text,
      icon: Icons.auto_awesome_rounded,
    ),
    _IntroPageData(
      headline: AppStrings.intro2Headline,
      body: AppStrings.intro2Text,
      icon: Icons.calendar_today_rounded,
    ),
    _IntroPageData(
      headline: AppStrings.intro3Headline,
      body: AppStrings.intro3Text,
      icon: Icons.visibility_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _atmosphere = UserPreferences.getAtmosphere();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _skipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _skipController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _buttonController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    _skipController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    Haptics.selection();
    setState(() => _currentPage = page);
  }

  void _onNext() {
    Haptics.buttonTap();
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _onComplete();
    }
  }

  void _onComplete() {
    Haptics.buttonTap();
    AppRouter.onboardingIntroDone(context);
  }

  // ── Farb-Getter ──
  Color get _primary => _atmosphere.colors.primary;
  Color get _secondary => _atmosphere.colors.secondary;

  // Hintergrund-Gradient dynamisch basierend auf Atmosphäre
  LinearGradient get _backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(AppColors.background, _primary, 0.05) ?? AppColors.background,
        AppColors.background,
        Color.lerp(AppColors.background, _secondary, 0.03) ?? AppColors.background,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedGradientBg(
        gradient: _backgroundGradient,
        orbColor: _primary, // ← Atmosphäre-Farbe für die Orbs!
        child: Stack(
          children: [
            // Extra Atmosphäre-Glow Layer für mehr Tiefe
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final t = _glowController.value * 2 * math.pi;
                return Stack(
                  children: [
                    // Oberer Glow — Atmosphäre-Primärfarbe
                    Positioned(
                      top: -80,
                      left: 0,
                      right: 0,
                      height: 350,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(
                              0.3 * math.sin(t * 0.2),
                              -0.4,
                            ),
                            radius: 1.0,
                            colors: [
                              _primary.withValues(alpha: 0.07),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Unterer Glow — Sekundärfarbe
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      height: 250,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(
                              -0.2 * math.cos(t * 0.15),
                              0.5,
                            ),
                            radius: 0.8,
                            colors: [
                              _secondary.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildSkipButton(),
                  Expanded(child: _buildPageView()),
                  _buildDotIndicators(),
                  SizedBox(height: AppSpacing.lg),
                  _buildContinueButton(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skip Button ───────────────────────────────────────────

  Widget _buildSkipButton() {
    final curved = CurvedAnimation(parent: _skipController, curve: _curve);

    return FadeTransition(
      opacity: curved,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.sm,
            right: AppSpacing.screenPadding,
          ),
          child: GestureDetector(
            onTap: _onComplete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Text(
                AppStrings.introSkip,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.white40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Page View ──────────────────────────────────────────────

  Widget _buildPageView() {
    final curved = CurvedAnimation(parent: _contentController, curve: _curve);

    return FadeTransition(
      opacity: curved,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemCount: _pages.length,
        itemBuilder: (context, index) => _buildPage(_pages[index]),
      ),
    );
  }

  // ─── Single Page ────────────────────────────────────────────

  Widget _buildPage(_IntroPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Icon Circle mit Atmosphäre-Farbe
          _buildIconCircle(page.icon),

          SizedBox(height: AppSpacing.xxl),

          // Headline
          Text(
            page.headline,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md),

          // Body
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              page.body,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.white60,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final t = _glowController.value * 2 * math.pi;
        final pulse = 0.08 + 0.05 * math.sin(t);

        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: pulse * 2),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.08),
              border: Border.all(
                color: _primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // 3D Inner Highlight
                Positioned(
                  top: 2,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 36,
                    color: _primary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Dot Indicators ────────────────────────────────────────

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            color: isActive ? _primary : AppColors.white15,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  // ─── Continue Button ───────────────────────────────────────

  Widget _buildContinueButton() {
    final curved = CurvedAnimation(parent: _buttonController, curve: _curve);
    final isLastPage = _currentPage == _pages.length - 1;

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _buttonController,
          curve: Curves.easeOutBack,
        )),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: _IntroButton(
            label: isLastPage
                ? AppStrings.intro3Button
                : AppStrings.generalContinue,
            color: _primary,
            onPressed: _onNext,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INTRO BUTTON
// ═══════════════════════════════════════════════════════════════════

class _IntroButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _IntroButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IntroButton> createState() => _IntroButtonState();
}

class _IntroButtonState extends State<_IntroButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.975 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Container(
              height: AppSpacing.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: widget.color
                        .withValues(alpha: _glowAnim.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      color: Colors.white.withValues(
                        alpha: _isPressed ? 0.10 : 0.06,
                      ),
                      border: Border.all(
                        color: widget.color
                            .withValues(alpha: _glowAnim.value * 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 3D Top Highlight
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: AppSpacing.buttonHeight * 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(AppSpacing.radiusLg),
                                topRight:
                                    Radius.circular(AppSpacing.radiusLg),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: widget.color,
                              height: 1.0,
                            ),
                            child: Text(widget.label),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PAGE DATA MODEL
// ═══════════════════════════════════════════════════════════════════

class _IntroPageData {
  final String headline;
  final String body;
  final IconData icon;

  const _IntroPageData({
    required this.headline,
    required this.body,
    required this.icon,
  });
}