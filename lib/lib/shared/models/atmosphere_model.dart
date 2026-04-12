import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class AtmosphereModel {
  final Atmosphere type;
  final String id;
  final String name;
  final String subtitle;
  final AtmosphereColors colors;

  const AtmosphereModel({
    required this.type,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.colors,
  });

  // ─── Gradient Convenience Getters ────────────────────────────
  Gradient get backgroundGradient => AppGradients.atmosphereBackground(type);
  Gradient get accentGradient => AppGradients.atmosphereAccent(type);
  Gradient get glowGradient => AppGradients.atmosphereGlow(type);
  Gradient get cardPreviewGradient => AppGradients.atmosphereCardPreview(type);

  /// Whether this atmosphere uses the crystal glass style.
  /// Used by widgets to switch from blur-heavy to pure glass rendering.
  bool get isCrystalGlass => type == Atmosphere.crystalGlass;

  // ─── Statisches Register ─────────────────────────────────────
  static final List<AtmosphereModel> all = [
    AtmosphereModel(
      type: Atmosphere.techFuture,
      id: 'tech_future',
      name: AppStrings.atmosphereTechFuture,
      subtitle: AppStrings.atmosphereTechFutureDesc,
      colors: AtmosphereColors.techFuture,
    ),
    AtmosphereModel(
      type: Atmosphere.luxusPremium,
      id: 'luxus_premium',
      name: AppStrings.atmosphereLuxusPremium,
      subtitle: AppStrings.atmosphereLuxusPremiumDesc,
      colors: AtmosphereColors.luxusPremium,
    ),
    AtmosphereModel(
      type: Atmosphere.calm,
      id: 'calm',
      name: AppStrings.atmosphereCalm,
      subtitle: AppStrings.atmosphereCalmDesc,
      colors: AtmosphereColors.calm,
    ),
    AtmosphereModel(
      type: Atmosphere.spiritual,
      id: 'spiritual',
      name: AppStrings.atmosphereSpiritual,
      subtitle: AppStrings.atmosphereSpiritualDesc,
      colors: AtmosphereColors.spiritual,
    ),
    AtmosphereModel(
      type: Atmosphere.lifestyle,
      id: 'lifestyle',
      name: AppStrings.atmosphereLifestyle,
      subtitle: AppStrings.atmosphereLifestyleDesc,
      colors: AtmosphereColors.lifestyle,
    ),
    // ── 6. Crystal Glass ── NEW
    AtmosphereModel(
      type: Atmosphere.crystalGlass,
      id: 'crystal_glass',
      name: 'CRYSTAL',
      subtitle: 'Rein. Klar. Transparent.',
      colors: AtmosphereColors.crystalGlass,
    ),
  ];

  static AtmosphereModel fromType(Atmosphere type) {
    return all.firstWhere((atmosphere) => atmosphere.type == type);
  }

  static AtmosphereModel fromId(String id) {
    return all.firstWhere(
      (atmosphere) => atmosphere.id == id,
      orElse: () => defaultAtmosphere,
    );
  }

  static AtmosphereModel get defaultAtmosphere => all.first;
  static int get count => all.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AtmosphereModel &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AtmosphereModel($id)';
}