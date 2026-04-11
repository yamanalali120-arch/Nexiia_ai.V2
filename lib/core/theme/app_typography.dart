import 'package:flutter/material.dart';
import 'app_colors.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Typography System
// ════════════════════════════════════════════════════════════════
//
// Font: Satoshi (local .otf assets)
//   → Modern geometric sans-serif
//   → Premium, clean, Apple-like precision
//   → Weights: Light 300, Regular 400, Medium 500, Bold 700, Black 900
//
// Fallback strategy:
//   → Primary: Satoshi (local)
//   → Fallback: System default (SF Pro on iOS, Roboto on Android)
//   → Flutter handles fallback automatically per missing glyph
//
// Architecture:
//   • _fontFamily  → Single source of truth for font name
//   • Headline     → Large display text (splash, hero, onboarding)
//   • Title        → Section headers, screen titles
//   • Body         → Readable content text
//   • Label        → Small UI text (buttons, tabs, chips, captions)
//   • Special      → One-off styles (splash logo, greeting, etc.)
//
// Design rules:
//   • Default text color is white95 (not pure white — softer)
//   • Secondary text uses white60
//   • Tertiary / hint text uses white40
//   • Letter spacing is tight on headlines (premium feel)
//   • Letter spacing is normal/wide on body (readability)
//   • Line height is generous (1.4–1.6 for body, 1.1–1.2 for headlines)
//   • Never use fontWeight directly — always use named styles
//   • To change the entire app font, change _fontFamily only
// ════════════════════════════════════════════════════════════════

class AppTypography {
  AppTypography._();

  // ──────────────────────────────────────────
  // FONT FAMILY — Single Source of Truth
  // ──────────────────────────────────────────
  // To switch the entire app's font, change this one value.
  // The name must match the "family" in pubspec.yaml exactly.

  static const String _fontFamily = 'Satoshi';

  // ──────────────────────────────────────────
  // HEADLINE — Large Display Text
  // ──────────────────────────────────────────
  // Used for: splash, hero sections, onboarding headlines,
  // screen titles, large emotional text.
  //
  // Tight letter spacing (-0.5 to -1.5) for premium density.
  // Short line height (1.1–1.2) for compact visual blocks.

  /// 36sp Black — Cinematic hero. Splash screen, main greeting.
  /// "Hallo, ich bin Nexiia."
  static const TextStyle headlineHero = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -1.2,
    color: AppColors.white95,
  );

  /// 28sp Bold — Primary headline. Screen titles, section heroes.
  /// "Willkommen zurück"
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
    color: AppColors.white95,
  );

  /// 24sp Bold — Secondary headline. Onboarding, feature intros.
  /// "Wie soll ich dich nennen?"
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.6,
    color: AppColors.white95,
  );

  /// 20sp Medium — Tertiary headline. Card titles, sub-sections.
  /// "Neues Problem lösen"
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.4,
    color: AppColors.white95,
  );

  // ──────────────────────────────────────────
  // TITLE — Section Headers & Screen Titles
  // ──────────────────────────────────────────
  // Used for: card headers, list section titles,
  // navigation titles, dialog headers.

  /// 18sp Medium — Primary section title.
  /// "Dein Tag auf einen Blick"
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.white95,
  );

  /// 16sp Medium — Secondary section title, card header.
  /// "Lösungswege"
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.2,
    color: AppColors.white95,
  );

  /// 14sp Medium — Small title, list item header.
  /// "14:00 Zahnarzt"
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.1,
    color: AppColors.white95,
  );

  // ──────────────────────────────────────────
  // BODY — Readable Content Text
  // ──────────────────────────────────────────
  // Used for: descriptions, explanations, chat messages,
  // onboarding text, form helper text, longer content.
  //
  // Normal letter spacing for readability.
  // Generous line height (1.5–1.6) for comfortable reading.

  /// 16sp Regular — Primary body text. Descriptions, content.
  /// "Ich helfe dir, Klarheit, Fokus und Struktur..."
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.0,
    color: AppColors.white80,
  );

  /// 14sp Regular — Standard body text. Most common text style.
  /// Chat messages, card descriptions, form instructions.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
    color: AppColors.white70,
  );

  /// 13sp Regular — Secondary body. Supporting info, subtexts.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.05,
    color: AppColors.white60,
  );

  // ──────────────────────────────────────────
  // LABEL — Small UI Text
  // ──────────────────────────────────────────
  // Used for: buttons, tabs, chips, input labels,
  // navigation labels, captions, badges, timestamps.

  /// 16sp Medium — Primary button text.
  /// "Anmelden", "Konto erstellen"
  static const TextStyle labelButton = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.1,
    color: AppColors.white,
  );

  /// 14sp Medium — Secondary button, tab label.
  /// "Passwort vergessen?", "Überspringen"
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.white80,
  );

  /// 13sp Medium — Input label (floating), chip text.
  /// "E-Mail", "Passwort", "Privat"
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.1,
    color: AppColors.white60,
  );

  /// 12sp Regular — Caption, timestamp, helper text.
  /// "Schwach", "Vor 2 Minuten"
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.2,
    color: AppColors.white50,
  );

  /// 11sp Medium — Micro label. Badges, counters.
  /// "3", "NEU"
  static const TextStyle labelMicro = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.3,
    color: AppColors.white50,
  );

  // ──────────────────────────────────────────
  // INPUT — Form-Specific Styles
  // ──────────────────────────────────────────
  // Dedicated styles for text input fields.
  // Ensures forms feel consistent and premium.

  /// Text the user types in an input field.
  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.white95,
  );

  /// Placeholder / hint text in an empty input field.
  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.white30,
  );

  /// Floating label above a focused input field.
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.2,
    color: AppColors.white50,
  );

  /// Error text below an input field.
  static const TextStyle inputError = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
    color: AppColors.error,
  );

  // ──────────────────────────────────────────
  // NAV — Bottom Navigation
  // ──────────────────────────────────────────

  /// Active tab label in bottom navigation.
  static const TextStyle navLabelActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.2,
    color: AppColors.electricBlue,
  );

  /// Inactive tab label (if visible).
  static const TextStyle navLabelInactive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0.2,
    color: AppColors.white40,
  );

  // ──────────────────────────────────────────
  // SPECIAL — Unique One-Off Styles
  // ──────────────────────────────────────────
  // For specific premium moments that don't fit
  // the standard hierarchy. Used sparingly.

  /// Splash screen — Nexiia wordmark.
  /// Large, bold, maximum presence.
  static const TextStyle splashWordmark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 2.0,
    color: AppColors.white,
  );

  /// Onboarding greeting line 1 — emotional, large.
  /// "Hallo, ich bin Nexiia."
  static const TextStyle greetingPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.white95,
  );

  /// Onboarding greeting line 2 — supporting.
  /// "Deine persönliche Assistenz."
  static const TextStyle greetingSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.white70,
  );

  /// Onboarding greeting line 3 — subtle, calm.
  /// "Ich helfe dir, Klarheit..."
  static const TextStyle greetingTertiary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.0,
    color: AppColors.white50,
  );

  /// Atmosphere card title.
  /// "TECH FUTURE", "CALM"
  static const TextStyle atmosphereTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.5,
    color: AppColors.white95,
  );

  /// Atmosphere card subtitle.
  /// "Präzise. Klar. Smart."
  static const TextStyle atmosphereSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.white60,
  );

  // ──────────────────────────────────────────
  // LINK — Tappable Text
  // ──────────────────────────────────────────

  /// Tappable link text.
  /// "Passwort vergessen?", "Jetzt registrieren"
  static const TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.electricBlue,
  );

  /// Small link / secondary tappable text.
  /// "Nutzungsbedingungen", "Datenschutz"
  static const TextStyle linkSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.electricBlue,
  );

  // ──────────────────────────────────────────
  // OR DIVIDER — Auth Screens
  // ──────────────────────────────────────────

  /// "oder" text between login methods.
  static const TextStyle dividerText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.white30,
  );
}