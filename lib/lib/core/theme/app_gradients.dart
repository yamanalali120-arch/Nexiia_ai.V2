import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // ═══════════════════════════════════════════
  // BACKGROUND GRADIENTS
  // ═══════════════════════════════════════════

  static const defaultBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      Color(0xFF0A0A14),
      AppColors.background,
    ],
  );

  // Neue Namen
  static const auth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0A16),
      AppColors.background,
      Color(0xFF0D0D1A),
    ],
  );

  static const splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0C0C18),
      AppColors.background,
      Color(0xFF06060C),
    ],
  );

  static const onboarding = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      Color(0xFF0A0A16),
      AppColors.background,
    ],
  );

  // Alte Namen — Aliase damit bestehende Screens funktionieren
  static const backgroundAuth = auth;
  static const backgroundSplash = splash;
  static const backgroundOnboarding = onboarding;
  static const backgroundDefault = defaultBackground;

  // ═══════════════════════════════════════════
  // SURFACE GRADIENTS
  // ═══════════════════════════════════════════

  static const glassSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0FFFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  static const glassElevated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  static const inputSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0FFFFFFF),
      Color(0x08FFFFFF),
    ],
  );

  // ═══════════════════════════════════════════
  // DIVIDER / FADE
  // ═══════════════════════════════════════════

  static const dividerFade = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x14FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  // ═══════════════════════════════════════════
  // BUTTON GRADIENTS
  // ═══════════════════════════════════════════

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A90F8),
      AppColors.electricBlue,
      Color(0xFF2060D0),
    ],
  );

  static const primaryPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3A7DE8),
      Color(0xFF2868D8),
      Color(0xFF1850C0),
    ],
  );

  static const primaryDisabled = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4D3478F6),
      Color(0x263478F6),
    ],
  );

  static const secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x08FFFFFF),
    ],
  );

  // ═══════════════════════════════════════════
  // GLOW GRADIENTS (Radial)
  // ═══════════════════════════════════════════

  static const glowBlue = RadialGradient(
    colors: [
      Color(0x593478F6),
      Color(0x003478F6),
    ],
  );

  static const glowSplash = RadialGradient(
    colors: [
      Color(0x403478F6),
      Color(0x003478F6),
    ],
  );

  static const glowGold = RadialGradient(
    colors: [
      Color(0x4DD4A853),
      Color(0x00D4A853),
    ],
  );

  static const glowAmbientTop = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.8,
    colors: [
      Color(0x243478F6),
      Color(0x003478F6),
    ],
  );

  // ═══════════════════════════════════════════
  // ATMOSPHERE GRADIENTS
  // ═══════════════════════════════════════════

  static LinearGradient atmosphereBackground(Atmosphere atmosphere) {
    final c = AtmosphereColors.fromType(atmosphere);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        c.primary.withValues(alpha: 0.18),
        AppColors.background,
        c.secondary.withValues(alpha: 0.10),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient atmosphereAccent(Atmosphere atmosphere) {
    final c = AtmosphereColors.fromType(atmosphere);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [c.primary, c.secondary],
    );
  }

  static RadialGradient atmosphereGlow(Atmosphere atmosphere) {
    final c = AtmosphereColors.fromType(atmosphere);
    return RadialGradient(
      colors: [
        c.glow.withValues(alpha: 0.35),
        c.glow.withValues(alpha: 0.0),
      ],
    );
  }

  static LinearGradient atmosphereCardPreview(Atmosphere atmosphere) {
    final c = AtmosphereColors.fromType(atmosphere);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        c.primary.withValues(alpha: 0.30),
        c.secondary.withValues(alpha: 0.18),
        c.surfaceTint.withValues(alpha: 0.06),
      ],
    );
  }
}