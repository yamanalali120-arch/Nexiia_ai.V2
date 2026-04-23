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
import 'widgets/auth_input_field.dart';
import 'widgets/password_strength_bar.dart';
import 'widgets/social_login_buttons.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ← NEU!

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _errorMessage;
  String _password = '';

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

    _passwordController.addListener(() {
      setState(() => _password = _passwordController.text);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _errorMessage = null);

    // Validate terms
    if (!_termsAccepted) {
      Haptics.error();
      setState(() => _errorMessage = AppStrings.validationTermsRequired);
      return;
    }

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      Haptics.error();
      return;
    }

    setState(() => _isLoading = true);
    Haptics.buttonTap();

    try {
      final authService = AuthService();
      await authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      Haptics.success();

      // Show success — user needs to confirm email
      _showSignupSuccess();
    } catch (e) {
      if (!mounted) return;
      Haptics.error();

      // ⬇️ DEBUG: Zeige echten Fehler in Console
      print('🔴🔴🔴 LOGIN ERROR: $e');
      print('🔴🔴🔴 ERROR TYPE: ${e.runtimeType}');
      if (e is AuthException) {
        print('🔴🔴🔴 MESSAGE: ${e.message}');
        print('🔴🔴🔴 STATUS CODE: ${e.statusCode}');
      }

      setState(() {
        // Temporär: echten Fehler anzeigen
        _errorMessage = 'DEBUG: $e';
        _isLoading = false;
      });
    }
  }

  void _showSignupSuccess() {
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.signupSuccessHeadline,
          style: AppTypography.headlineSmall,
        ),
        content: Text(
          AppStrings.signupSuccessSubtext,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to login
            },
            child: const Text(AppStrings.signupSuccessButton),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Haptics.light();
    Navigator.of(context).pop();
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
                        AppStrings.signupHeadline,
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.signupSubtext,
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
                            // Email
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

                            // Password
                            AuthInputField(
                              controller: _passwordController,
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              obscureText: true,
                              showToggleVisibility: true,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.next,
                              focusNode: _passwordFocus,
                              nextFocusNode: _confirmFocus,
                              validator: Validators.password,
                              enabled: !_isLoading,
                            ),

                            // Password Strength
                            PasswordStrengthBar(password: _password),
                            const SizedBox(height: AppSpacing.md),

                            // Confirm Password
                            AuthInputField(
                              controller: _confirmController,
                              label: AppStrings.passwordConfirmLabel,
                              hint: AppStrings.passwordConfirmHint,
                              obscureText: true,
                              showToggleVisibility: true,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              focusNode: _confirmFocus,
                              validator: (value) => Validators.passwordConfirm(
                                value,
                                _passwordController.text,
                              ),
                              enabled: !_isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Terms Checkbox ──
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Haptics.selection();
                                setState(
                                    () => _termsAccepted = !_termsAccepted);
                              },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                onChanged: _isLoading
                                    ? null
                                    : (value) {
                                        Haptics.selection();
                                        setState(() =>
                                            _termsAccepted = value ?? false);
                                      },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text.rich(
                                  TextSpan(
                                    text: AppStrings.signupTermsPrefix,
                                    style: AppTypography.bodySmall,
                                    children: [
                                      TextSpan(
                                        text: AppStrings.signupTermsLink,
                                        style: AppTypography.linkSmall,
                                      ),
                                      TextSpan(
                                        text: AppStrings.signupTermsMiddle,
                                      ),
                                      TextSpan(
                                        text: AppStrings.signupPrivacyLink,
                                        style: AppTypography.linkSmall,
                                      ),
                                      TextSpan(
                                        text: AppStrings.signupTermsSuffix,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Signup Button ──
                      PremiumButton(
                        label: AppStrings.signupButton,
                        onPressed: _isLoading ? null : _handleSignup,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Social Login ──
                      SocialLoginButtons(
                        onApplePressed: _isLoading ? null : () {},
                        onGooglePressed: _isLoading ? null : () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Login Link ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.signupHasAccount,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: _isLoading ? null : _navigateToLogin,
                            child: Text(
                              AppStrings.signupHasAccountAction,
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
