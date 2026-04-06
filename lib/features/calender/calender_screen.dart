// ═══════════════════════════════════════════════════════════════════════════════
// NEXIIA HORIZON CALENDAR — Liquid Glass Edition v5
// Datei: lib/features/calender/calendar_screen.dart
// iOS 26 Liquid Glass · Transparent · Floating · Animated · Editable
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ENUMS & CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

enum _CalView { day, week }
enum _SmartLayer { focus, energy, recovery, buffer, free }

const double _kHourH = 76.0;
const int _kStart = 6;
const int _kEnd = 24;
const int _kTotal = _kEnd - _kStart;

extension _SmartLayerX on _SmartLayer {
  String get label {
    switch (this) {
      case _SmartLayer.focus: return 'Fokus';
      case _SmartLayer.energy: return 'Energie';
      case _SmartLayer.recovery: return 'Recovery';
      case _SmartLayer.buffer: return 'Puffer';
      case _SmartLayer.free: return 'Freie Zeit';
    }
  }

  IconData get icon {
    switch (this) {
      case _SmartLayer.focus: return Icons.center_focus_strong_rounded;
      case _SmartLayer.energy: return Icons.bolt_rounded;
      case _SmartLayer.recovery: return Icons.self_improvement_rounded;
      case _SmartLayer.buffer: return Icons.hourglass_top_rounded;
      case _SmartLayer.free: return Icons.wb_sunny_outlined;
    }
  }

  Color get color {
    switch (this) {
      case _SmartLayer.focus: return const Color(0xFF3478F6);
      case _SmartLayer.energy: return const Color(0xFF60A5FA);
      case _SmartLayer.recovery: return const Color(0xFF30A46C);
      case _SmartLayer.buffer: return const Color(0xFFD4A853);
      case _SmartLayer.free: return const Color(0xFF34D399);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class NexiiaEvent {
  final String id;
  String title;
  String? subtitle;
  String? location;
  DateTime start;
  DateTime end;
  Color color;
  double? energyLevel;
  bool isAiSuggested;

  NexiiaEvent({
    required this.id,
    required this.title,
    this.subtitle,
    this.location,
    required this.start,
    required this.end,
    required this.color,
    this.energyLevel,
    this.isAiSuggested = false,
  });

  int get durationMinutes => end.difference(start).inMinutes;

  NexiiaEvent copy() => NexiiaEvent(
        id: id, title: title, subtitle: subtitle, location: location,
        start: start, end: end, color: color,
        energyLevel: energyLevel, isAiSuggested: isAiSuggested,
      );
}

List<NexiiaEvent> _buildMockEvents() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    NexiiaEvent(id: '1', title: 'Team Standup', subtitle: 'Mit Felix & Sarah',
      location: 'Zoom', start: today.add(const Duration(hours: 9)),
      end: today.add(const Duration(hours: 9, minutes: 30)), color: const Color(0xFF818CF8)),
    NexiiaEvent(id: '2', title: 'Deep Work – Nexiia UI', subtitle: 'Kein Slack, kein Mail',
      start: today.add(const Duration(hours: 10)), end: today.add(const Duration(hours: 12)),
      color: const Color(0xFF60A5FA), energyLevel: 0.85),
    NexiiaEvent(id: '3', title: 'Mittagspause',
      start: today.add(const Duration(hours: 12)), end: today.add(const Duration(hours: 13)),
      color: const Color(0xFF34D399)),
    NexiiaEvent(id: '4', title: 'Investor Call', subtitle: 'Series A Vorbereitung',
      location: 'Konferenzraum B', start: today.add(const Duration(hours: 14)),
      end: today.add(const Duration(hours: 15)), color: const Color(0xFFF59E0B), energyLevel: 0.95),
    NexiiaEvent(id: '5', title: 'Fokusblock · KI', subtitle: 'Von Nexiia vorgeschlagen',
      start: today.add(const Duration(hours: 16)),
      end: today.add(const Duration(hours: 17, minutes: 30)),
      color: const Color(0xFF60A5FA), energyLevel: 0.7, isAiSuggested: true),
    NexiiaEvent(id: '6', title: 'Design Review', subtitle: 'Figma Walkthrough',
      start: today.add(const Duration(days: 1, hours: 10)),
      end: today.add(const Duration(days: 1, hours: 11)), color: const Color(0xFFA78BFA)),
    NexiiaEvent(id: '7', title: 'Sprint Planning',
      start: today.add(const Duration(days: 2, hours: 9)),
      end: today.add(const Duration(days: 2, hours: 11)), color: const Color(0xFFF87171)),
    NexiiaEvent(id: '8', title: 'User Research',
      start: today.add(const Duration(days: 3, hours: 14)),
      end: today.add(const Duration(days: 3, hours: 16)), color: const Color(0xFF34D399)),
    NexiiaEvent(id: '9', title: 'Weekly Review',
      start: today.add(const Duration(days: 4, hours: 17)),
      end: today.add(const Duration(days: 4, hours: 18)),
      color: const Color(0xFF60A5FA), energyLevel: 0.5),
    NexiiaEvent(id: '10', title: 'Boxtraining',
      start: today.add(const Duration(days: 3, hours: 18)),
      end: today.add(const Duration(days: 3, hours: 19)), color: const Color(0xFFF87171)),
  ];
}

String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

const List<Color> _kEventColors = [
  Color(0xFF818CF8), Color(0xFF60A5FA), Color(0xFF34D399), Color(0xFFF59E0B),
  Color(0xFFF87171), Color(0xFFA78BFA), Color(0xFFFB7DA8), Color(0xFF06B6D4),
];

// ═══════════════════════════════════════════════════════════════════════════════
// LIQUID GLASS — Reusable iOS 26 Base Widget
// ═══════════════════════════════════════════════════════════════════════════════

class _LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blur;
  final double fillOpacity;
  final double borderOpacity;
  final Color? glowColor;
  final double glowOpacity;
  final bool showSpecularHighlight;

  const _LiquidGlass({
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.blur = 50,
    this.fillOpacity = 0.08,
    this.borderOpacity = 0.18,
    this.glowColor,
    this.glowOpacity = 0.08,
    this.showSpecularHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            // iOS 26 Glass Gradient: brighter at top, fades down
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(fillOpacity + 0.07),
                Colors.white.withOpacity(fillOpacity),
                Colors.white.withOpacity(fillOpacity * 0.4),
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 0.5,
            ),
            boxShadow: [
              // Outer depth
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 32,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
              // Color glow
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withOpacity(glowOpacity),
                  blurRadius: 44,
                  spreadRadius: -6,
                  offset: const Offset(0, 6),
                ),
              // Inner top light
              BoxShadow(
                color: Colors.white.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, -1),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Specular highlight — thin light line at top edge
              if (showSpecularHighlight)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.40),
                          Colors.white.withOpacity(0.50),
                          Colors.white.withOpacity(0.40),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

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

  _CalView _view = _CalView.day;
  int _dayOffset = 0;
  _SmartLayer _smartLayer = _SmartLayer.focus;
  bool _voiceActive = false;
  bool _voiceListen = false;
  bool _showAiCard = false;
  String _aiCardText = '';
  NexiiaEvent? _selectedEvent;
  final List<NexiiaEvent> _events = _buildMockEvents();
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _orbBreathCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _voiceWaveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _nowPulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
    _ambientCtrl.dispose(); _orbBreathCtrl.dispose(); _voiceWaveCtrl.dispose();
    _nowPulseCtrl.dispose(); _entryCtrl.dispose(); _fabCtrl.dispose();
    _dayScroll.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!_dayScroll.hasClients) return;
    final now = TimeOfDay.now();
    final raw = (now.hour - _kStart) * _kHourH + now.minute * (_kHourH / 60.0) - 180.0;
    _dayScroll.animateTo(
      raw.clamp(0.0, _dayScroll.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic,
    );
  }

  void _switchView(_CalView v) {
    if (v == _view) return;
    HapticFeedback.selectionClick();
    setState(() => _view = v);
  }

  void _toggleVoice() {
    HapticFeedback.mediumImpact();
    final next = !_voiceActive;
    setState(() {
      _voiceActive = next; _voiceListen = next;
      if (!next) { _showAiCard = false; _aiCardText = ''; }
    });
    if (next) {
      _voiceWaveCtrl.repeat();
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (!mounted || !_voiceActive) return;
        _voiceWaveCtrl.stop();
        setState(() {
          _voiceListen = false;
          _aiCardText = 'Du hast um 15:00 Uhr einen freien Block. '
              'Soll ich dort eine 90-minütige Fokuszeit einplanen?';
          _showAiCard = true;
        });
      });
    } else {
      _voiceWaveCtrl.stop();
    }
  }

  List<NexiiaEvent> _eventsFor(int offset) {
    final t = DateTime.now().add(Duration(days: offset));
    return _events.where((e) =>
      e.start.year == t.year && e.start.month == t.month && e.start.day == t.day
    ).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  List<NexiiaEvent> get _weekEvents {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 7));
    return _events.where((e) => !e.start.isBefore(monday) && e.start.isBefore(sunday))
        .toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  int _freeSlots(List<NexiiaEvent> evts) {
    int free = 0;
    for (int h = 8; h < 20; h++) {
      if (!evts.any((e) => e.start.hour <= h && e.end.hour > h)) free++;
    }
    return (free / 2).round().clamp(1, 8);
  }

  // ── CRUD ──
  void _addEvent({DateTime? presetStart}) {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day + _dayOffset);
    final start = presetStart ?? day.add(Duration(hours: now.hour + 1));
    final end = start.add(const Duration(hours: 1));
    final newEvt = NexiiaEvent(
      id: '${_nextId++}', title: 'Neuer Termin', start: start, end: end,
      color: _kEventColors[math.Random().nextInt(_kEventColors.length)],
    );
    setState(() { _events.add(newEvt); _selectedEvent = newEvt; });
  }

  void _deleteEvent(NexiiaEvent e) {
    HapticFeedback.heavyImpact();
    setState(() { _events.removeWhere((ev) => ev.id == e.id); _selectedEvent = null; });
  }

  void _duplicateEvent(NexiiaEvent e) {
    HapticFeedback.mediumImpact();
    setState(() {
      _events.add(NexiiaEvent(
        id: '${_nextId++}', title: e.title, subtitle: e.subtitle, location: e.location,
        start: e.start.add(const Duration(days: 1)), end: e.end.add(const Duration(days: 1)),
        color: e.color, energyLevel: e.energyLevel, isAiSuggested: false,
      ));
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
        _ctxItem('edit', Icons.edit_outlined, 'Bearbeiten', AppColors.electricBlueLight),
        _ctxItem('dup', Icons.copy_rounded, 'Duplizieren', AppColors.electricBlueLight),
        _ctxItem('del', Icons.delete_outline_rounded, 'Löschen', AppColors.error),
      ],
    ).then((v) {
      if (v == 'edit') setState(() => _selectedEvent = event);
      else if (v == 'dup') _duplicateEvent(event);
      else if (v == 'del') _deleteEvent(event);
    });
  }

  PopupMenuItem<String> _ctxItem(String val, IconData ic, String lbl, Color c) =>
      PopupMenuItem(value: val, child: Row(children: [
        Icon(ic, size: 16, color: c), const SizedBox(width: 10),
        Text(lbl, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w500, color: c)),
      ]));

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
          _AmbientBackground(ctrl: _ambientCtrl),

          FadeTransition(
            opacity: CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPad + 8),
                  _SmartHeader(
                    dayOffset: _dayOffset, events: todayEvts, freeSlots: _freeSlots(todayEvts),
                    ambientCtrl: _ambientCtrl,
                    onPrev: () { setState(() => _dayOffset--); _postScroll(); },
                    onNext: () { setState(() => _dayOffset++); _postScroll(); },
                    onToday: () { setState(() => _dayOffset = 0); _postScroll(); },
                  ),
                  const SizedBox(height: 10),
                  _ViewToggle(current: _view, onChange: _switchView),
                  const SizedBox(height: 8),
                  _SmartLayerChips(current: _smartLayer, onChange: (v) => setState(() => _smartLayer = v)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _view == _CalView.day
                          ? _DayView(
                              key: ValueKey('day_$_dayOffset'),
                              events: todayEvts, scrollCtrl: _dayScroll, nowPulseCtrl: _nowPulseCtrl,
                              smartLayer: _smartLayer, dayOffset: _dayOffset, bottomPad: botPad,
                              onEventTap: (e) { HapticFeedback.lightImpact(); setState(() => _selectedEvent = e); },
                              onEventLongPress: _showCtxMenu,
                              onSlotTap: (h) => _addEvent(presetStart: DateTime(
                                DateTime.now().year, DateTime.now().month, DateTime.now().day + _dayOffset, h)),
                            )
                          : _WeekView(
                              key: const ValueKey('week'),
                              allEvents: _events, weekEvents: _weekEvents,
                              selectedOffset: _dayOffset, bottomPad: botPad,
                              onDayTap: (o) { setState(() { _dayOffset = o; _switchView(_CalView.day); }); },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Add Button
          Positioned(
            bottom: botPad + 26, left: 20,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut),
              child: _FloatingAddButton(onTap: () => _addEvent(), breathCtrl: _orbBreathCtrl),
            ),
          ),

          // AI Card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic,
            bottom: _showAiCard ? botPad + 110.0 : -220.0, left: 20, right: 88,
            child: _showAiCard ? _AiCard(
              text: _aiCardText,
              onAccept: () { setState(() { _showAiCard = false; _voiceActive = false;
                final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                _events.add(NexiiaEvent(id: '${_nextId++}', title: 'Fokuszeit', subtitle: 'Von Nexiia geplant',
                  start: today.add(const Duration(hours: 15)), end: today.add(const Duration(hours: 16, minutes: 30)),
                  color: AppColors.electricBlue, energyLevel: 0.8, isAiSuggested: true));
              }); },
              onDismiss: () => setState(() { _showAiCard = false; _voiceActive = false; }),
            ) : const SizedBox.shrink(),
          ),

          // Voice Orb
          Positioned(
            bottom: botPad + 26, right: 20,
            child: _VoiceOrb(isActive: _voiceActive, isListening: _voiceListen,
              breathCtrl: _orbBreathCtrl, waveCtrl: _voiceWaveCtrl, onTap: _toggleVoice),
          ),

          // Event Sheet
          if (_selectedEvent != null)
            _EventSheet(
              event: _selectedEvent!, botPad: botPad,
              onClose: () => setState(() => _selectedEvent = null),
              onDelete: () => _deleteEvent(_selectedEvent!),
              onDuplicate: () { _duplicateEvent(_selectedEvent!); setState(() => _selectedEvent = null); },
              onSave: (t, s, l) { setState(() {
                _selectedEvent!.title = t;
                _selectedEvent!.subtitle = s.isEmpty ? null : s;
                _selectedEvent!.location = l.isEmpty ? null : l;
                _selectedEvent = null;
              }); },
            ),
        ],
      ),
    );
  }

  void _postScroll() {
    if (_view == _CalView.day) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND — Enhanced with vivid color islands
// ═══════════════════════════════════════════════════════════════════════════════

class _AmbientBackground extends StatelessWidget {
  final AnimationController ctrl;
  const _AmbientBackground({required this.ctrl});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        painter: _AmbientPainter(t: ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final double t;
  const _AmbientPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base — slightly warmer for glass contrast
    canvas.drawRect(r, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF070B1A), Color(0xFF0B0E1A), Color(0xFF080C1E)],
      ).createShader(r));

    // Blue blob top-left
    canvas.drawRect(r, Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.5 + t * 0.15, -0.5 + math.sin(t * math.pi) * 0.08),
        radius: 0.9,
        colors: [AppColors.electricBlue.withOpacity(0.16 + t * 0.07), Colors.transparent],
      ).createShader(r));

    // Violet blob bottom-right
    canvas.drawRect(r, Paint()
      ..shader = RadialGradient(
        center: Alignment(0.65 + math.cos(t * math.pi) * 0.1, 0.6 + t * 0.06),
        radius: 0.7,
        colors: [const Color(0xFF6366F1).withOpacity(0.12 + t * 0.05), Colors.transparent],
      ).createShader(r));

    // Cyan blob center-right
    canvas.drawRect(r, Paint()
      ..shader = RadialGradient(
        center: Alignment(0.4, -0.1 + math.sin(t * math.pi * 1.3) * 0.12),
        radius: 0.55,
        colors: [const Color(0xFF06B6D4).withOpacity(0.08 + t * 0.04), Colors.transparent],
      ).createShader(r));

    // Rose blob bottom-left
    canvas.drawRect(r, Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.6, 0.75 + math.cos(t * math.pi * 0.8) * 0.06),
        radius: 0.5,
        colors: [const Color(0xFFF472B6).withOpacity(0.06 + t * 0.03), Colors.transparent],
      ).createShader(r));

    // Teal blob top-right
    canvas.drawRect(r, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.65), radius: 0.45,
        colors: [const Color(0xFF2DB08A).withOpacity(0.05 + t * 0.03), Colors.transparent],
      ).createShader(r));

    // Horizon line
    final hy = size.height * 0.38 + math.sin(t * math.pi) * 6;
    canvas.drawLine(Offset(0, hy), Offset(size.width, hy), Paint()
      ..shader = LinearGradient(colors: [
        Colors.transparent,
        AppColors.electricBlue.withOpacity(0.28 + t * 0.14),
        AppColors.electricBlue.withOpacity(0.42 + t * 0.16),
        AppColors.electricBlue.withOpacity(0.28 + t * 0.14),
        Colors.transparent,
      ], stops: const [0.0, 0.2, 0.5, 0.8, 1.0])
          .createShader(Rect.fromLTWH(0, hy - 1, size.width, 2))
      ..strokeWidth = 0.8 ..style = PaintingStyle.stroke);

    // Horizon glow
    canvas.drawRect(Rect.fromLTWH(0, hy - 80, size.width, 160), Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, AppColors.electricBlue.withOpacity(0.05 + t * 0.03), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, hy - 80, size.width, 160)));

    // Particles
    final rng = math.Random(42);
    final pColors = [AppColors.electricBlueLight, const Color(0xFF6366F1), const Color(0xFF06B6D4), const Color(0xFF34D399)];
    for (int i = 0; i < 28; i++) {
      final px = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.12 + rng.nextDouble() * 0.4;
      var py = (baseY - t * size.height * speed) % size.height;
      if (py < 0) py += size.height;
      canvas.drawCircle(Offset(px, py), 0.4 + rng.nextDouble() * 1.2, Paint()
        ..color = pColors[i % pColors.length].withOpacity(0.04 + rng.nextDouble() * 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.t != t;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMART HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SmartHeader extends StatelessWidget {
  final int dayOffset;
  final List<NexiiaEvent> events;
  final int freeSlots;
  final AnimationController ambientCtrl;
  final VoidCallback onPrev, onNext, onToday;

  const _SmartHeader({
    required this.dayOffset, required this.events, required this.freeSlots,
    required this.ambientCtrl, required this.onPrev, required this.onNext, required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().add(Duration(days: dayOffset));
    const months = ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'];
    const weekdays = ['Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag','Sonntag'];
    final dayLabel = dayOffset == 0 ? 'Heute' : dayOffset == 1 ? 'Morgen' : dayOffset == -1 ? 'Gestern' : weekdays[now.weekday - 1];
    final aiCount = events.where((e) => e.isAiSuggested).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: ambientCtrl,
        builder: (_, child) => _LiquidGlass(
          borderRadius: 24, blur: 55, fillOpacity: 0.06,
          borderOpacity: 0.12 + ambientCtrl.value * 0.06,
          glowColor: AppColors.electricBlue, glowOpacity: 0.08 + ambientCtrl.value * 0.05,
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: child!,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(child: Text('${now.day}. ${months[now.month - 1]}',
                      style: const TextStyle(fontFamily: 'Satoshi', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1))),
                    const SizedBox(width: 10),
                    Text(dayLabel, style: const TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.electricBlueLight, letterSpacing: 0.2)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 7, runSpacing: 6, children: [
                  if (events.isNotEmpty) _SummaryChip(icon: Icons.event_rounded, label: '${events.length} Termine', color: AppColors.electricBlue),
                  if (aiCount > 0) _SummaryChip(icon: Icons.auto_awesome_rounded, label: '$aiCount KI-Block${aiCount > 1 ? 's' : ''}', color: AppColors.electricBlueLight),
                  _SummaryChip(icon: Icons.wb_sunny_outlined, label: '$freeSlots freie Slots', color: AppColors.success),
                ]),
              ],
            )),
            const SizedBox(width: 10),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
              const SizedBox(width: 5),
              _NavBtn(icon: Icons.today_rounded, onTap: onToday),
              const SizedBox(width: 5),
              _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SummaryChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.20), width: 0.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ]),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _LiquidGlass(
        borderRadius: 11, blur: 20, fillOpacity: 0.05, borderOpacity: 0.12, showSpecularHighlight: false,
        child: SizedBox(width: 34, height: 34, child: Center(child: Icon(icon, size: 17, color: Colors.white.withOpacity(0.60)))),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VIEW TOGGLE
// ═══════════════════════════════════════════════════════════════════════════════

class _ViewToggle extends StatelessWidget {
  final _CalView current; final ValueChanged<_CalView> onChange;
  const _ViewToggle({required this.current, required this.onChange});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _LiquidGlass(
        borderRadius: 16, blur: 40, fillOpacity: 0.04, borderOpacity: 0.10,
        child: SizedBox(height: 42, child: Row(
          children: _CalView.values.map((v) {
            final sel = v == current;
            return Expanded(child: GestureDetector(
              onTap: () => onChange(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: sel ? AppColors.electricBlue.withOpacity(0.14) : Colors.transparent,
                  border: sel ? Border.all(color: AppColors.electricBlue.withOpacity(0.30), width: 0.5) : null,
                  boxShadow: sel ? [BoxShadow(color: AppColors.electricBlue.withOpacity(0.12), blurRadius: 16, spreadRadius: -3)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  v == _CalView.day ? 'Tag' : 'Woche',
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 13,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? AppColors.electricBlueLight : Colors.white.withOpacity(0.35), letterSpacing: 0.2),
                ),
              ),
            ));
          }).toList(),
        )),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMART LAYER CHIPS
// ═══════════════════════════════════════════════════════════════════════════════

class _SmartLayerChips extends StatelessWidget {
  final _SmartLayer current; final ValueChanged<_SmartLayer> onChange;
  const _SmartLayerChips({required this.current, required this.onChange});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 34, child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
      children: _SmartLayer.values.map((m) {
        final sel = m == current;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onChange(m); },
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: sel ? m.color.withOpacity(0.10) : Colors.white.withOpacity(0.03),
                    border: Border.all(color: sel ? m.color.withOpacity(0.30) : Colors.white.withOpacity(0.07), width: 0.5),
                    boxShadow: sel ? [BoxShadow(color: m.color.withOpacity(0.08), blurRadius: 12, spreadRadius: -3)] : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(m.icon, size: 11, color: sel ? m.color : Colors.white.withOpacity(0.32)),
                    const SizedBox(width: 5),
                    Text(m.label, style: TextStyle(fontFamily: 'Satoshi', fontSize: 11,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? m.color : Colors.white.withOpacity(0.32))),
                  ]),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }
}// ═══════════════════════════════════════════════════════════════════════════════
// DAY VIEW — With slot tap + longpress interaction
// ═══════════════════════════════════════════════════════════════════════════════

class _DayView extends StatelessWidget {
  final List<NexiiaEvent> events;
  final ScrollController scrollCtrl;
  final AnimationController nowPulseCtrl;
  final _SmartLayer smartLayer;
  final int dayOffset;
  final double bottomPad;
  final ValueChanged<NexiiaEvent> onEventTap;
  final void Function(NexiiaEvent event, Offset position) onEventLongPress;
  final ValueChanged<int> onSlotTap;

  const _DayView({
    super.key,
    required this.events,
    required this.scrollCtrl,
    required this.nowPulseCtrl,
    required this.smartLayer,
    required this.dayOffset,
    required this.bottomPad,
    required this.onEventTap,
    required this.onEventLongPress,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final nowPx = dayOffset == 0
        ? ((now.hour - _kStart) * _kHourH + now.minute * (_kHourH / 60.0))
            .clamp(0.0, (_kTotal * _kHourH))
            .toDouble()
        : -1.0;
    final totalH = (_kTotal * _kHourH + 80.0);

    return SingleChildScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad + 120.0),
      child: SizedBox(
        height: totalH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Hour lines with tap zones ──
            ...List.generate(_kTotal, (i) {
              final hour = _kStart + i;
              final hasEvent =
                  events.any((e) => e.start.hour <= hour && e.end.hour > hour);
              return Positioned(
                top: (i * _kHourH),
                left: 0,
                right: 0,
                child: _HourLine(
                  hour: hour,
                  isFree: !hasEvent && hour >= 7 && hour <= 21,
                  onTap: hasEvent ? null : () => onSlotTap(hour),
                  onLongPress: hasEvent
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onSlotTap(hour);
                        },
                ),
              );
            }),

            // ── Layer overlays ──
            ..._buildLayerOverlays(),

            // ── Free slot hints ──
            ..._buildFreeHints(),

            // ── Event cards ──
            ...events.map((e) {
              final startMin =
                  (e.start.hour - _kStart) * 60.0 + e.start.minute.toDouble();
              final top = startMin * (_kHourH / 60.0);
              final height = (e.durationMinutes * (_kHourH / 60.0))
                  .clamp(44.0, double.infinity)
                  .toDouble();
              return Positioned(
                top: top,
                left: 54,
                right: 0,
                height: height,
                child: _EventCard(
                  event: e,
                  smartLayer: smartLayer,
                  onTap: () => onEventTap(e),
                  onLongPress: (details) =>
                      onEventLongPress(e, details.globalPosition),
                ),
              );
            }),

            // ── Now line ──
            if (nowPx >= 0)
              Positioned(
                top: nowPx - 1.0,
                left: 46,
                right: 0,
                child: AnimatedBuilder(
                  animation: nowPulseCtrl,
                  builder: (_, __) => _NowLine(pulse: nowPulseCtrl.value),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLayerOverlays() {
    final layers = <({int sh, int eh, int? dur, Color c, String lbl})>[];

    if (smartLayer == _SmartLayer.energy || smartLayer == _SmartLayer.focus) {
      layers.add((
        sh: 8, eh: 11, dur: null, c: AppColors.electricBlue,
        lbl: '⚡ Höchste Energie',
      ));
    }
    if (smartLayer == _SmartLayer.energy ||
        smartLayer == _SmartLayer.recovery) {
      layers.add((
        sh: 13, eh: 14, dur: null, c: AppColors.warning,
        lbl: '😴 Mittagstief',
      ));
    }
    if (smartLayer == _SmartLayer.focus) {
      layers.add((
        sh: 15, eh: 18, dur: null, c: AppColors.electricBlueLight,
        lbl: '🎯 Fokus-Fenster',
      ));
    }
    if (smartLayer == _SmartLayer.recovery) {
      layers.add((
        sh: 20, eh: 22, dur: null, c: AppColors.success,
        lbl: '🌙 Recovery',
      ));
    }
    if (smartLayer == _SmartLayer.buffer) {
      layers.addAll([
        (sh: 9, eh: 9, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
        (sh: 12, eh: 12, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
        (sh: 16, eh: 16, dur: 15, c: AppColors.gold, lbl: '⏱ Puffer'),
      ]);
    }

    return layers.map((l) {
      final startMin = (l.sh - _kStart) * 60;
      final durMin = l.dur ?? ((l.eh - l.sh) * 60);
      final top = (startMin * (_kHourH / 60.0));
      final height =
          (durMin * (_kHourH / 60.0)).clamp(20.0, double.infinity).toDouble();

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
              left: BorderSide(color: l.c.withOpacity(0.22), width: 2.0),
            ),
          ),
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 56, top: 4),
          child: Text(
            l.lbl,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: l.c.withOpacity(0.48),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFreeHints() {
    final hints = <Widget>[];
    for (int h = _kStart; h < _kEnd - 1; h++) {
      if (h < 8 || h > 19) continue;
      if (events.any((e) => e.start.hour <= h && e.end.hour > h)) continue;
      final top = ((h - _kStart) * _kHourH + 6.0);
      hints.add(
        Positioned(
          top: top,
          left: 54,
          right: 0,
          height: 24,
          child: GestureDetector(
            onTap: () => onSlotTap(h),
            child: _FreeHint(
              label: '+ Termin · ${h.toString().padLeft(2, '0')}:00',
            ),
          ),
        ),
      );
    }
    return hints.take(4).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOUR LINE — Tappable slot zones
// ─────────────────────────────────────────────────────────────────────────────

class _HourLine extends StatelessWidget {
  final int hour;
  final bool isFree;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _HourLine({
    required this.hour,
    this.isFree = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final main = hour % 3 == 0;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _kHourH,
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
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(main ? 0.09 : 0.04),
                          Colors.white.withOpacity(main ? 0.04 : 0.015),
                        ],
                      ),
                    ),
                  ),
                  // Subtle tap hint on free slots
                  if (isFree)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EVENT CARD — Liquid Glass with press animation
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatefulWidget {
  final NexiiaEvent event;
  final _SmartLayer smartLayer;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails details) onLongPress;

  const _EventCard({
    required this.event,
    required this.smartLayer,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.event.color;
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      onLongPressStart: (details) {
        _press.reverse();
        widget.onLongPress(details);
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Row(
          children: [
            // ── Color accent bar ──
            Container(
              width: 3.0,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(color: c.withOpacity(0.55), blurRadius: 10),
                ],
              ),
            ),

            // ── Glass card body ──
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        // Ultra-transparent glass with color tint
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
                          // Specular top highlight
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.event.title,
                                        style: const TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.event.isAiSuggested) ...[
                                      const SizedBox(width: 6),
                                      _AiBadge(),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${_fmtTime(widget.event.start)} – ${_fmtTime(widget.event.end)}',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.40),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (widget.event.subtitle != null &&
                                    widget.event.durationMinutes >= 45) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.event.subtitle!,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.30),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (widget.event.energyLevel != null &&
                                    widget.event.durationMinutes >= 55) ...[
                                  const SizedBox(height: 7),
                                  _EnergyBar(
                                    label: widget.smartLayer == _SmartLayer.focus
                                        ? 'Fokus'
                                        : 'Energie',
                                    value: widget.event.energyLevel!,
                                    color: c,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.electricBlue.withOpacity(0.15),
            border: Border.all(
              color: AppColors.electricBlue.withOpacity(0.30),
              width: 0.5,
            ),
          ),
          child: const Text(
            'KI',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.electricBlueLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _EnergyBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.60),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.65)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 9,
            color: color.withOpacity(0.50),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOW LINE
// ─────────────────────────────────────────────────────────────────────────────

class _NowLine extends StatelessWidget {
  final double pulse;
  const _NowLine({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricBlueLight,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.50 + pulse * 0.35),
                blurRadius: 10 + pulse * 10,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlueLight.withOpacity(0.80),
                  AppColors.electricBlue.withOpacity(0.30),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.20 + pulse * 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FREE HINT — Tappable glass pill
// ─────────────────────────────────────────────────────────────────────────────

class _FreeHint extends StatelessWidget {
  final String label;
  const _FreeHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.success.withOpacity(0.06),
            border: Border.all(
              color: AppColors.success.withOpacity(0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 11,
                color: AppColors.success.withOpacity(0.65),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WEEK VIEW — Liquid Glass panels
// ═══════════════════════════════════════════════════════════════════════════════

class _WeekView extends StatelessWidget {
  final List<NexiiaEvent> allEvents;
  final List<NexiiaEvent> weekEvents;
  final int selectedOffset;
  final double bottomPad;
  final ValueChanged<int> onDayTap;

  const _WeekView({
    super.key,
    required this.allEvents,
    required this.weekEvents,
    required this.selectedOffset,
    required this.bottomPad,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Week Strip ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeekStrip(
                allEvents: allEvents,
                selectedOffset: selectedOffset,
                onDayTap: onDayTap,
              ),
            ),
            const SizedBox(height: 14),

            // ── Events panel ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 120.0),
                child: _LiquidGlass(
                  borderRadius: 24,
                  blur: 50,
                  fillOpacity: 0.05,
                  borderOpacity: 0.10,
                  glowColor: AppColors.electricBlue,
                  glowOpacity: 0.05,
                  child: weekEvents.isEmpty ? _buildEmpty() : _buildList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 36,
            color: Colors.white.withOpacity(0.14),
          ),
          const SizedBox(height: 12),
          Text(
            'Keine Termine diese Woche',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.30),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tippe auf einen Tag für Details',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12,
              color: Colors.white.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text(
                'DIESE WOCHE',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: Colors.white.withOpacity(0.32),
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: AppColors.electricBlue.withOpacity(0.10),
                      border: Border.all(
                        color: AppColors.electricBlue.withOpacity(0.22),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${weekEvents.length} Termine',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricBlueLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Event list
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            physics: const BouncingScrollPhysics(),
            itemCount: weekEvents.length,
            shrinkWrap: false,
            separatorBuilder: (_, __) => Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            itemBuilder: (_, i) => _WeekRow(event: weekEvents[i]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEEK STRIP — Liquid Glass day pills
// ─────────────────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final List<NexiiaEvent> allEvents;
  final int selectedOffset;
  final ValueChanged<int> onDayTap;

  const _WeekStrip({
    required this.allEvents,
    required this.selectedOffset,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    return _LiquidGlass(
      borderRadius: 20,
      blur: 40,
      fillOpacity: 0.04,
      borderOpacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: List.generate(7, (i) {
          final day = monday.add(Duration(days: i));
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: isSel
                      ? AppColors.electricBlue.withOpacity(0.14)
                      : isToday
                          ? Colors.white.withOpacity(0.04)
                          : Colors.transparent,
                  border: isSel
                      ? Border.all(
                          color: AppColors.electricBlue.withOpacity(0.32),
                          width: 0.5,
                        )
                      : null,
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: AppColors.electricBlue.withOpacity(0.12),
                            blurRadius: 14,
                            spreadRadius: -3,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: isSel
                            ? AppColors.electricBlueLight
                            : Colors.white.withOpacity(0.34),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 15,
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isSel
                            ? AppColors.electricBlueLight
                            : isToday
                                ? Colors.white.withOpacity(0.90)
                                : Colors.white.withOpacity(0.50),
                      ),
                    ),
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
                                      blurRadius: 4,
                                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// WEEK ROW
// ─────────────────────────────────────────────────────────────────────────────

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
                BoxShadow(
                  color: event.color.withOpacity(0.35),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${wd[(event.start.weekday - 1).clamp(0, 6)]} · ${_fmtTime(event.start)} Uhr',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: event.color.withOpacity(0.08),
                  border: Border.all(
                    color: event.color.withOpacity(0.20),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${event.durationMinutes} min',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: event.color.withOpacity(0.75),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}// ═══════════════════════════════════════════════════════════════════════════════
// FLOATING ADD BUTTON — Liquid Glass Pill
// ═══════════════════════════════════════════════════════════════════════════════

class _FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController breathCtrl;

  const _FloatingAddButton({
    required this.onTap,
    required this.breathCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: breathCtrl,
        builder: (_, child) {
          final b = 0.97 + breathCtrl.value * 0.03;
          return Transform.scale(scale: b, child: child);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.electricBlue.withOpacity(0.22),
                    AppColors.electricBlue.withOpacity(0.10),
                    Colors.white.withOpacity(0.04),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                border: Border.all(
                  color: AppColors.electricBlue.withOpacity(0.30),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.20),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 0.8,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.35),
                            AppColors.electricBlueLight.withOpacity(0.40),
                            Colors.white.withOpacity(0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.electricBlueLight.withOpacity(0.90),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Termin',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.electricBlueLight.withOpacity(0.90),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// VOICE ORB — Liquid Glass
// ═══════════════════════════════════════════════════════════════════════════════

class _VoiceOrb extends StatelessWidget {
  final bool isActive;
  final bool isListening;
  final AnimationController breathCtrl;
  final AnimationController waveCtrl;
  final VoidCallback onTap;

  const _VoiceOrb({
    required this.isActive,
    required this.isListening,
    required this.breathCtrl,
    required this.waveCtrl,
    required this.onTap,
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
                // Pulse rings
                if (isListening)
                  ...List.generate(3, (i) {
                    final delay = i * 0.33;
                    final p =
                        ((wave - delay) % 1.0).clamp(0.0, 1.0).toDouble();
                    return Container(
                      width: 64 + p * 44,
                      height: 64 + p * 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.electricBlue
                              .withOpacity((1 - p) * 0.30),
                          width: 1.0,
                        ),
                      ),
                    );
                  }),

                // Glow
                if (isActive)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue
                              .withOpacity(0.25 + breathCtrl.value * 0.18),
                          blurRadius: 30 + breathCtrl.value * 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                // Orb body
                Transform.scale(
                  scale: breathe,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isActive
                                ? [
                                    AppColors.electricBlue.withOpacity(0.40),
                                    AppColors.electricBlue.withOpacity(0.14),
                                    Colors.white.withOpacity(0.04),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.10),
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.02),
                                  ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          border: Border.all(
                            color: isActive
                                ? AppColors.electricBlue.withOpacity(0.50)
                                : Colors.white.withOpacity(0.16),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                              spreadRadius: -4,
                            ),
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

                // Waveform
                if (isListening)
                  Positioned(bottom: 0, child: _WaveformBar(wave: wave)),
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
  const _WaveformBar({required this.wave});

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(12);
    const bars = 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(bars, (i) {
        final h = (4.0 +
                math.sin((wave * math.pi * 2) + (i * math.pi / bars)) *
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
            color: AppColors.electricBlueLight.withOpacity(0.75),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.20),
                blurRadius: 4,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI CARD — Liquid Glass
// ═══════════════════════════════════════════════════════════════════════════════

class _AiCard extends StatefulWidget {
  final String text;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _AiCard({
    required this.text,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  State<_AiCard> createState() => _AiCardState();
}

class _AiCardState extends State<_AiCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.electricBlue.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: AppColors.electricBlue.withOpacity(0.25),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.14),
                    blurRadius: 36,
                    offset: const Offset(0, 8),
                    spreadRadius: -6,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight
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
                            AppColors.electricBlueLight.withOpacity(0.30),
                            Colors.white.withOpacity(0.35),
                            AppColors.electricBlueLight.withOpacity(0.30),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Column(
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
                              color: AppColors.electricBlueLight,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.electricBlue.withOpacity(0.40),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Nexiia AI',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                              color: AppColors.electricBlueLight,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.onDismiss,
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          color: Colors.white.withOpacity(0.80),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _GlassButton(
                              label: 'Ablehnen',
                              color: Colors.white,
                              filled: false,
                              onTap: widget.onDismiss,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _GlassButton(
                              label: 'Einplanen',
                              color: AppColors.electricBlue,
                              filled: true,
                              onTap: widget.onAccept,
                            ),
                          ),
                        ],
                      ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// EVENT SHEET — Liquid Glass (transparent, floating, editable)
// ═══════════════════════════════════════════════════════════════════════════════

class _EventSheet extends StatefulWidget {
  final NexiiaEvent event;
  final double botPad;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final void Function(String title, String subtitle, String location) onSave;

  const _EventSheet({
    required this.event,
    required this.botPad,
    required this.onClose,
    required this.onDelete,
    required this.onDuplicate,
    required this.onSave,
  });

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _locationCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _titleCtrl = TextEditingController(text: widget.event.title);
    _subtitleCtrl = TextEditingController(text: widget.event.subtitle ?? '');
    _locationCtrl = TextEditingController(text: widget.event.location ?? '');
  }

  void _close() => _ctrl.reverse().then((_) => widget.onClose());

  void _toggleEdit() {
    HapticFeedback.lightImpact();
    setState(() => _editing = !_editing);
  }

  void _save() {
    HapticFeedback.mediumImpact();
    widget.onSave(
      _titleCtrl.text,
      _subtitleCtrl.text,
      _locationCtrl.text,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.event.color;
    final screenH = MediaQuery.of(context).size.height;
    final maxSize = (_editing ? 520.0 : 420.0) / screenH;
    final clampedMax = maxSize.clamp(0.35, 0.78).toDouble();
    final initSize = (_editing ? 480.0 : 340.0) / screenH;
    final clampedInit = initSize.clamp(0.30, 0.68).toDouble();

    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: DraggableScrollableSheet(
            initialChildSize: clampedInit,
            minChildSize: 0.20,
            maxChildSize: clampedMax,
            snap: true,
            snapSizes: [clampedInit, clampedMax],
            builder: (context, scrollCtrl) {
              return GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        // LIQUID GLASS — not opaque!
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.06),
                            Colors.white.withOpacity(0.03),
                            Colors.black.withOpacity(0.02),
                          ],
                          stops: const [0.0, 0.2, 0.5, 1.0],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.18),
                            width: 0.5,
                          ),
                          left: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                            width: 0.5,
                          ),
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                            width: 0.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            blurRadius: 50,
                            offset: const Offset(0, -10),
                            spreadRadius: -10,
                          ),
                          BoxShadow(
                            color: c.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(0, -6),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Top specular highlight
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    c.withOpacity(0.40),
                                    Colors.white.withOpacity(0.50),
                                    c.withOpacity(0.40),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          CustomScrollView(
                            controller: scrollCtrl,
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 12),
                                    // Handle
                                    Center(
                                      child: Container(
                                        width: 36,
                                        height: 4,
                                        margin:
                                            const EdgeInsets.only(bottom: 18),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color:
                                              Colors.white.withOpacity(0.16),
                                        ),
                                      ),
                                    ),
                                    // Content area
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 0, 24, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Title row
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 3.5,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: c,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          c.withOpacity(0.50),
                                                      blurRadius: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: _editing
                                                    ? _GlassTextField(
                                                        controller: _titleCtrl,
                                                        hint: 'Titel',
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            widget.event.title,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Satoshi',
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                              height: 1.15,
                                                            ),
                                                          ),
                                                          if (widget.event
                                                                  .subtitle !=
                                                              null) ...[
                                                            const SizedBox(
                                                                height: 3),
                                                            Text(
                                                              widget.event
                                                                  .subtitle!,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Satoshi',
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.40),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                              ),
                                              if (widget.event.isAiSuggested)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: _AiBadge(),
                                                ),
                                            ],
                                          ),

                                          // Edit fields
                                          if (_editing) ...[
                                            const SizedBox(height: 12),
                                            _GlassTextField(
                                              controller: _subtitleCtrl,
                                              hint: 'Beschreibung',
                                              fontSize: 14,
                                            ),
                                            const SizedBox(height: 10),
                                            _GlassTextField(
                                              controller: _locationCtrl,
                                              hint: 'Ort',
                                              fontSize: 14,
                                              prefixIcon:
                                                  Icons.location_on_outlined,
                                            ),
                                          ],

                                          const SizedBox(height: 20),

                                          // Time
                                          _SheetInfoRow(
                                            icon: Icons.schedule_rounded,
                                            text:
                                                '${_fmtTime(widget.event.start)} – '
                                                '${_fmtTime(widget.event.end)} · '
                                                '${widget.event.durationMinutes} Min.',
                                            color: c,
                                          ),

                                          if (widget.event.location != null &&
                                              !_editing) ...[
                                            const SizedBox(height: 10),
                                            _SheetInfoRow(
                                              icon:
                                                  Icons.location_on_outlined,
                                              text: widget.event.location!,
                                              color: c,
                                            ),
                                          ],

                                          // Energy bar
                                          if (widget.event.energyLevel !=
                                              null) ...[
                                            const SizedBox(height: 18),
                                            Text(
                                              'FOKUS-INTENSITÄT',
                                              style: TextStyle(
                                                fontFamily: 'Satoshi',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.1,
                                                color: Colors.white
                                                    .withOpacity(0.32),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _EnergyBar(
                                              label: 'Fokus',
                                              value:
                                                  widget.event.energyLevel!,
                                              color: c,
                                            ),
                                          ],

                                          const SizedBox(height: 22),

                                          // Actions
                                          if (_editing)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _GlassButton(
                                                    label: 'Abbrechen',
                                                    color: Colors.white,
                                                    filled: false,
                                                    onTap: _toggleEdit,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _GlassButton(
                                                    label: 'Speichern',
                                                    color:
                                                        AppColors.electricBlue,
                                                    filled: true,
                                                    onTap: _save,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                _SheetAction(
                                                  icon: Icons.edit_outlined,
                                                  label: 'Bearbeiten',
                                                  color: c,
                                                  onTap: _toggleEdit,
                                                ),
                                                const SizedBox(width: 8),
                                                _SheetAction(
                                                  icon: Icons.copy_rounded,
                                                  label: 'Duplizieren',
                                                  color: AppColors
                                                      .electricBlueLight,
                                                  onTap: widget.onDuplicate,
                                                ),
                                                const SizedBox(width: 8),
                                                _SheetAction(
                                                  icon: Icons
                                                      .delete_outline_rounded,
                                                  label: 'Löschen',
                                                  color: AppColors.error,
                                                  onTap: widget.onDelete,
                                                ),
                                              ],
                                            ),

                                          SizedBox(
                                              height: widget.botPad + 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS TEXT FIELD — Transparent editable input
// ─────────────────────────────────────────────────────────────────────────────

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double fontSize;
  final FontWeight fontWeight;
  final IconData? prefixIcon;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.white.withOpacity(0.22),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18,
                      color: Colors.white.withOpacity(0.30))
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS BUTTON — Reusable action button
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _GlassButton({
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: filled
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.70),
                        color.withOpacity(0.50),
                      ],
                    )
                  : null,
              color: filled ? null : Colors.white.withOpacity(0.06),
              border: Border.all(
                color: filled
                    ? color.withOpacity(0.50)
                    : Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : Colors.white.withOpacity(0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET INFO ROW
// ─────────────────────────────────────────────────────────────────────────────

class _SheetInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SheetInfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color.withOpacity(0.60)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: Colors.white.withOpacity(0.60),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET ACTION — Glass pill button
// ─────────────────────────────────────────────────────────────────────────────

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: color.withOpacity(0.07),
                border: Border.all(
                  color: color.withOpacity(0.18),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: color.withOpacity(0.85)),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: color.withOpacity(0.85),
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// END OF FILE — Liquid Glass Edition v5
// ═══════════════════════════════════════════════════════════════════════════════