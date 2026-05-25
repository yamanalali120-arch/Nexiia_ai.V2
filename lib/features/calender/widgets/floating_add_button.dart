import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController breathCtrl;
  final Color pri;
  final Color priLight;

  const FloatingAddButton({
    super.key,
    required this.onTap,
    required this.breathCtrl,
    required this.pri,
    required this.priLight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: breathCtrl,
        builder: (_, child) {
          return Transform.scale(
            scale: 0.97 + breathCtrl.value * 0.03,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    pri.withOpacity(0.22),
                    pri.withOpacity(0.10),
                    Colors.white.withOpacity(0.04)
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                border: Border.all(color: pri.withOpacity(0.30), width: 0.5),
                boxShadow: [
                  BoxShadow(
                      color: pri.withOpacity(0.20),
                      blurRadius: 28,
                      spreadRadius: -4,
                      offset: const Offset(0, 6)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -8),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 20, color: priLight.withOpacity(0.90)),
                    const SizedBox(width: 8),
                    Text('Termin',
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: priLight.withOpacity(0.90),
                            letterSpacing: 0.2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
