// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Intro Sequence Screen (Onboarding Step 4)
// Schnellere Animationen + Atmosphäre-Farben
// ═══════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
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
      duration: const Duration(milliseconds: 300),
    );
    _skipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _skipController.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
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

  Color get _primary => _atmosphere.colors.primary;
  Color get _secondary => _atmosphere.colors.secondary;

  LinearGradient get _backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(AppColors.background, _primary, 0.05) ??
            AppColors.background,
        AppColors.background,
        Color.lerp(AppColors.background, _secondary, 0.03) ??
            AppColors.background,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedGradientBg(
        gradient: _backgroundGradient,
        orbColor: _primary,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final t = _glowController.value * 2 * math.pi;
                return Stack(
                  children: [
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

  Widget _buildPage(_IntroPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _buildIconCircle(page.icon),
          SizedBox(height: AppSpacing.xxl),
          Text(
            page.headline,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
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
          child: GestureDetector(
            onTap: _onNext,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primary.withValues(alpha: 0.85),
                    _primary.withValues(alpha: 0.65),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.3),
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
                  Center(
                    child: Text(
                      isLastPage ? AppStrings.intro3Button : 'Weiter',
                      style: const TextStyle(
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
          ),
        ),
      ),
    );
  }
}

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
