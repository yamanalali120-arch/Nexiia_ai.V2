import 'package:flutter/material.dart';
import '../models/nexiia_event.dart';
import 'liquid_glass.dart';
import '../utils/calendar_time_utils.dart';

class WeekView extends StatelessWidget {
  final List<NexiiaEvent> allEvents;
  final List<NexiiaEvent> weekEvents;
  final int selectedOffset;
  final double bottomPad;
  final Color pri;
  final Color priLight;
  final ValueChanged<int> onDayTap;

  const WeekView({
    super.key,
    required this.allEvents,
    required this.weekEvents,
    required this.selectedOffset,
    required this.bottomPad,
    required this.pri,
    required this.priLight,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _WeekStrip(
            allEvents: allEvents,
            selectedOffset: selectedOffset,
            onDayTap: onDayTap,
            pri: pri,
            priLight: priLight,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 120),
            child: LiquidGlass(
              borderRadius: 24,
              blur: 50,
              fillOpacity: 0.05,
              borderOpacity: 0.10,
              glowColor: pri,
              glowOpacity: 0.05,
              child: weekEvents.isEmpty ? _buildEmpty() : _buildList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 36, color: Colors.white.withOpacity(0.14)),
          const SizedBox(height: 12),
          Text('Keine Termine diese Woche',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.30))),
          const SizedBox(height: 6),
          Text('Tippe auf einen Tag für Details',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.18))),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text('DIESE WOCHE',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: Colors.white.withOpacity(0.32))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: pri.withOpacity(0.10),
                  border: Border.all(color: pri.withOpacity(0.22), width: 0.5),
                ),
                child: Text('${weekEvents.length} Termine',
                    style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: priLight)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            physics: const BouncingScrollPhysics(),
            itemCount: weekEvents.length,
            separatorBuilder: (_, __) => Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.0),
                ]),
              ),
            ),
            itemBuilder: (_, i) => _WeekRow(event: weekEvents[i]),
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<NexiiaEvent> allEvents;
  final int selectedOffset;
  final ValueChanged<int> onDayTap;
  final Color pri;
  final Color priLight;

  const _WeekStrip({
    required this.allEvents,
    required this.selectedOffset,
    required this.onDayTap,
    required this.pri,
    required this.priLight,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    return LiquidGlass(
      borderRadius: 20,
      blur: 40,
      fillOpacity: 0.04,
      borderOpacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: List.generate(7, (i) {
          final day = mon.add(Duration(days: i));
          final isToday = day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;
          final offset =
              day.difference(DateTime(now.year, now.month, now.day)).inDays;
          final isSel = offset == selectedOffset;
          final evts = allEvents
              .where((e) =>
                  e.start.year == day.year &&
                  e.start.month == day.month &&
                  e.start.day == day.day)
              .toList();

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(offset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: isSel
                      ? pri.withOpacity(0.14)
                      : isToday
                          ? Colors.white.withOpacity(0.04)
                          : Colors.transparent,
                  border: isSel
                      ? Border.all(color: pri.withOpacity(0.32), width: 0.5)
                      : null,
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                              color: pri.withOpacity(0.12),
                              blurRadius: 14,
                              spreadRadius: -3)
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(labels[i],
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: isSel
                                ? priLight
                                : Colors.white.withOpacity(0.34))),
                    const SizedBox(height: 5),
                    Text('${day.day}',
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 15,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isSel
                                ? priLight
                                : isToday
                                    ? Colors.white.withOpacity(0.90)
                                    : Colors.white.withOpacity(0.50))),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2,
                      runSpacing: 2,
                      children: evts
                          .take(3)
                          .map((e) => Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: e.color.withOpacity(0.80),
                                  boxShadow: [
                                    BoxShadow(
                                        color: e.color.withOpacity(0.40),
                                        blurRadius: 4)
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  final NexiiaEvent event;
  const _WeekRow({required this.event});

  @override
  Widget build(BuildContext context) {
    const wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: event.color.withOpacity(0.35), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    '${wd[(event.start.weekday - 1).clamp(0, 6)]} · ${fmtTime(event.start)} Uhr',
                    style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.35))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: event.color.withOpacity(0.08),
              border:
                  Border.all(color: event.color.withOpacity(0.20), width: 0.5),
            ),
            child: Text('${event.durationMinutes} min',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: event.color.withOpacity(0.75))),
          ),
        ],
      ),
    );
  }
}
