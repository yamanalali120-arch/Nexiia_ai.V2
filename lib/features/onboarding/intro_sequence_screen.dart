// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Intro Sequence Screen (Onboarding Step 4)
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

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _skipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _skipController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    _skipController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    Haptics.selection();
    setState(() {
      _currentPage = page;
    });
  }

  void _onComplete() {
    Haptics.buttonTap();
    AppRouter.onboardingIntroDone(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedGradientBg(
        gradient: AppGradients.backgroundOnboarding,
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(child: _buildPageView()),
              _buildDotIndicators(),
              SizedBox(height: AppSpacing.xl),
              if (isLastPage) _buildCompleteButton(),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Skip Button ───────────────────────────────────────────

  Widget _buildSkipButton() {
    final curvedAnimation = CurvedAnimation(
      parent: _skipController,
      curve: _curve,
    );

    return FadeTransition(
      opacity: curvedAnimation,
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
    final curvedAnimation = CurvedAnimation(
      parent: _contentController,
      curve: _curve,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          return _buildPage(page);
        },
      ),
    );
  }

  // ─── Single Page ────────────────────────────────────────────

  Widget _buildPage(_IntroPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // ── Icon / Visual ─────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.electricBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              page.icon,
              size: 36,
              color: AppColors.electricBlue,
            ),
          ),

          SizedBox(height: AppSpacing.xxl),

          // ── Headline ──────────────────────────────
          Text(
            page.headline,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md),

          // ── Body ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              page.body,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(flex: 3),
        ],
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            color: isActive
                ? AppColors.electricBlue
                : AppColors.white20,
          ),
        );
      }),
    );
  }

  // ─── Complete Button ───────────────────────────────────────

  Widget _buildCompleteButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: PremiumButton(
        label: AppStrings.intro3Button,
        onPressed: _onComplete,
        isExpanded: true,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PAGE DATA MODEL (Privat)
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