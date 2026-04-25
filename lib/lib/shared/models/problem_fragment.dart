import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════
// Vec3 — Einfache 3D-Vektor-Klasse für Sphären-Projektion
// ═══════════════════════════════════════════════════════════════

class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);
  static const zero = Vec3(0, 0, 0);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);

  double get length => math.sqrt(x * x + y * y + z * z);

  Vec3 normalized() {
    final l = length;
    if (l == 0) return zero;
    return Vec3(x / l, y / l, z / l);
  }

  double distanceTo(Vec3 o) => (this - o).length;

  Vec3 rotateY(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Vec3(x * c + z * s, y, -x * s + z * c);
  }

  Vec3 rotateX(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Vec3(x, y * c - z * s, y * s + z * c);
  }

  static Vec3 lerp(Vec3 a, Vec3 b, double t) {
    return Vec3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FragmentType — Kategorien der Problemfragmente
// ═══════════════════════════════════════════════════════════════

enum FragmentType {
  core,
  cause,
  effect,
  solution,
  action,
  insight,
}

// ═══════════════════════════════════════════════════════════════
// ProblemFragment — Einzelner Knoten auf der Sphäre
// ═══════════════════════════════════════════════════════════════

class ProblemFragment {
  final String id;
  final String title;
  final String description;
  final FragmentType type;
  Vec3 position;
  Vec3 targetPosition;
  double opacity;
  double targetOpacity;

  ProblemFragment({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    this.position = Vec3.zero,
    this.targetPosition = Vec3.zero,
    this.opacity = 1.0,
    this.targetOpacity = 1.0,
  });

  String get typeLabel {
    switch (type) {
      case FragmentType.core:
        return 'Kernproblem';
      case FragmentType.cause:
        return 'Ursache';
      case FragmentType.effect:
        return 'Auswirkung';
      case FragmentType.solution:
        return 'Lösung';
      case FragmentType.action:
        return 'Maßnahme';
      case FragmentType.insight:
        return 'Erkenntnis';
    }
  }

  double get nodeSize {
    switch (type) {
      case FragmentType.core:
        return 7.0;
      case FragmentType.solution:
        return 5.5;
      case FragmentType.cause:
        return 5.0;
      case FragmentType.effect:
        return 4.5;
      case FragmentType.action:
        return 4.0;
      case FragmentType.insight:
        return 3.5;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// FragmentConnection — Verbindungslinie zwischen Knoten
// ═══════════════════════════════════════════════════════════════

class FragmentConnection {
  final String fromId;
  final String toId;
  const FragmentConnection(this.fromId, this.toId);
}

// ═══════════════════════════════════════════════════════════════
// Fibonacci-Sphere — Gleichverteilung auf Kugeloberfläche
// ═══════════════════════════════════════════════════════════════

List<Vec3> generateSpherePositions(int count, {double radius = 1.0}) {
  final positions = <Vec3>[];
  final goldenRatio = (1.0 + math.sqrt(5.0)) / 2.0;

  for (int i = 0; i < count; i++) {
    final theta = math.acos(1.0 - 2.0 * (i + 0.5) / count);
    final phi = 2.0 * math.pi * i / goldenRatio;

    positions.add(Vec3(
      radius * math.sin(theta) * math.cos(phi),
      radius * math.sin(theta) * math.sin(phi),
      radius * math.cos(theta),
    ));
  }
  return positions;
}