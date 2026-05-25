import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/nexiia_event.dart';
import '../models/smart_layer.dart';
import '../utils/calendar_time_utils.dart';
import 'calendar_helpers.dart';

class EventCard extends StatefulWidget {
  final NexiiaEvent event;
  final SmartLayer smartLayer;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails) onLongPress;

  const EventCard({
    super.key,
    required this.event,
    required this.smartLayer,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<EventCard> createState() => EventCardState();
}

class EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.965)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
    _glow = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.event.color;
    final isShort = widget.event.durationMinutes <= 30;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      onLongPressStart: (d) {
        _press.reverse();
        widget.onLongPress(d);
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Row(
          children: [
            // Color bar
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(color: c.withOpacity(0.55), blurRadius: 10)
                ],
              ),
            ),
            // Glass body
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              c.withOpacity(0.10 + _glow.value * 0.06),
                              Colors.white.withOpacity(0.06),
                              Colors.white.withOpacity(0.02),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          border: Border.all(
                            color: c.withOpacity(0.16 + _glow.value * 0.10),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.withOpacity(0.10 + _glow.value * 0.08),
                              blurRadius: 22,
                              spreadRadius: -5,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Specular
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 0.8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      c.withOpacity(0.25),
                                      Colors.white.withOpacity(0.30),
                                      c.withOpacity(0.25),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: isShort ? 3 : 8,
                              ),
                              child: LayoutBuilder(
                                builder: (ctx, box) {
                                  final ah = box.maxHeight;
                                  final showTime = ah > 26;
                                  final showSub =
                                      widget.event.subtitle != null && ah > 52;
                                  final showE =
                                      widget.event.energyLevel != null &&
                                          ah > 75;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.event.title,
                                              style: TextStyle(
                                                fontFamily: 'Satoshi',
                                                fontSize: isShort ? 11 : 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (widget.event.isAiSuggested) ...[
                                            const SizedBox(width: 4),
                                            const AiBadge(),
                                          ],
                                        ],
                                      ),
                                      if (showTime) ...[
                                        SizedBox(height: isShort ? 1 : 3),
                                        Text(
                                          '${fmtTime(widget.event.start)} — ${fmtTime(widget.event.end)}',
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: isShort ? 9 : 10,
                                            color:
                                                Colors.white.withOpacity(0.40),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                      if (showSub) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.event.subtitle!,
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: 11,
                                            color:
                                                Colors.white.withOpacity(0.30),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (showE) ...[
                                        const SizedBox(height: 7),
                                        EnergyBar(
                                          label: widget.smartLayer ==
                                                  SmartLayer.focus
                                              ? 'Fokus'
                                              : 'Energie',
                                          value: widget.event.energyLevel!,
                                          color: c,
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
