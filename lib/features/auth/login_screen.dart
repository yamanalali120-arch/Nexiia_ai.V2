// ════════════════════════════════════════════════════════════════
// NEXIIA — Login Screen
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
// ════════════════════════════════════════════════════════════════
// NEXIIA — Login Screen
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/widgets/premium_button.dart';
import '../../navigation/app_router.dart';
import 'widgets/auth_input_field.dart';
import 'widgets/social_login_buttons.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.cinematic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      Haptics.error();
      return;
    }

    setState(() => _isLoading = true);
    Haptics.buttonTap();

    try {
      final authService = AuthService();
      await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      Haptics.success();

      // Nach Login → Onboarding starten
      AppRouter.startOnboarding(context);
    } catch (e) {
      if (!mounted) return;
      Haptics.error();
      setState(() {
        _errorMessage = AuthErrorMapper.mapAny(e);
        _isLoading = false;
      });
    }
  }

  void _navigateToSignup() {
    Haptics.light();
    AppRouter.pushFadeSlide(context, const SignupScreen());
  }

  void _handleForgotPassword() {
    Haptics.light();
    // TODO: Implement forgot password flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundAuth,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: AppSpacing.screenH,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Wordmark ──
                      Text(
                        AppStrings.splashWordmark,
                        style: AppTypography.splashWordmark.copyWith(
                          fontSize: 22,
                          letterSpacing: 1.5,
                          color: AppColors.white50,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.huge),

                      // ── Headline ──
                      Text(
                        AppStrings.loginHeadline,
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.loginSubtext,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Error Message ──
                      if (_errorMessage != null) _buildErrorBanner(),

                      // ── Form ──
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthInputField(
                              controller: _emailController,
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusNode: _emailFocus,
                              nextFocusNode: _passwordFocus,
                              validator: Validators.email,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthInputField(
                              controller: _passwordController,
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              obscureText: true,
                              showToggleVisibility: true,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              focusNode: _passwordFocus,
                              validator: Validators.password,
                              enabled: !_isLoading,
                            ),
                          ],
                        ),
                      ),

                      // ── Forgot Password ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleForgotPassword,
                            child: Text(
                              AppStrings.loginForgotPassword,
                              style: AppTypography.link,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Login Button ──
                      PremiumButton(
                        label: AppStrings.loginButton,
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Social Login ──
                      SocialLoginButtons(
                        onApplePressed: _isLoading ? null : () {},
                        onGooglePressed: _isLoading ? null : () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Signup Link ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.loginNoAccount,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: _isLoading ? null : _navigateToSignup,
                            child: Text(
                              AppStrings.loginNoAccountAction,
                              style: AppTypography.link,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: AppSpacing.iconSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}