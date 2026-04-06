import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Haptic Feedback System
// ════════════════════════════════════════════════════════════════
//
// Provides consistent, premium haptic feedback throughout the app.
//
// Design rules:
//   • Haptics must feel subtle and refined, never aggressive
//   • Every important interaction gets a haptic response
//   • Intensity matches the importance of the action
//   • Light = frequent interactions (tabs, toggles)
//   • Medium = confirmations (button press, selection)
//   • Heavy = critical actions (delete, error)
//   • Selection = micro-feedback (scroll snaps, chips)
//
// Usage:
//   Haptics.light();          → Tab switch, toggle
//   Haptics.medium();         → Button tap, confirm
//   Haptics.heavy();          → Error, destructive action
//   Haptics.selection();      → Scroll snap, chip select
//   Haptics.success();        → Login success, save complete
//   Haptics.error();          → Validation failed, auth error
//
// Note: Haptics are no-ops on web and unsupported devices.
//       Flutter handles this gracefully — no try/catch needed.
// ════════════════════════════════════════════════════════════════

class Haptics {
  Haptics._();

  // ──────────────────────────────────────────
  // CORE — Direct Intensity Levels
  // ──────────────────────────────────────────

  /// Lightest feedback. Barely noticeable.
  /// Use for: tab switches, scroll snaps, hover states,
  /// toggling password visibility.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium feedback. Clearly noticeable.
  /// Use for: button presses, confirming a selection,
  /// atmosphere card tap, CTA interactions.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy feedback. Strong and deliberate.
  /// Use for: destructive actions, critical errors,
  /// long-press triggers, important state changes.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Micro selection feedback. Very subtle tick.
  /// Use for: chip selection, segmented control change,
  /// date picker scroll, list item selection.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  // ──────────────────────────────────────────
  // SEMANTIC — Named by Purpose
  // ──────────────────────────────────────────
  // These map to the core levels above but provide
  // clearer intent when reading the code.

  /// A button was tapped (primary CTA).
  /// Maps to: medium
  static Future<void> buttonTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Navigation tab was changed.
  /// Maps to: light
  static Future<void> tabChange() async {
    await HapticFeedback.lightImpact();
  }

  /// User selected an option (atmosphere, chip, toggle).
  /// Maps to: selection
  static Future<void> optionSelected() async {
    await HapticFeedback.selectionClick();
  }

  /// An action completed successfully.
  /// Login, signup, save, problem solved.
  /// Maps to: medium
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Something went wrong — validation error, auth failure.
  /// Maps to: heavy (single strong pulse = "attention!")
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Long press threshold reached (e.g. nav bar edit mode).
  /// Maps to: heavy
  static Future<void> longPress() async {
    await HapticFeedback.heavyImpact();
  }

  /// Transitional moment — screen change, onboarding step.
  /// Maps to: light
  static Future<void> transition() async {
    await HapticFeedback.lightImpact();
  }

  /// Keyboard opened or important focus change.
  /// Maps to: selection
  static Future<void> focus() async {
    await HapticFeedback.selectionClick();
  }
}