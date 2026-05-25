import 'package:flutter/material.dart';
import 'liquid_glass.dart';

enum CalView { day, week }

class ViewToggle extends StatelessWidget {
  final CalView current;
  final ValueChanged<CalView> onChange;
  final Color pri;
  final Color priLight;

  const ViewToggle({
    super.key,
    required this.current,
    required this.onChange,
    required this.pri,
    required this.priLight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LiquidGlass(
        borderRadius: 16,
        blur: 40,
        fillOpacity: 0.04,
        borderOpacity: 0.10,
        child: SizedBox(
          height: 42,
          child: Row(
            children: CalView.values.map((v) {
              final sel = v == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChange(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: sel ? pri.withOpacity(0.14) : Colors.transparent,
                      border: sel
                          ? Border.all(color: pri.withOpacity(0.30), width: 0.5)
                          : null,
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: pri.withOpacity(0.12),
                                  blurRadius: 16,
                                  spreadRadius: -3)
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      v == CalView.day ? 'Tag' : 'Woche',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? priLight : Colors.white.withOpacity(0.35),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
