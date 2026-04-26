import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/onboarding/name_input_screen.dart';
import '../features/onboarding/atmosphere_screen.dart';
import '../features/onboarding/intro_sequence_screen.dart';
import '../features/onboarding/transition_screen.dart';
import '../features/onboarding/goal_selection_screen.dart';
import '../features/home/home_screen.dart';

class AppRouter {
  AppRouter._();

  // ═══════════════════════════════════════════
  // CORE NAVIGATION
  // ═══════════════════════════════════════════

  static void pushFade(BuildContext context, Widget screen) {
    Navigator.of(context).push(_fadeRoute(screen));
  }

  static void pushFadeSlide(BuildContext context, Widget screen) {
    Navigator.of(context).push(_fadeSlideRoute(screen));
  }

  static void replaceFade(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(_fadeRoute(screen));
  }

  static void replaceAllFade(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      _fadeRoute(screen),
      (route) => false,
    );
  }

  // ═══════════════════════════════════════════
  // AUTH ROUTES
  // ═══════════════════════════════════════════

  static void toLogin(BuildContext context) {
    replaceAllFade(context, const LoginScreen());
  }

  static void toSignup(BuildContext context) {
    pushFadeSlide(context, const SignupScreen());
  }

  // ═══════════════════════════════════════════
  // ONBOARDING FLOW
  // ═══════════════════════════════════════════

  static void startOnboarding(BuildContext context) {
    // New onboarding start: immediate intent selection -> direct value.
    replaceAllFade(context, const GoalSelectionScreen());
  }

  static void onboardingGreetingDone(BuildContext context) {
    replaceFade(context, const NameInputScreen());
  }

  static void onboardingNameDone(BuildContext context) {
    replaceFade(context, const AtmosphereScreen());
  }

  static void onboardingAtmosphereDone(BuildContext context) {
    replaceFade(context, const IntroSequenceScreen());
  }

  static void onboardingIntroDone(BuildContext context) {
    replaceFade(context, const TransitionScreen());
  }

  static void onboardingTransitionDone(BuildContext context) {
    replaceAllFade(context, const HomeScreen());
  }

  // ═══════════════════════════════════════════
  // HOME
  // ═══════════════════════════════════════════

  static void toHome(BuildContext context) {
    replaceAllFade(context, const HomeScreen());
  }

  // ═══════════════════════════════════════════
  // ROUTE BUILDERS
  // ═══════════════════════════════════════════

  static PageRouteBuilder _fadeRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _fadeSlideRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
