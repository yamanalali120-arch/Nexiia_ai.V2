// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Atmosphere Screen (Onboarding Step 3)
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
      duration: const Duration(milliseconds: 400),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bgMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bgTintAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _bgMorphController, curve: _curve));

    _cardControllers = List.generate(
      AtmosphereModel.count,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 120));
    for (int i = 0; i < _cardControllers.length; i++) {
      if (!mounted) return;
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _buttonController.dispose();
    _bgMorphController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onAtmosphereSelected(AtmosphereModel atmosphere) {
    if (_isSaving) return;
    Haptics.optionSelected();

    final prev = _currentBgTint;
    _currentBgTint = atmosphere.colors.primary;
    _bgTintAnimation = ColorTween(begin: prev, end: _currentBgTint)
        .animate(CurvedAnimation(parent: _bgMorphController, curve: _curve));
    _bgMorphController.forward(from: 0.0);

    setState(() => _selected = atmosphere);

    if (_buttonController.status != AnimationStatus.completed) {
      _buttonController.forward();
    }
  }

  Future<void> _onContinue() async {
    if (_selected == null || _isSaving) return;
    Haptics.buttonTap();
    setState(() => _isSaving = true);
    await UserPreferences.setAtmosphere(_selected!.id);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Haptics.success();
    AppRouter.onboardingAtmosphereDone(context);
  }

  Widget _buildAnimated({
    required AnimationController controller,
    required Widget child,
  }) {
    final curved = CurvedAnimation(parent: controller, curve: _curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
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
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.4,
                        colors: [
                          (_bgTintAnimation.value ?? Colors.transparent)
                              .withValues(alpha: 0.08),
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
          bottom: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white15,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppStrings.atmosphereHeadline,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.atmosphereSubtext,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white40),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    final atmospheres = AtmosphereModel.all;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.03, 0.94, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        itemCount: atmospheres.length,
        itemBuilder: (context, index) {
          final atm = atmospheres[index];
          final isSelected = _selected?.type == atm.type;
          final hasSelection = _selected != null;

          return _buildAnimated(
            controller: _cardControllers[index],
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.smd),
              child: _AtmosphereCard(
                atmosphere: atm,
                isSelected: isSelected,
                isDimmed: hasSelection && !isSelected,
                onTap: () => _onAtmosphereSelected(atm),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton() {
    final fade = CurvedAnimation(parent: _buttonController, curve: _curve);
    final slide = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(slide),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            bottom: AppSpacing.xxl,
            top: AppSpacing.sm,
          ),
          child: _AtmosphereButton(
            label: AppStrings.atmosphereContinue,
            atmosphere: _selected,
            onPressed: _selected != null ? _onContinue : null,
            isLoading: _isSaving,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ATMOSPHERE BUTTON
// ═══════════════════════════════════════════════════════════════════

class _AtmosphereButton extends StatefulWidget {
  final String label;
  final AtmosphereModel? atmosphere;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AtmosphereButton({
    required this.label,
    required this.atmosphere,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_AtmosphereButton> createState() => _AtmosphereButtonState();
}

class _AtmosphereButtonState extends State<_AtmosphereButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
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
    final color = widget.atmosphere?.colors.primary ?? AppColors.electricBlue;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) {
            if (isEnabled) setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            if (isEnabled) setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (isEnabled) setState(() => _isPressed = false);
          },
          onTap: () {
            if (isEnabled) {
              Haptics.buttonTap();
              widget.onPressed!();
            }
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.975 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: AppSpacing.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _glowAnim.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
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
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      color: Colors.white.withValues(
                        alpha: _isPressed ? 0.10 : 0.07,
                      ),
                      border: Border.all(
                        color: color.withValues(alpha: _glowAnim.value * 0.45),
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
                                topLeft: Radius.circular(AppSpacing.radiusLg),
                                topRight: Radius.circular(AppSpacing.radiusLg),
                              ),
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
                          child: widget.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(color),
                                  ),
                                )
                              : AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: color,
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
// ATMOSPHERE CARD
// ═══════════════════════════════════════════════════════════════════

class _AtmosphereCard extends StatefulWidget {
  final AtmosphereModel atmosphere;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _AtmosphereCard({
    required this.atmosphere,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  @override
  State<_AtmosphereCard> createState() => _AtmosphereCardState();
}

class _AtmosphereCardState extends State<_AtmosphereCard>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _orbController;
  late final AnimationController _selectController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();

    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant _AtmosphereCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _selectController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.atmosphere.type) {
      case Atmosphere.techFuture:
        return Icons.auto_awesome;
      case Atmosphere.luxusPremium:
        return Icons.diamond_outlined;
      case Atmosphere.calm:
        return Icons.spa_outlined;
      case Atmosphere.spiritual:
        return Icons.self_improvement_outlined;
      case Atmosphere.lifestyle:
        return Icons.palette_outlined;
      case Atmosphere.crystalGlass:
        return Icons.blur_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.atmosphere.colors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : (widget.isSelected ? 1.01 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isDimmed ? 0.4 : 1.0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 2),
              child: Stack(
                children: [
                  // Base Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.atmosphere.cardPreviewGradient,
                      ),
                    ),
                  ),

                  // Dark overlay for depth
                  Positioned.fill(
                    child: Container(
                      color: AppColors.background.withValues(alpha: 0.3),
                    ),
                  ),

                  // ── DECORATIVE ILLUSTRATION ──
                  _buildIllustration(colors),

                  // Glass overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Selection border
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 2),
                        border: Border.all(
                          color: widget.isSelected
                              ? colors.primary.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.06),
                          width: widget.isSelected ? 1.2 : 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Top reflection
                  Positioned(
                    top: 0.5,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(
                              alpha: widget.isSelected ? 0.10 : 0.04,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        _buildIconCircle(colors),
                        SizedBox(width: AppSpacing.md),
                        Expanded(child: _buildText()),
                        _buildCheckmark(colors),
                      ],
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

  // ═══════════════════════════════════════════════════════════
  // ILLUSTRATIONS — Unique pro Atmosphäre
  // ═══════════════════════════════════════════════════════════

  Widget _buildIllustration(AtmosphereColors colors) {
    switch (widget.atmosphere.type) {
      case Atmosphere.techFuture:
        return _buildTechFutureIllustration(colors);
      case Atmosphere.luxusPremium:
        return _buildLuxusIllustration(colors);
      case Atmosphere.calm:
        return _buildCalmIllustration(colors);
      case Atmosphere.spiritual:
        return _buildSpiritualIllustration(colors);
      case Atmosphere.lifestyle:
        return _buildLifestyleIllustration(colors);
      case Atmosphere.crystalGlass:
        return _buildCrystalIllustration(colors);
    }
  }

  // ── TECH FUTURE: Schwebende Sterne / Sparkles ──
  Widget _buildTechFutureIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        return Stack(
          children: [
            // Großer Stern
            Positioned(
              right: 55 + 4 * math.sin(t),
              top: 14 + 3 * math.cos(t),
              child: _StarShape(
                size: 28,
                color: colors.primary.withValues(alpha: 0.7),
              ),
            ),
            // Kleiner Stern
            Positioned(
              right: 30 + 3 * math.cos(t + 1.0),
              top: 8 + 2 * math.sin(t + 1.0),
              child: _StarShape(
                size: 18,
                color: colors.secondary.withValues(alpha: 0.5),
              ),
            ),
            // Winziger Stern
            Positioned(
              right: 75 + 2 * math.sin(t + 2.5),
              top: 35 + 2 * math.cos(t + 2.5),
              child: _StarShape(
                size: 12,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            // Glow
            Positioned(
              right: 30,
              top: 5,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── LUXUS PREMIUM: Goldene Karten / Cards ──
  Widget _buildLuxusIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        final tilt = math.sin(t) * 0.03;
        return Stack(
          children: [
            // Hintere Karte
            Positioned(
              right: 42 + 2 * math.sin(t),
              top: 18,
              child: Transform.rotate(
                angle: -0.15 + tilt,
                child: Container(
                  width: 32,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.4),
                        colors.secondary.withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            // Vordere Karte
            Positioned(
              right: 30 + 2 * math.cos(t),
              top: 22,
              child: Transform.rotate(
                angle: 0.12 + tilt,
                child: Container(
                  width: 32,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.6),
                        colors.primary.withValues(alpha: 0.3),
                      ],
                    ),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Gold Glow
            Positioned(
              right: 25,
              top: 15,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── CALM: Blatt / Lotus Form ──
  Widget _buildCalmIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        final scale = 1.0 + 0.03 * math.sin(t);
        return Stack(
          children: [
            Positioned(
              right: 30,
              top: 15,
              child: Transform.scale(
                scale: scale,
                child: CustomPaint(
                  size: const Size(50, 60),
                  painter: _LotusPainter(
                    color: colors.primary,
                    progress: _orbController.value,
                  ),
                ),
              ),
            ),
            // Soft Glow
            Positioned(
              right: 35,
              top: 20,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── SPIRITUAL: Peace / Mandala ──
  Widget _buildSpiritualIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        return Stack(
          children: [
            // Peace Circle
            Positioned(
              right: 28,
              top: 14,
              child: Transform.rotate(
                angle: t * 0.05,
                child: CustomPaint(
                  size: const Size(56, 56),
                  painter: _PeaceSymbolPainter(
                    color: colors.primary,
                    glowOpacity: 0.15 + 0.05 * math.sin(t),
                  ),
                ),
              ),
            ),
            // Floating dots
            for (int i = 0; i < 5; i++)
              Positioned(
                right: 20 + 50 * math.cos(t * 0.3 + i * 1.2),
                top: 10 + 40 * math.sin(t * 0.3 + i * 1.2) + 25,
                child: Container(
                  width: 2.5,
                  height: 2.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2 + 0.1 * math.sin(t + i)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── LIFESTYLE: Farbige Kreise / Disco Ball ──
  Widget _buildLifestyleIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        return Stack(
          children: [
            // Hauptkreis
            Positioned(
              right: 32,
              top: 20,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.5),
                      colors.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 18,
                ),
              ),
            ),
            // Tanzende Partikel
            for (int i = 0; i < 4; i++)
              Positioned(
                right: 38 + 22 * math.cos(t * 0.5 + i * 1.57),
                top: 28 + 22 * math.sin(t * 0.5 + i * 1.57),
                child: Container(
                  width: 4 + 2 * math.sin(t + i).abs(),
                  height: 4 + 2 * math.sin(t + i).abs(),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [
                      colors.primary,
                      colors.secondary,
                      Colors.white,
                      colors.primary,
                    ][i]
                        .withValues(alpha: 0.3 + 0.15 * math.sin(t + i)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── CRYSTAL: Diamant ──
  Widget _buildCrystalIllustration(AtmosphereColors colors) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value * 2 * math.pi;
        final shimmer = 0.3 + 0.2 * math.sin(t * 2);
        return Stack(
          children: [
            Positioned(
              right: 30,
              top: 16,
              child: CustomPaint(
                size: const Size(48, 52),
                painter: _DiamondPainter(
                  color: colors.primary,
                  shimmerOpacity: shimmer,
                ),
              ),
            ),
            // Refraction sparkles
            Positioned(
              right: 25 + 3 * math.sin(t),
              top: 12 + 2 * math.cos(t),
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: shimmer * 0.8),
                ),
              ),
            ),
            Positioned(
              right: 60 + 2 * math.cos(t + 1),
              top: 30 + 2 * math.sin(t + 1),
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: shimmer * 0.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Helpers ──

  Widget _buildIconCircle(AtmosphereColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected
            ? colors.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: widget.isSelected
              ? colors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Icon(
        _getIcon(),
        color: widget.isSelected ? colors.primary : AppColors.white30,
        size: 18,
      ),
    );
  }

  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.atmosphere.name,
          style: AppTypography.atmosphereTitle.copyWith(
            color: widget.isSelected ? AppColors.white95 : AppColors.white70,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          widget.atmosphere.subtitle,
          style: AppTypography.atmosphereSubtitle.copyWith(
            color: widget.isSelected ? AppColors.white50 : AppColors.white30,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckmark(AtmosphereColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected
            ? colors.primary.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: widget.isSelected
              ? colors.primary
              : Colors.white.withValues(alpha: 0.08),
          width: widget.isSelected ? 0 : 0.5,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: widget.isSelected
            ? const Icon(Icons.check_rounded,
                key: ValueKey('c'), color: Colors.white, size: 14)
            : const SizedBox.shrink(key: ValueKey('e')),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS — Illustrationen
// ═══════════════════════════════════════════════════════════════════

// ── 4-Point Star ──
class _StarShape extends StatelessWidget {
  final double size;
  final Color color;
  const _StarShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final ir = r * 0.3;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final outerAngle = (i * math.pi / 2) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 4;
      if (i == 0) {
        path.moveTo(cx + r * math.cos(outerAngle), cy + r * math.sin(outerAngle));
      } else {
        path.lineTo(cx + r * math.cos(outerAngle), cy + r * math.sin(outerAngle));
      }
      path.lineTo(cx + ir * math.cos(innerAngle), cy + ir * math.sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.color != color;
}

// ── Lotus / Leaf ──
class _LotusPainter extends CustomPainter {
  final Color color;
  final double progress;
  _LotusPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Center petal
    _drawPetal(canvas, cx, cy, 0, size.height * 0.38, paint);
    _drawPetal(canvas, cx, cy, 0, size.height * 0.38, strokePaint);

    // Side petals
    _drawPetal(canvas, cx, cy, -0.4, size.height * 0.3, paint);
    _drawPetal(canvas, cx, cy, 0.4, size.height * 0.3, paint);

    // Outer petals
    _drawPetal(canvas, cx, cy, -0.75, size.height * 0.22, paint);
    _drawPetal(canvas, cx, cy, 0.75, size.height * 0.22, paint);
  }

  void _drawPetal(Canvas canvas, double cx, double cy, double angle, double h, Paint paint) {
    final path = Path();
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    path.moveTo(0, 0);
    path.quadraticBezierTo(-h * 0.35, -h * 0.5, 0, -h);
    path.quadraticBezierTo(h * 0.35, -h * 0.5, 0, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LotusPainter old) => true;
}

// ── Peace Symbol ──
class _PeaceSymbolPainter extends CustomPainter {
  final Color color;
  final double glowOpacity;
  _PeaceSymbolPainter({required this.color, required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    final paint = Paint()
      ..color = color.withValues(alpha: glowOpacity + 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Vertical line
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);

    // Bottom-left line
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx - r * 0.7, cy + r * 0.7),
      paint,
    );

    // Bottom-right line
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.7, cy + r * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PeaceSymbolPainter old) =>
      old.glowOpacity != glowOpacity;
}

// ── Diamond ──
class _DiamondPainter extends CustomPainter {
  final Color color;
  final double shimmerOpacity;
  _DiamondPainter({required this.color, required this.shimmerOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Crown (top)
    final crownPath = Path()
      ..moveTo(w * 0.15, h * 0.3)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.85, h * 0.3)
      ..close();

    final crownPaint = Paint()
      ..color = color.withValues(alpha: shimmerOpacity * 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crownPath, crownPaint);

    // Body (bottom)
    final bodyPath = Path()
      ..moveTo(w * 0.15, h * 0.3)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.85, h * 0.3)
      ..close();

    final bodyPaint = Paint()
      ..color = color.withValues(alpha: shimmerOpacity * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Divider line
    final linePaint = Paint()
      ..color = color.withValues(alpha: shimmerOpacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(w * 0.15, h * 0.3), Offset(w * 0.85, h * 0.3), linePaint);

    // Inner facet lines
    canvas.drawLine(Offset(w * 0.35, h * 0.3), Offset(w * 0.5, h), linePaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.3), Offset(w * 0.5, h), linePaint);
    canvas.drawLine(Offset(w * 0.35, h * 0.3), Offset(w * 0.5, 0), linePaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.3), Offset(w * 0.5, 0), linePaint);

    // Outline
    final outlinePath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.85, h * 0.3)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.15, h * 0.3)
      ..close();
    final outlinePaint = Paint()
      ..color = color.withValues(alpha: shimmerOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(outlinePath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter old) =>
      old.shimmerOpacity != shimmerOpacity;
}