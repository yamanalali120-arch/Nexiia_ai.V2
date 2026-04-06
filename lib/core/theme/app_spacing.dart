import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Spacing & Dimension System
// ════════════════════════════════════════════════════════════════
//
// Architecture:
//   • Spacing   → Consistent padding/margin scale (4px base)
//   • Radius    → Border radius tokens for all UI shapes
//   • Size      → Fixed component dimensions (icons, buttons, nav)
//   • Duration  → Animation timing tokens
//   • Curves    → Animation curve presets
//
// Design rules:
//   • All spacing is based on a 4px grid
//   • Generous whitespace — the app must breathe
//   • Radius follows a clear hierarchy:
//     small elements → small radius
//     large elements → large radius
//     full-width elements → extra large radius
//   • Animation timing is always between 150ms–400ms
//   • Never use magic numbers — always reference tokens
// ════════════════════════════════════════════════════════════════

class AppSpacing {
  AppSpacing._();

  // ──────────────────────────────────────────
  // SPACING — Padding & Margin Scale
  // ──────────────────────────────────────────
  // Based on a 4px grid system.
  // Naming: sp{size} for quick reference.
  //
  // Usage examples:
  //   padding: EdgeInsets.all(AppSpacing.md)
  //   SizedBox(height: AppSpacing.lg)
  //   EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding)

  /// 2px — Micro spacing. Between tightly coupled elements.
  static const double xxs = 2.0;

  /// 4px — Extra small. Icon-to-text gap, chip internal padding.
  static const double xs = 4.0;

  /// 8px — Small. Between related elements in a group.
  static const double sm = 8.0;

  /// 12px — Small-medium. List item internal spacing.
  static const double smd = 12.0;

  /// 16px — Medium. Standard padding, section internal spacing.
  static const double md = 16.0;

  /// 20px — Medium-large. Between distinct content blocks.
  static const double mlg = 20.0;

  /// 24px — Large. Between sections on a screen.
  static const double lg = 24.0;

  /// 32px — Extra large. Major section separation.
  static const double xl = 32.0;

  /// 40px — 2XL. Top-of-screen breathing room.
  static const double xxl = 40.0;

  /// 48px — 3XL. Hero spacing, large visual gaps.
  static const double xxxl = 48.0;

  /// 64px — 4XL. Cinematic spacing for onboarding/splash.
  static const double huge = 64.0;

  /// 80px — Maximum spacing. Extreme breathing room.
  static const double massive = 80.0;

  // ──────────────────────────────────────────
  // SCREEN — Standard Screen Padding
  // ──────────────────────────────────────────
  // Consistent horizontal padding for all screens.
  // 24px gives the content room to breathe while
  // maximizing readable width on mobile.

  /// Standard horizontal screen padding (24px).
  static const double screenPadding = 24.0;

  /// Symmetrical screen edge insets.
  static const EdgeInsets screenH = EdgeInsets.symmetric(
    horizontal: 24.0,
  );

  /// Full screen padding including top breathing room.
  static const EdgeInsets screenAll = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );

  // ──────────────────────────────────────────
  // RADIUS — Border Radius Tokens
  // ──────────────────────────────────────────
  // Clear hierarchy:
  //   xs  → Small interactive elements (chips, badges)
  //   sm  → Input fields, small cards
  //   md  → Standard cards, panels
  //   lg  → Large cards, hero elements
  //   xl  → Bottom sheets, modals
  //   pill → Buttons, nav bar, tabs (fully rounded)

  /// 6px — Chips, badges, small tags.
  static const double radiusXs = 6.0;

  /// 10px — Input fields, small interactive elements.
  static const double radiusSm = 10.0;

  /// 14px — Standard cards, list tiles.
  static const double radiusMd = 14.0;

  /// 18px — Large cards, hero sections.
  static const double radiusLg = 18.0;

  /// 24px — Bottom sheets, modals, large panels.
  static const double radiusXl = 24.0;

  /// 32px — Extra large. Special floating elements.
  static const double radiusXxl = 32.0;

  /// 999px — Pill shape. Buttons, nav bar, segmented controls.
  static const double radiusPill = 999.0;

  // Pre-built BorderRadius objects for convenience.

  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(radiusPill);

  // ──────────────────────────────────────────
  // SIZE — Fixed Component Dimensions
  // ──────────────────────────────────────────
  // Standard sizes for common UI components.
  // Ensures visual consistency across the app.

  /// Standard button height (56px — large, comfortable tap target).
  static const double buttonHeight = 56.0;

  /// Small button height (44px — secondary actions).
  static const double buttonHeightSmall = 44.0;

  /// Standard input field height (56px — matches button height).
  static const double inputHeight = 56.0;

  /// Bottom navigation bar height (64px).
  static const double navBarHeight = 64.0;

  /// Bottom navigation bar horizontal margin from screen edges.
  static const double navBarMargin = 16.0;

  /// Space reserved at bottom of screen for floating nav bar.
  /// navBarHeight + navBarMargin + bottom safe area padding.
  static const double navBarFootprint = 96.0;

  /// Standard icon size in navigation and actions.
  static const double iconMd = 24.0;

  /// Small icon size for inline elements.
  static const double iconSm = 20.0;

  /// Large icon size for feature highlights.
  static const double iconLg = 28.0;

  /// Touch target minimum (48px — accessibility standard).
  static const double touchTarget = 48.0;
}

// ════════════════════════════════════════════════════════════════
// ANIMATION — Timing & Curve Tokens
// ════════════════════════════════════════════════════════════════
//
// Consistent animation language across the entire app.
// Every transition, every micro-interaction uses these tokens.
//
// Design rules:
//   • fast  = immediate response feedback (taps, toggles)
//   • mid   = standard transitions (page changes, reveals)
//   • slow  = cinematic moments (onboarding, splash)
//   • Never exceed 500ms for UI interactions
//   • Always use ease-out or custom spring for natural feel
//   • ease-in is only for elements leaving the screen
// ════════════════════════════════════════════════════════════════

class AppDurations {
  AppDurations._();

  /// 100ms — Instant feedback. Opacity changes, color shifts.
  static const Duration fastest = Duration(milliseconds: 100);

  /// 150ms — Quick response. Button press, icon toggle.
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms — Standard micro-interaction. Tab switch, state change.
  static const Duration mid = Duration(milliseconds: 200);

  /// 300ms — Smooth transition. Card expand, slide in, page fade.
  static const Duration smooth = Duration(milliseconds: 300);

  /// 400ms — Deliberate motion. Modal appear, onboarding elements.
  static const Duration slow = Duration(milliseconds: 400);

  /// 500ms — Cinematic. Splash fade, greeting text, hero reveals.
  static const Duration cinematic = Duration(milliseconds: 500);

  /// 800ms — Extended cinematic. Staggered sequences.
  static const Duration cinematicLong = Duration(milliseconds: 800);

  /// 1100ms — Splash screen total duration.
  static const Duration splash = Duration(milliseconds: 1100);
}

class AppCurves {
  AppCurves._();

  /// Default ease-out for most UI transitions.
  /// Natural deceleration — fast start, gentle stop.
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Smooth ease for gentle reveals and fades.
  static const Curve gentle = Curves.easeOut;

  /// Springy feel for interactive elements (buttons, cards).
  /// Overshoots slightly for a tactile, alive feeling.
  static const Curve spring = Curves.easeOutBack;

  /// Elements entering the screen — slide/fade in.
  static const Curve enter = Curves.easeOutCubic;

  /// Elements leaving the screen — slide/fade out.
  static const Curve exit = Curves.easeInCubic;

  /// Linear for shimmer/loading animations.
  static const Curve linear = Curves.linear;
}