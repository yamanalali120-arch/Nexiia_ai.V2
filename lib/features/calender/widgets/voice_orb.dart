import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class VoiceOrb extends StatelessWidget {
  final bool isActive;
  final bool isListening;
  final AnimationController breathCtrl;
  final AnimationController waveCtrl;
  final VoidCallback onTap;
  final Color pri;
  final Color priLight;

  const VoiceOrb({
    super.key,
    required this.isActive,
    required this.isListening,
    required this.breathCtrl,
    required this.waveCtrl,
    required this.onTap,
    required this.pri,
    required this.priLight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([breathCtrl, waveCtrl]),
        builder: (_, __) {
          final breathe = isActive ? 0.94 + breathCtrl.value * 0.10 : 1.0;
          final wave = isListening ? waveCtrl.value : 0.0;

          return SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isListening)
                  ...List.generate(3, (i) {
                    final p =
                        ((wave - i * 0.33) % 1.0).clamp(0.0, 1.0).toDouble();
                    return Container(
                      width: 64 + p * 44,
                      height: 64 + p * 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: pri.withOpacity((1 - p) * 0.30), width: 1.0),
                      ),
                    );
                  }),
                if (isActive)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color:
                                pri.withOpacity(0.25 + breathCtrl.value * 0.18),
                            blurRadius: 30 + breathCtrl.value * 18,
                            spreadRadius: 2)
                      ],
                    ),
                  ),
                Transform.scale(
                  scale: breathe,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isActive
                                ? [
                                    pri.withOpacity(0.40),
                                    pri.withOpacity(0.14),
                                    Colors.white.withOpacity(0.04)
                                  ]
                                : [
                                    Colors.white.withOpacity(0.10),
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.02)
                                  ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          border: Border.all(
                            color: isActive
                                ? pri.withOpacity(0.50)
                                : Colors.white.withOpacity(0.16),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                                spreadRadius: -4)
                          ],
                        ),
                        child: Icon(
                          isListening
                              ? Icons.mic_rounded
                              : isActive
                                  ? Icons.stop_rounded
                                  : Icons.mic_none_rounded,
                          size: 22,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.50),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isListening)
                  Positioned(
                      bottom: 0,
                      child: _WaveformBar(
                          wave: wave, pri: pri, priLight: priLight)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WaveformBar extends StatelessWidget {
  final double wave;
  final Color pri;
  final Color priLight;
  const _WaveformBar(
      {required this.wave, required this.pri, required this.priLight});

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(12);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (i) {
        final h = (4.0 +
                math.sin((wave * math.pi * 2) + (i * math.pi / 5)) *
                    6.0 *
                    (0.5 + rng.nextDouble() * 0.5))
            .abs()
            .clamp(2.0, 12.0)
            .toDouble();
        return Container(
          width: 3,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: priLight.withOpacity(0.75),
            boxShadow: [BoxShadow(color: pri.withOpacity(0.20), blurRadius: 4)],
          ),
        );
      }),
    );
  }
}
