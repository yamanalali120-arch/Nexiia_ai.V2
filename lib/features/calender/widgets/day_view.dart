import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nexiia_event.dart';
import '../models/smart_layer.dart';
import '../utils/calendar_time_utils.dart';
import 'event_card.dart';
import '../../../core/theme/app_colors.dart';

class DayView extends StatelessWidget {
  final List<NexiiaEvent> events;
  final ScrollController scrollCtrl;
  final AnimationController nowPulseCtrl;
  final SmartLayer smartLayer;
  final int dayOffset;
  final double bottomPad;
  final Color pri;
  final Color priLight;
  final ValueChanged<NexiiaEvent> onEventTap;
  final void Function(NexiiaEvent, Offset) onEventLongPress;
  final ValueChanged<int> onSlotTap;

  const DayView({
    super.key,
    required this.events,
    required this.scrollCtrl,
    required this.nowPulseCtrl,
    required this.smartLayer,
    required this.dayOffset,
    required this.bottomPad,
    required this.pri,
    required this.priLight,
    required this.onEventTap,
    required this.onEventLongPress,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final nowPx = dayOffset == 0
        ? ((now.hour - kStart) * kHourH + now.minute * (kHourH / 60.0))
            .clamp(0.0, kTotal * kHourH)
            .toDouble()
        : -1.0;

    return SingleChildScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad + 120),
      child: SizedBox(
        height: kTotal * kHourH + 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(kTotal, (i) {
              final h = kStart + i;
              final has =
                  events.any((e) => e.start.hour <= h && e.end.hour > h);
              return Positioned(
                top: i * kHourH,
                left: 0,
                right: 0,
                child: _HourLine(
                  hour: h,
                  isFree: !has && h >= 7 && h <= 21,
                  onTap: has ? null : () => onSlotTap(h),
                  onLongPress: has
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onSlotTap(h);
                        },
                ),
              );
            }),
            ..._buildLayers(),
            ..._buildFree(),
            ...events.map((e) {
              final sm = (e.start.hour - kStart) * 60.0 + e.start.minute;
              final top = sm * (kHourH / 60);
              final hh = (e.durationMinutes * (kHourH / 60))
                  .clamp(38.0, double.infinity)
                  .toDouble();
              return Positioned(
                top: top,
                left: 54,
                right: 0,
                height: hh,
                child: EventCard(
                  event: e,
                  smartLayer: smartLayer,
                  onTap: () => onEventTap(e),
                  onLongPress: (d) => onEventLongPress(e, d.globalPosition),
                ),
              );
            }),
            if (nowPx >= 0)
              Positioned(
                top: nowPx - 1,
                left: 46,
                right: 0,
                child: AnimatedBuilder(
                  animation: nowPulseCtrl,
                  builder: (_, __) => _NowLine(
                      pulse: nowPulseCtrl.value, pri: pri, priLight: priLight),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLayers() {
    final layers = <({int sh, int eh, int? dur, Color c, String lbl})>[];
    if (smartLayer == SmartLayer.energy || smartLayer == SmartLayer.focus) {
      layers.add((sh: 8, eh: 11, dur: null, c: pri, lbl: '⚡ Höchste Energie'));
    }
    if (smartLayer == SmartLayer.energy ||
        smartLayer == SmartLayer.recovery) {
      layers.add((
        sh: 13,
        eh: 14,
        dur: null,
        c: AppColors.warning,
        lbl: '😴 Mittagstief'
      ));
    }
    if (smartLayer == SmartLayer.focus) {
      layers.add(
          (sh: 15, eh: 18, dur: null, c: priLight, lbl: '🎯 Fokus-Fenster'));
    }
    if (smartLayer == SmartLayer.recovery) {
      layers.add((
        sh: 20,
        eh: 22,
        dur: null,
        c: AppColors.success,
        lbl: '🌙 Recovery'
      ));
    }
    if (smartLayer == SmartLayer.buffer) {
      layers.addAll([
        (sh: 9, eh: 9, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
        (sh: 12, eh: 12, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
        (sh: 16, eh: 16, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
      ]);
    }
    return layers.map((l) {
      final sm = (l.sh - kStart) * 60;
      final dm = l.dur ?? ((l.eh - l.sh) * 60);
      final top = sm * (kHourH / 60);
      final height =
          (dm * (kHourH / 60)).clamp(20.0, double.infinity).toDouble();
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: l.c.withOpacity(0.04),
            border: Border(
                left: BorderSide(color: l.c.withOpacity(0.22), width: 2)),
          ),
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 56, top: 4),
          child: Text(l.lbl,
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: l.c.withOpacity(0.48))),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFree() {
    final hints = <Widget>[];
    for (int hr = kStart; hr < kEnd - 1; hr++) {
      if (hr < 8 || hr > 19) continue;
      if (events.any((e) => e.start.hour <= hr && e.end.hour > hr)) continue;
      hints.add(
        Positioned(
          top: (hr - kStart) * kHourH + 6,
          left: 54,
          right: 0,
          height: 24,
          child: GestureDetector(
            onTap: () => onSlotTap(hr),
            child: _FreeHint(
                label: '+ Termin · ${hr.toString().padLeft(2, '0')}:00'),
          ),
        ),
      );
    }
    return hints.take(4).toList();
  }
}

class _HourLine extends StatelessWidget {
  final int hour;
  final bool isFree;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _HourLine(
      {required this.hour, this.isFree = false, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final main = hour % 3 == 0;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: kHourH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 46,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10,
                      color: Colors.white.withOpacity(main ? 0.30 : 0.14),
                      letterSpacing: 0.2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.white.withOpacity(main ? 0.09 : 0.04),
                          Colors.white.withOpacity(main ? 0.04 : 0.015),
                        ]),
                      ),
                    ),
                    if (isFree)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                            child: Icon(Icons.add_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.06))),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowLine extends StatelessWidget {
  final double pulse;
  final Color pri;
  final Color priLight;
  const _NowLine(
      {required this.pulse, required this.pri, required this.priLight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: priLight,
            boxShadow: [
              BoxShadow(
                  color: pri.withOpacity(0.50 + pulse * 0.35),
                  blurRadius: 10 + pulse * 10)
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                priLight.withOpacity(0.80),
                pri.withOpacity(0.30),
                Colors.transparent
              ]),
              boxShadow: [
                BoxShadow(
                    color: pri.withOpacity(0.20 + pulse * 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 1))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FreeHint extends StatelessWidget {
  final String label;
  const _FreeHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.success.withOpacity(0.08),
        border:
            Border.all(color: AppColors.success.withOpacity(0.18), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline_rounded,
              size: 11, color: AppColors.success.withOpacity(0.65)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success.withOpacity(0.65))),
        ],
      ),
    );
  }
}
