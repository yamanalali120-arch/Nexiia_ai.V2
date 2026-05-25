import 'package:flutter/material.dart';

enum SmartLayer { focus, energy, recovery, buffer, free }

extension SmartLayerX on SmartLayer {
  String get label {
    switch (this) {
      case SmartLayer.focus:
        return 'Fokus';
      case SmartLayer.energy:
        return 'Energie';
      case SmartLayer.recovery:
        return 'Recovery';
      case SmartLayer.buffer:
        return 'Puffer';
      case SmartLayer.free:
        return 'Freie Zeit';
    }
  }

  IconData get icon {
    switch (this) {
      case SmartLayer.focus:
        return Icons.center_focus_strong_rounded;
      case SmartLayer.energy:
        return Icons.bolt_rounded;
      case SmartLayer.recovery:
        return Icons.self_improvement_rounded;
      case SmartLayer.buffer:
        return Icons.hourglass_top_rounded;
      case SmartLayer.free:
        return Icons.wb_sunny_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SmartLayer.focus:
        return const Color(0xFF3478F6);
      case SmartLayer.energy:
        return const Color(0xFF60A5FA);
      case SmartLayer.recovery:
        return const Color(0xFF30A46C);
      case SmartLayer.buffer:
        return const Color(0xFFD4A853);
      case SmartLayer.free:
        return const Color(0xFF34D399);
    }
  }
}
