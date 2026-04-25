import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — Color System
// ════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ──────────────────────────────────────────
  // BASE — Dark Surface Palette
  // ──────────────────────────────────────────
  static const Color background = Color(0xFF08080F);
  static const Color surface = Color(0xFF111118);
  static const Color surfaceElevated = Color(0xFF181822);
  static const Color surfaceHighest = Color(0xFF22222E);

  // ──────────────────────────────────────────
  // NEUTRAL — White Opacity Scale
  // ──────────────────────────────────────────
  static const Color white   = Color(0xFFFFFFFF);
  static const Color white95 = Color(0xF2FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white08 = Color(0x14FFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);
  static const Color white03 = Color(0x08FFFFFF);

  // ──────────────────────────────────────────
  // PRIMARY ACCENT — Electric Blue
  // ──────────────────────────────────────────
  static const Color electricBlue = Color(0xFF3478F6);
  static const Color electricBlueLight = Color(0xFF5A9CFF);
  static const Color electricBlueDark = Color(0xFF1B5CD4);
  static const Color electricBlueMuted = Color(0xFF152A52);
  static const Color electricBlueGlow = Color(0x403478F6);

  // ──────────────────────────────────────────
  // PREMIUM ACCENT — Gold
  // ──────────────────────────────────────────
  static const Color gold = Color(0xFFD4A853);
  static const Color goldMuted = Color(0xFF6B5430);
  static const Color goldGlow = Color(0x40D4A853);

  // ──────────────────────────────────────────
  // SEMANTIC
  // ──────────────────────────────────────────
  static const Color error = Color(0xFFE5484D);
  static const Color errorSurface = Color(0x1AE5484D);
  static const Color success = Color(0xFF30A46C);
  static const Color successSurface = Color(0x1A30A46C);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSurface = Color(0x1AF5A623);

  // ──────────────────────────────────────────
  // PASSWORD STRENGTH
  // ──────────────────────────────────────────
  static const Color strengthWeak = Color(0xFFE5484D);
  static const Color strengthFair = Color(0xFFF5A623);
  static const Color strengthStrong = Color(0xFF2DB08A);
  static const Color strengthVeryStrong = Color(0xFF30A46C);

  // ──────────────────────────────────────────
  // GLASS
  // ──────────────────────────────────────────
  static const Color glassBackground = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x12FFFFFF);
  static const Color glassBorderFocused = Color(0x26FFFFFF);
  static const Color glassShadow = Color(0x40000000);
}

// ════════════════════════════════════════════════════════════════
// ATMOSPHERE — Dynamic Theme Color Sets  (6 modes)
// ════════════════════════════════════════════════════════════════

enum Atmosphere {
  techFuture,
  luxusPremium,
  calm,
  spiritual,
  lifestyle,
  crystalGlass,   // ← NEW
}

class AtmosphereColors {
  final Color primary;
  final Color secondary;
  final Color glow;
  final Color surfaceTint;

  const AtmosphereColors({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.surfaceTint,
  });

  // ── Tech Future ─────────────────────────
  static const techFuture = AtmosphereColors(
    primary: Color(0xFF3478F6),
    secondary: Color(0xFF06B6D4),
    glow: Color(0x3006B6D4),
    surfaceTint: Color(0x0806B6D4),
  );

  // ── Luxus Premium ──────────────────────
  static const luxusPremium = AtmosphereColors(
    primary: Color(0xFFD4A853),
    secondary: Color(0xFFE8C87A),
    glow: Color(0x30D4A853),
    surfaceTint: Color(0x08D4A853),
  );

  // ── Calm ───────────────────────────────
  static const calm = AtmosphereColors(
    primary: Color(0xFF2DB08A),
    secondary: Color(0xFF5ECEB0),
    glow: Color(0x302DB08A),
    surfaceTint: Color(0x082DB08A),
  );

  // ── Spiritual ──────────────────────────
  static const spiritual = AtmosphereColors(
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFFA78BFA),
    glow: Color(0x308B5CF6),
    surfaceTint: Color(0x088B5CF6),
  );

  // ── Lifestyle ──────────────────────────
  static const lifestyle = AtmosphereColors(
    primary: Color(0xFFF472B6),
    secondary: Color(0xFFFB7DA8),
    glow: Color(0x30F472B6),
    surfaceTint: Color(0x08F472B6),
  );

  // ── Crystal Glass ──────────────────────  ← NEW
  // Pure White + Silver — Transparent, clean, pristine.
  // This atmosphere uses near-white tones for a
  // true glass/crystal feel with rainbow refractions.
  static const crystalGlass = AtmosphereColors(
    primary: Color(0xFFE8ECF4),     // Cool white-silver
    secondary: Color(0xFFC4D0E0),   // Soft silver-blue
    glow: Color(0x20FFFFFF),        // White glow
    surfaceTint: Color(0x06FFFFFF), // Nearly invisible tint
  );

  static AtmosphereColors fromType(Atmosphere type) {
    switch (type) {
      case Atmosphere.techFuture:
        return techFuture;
      case Atmosphere.luxusPremium:
        return luxusPremium;
      case Atmosphere.calm:
        return calm;
      case Atmosphere.spiritual:
        return spiritual;
      case Atmosphere.lifestyle:
        return lifestyle;
      case Atmosphere.crystalGlass:
        return crystalGlass;
    }
  }
}