import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_strings.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Error Mapper
// ════════════════════════════════════════════════════════════════
//
// Translates technical errors into friendly German UI messages.
//
// Problem:
//   Supabase returns errors like "Invalid login credentials"
//   or "User already registered" — these are:
//   • In English
//   • Technical
//   • Not user-friendly
//   • Inconsistent across versions
//
// Solution:
//   This mapper catches all known error patterns and returns
//   clear, warm, understandable German messages.
//
// Architecture:
//   • AuthErrorMapper   → Handles Supabase Auth errors
//   • Maps AuthException messages + status codes
//   • Falls back to a generic friendly message
//   • Also handles network errors (SocketException)
//
// Usage:
//   try {
//     await supabase.auth.signInWithPassword(...);
//   } on AuthException catch (e) {
//     final message = AuthErrorMapper.map(e);
//     showError(message);
//   } catch (e) {
//     final message = AuthErrorMapper.mapGeneral(e);
//     showError(message);
//   }
// ════════════════════════════════════════════════════════════════

class AuthErrorMapper {
  AuthErrorMapper._();

  // ──────────────────────────────────────────
  // MAP AUTH EXCEPTION
  // ──────────────────────────────────────────
  // Handles Supabase AuthException specifically.
  // Checks both the message string and status code
  // for maximum coverage across Supabase versions.

  /// Maps a Supabase [AuthException] to a user-friendly German string.
  static String map(AuthException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // ── Invalid credentials ──────────────────
    // User typed wrong email or password.
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        message.contains('invalid email or password')) {
      return AppStrings.errorInvalidCredentials;
    }

    // ── User already exists ──────────────────
    // Email is already registered (signup attempt).
    if (message.contains('user already registered') ||
        message.contains('already been registered') ||
        message.contains('already exists')) {
      return AppStrings.errorUserAlreadyExists;
    }

    // ── Password too short ───────────────────
    // Supabase enforces minimum password length.
    if (message.contains('password') &&
        (message.contains('too short') ||
            message.contains('at least') ||
            message.contains('minimum'))) {
      return AppStrings.errorPasswordTooShort;
    }

    // ── Email not confirmed ──────────────────
    // User tries to login but hasn't clicked confirmation link.
    if (message.contains('email not confirmed') ||
        message.contains('not confirmed') ||
        message.contains('confirm your email')) {
      return AppStrings.errorEmailNotConfirmed;
    }

    // ── Rate limited ─────────────────────────
    // Too many requests in a short time.
    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('429') ||
        statusCode == '429') {
      return AppStrings.errorTooManyRequests;
    }

    // ── Invalid email format ─────────────────
    // Supabase rejected the email format.
    if (message.contains('invalid email') ||
        message.contains('unable to validate email')) {
      return AppStrings.validationEmailInvalid;
    }

    // ── Signup disabled ──────────────────────
    // Supabase project has signups disabled.
    if (message.contains('signups not allowed') ||
        message.contains('signup is disabled')) {
      return AppStrings.errorSignupFailed;
    }

    // ── Session / token errors ───────────────
    // Expired or invalid session.
    if (message.contains('session') ||
        message.contains('token') ||
        message.contains('expired') ||
        message.contains('refresh')) {
      return AppStrings.errorUnknown;
    }

    // ── Status code fallbacks ────────────────
    if (statusCode == '400') {
      return AppStrings.errorInvalidCredentials;
    }
    if (statusCode == '422') {
      return AppStrings.errorSignupFailed;
    }
    if (statusCode == '500' || statusCode == '503') {
      return AppStrings.errorUnknown;
    }

    // ── Unknown auth error ───────────────────
    return AppStrings.errorUnknown;
  }

  // ──────────────────────────────────────────
  // MAP GENERAL EXCEPTION
  // ──────────────────────────────────────────
  // Handles non-auth errors: network issues,
  // timeouts, unexpected exceptions.

  /// Maps any general [Exception] or [Error] to a user-friendly string.
  /// Use this in the outer catch block after AuthException.
  static String mapGeneral(dynamic error) {
    // ── Network errors ───────────────────────
    // Device is offline or server unreachable.
    if (error is SocketException) {
      return AppStrings.errorNoConnection;
    }

    // ── String check for network-related messages ──
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('no internet') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection timed out') ||
        errorString.contains('handshake')) {
      return AppStrings.errorNoConnection;
    }

    // ── Timeout ──────────────────────────────
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return AppStrings.errorNoConnection;
    }

    // ── Format / parsing errors ──────────────
    if (errorString.contains('format') ||
        errorString.contains('parsing') ||
        errorString.contains('type')) {
      return AppStrings.errorUnknown;
    }

    // ── Fallback ─────────────────────────────
    return AppStrings.errorUnknown;
  }

  // ──────────────────────────────────────────
  // CONVENIENCE — Single Entry Point
  // ──────────────────────────────────────────

  /// Maps any error to a user-friendly string.
  /// Automatically detects if it's an AuthException
  /// or a general error.
  ///
  /// Usage:
  /// ```dart
  /// try {
  ///   await authService.login(email, password);
  /// } catch (e) {
  ///   final message = AuthErrorMapper.mapAny(e);
  ///   // show message to user
  /// }
  /// ```
  static String mapAny(dynamic error) {
    if (error is AuthException) {
      return map(error);
    }
    return mapGeneral(error);
  }
}