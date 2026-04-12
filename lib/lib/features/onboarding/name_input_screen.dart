// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Name Input Screen (Onboarding Step 2)
// Modern Input + Farbiger Weiter-Button + Auto-Keyboard
// ═══════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/services/user_preferences.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../navigation/app_router.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isValid = false;
  bool _isSaving = false;

  late final AnimationController _headlineController;
  late final AnimationController _inputController;
  late final AnimationController _buttonController;
  late final AnimationController _glowController;

  static const _curve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _headlineController.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _inputController.forward();

    // Tastatur geht SOFORT hoch
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _headlineController.dispose();
    _inputController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final valid = text.length >= 2;

    if (valid != _isValid) {
      setState(() => _isValid = valid);
      if (valid) {
        _buttonController.forward();
        Haptics.light();
      } else {
        _buttonController.reverse();
      }
    }
  }

  Future<void> _onContinue() async {
    if (!_isValid || _isSaving) return;
    Haptics.buttonTap();
    setState(() => _isSaving = true);

    final name = _textController.text.trim();
    await UserPreferences.setUserName(name);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Haptics.success();
    AppRouter.onboardingNameDone(context);
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
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Headline
                  _buildAnimated(
                    controller: _headlineController,
                    child: Text(
                      AppStrings.nameHeadline,
                      style: AppTypography.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // Modernes Input-Feld
                  _buildAnimated(
                    controller: _inputController,
                    child: _buildModernInputField(),
                  ),

                  const Spacer(flex: 4),

                  // Farbiger Weiter-Button
                  _buildAnimatedButton(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowVal = _glowController.value;
        final isFocused = _focusNode.hasFocus;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue
                          .withValues(alpha: 0.08 + glowVal * 0.06),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.electricBlue
                            .withValues(alpha: 0.25 + glowVal * 0.1)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isFocused ? 1.2 : 0.5,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: false, // Wir steuern das manuell
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onContinue(),
                  decoration: InputDecoration(
                    hintText: AppStrings.nameHint,
                    hintStyle: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.22),
                      letterSpacing: 0.2,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton() {
    final curvedAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, _) {
            final glowVal = _glowController.value;

            return GestureDetector(
              onTap: _isValid ? _onContinue : null,
              child: AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
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
                    boxShadow: _isValid
                        ? [
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
                          ]
                        : [],
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
                      Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
              ),
            );
          },
        ),
      ),
    );
  }
}