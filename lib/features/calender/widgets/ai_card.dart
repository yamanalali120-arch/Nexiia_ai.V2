import 'dart:ui';
import 'package:flutter/material.dart';
import 'calendar_helpers.dart';

class AiCard extends StatefulWidget {
  final String text;
  final Color pri;
  final Color priLight;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const AiCard({
    super.key,
    required this.text,
    required this.pri,
    required this.priLight,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  State<AiCard> createState() => AiCardState();
}

class AiCardState extends State<AiCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.pri.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02)
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border:
                    Border.all(color: widget.pri.withOpacity(0.25), width: 0.5),
                boxShadow: [
                  BoxShadow(
                      color: widget.pri.withOpacity(0.14),
                      blurRadius: 36,
                      offset: const Offset(0, 8),
                      spreadRadius: -6),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.priLight,
                          boxShadow: [
                            BoxShadow(
                                color: widget.pri.withOpacity(0.40),
                                blurRadius: 6)
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text('Nexiia AI',
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                              color: widget.priLight)),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Icon(Icons.close_rounded,
                            size: 15, color: Colors.white.withOpacity(0.35)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.text,
                      style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          color: Colors.white.withOpacity(0.80))),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: GlassButton(
                              label: 'Ablehnen',
                              color: Colors.white,
                              filled: false,
                              onTap: widget.onDismiss)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GlassButton(
                              label: 'Einplanen',
                              color: widget.pri,
                              filled: true,
                              onTap: widget.onAccept)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
