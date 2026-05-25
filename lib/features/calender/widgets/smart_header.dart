import 'package:flutter/material.dart';
import '../models/nexiia_event.dart';
import 'liquid_glass.dart';
import '../../../core/theme/app_colors.dart';

class SmartHeader extends StatelessWidget {
  final int dayOffset;
  final List<NexiiaEvent> events;
  final int freeSlots;
  final AnimationController ambientCtrl;
  final Color pri;
  final Color priLight;
  final VoidCallback onPrev, onNext, onToday;

  const SmartHeader({
    super.key,
    required this.dayOffset,
    required this.events,
    required this.freeSlots,
    required this.ambientCtrl,
    required this.pri,
    required this.priLight,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().add(Duration(days: dayOffset));
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ];
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag'
    ];
    final dayLabel = dayOffset == 0
        ? 'Heute'
        : dayOffset == 1
            ? 'Morgen'
            : dayOffset == -1
                ? 'Gestern'
                : weekdays[now.weekday - 1];
    final aiCount = events.where((e) => e.isAiSuggested).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: ambientCtrl,
        builder: (_, child) => LiquidGlass(
          borderRadius: 24,
          blur: 55,
          fillOpacity: 0.06,
          borderOpacity: 0.12 + ambientCtrl.value * 0.06,
          glowColor: pri,
          glowOpacity: 0.08 + ambientCtrl.value * 0.05,
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: child!,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          '${now.day}. ${months[now.month - 1]}',
                          style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(dayLabel,
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: priLight,
                              letterSpacing: 0.2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      if (events.isNotEmpty)
                        _SummaryChip(
                            icon: Icons.event_rounded,
                            label: '${events.length} Termine',
                            color: pri),
                      if (aiCount > 0)
                        _SummaryChip(
                            icon: Icons.auto_awesome_rounded,
                            label: '$aiCount KI-Block${aiCount > 1 ? 's' : ''}',
                            color: priLight),
                      _SummaryChip(
                          icon: Icons.wb_sunny_outlined,
                          label: '$freeSlots freie Slots',
                          color: AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
                const SizedBox(width: 5),
                _NavBtn(icon: Icons.today_rounded, onTap: onToday),
                const SizedBox(width: 5),
                _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.20), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: 11,
        blur: 20,
        fillOpacity: 0.05,
        borderOpacity: 0.12,
        showSpecularHighlight: false,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
              child:
                  Icon(icon, size: 17, color: Colors.white.withOpacity(0.60))),
        ),
      ),
    );
  }
}
