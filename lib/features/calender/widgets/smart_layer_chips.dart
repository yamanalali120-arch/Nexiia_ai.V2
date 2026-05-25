import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/smart_layer.dart';

class SmartLayerChips extends StatelessWidget {
  final SmartLayer current;
  final ValueChanged<SmartLayer> onChange;
  const SmartLayerChips({
    super.key,
    required this.current,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: SmartLayer.values.map((m) {
          final sel = m == current;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChange(m);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: sel
                      ? m.color.withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: sel
                        ? m.color.withOpacity(0.30)
                        : Colors.white.withOpacity(0.07),
                    width: 0.5,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: m.color.withOpacity(0.08),
                              blurRadius: 12,
                              spreadRadius: -3)
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.icon,
                        size: 11,
                        color: sel ? m.color : Colors.white.withOpacity(0.32)),
                    const SizedBox(width: 5),
                    Text(
                      m.label,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? m.color : Colors.white.withOpacity(0.32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
