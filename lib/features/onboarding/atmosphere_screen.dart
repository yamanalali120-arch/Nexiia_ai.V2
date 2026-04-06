// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Atmosphere Screen (Onboarding Step 3)
// ═══════════════════════════════════════════════════════════════════

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
import '../../shared/widgets/premium_button.dart';
import '../../navigation/app_router.dart';

class AtmosphereScreen extends StatefulWidget {
  const AtmosphereScreen({super.key});

  @override
  State<AtmosphereScreen> createState() => _AtmosphereScreenState();
}

class _AtmosphereScreenState extends State<AtmosphereScreen>
    with TickerProviderStateMixin {
  AtmosphereModel? _selected;
  bool _isSaving = false;

  late final AnimationController _headerController;
  late final AnimationController _buttonController;
  late final List<AnimationController> _cardControllers;

  late final AnimationController _bgMorphController;
  late Animation<Color?> _bgTintAnimation;
  Color _currentBgTint = Colors.transparent;

  static const _curve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bgMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bgTintAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _bgMorphController,
      curve: _curve,
    ));

    _cardControllers = List.generate(
      AtmosphereModel.count,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _cardControllers.length; i++) {
      if (!mounted) return;
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _buttonController.dispose();
    _bgMorphController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAtmosphereSelected(AtmosphereModel atmosphere) {
    if (_isSaving) return;

    Haptics.optionSelected();

    final previousTint = _currentBgTint;
    _currentBgTint = atmosphere.colors.surfaceTint;

    _bgTintAnimation = ColorTween(
      begin: previousTint,
      end: _currentBgTint,
    ).animate(CurvedAnimation(
      parent: _bgMorphController,
      curve: _curve,
    ));
    _bgMorphController.forward(from: 0.0);

    setState(() {
      _selected = atmosphere;
    });

    if (_buttonController.status != AnimationStatus.completed) {
      _buttonController.forward();
    }
  }

  Future<void> _onContinue() async {
    if (_selected == null || _isSaving) return;

    Haptics.buttonTap();

    setState(() {
      _isSaving = true;
    });

    await UserPreferences.setAtmosphere(_selected!.id);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Haptics.success();
    AppRouter.onboardingAtmosphereDone(context);
  }

  Widget _buildAnimated({
    required AnimationController controller,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: _curve,
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
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
      body: AnimatedBuilder(
        animation: _bgMorphController,
        builder: (context, child) {
          return Stack(
            children: [
              AnimatedGradientBg(
                gradient: AppGradients.backgroundOnboarding,
                child: const SizedBox.expand(),
              ),
              if (_bgTintAnimation.value != null &&
                  _bgTintAnimation.value != Colors.transparent)
                Positioned.fill(
                  child: Container(
                    color: (_bgTintAnimation.value ?? Colors.transparent)
                        .withValues(alpha: 0.08),
                  ),
                ),
              child!,
            ],
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCardList()),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _buildAnimated(
      controller: _headerController,
      child: Padding(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          bottom: AppSpacing.md,
        ),
        child: Column(
          children: [
            Text(
              AppStrings.atmosphereHeadline,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.atmosphereSubtext,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    final atmospheres = AtmosphereModel.all;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      itemCount: atmospheres.length,
      itemBuilder: (context, index) {
        final atmosphere = atmospheres[index];
        final isSelected = _selected?.type == atmosphere.type;

        return _buildAnimated(
          controller: _cardControllers[index],
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.smd),
            child: _AtmosphereCard(
              atmosphere: atmosphere,
              isSelected: isSelected,
              onTap: () => _onAtmosphereSelected(atmosphere),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    final curvedAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: _curve,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          bottom: AppSpacing.xxl,
          top: AppSpacing.sm,
        ),
        child: PremiumButton(
          label: AppStrings.atmosphereContinue,
          onPressed: _selected != null ? _onContinue : null,
          isLoading: _isSaving,
          isExpanded: true,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ATMOSPHERE CARD
// ═══════════════════════════════════════════════════════════════════

class _AtmosphereCard extends StatefulWidget {
  final AtmosphereModel atmosphere;
  final bool isSelected;
  final VoidCallback onTap;

  const _AtmosphereCard({
    required this.atmosphere,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AtmosphereCard> createState() => _AtmosphereCardState();
}

class _AtmosphereCardState extends State<_AtmosphereCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant _AtmosphereCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 100,
          decoration: BoxDecoration(
            gradient: widget.atmosphere.cardPreviewGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.electricBlue
                  : AppColors.glassBorder,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.atmosphere.name,
                  style: AppTypography.atmosphereTitle,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  widget.atmosphere.subtitle,
                  style: AppTypography.atmosphereSubtitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}