// ═══════════════════════════════════════════════════════════════════
// NEXIIA — Name Input Screen (Onboarding Step 2)
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/services/user_preferences.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/premium_button.dart';
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

  static const _animDuration = Duration(milliseconds: 400);
  static const _curve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();

    _textController.addListener(_onTextChanged);

    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _inputController = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startEntrance();
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _headlineController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _inputController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
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
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final valid = text.length >= 2;

    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });

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

    setState(() {
      _isSaving = true;
    });

    final name = _textController.text.trim();
    await UserPreferences.setUserName(name);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

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
                  _buildAnimated(
                    controller: _headlineController,
                    child: Text(
                      AppStrings.nameHeadline,
                      style: AppTypography.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  _buildAnimated(
                    controller: _inputController,
                    child: _buildInputField(),
                  ),
                  const Spacer(flex: 4),
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

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppColors.glassBorderFocused
              : AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        style: AppTypography.inputText,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _onContinue(),
        decoration: InputDecoration(
          hintText: AppStrings.nameHint,
          hintStyle: AppTypography.inputHint,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton() {
    final curvedAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: _curve,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: PremiumButton(
        label: AppStrings.nameContinue,
        onPressed: _isValid ? _onContinue : null,
        isLoading: _isSaving,
        isExpanded: true,
      ),
    );
  }
}