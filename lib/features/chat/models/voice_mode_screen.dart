import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexiia_app/core/theme/app_colors.dart';

class NexiiaVoiceModeScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onClose;

  const NexiiaVoiceModeScreen({
    super.key,
    required this.userName,
    required this.onClose,
  });

  @override
  State<NexiiaVoiceModeScreen> createState() => _NexiiaVoiceModeScreenState();
}

class _NexiiaVoiceModeScreenState extends State<NexiiaVoiceModeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbCtrl;
  late final AnimationController _breathCtrl;
  late final AnimationController _ringCtrl;
  bool _isListening = false;
  bool _aiSpeaking = false;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _breathCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      _ringCtrl.repeat();
      // Simulate AI response after listening
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !_isListening) return;
        setState(() {
          _isListening = false;
          _aiSpeaking = true;
        });
        _ringCtrl.stop();
        // Simulate AI speaking
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _aiSpeaking = false);
        });
      });
    } else {
      _ringCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background ──
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) => CustomPaint(
              painter: _VoiceBgPainter(
                t: _orbCtrl.value,
                isActive: _isListening || _aiSpeaking,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onClose,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.06),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.10),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.white.withOpacity(0.60),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Voice Mode',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.70),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Status Text ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isListening
                        ? 'Ich höre zu…'
                        : _aiSpeaking
                            ? 'Nexiia spricht…'
                            : 'Tippe zum Sprechen',
                    key: ValueKey('$_isListening$_aiSpeaking'),
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.50),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── AI Core Orb ──
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_orbCtrl, _breathCtrl, _ringCtrl]),
                    builder: (_, __) {
                      final breath = 0.94 + _breathCtrl.value * 0.06;
                      final orbRotation = _orbCtrl.value * math.pi * 2;
                      final isActive = _isListening || _aiSpeaking;
                      final ringVal = _isListening ? _ringCtrl.value : 0.0;

                      return SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ── Outer rings ──
                            if (isActive)
                              ...List.generate(3, (i) {
                                final delay = i * 0.33;
                                final p = ((ringVal - delay) % 1.0)
                                    .clamp(0.0, 1.0)
                                    .toDouble();
                                final size = 180.0 + p * 70;
                                return Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: (_aiSpeaking
                                              ? const Color(0xFF8B5CF6)
                                              : AppColors.electricBlue)
                                          .withOpacity((1 - p) * 0.25),
                                      width: 1.0,
                                    ),
                                  ),
                                );
                              }),

                            // ── Glow ──
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isActive
                                            ? (_aiSpeaking
                                                ? const Color(0xFF8B5CF6)
                                                : AppColors.electricBlue)
                                            : AppColors.electricBlue)
                                        .withOpacity(isActive ? 0.25 : 0.10),
                                    blurRadius: isActive ? 60 : 30,
                                    spreadRadius: isActive ? 10 : 0,
                                  ),
                                ],
                              ),
                            ),

                            // ── Main Orb ──
                            Transform.scale(
                              scale: breath,
                              child: Transform.rotate(
                                angle: orbRotation * 0.1,
                                child: ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 40, sigmaY: 40),
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          startAngle: orbRotation,
                                          colors: [
                                            AppColors.electricBlue.withOpacity(
                                                isActive ? 0.35 : 0.18),
                                            const Color(0xFF8B5CF6).withOpacity(
                                                isActive ? 0.25 : 0.10),
                                            const Color(0xFF06B6D4).withOpacity(
                                                isActive ? 0.30 : 0.12),
                                            AppColors.electricBlue.withOpacity(
                                                isActive ? 0.35 : 0.18),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                              isActive ? 0.20 : 0.10),
                                          width: 0.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            blurRadius: 30,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ── Inner core ──
                            Transform.scale(
                              scale: breath,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white
                                          .withOpacity(isActive ? 0.25 : 0.12),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  _isListening
                                      ? Icons.mic_rounded
                                      : _aiSpeaking
                                          ? Icons.volume_up_rounded
                                          : Icons.mic_none_rounded,
                                  size: 24,
                                  color: Colors.white
                                      .withOpacity(isActive ? 0.90 : 0.50),
                                ),
                              ),
                            ),

                            // ── Specular highlight ──
                            Positioned(
                              top: 45,
                              child: Transform.scale(
                                scale: breath,
                                child: Container(
                                  width: 80,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.25),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // ── Hint ──
                Text(
                  _isListening
                      ? 'Tippe erneut zum Stoppen'
                      : 'Tippe auf den Orb oder wische darüber',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.28),
                  ),
                ),

                const Spacer(),

                // ── Bottom Actions ──
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, botPad + 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _VoiceActionBtn(
                        icon: Icons.keyboard_rounded,
                        label: 'Text',
                        onTap: widget.onClose,
                      ),
                      _VoiceActionBtn(
                        icon: Icons.translate_rounded,
                        label: 'Sprache',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                      _VoiceActionBtn(
                        icon: Icons.more_horiz_rounded,
                        label: 'Mehr',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VOICE ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VoiceActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VOICE BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceBgPainter extends CustomPainter {
  final double t;
  final bool isActive;

  const _VoiceBgPainter({required this.t, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // Deep dark base
    canvas.drawRect(
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [Color(0xFF0A0E1E), Color(0xFF060818), Color(0xFF040610)],
          ).createShader(r));

    // Central glow
    final glowOpacity = isActive ? 0.18 + t * 0.08 : 0.08 + t * 0.04;
    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(0, 0.1 + math.sin(t * math.pi) * 0.05),
            radius: 0.6,
            colors: [
              AppColors.electricBlue.withOpacity(glowOpacity),
              Colors.transparent,
            ],
          ).createShader(r));

    // Violet glow
    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(0.3, -0.2),
            radius: 0.5,
            colors: [
              const Color(0xFF8B5CF6).withOpacity(isActive ? 0.08 : 0.04),
              Colors.transparent,
            ],
          ).createShader(r));
  }

  @override
  bool shouldRepaint(_VoiceBgPainter old) =>
      old.t != t || old.isActive != isActive;
}
