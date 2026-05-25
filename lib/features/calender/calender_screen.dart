import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/user_preferences.dart';

import 'models/nexiia_event.dart';
import 'models/smart_layer.dart';
import 'data/mock_events.dart';
import 'utils/calendar_time_utils.dart';
import 'widgets/ambient_background.dart';
import 'widgets/smart_header.dart';
import 'widgets/view_toggle.dart';
import 'widgets/smart_layer_chips.dart';
import 'widgets/day_view.dart';
import 'widgets/week_view.dart';
import 'widgets/floating_add_button.dart';
import 'widgets/voice_orb.dart';
import 'widgets/ai_card.dart';
import 'widgets/event_sheet.dart';

const List<Color> _kEventColors = [
  Color(0xFF818CF8),
  Color(0xFF60A5FA),
  Color(0xFF34D399),
  Color(0xFFF59E0B),
  Color(0xFFF87171),
  Color(0xFFA78BFA),
  Color(0xFFFB7DA8),
  Color(0xFF06B6D4),
];

class NexiiaHorizonCalendar extends StatefulWidget {
  const NexiiaHorizonCalendar({super.key});

  @override
  State<NexiiaHorizonCalendar> createState() => _NexiiaHorizonCalendarState();
}

class _NexiiaHorizonCalendarState extends State<NexiiaHorizonCalendar>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final AnimationController _orbBreathCtrl;
  late final AnimationController _voiceWaveCtrl;
  late final AnimationController _nowPulseCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _fabCtrl;
  late final ScrollController _dayScroll;

  late Color _pri;
  late Color _priLight;

  CalView _view = CalView.day;
  int _dayOffset = 0;
  SmartLayer _smartLayer = SmartLayer.focus;

  bool _voiceActive = false;
  bool _voiceListen = false;
  bool _showAiCard = false;

  String _aiCardText = '';
  NexiiaEvent? _selectedEvent;

  final List<NexiiaEvent> _events = buildMockEvents();
  int _nextId = 100;

  @override
  void initState() {
    super.initState();

    final atmo = UserPreferences.getAtmosphere();
    _pri = atmo.colors.primary;
    _priLight = atmo.colors.secondary;

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _orbBreathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _voiceWaveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _nowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dayScroll = ScrollController();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _entryCtrl.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _fabCtrl.forward();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 450), _scrollToNow);
    });
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _orbBreathCtrl.dispose();
    _voiceWaveCtrl.dispose();
    _nowPulseCtrl.dispose();
    _entryCtrl.dispose();
    _fabCtrl.dispose();
    _dayScroll.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!_dayScroll.hasClients) return;

    final now = TimeOfDay.now();
    final raw =
        (now.hour - kStart) * kHourH + now.minute * (kHourH / 60.0) - 180.0;

    _dayScroll.animateTo(
      raw.clamp(0.0, _dayScroll.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  void _switchView(CalView v) {
    if (v == _view) return;

    HapticFeedback.selectionClick();
    setState(() => _view = v);
  }

  void _toggleVoice() {
    HapticFeedback.mediumImpact();

    final next = !_voiceActive;

    setState(() {
      _voiceActive = next;
      _voiceListen = next;

      if (!next) {
        _showAiCard = false;
        _aiCardText = '';
      }
    });

    if (next) {
      _voiceWaveCtrl.repeat();

      Future.delayed(const Duration(milliseconds: 2800), () {
        if (!mounted || !_voiceActive) return;

        _voiceWaveCtrl.stop();

        setState(() {
          _voiceListen = false;
          _aiCardText =
              'Du hast um 15:00 Uhr einen freien Block. Soll ich dort eine 90-minütige Fokuszeit einplanen?';
          _showAiCard = true;
        });
      });
    } else {
      _voiceWaveCtrl.stop();
    }
  }

  List<NexiiaEvent> _eventsFor(int offset) {
    final t = DateTime.now().add(Duration(days: offset));

    return _events
        .where(
          (e) =>
              e.start.year == t.year &&
              e.start.month == t.month &&
              e.start.day == t.day,
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  List<NexiiaEvent> get _weekEvents {
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    final sun = mon.add(const Duration(days: 7));

    return _events
        .where((e) => !e.start.isBefore(mon) && e.start.isBefore(sun))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  int _freeSlots(List<NexiiaEvent> evts) {
    int f = 0;

    for (int h = 8; h < 20; h++) {
      if (!evts.any((e) => e.start.hour <= h && e.end.hour > h)) f++;
    }

    return (f / 2).round().clamp(1, 8);
  }

  void _addEvent({DateTime? presetStart}) {
    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day + _dayOffset);

    final start = presetStart ?? day.add(Duration(hours: now.hour + 1));
    final end = start.add(const Duration(hours: 1));

    final newEvt = NexiiaEvent(
      id: '${_nextId++}',
      title: '',
      start: start,
      end: end,
      color: _kEventColors[math.Random().nextInt(_kEventColors.length)],
    );

    setState(() {
      _events.add(newEvt);
      _selectedEvent = newEvt;
    });
  }

  void _deleteEvent(NexiiaEvent e) {
    HapticFeedback.heavyImpact();

    setState(() {
      _events.removeWhere((ev) => ev.id == e.id);
      _selectedEvent = null;
    });
  }

  void _duplicateEvent(NexiiaEvent e) {
    HapticFeedback.mediumImpact();

    setState(() {
      _events.add(
        NexiiaEvent(
          id: '${_nextId++}',
          title: e.title,
          subtitle: e.subtitle,
          location: e.location,
          start: e.start.add(const Duration(days: 1)),
          end: e.end.add(const Duration(days: 1)),
          color: e.color,
          energyLevel: e.energyLevel,
          isAiSuggested: false,
        ),
      );
    });
  }

  void _showCtxMenu(NexiiaEvent event, Offset pos) {
    HapticFeedback.mediumImpact();

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
      color: const Color(0xFF141420).withOpacity(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        _ctxItem('edit', Icons.edit_outlined, 'Bearbeiten', _priLight),
        _ctxItem('dup', Icons.copy_rounded, 'Duplizieren', _priLight),
        _ctxItem(
          'del',
          Icons.delete_outline_rounded,
          'Löschen',
          AppColors.error,
        ),
      ],
    ).then((v) {
      if (v == 'edit') {
        setState(() => _selectedEvent = event);
      } else if (v == 'dup') {
        _duplicateEvent(event);
      } else if (v == 'del') {
        _deleteEvent(event);
      }
    });
  }

  PopupMenuItem<String> _ctxItem(
    String val,
    IconData ic,
    String lbl,
    Color c,
  ) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(ic, size: 16, color: c),
          const SizedBox(width: 10),
          Text(
            lbl,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final todayEvts = _eventsFor(_dayOffset);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AmbientBackground(
            ctrl: _ambientCtrl,
            pri: _pri,
            priLight: _priLight,
          ),

          FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryCtrl,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _entryCtrl,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPad + 8),
                  SmartHeader(
                    dayOffset: _dayOffset,
                    events: todayEvts,
                    freeSlots: _freeSlots(todayEvts),
                    ambientCtrl: _ambientCtrl,
                    pri: _pri,
                    priLight: _priLight,
                    onPrev: () {
                      setState(() => _dayOffset--);
                      _postScroll();
                    },
                    onNext: () {
                      setState(() => _dayOffset++);
                      _postScroll();
                    },
                    onToday: () {
                      setState(() => _dayOffset = 0);
                      _postScroll();
                    },
                  ),
                  const SizedBox(height: 10),
                  ViewToggle(
                    current: _view,
                    onChange: _switchView,
                    pri: _pri,
                    priLight: _priLight,
                  ),
                  const SizedBox(height: 8),
                  SmartLayerChips(
                    current: _smartLayer,
                    onChange: (v) => setState(() => _smartLayer = v),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _view == CalView.day
                          ? DayView(
                              key: ValueKey('day_$_dayOffset'),
                              events: todayEvts,
                              scrollCtrl: _dayScroll,
                              nowPulseCtrl: _nowPulseCtrl,
                              smartLayer: _smartLayer,
                              dayOffset: _dayOffset,
                              bottomPad: botPad,
                              pri: _pri,
                              priLight: _priLight,
                              onEventTap: (e) {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedEvent = e);
                              },
                              onEventLongPress: _showCtxMenu,
                              onSlotTap: (h) => _addEvent(
                                presetStart: DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day + _dayOffset,
                                  h,
                                ),
                              ),
                            )
                          : WeekView(
                              key: const ValueKey('week'),
                              allEvents: _events,
                              weekEvents: _weekEvents,
                              selectedOffset: _dayOffset,
                              bottomPad: botPad,
                              pri: _pri,
                              priLight: _priLight,
                              onDayTap: (o) {
                                setState(() {
                                  _dayOffset = o;
                                  _switchView(CalView.day);
                                });
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: botPad + 110,
            left: 20,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabCtrl,
                curve: Curves.elasticOut,
              ),
              child: FloatingAddButton(
                onTap: () => _addEvent(),
                breathCtrl: _orbBreathCtrl,
                pri: _pri,
                priLight: _priLight,
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            bottom: _showAiCard ? botPad + 194.0 : -220.0,
            left: 20,
            right: 88,
            child: _showAiCard
                ? AiCard(
                    text: _aiCardText,
                    pri: _pri,
                    priLight: _priLight,
                    onAccept: () {
                      setState(() {
                        _showAiCard = false;
                        _voiceActive = false;

                        final today = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        );

                        _events.add(
                          NexiiaEvent(
                            id: '${_nextId++}',
                            title: 'Fokuszeit',
                            subtitle: 'Von Nexiia geplant',
                            start: today.add(const Duration(hours: 15)),
                            end: today.add(
                              const Duration(hours: 16, minutes: 30),
                            ),
                            color: _pri,
                            energyLevel: 0.8,
                            isAiSuggested: true,
                          ),
                        );
                      });
                    },
                    onDismiss: () => setState(() {
                      _showAiCard = false;
                      _voiceActive = false;
                    }),
                  )
                : const SizedBox.shrink(),
          ),

          Positioned(
            bottom: botPad + 110,
            right: 20,
            child: VoiceOrb(
              isActive: _voiceActive,
              isListening: _voiceListen,
              breathCtrl: _orbBreathCtrl,
              waveCtrl: _voiceWaveCtrl,
              onTap: _toggleVoice,
              pri: _pri,
              priLight: _priLight,
            ),
          ),

          if (_selectedEvent != null)
            EventSheet(
              event: _selectedEvent!,
              botPad: botPad,
              pri: _pri,
              priLight: _priLight,
              onClose: () {
                final selected = _selectedEvent;

                setState(() {
                  if (selected != null && selected.title.trim().isEmpty) {
                    _events.removeWhere((e) => e.id == selected.id);
                  }

                  _selectedEvent = null;
                });
              },
              onDelete: () => _deleteEvent(_selectedEvent!),
              onDuplicate: () {
                _duplicateEvent(_selectedEvent!);
                setState(() => _selectedEvent = null);
              },
              onSave: (t, s, l, start, end) {
                setState(() {
                  _selectedEvent!.title =
                      t.trim().isEmpty ? 'Neuer Termin' : t.trim();
                  _selectedEvent!.subtitle =
                      s.trim().isEmpty ? null : s.trim();
                  _selectedEvent!.location =
                      l.trim().isEmpty ? null : l.trim();
                  _selectedEvent!.start = start;
                  _selectedEvent!.end =
                      end.isAfter(start) ? end : start.add(const Duration(hours: 1));
                  _selectedEvent = null;
                });
              },
            ),
        ],
      ),
    );
  }

  void _postScroll() {
    if (_view == CalView.day) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
    }
  }
}