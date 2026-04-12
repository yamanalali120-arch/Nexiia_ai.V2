// ════════════════════════════════════════════════════════════════
// NEXIIA — Form Validators
// ════════════════════════════════════════════════════════════════
//
// Pure validation logic — no UI, no dependencies.
// Used by auth screens and any future forms.
//
// Architecture:
//   • Validators    → Return error string or null (Flutter convention)
//   • PasswordStrength → Enum with 4 levels + calculator
//
// Flutter form convention:
//   validator: (value) => Validators.email(value)
//   → Returns null if valid (no error)
//   → Returns error string if invalid
//
// All error messages come from AppStrings (imported by the caller),
// but we keep basic messages here as fallback so validators
// work independently.
// ════════════════════════════════════════════════════════════════

// ──────────────────────────────────────────
// PASSWORD STRENGTH ENUM
// ──────────────────────────────────────────

/// Four levels of password strength.
/// Used by the PasswordStrengthBar widget.
enum PasswordStrength {
  /// Less than 8 chars or very simple.
  weak,

  /// 8+ chars with some variety.
  fair,

  /// 10+ chars with good variety.
  strong,

  /// 12+ chars with excellent variety.
  veryStrong,
}

// ──────────────────────────────────────────
// VALIDATORS
// ──────────────────────────────────────────

class Validators {
  Validators._();

  // ════════════════════════════════════════
  // EMAIL
  // ════════════════════════════════════════

  /// Validates an email address.
  /// Returns error message or null if valid.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte gib deine E-Mail ein.';
    }

    final trimmed = value.trim();

    // RFC 5322 simplified — covers 99% of real emails.
    // Checks: something@something.something
    // Allows: dots, hyphens, underscores, plus signs in local part
    // Requires: at least 2 chars in TLD
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Bitte gib eine gültige E-Mail ein.';
    }

    return null;
  }

  // ════════════════════════════════════════
  // PASSWORD
  // ════════════════════════════════════════

  /// Validates a password.
  /// Returns error message or null if valid.
  ///
  /// Rules:
  ///   • Required
  ///   • Minimum 8 characters
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte gib ein Passwort ein.';
    }

    if (value.length < 8) {
      return 'Mindestens 8 Zeichen erforderlich.';
    }

    return null;
  }

  /// Validates that the confirm password matches the original.
  /// [original] is the password from the first field.
  /// Returns error message or null if matching.
  static String? passwordConfirm(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Bitte bestätige dein Passwort.';
    }

    if (value != original) {
      return 'Passwörter stimmen nicht überein.';
    }

    return null;
  }

  // ════════════════════════════════════════
  // NAME
  // ════════════════════════════════════════

  /// Validates a display name.
  /// Returns error message or null if valid.
  ///
  /// Rules:
  ///   • Required
  ///   • Minimum 2 characters
  ///   • Maximum 30 characters
  ///   • No leading/trailing whitespace (trimmed)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte gib deinen Namen ein.';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Mindestens 2 Zeichen erforderlich.';
    }

    if (trimmed.length > 30) {
      return 'Maximal 30 Zeichen erlaubt.';
    }

    return null;
  }

  // ════════════════════════════════════════
  // TERMS CHECKBOX
  // ════════════════════════════════════════

  /// Validates that terms have been accepted.
  /// Returns error message or null if accepted.
  static String? terms(bool accepted) {
    if (!accepted) {
      return 'Bitte akzeptiere die Nutzungsbedingungen.';
    }

    return null;
  }

  // ════════════════════════════════════════
  // PASSWORD STRENGTH CALCULATOR
  // ════════════════════════════════════════

  /// Calculates the strength of a password.
  /// Used by the PasswordStrengthBar widget on the signup screen.
  ///
  /// Scoring criteria (each adds 1 point):
  ///   • Length >= 8
  ///   • Length >= 12
  ///   • Contains lowercase letter
  ///   • Contains uppercase letter
  ///   • Contains digit
  ///   • Contains special character
  ///
  /// Mapping:
  ///   0–2 points → weak
  ///   3 points   → fair
  ///   4–5 points → strong
  ///   6 points   → veryStrong
  static PasswordStrength passwordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Length checks
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*()_+\-=$$$${};:"\\|,.<>/?`~]').hasMatch(password)) {
      score++;
    }

    // Map score to strength level
    if (score <= 2) return PasswordStrength.weak;
    if (score == 3) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// Returns the number of active bars (1–4) for the strength indicator.
  /// Useful for the visual PasswordStrengthBar widget.
  static int strengthBars(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.strong:
        return 3;
      case PasswordStrength.veryStrong:
        return 4;
    }
  }

  /// Returns the display label for a password strength level.
  /// Uses German labels matching AppStrings.
  static String strengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Schwach';
      case PasswordStrength.fair:
        return 'Mittel';
      case PasswordStrength.strong:
        return 'Stark';
      case PasswordStrength.veryStrong:
        return 'Sehr stark';
    }
  }
}