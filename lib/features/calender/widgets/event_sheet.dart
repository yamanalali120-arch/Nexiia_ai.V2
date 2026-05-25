import 'dart:async';
import '../services/supabase_calendar_service.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/nexiia_event.dart';
import '../utils/calendar_time_utils.dart';
import '../services/event_intelligence_service.dart';

class EventSheet extends StatefulWidget {
  final NexiiaEvent event;
  final double botPad;
  final Color pri;
  final Color priLight;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final void Function(String, String, String, DateTime, DateTime) onSave;

  const EventSheet({
    super.key,
    required this.event,
    required this.botPad,
    required this.pri,
    required this.priLight,
    required this.onClose,
    required this.onDelete,
    required this.onDuplicate,
    required this.onSave,
  });

  @override
  State<EventSheet> createState() => EventSheetState();
}

class EventSheetState extends State<EventSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _locationCtrl;

  late DateTime _start;
  late DateTime _end;

  EventGoal _goal = EventGoal.focus;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();

    _titleCtrl = TextEditingController(text: widget.event.title);
    _subtitleCtrl = TextEditingController(text: widget.event.subtitle ?? '');
    _locationCtrl = TextEditingController(text: widget.event.location ?? '');

    _start = widget.event.start;
    _end = widget.event.end.isAfter(widget.event.start)
        ? widget.event.end
        : widget.event.start.add(const Duration(hours: 1));

    _goal = EventIntelligenceService.inferGoal(widget.event.title);

    _titleCtrl.addListener(_onTextChanged);
    _subtitleCtrl.addListener(_onTextChanged);
    _locationCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _titleCtrl.removeListener(_onTextChanged);
    _subtitleCtrl.removeListener(_onTextChanged);
    _locationCtrl.removeListener(_onTextChanged);
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;

    setState(() {
      if (_titleCtrl.text.trim().isNotEmpty) {
        _goal = EventIntelligenceService.inferGoal(_titleCtrl.text);
      }
    });
  }

  void _close() {
    _ctrl.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  Future<void> _save() async {
  HapticFeedback.mediumImpact();

  final safeEnd = _end.isAfter(_start)
      ? _end
      : _start.add(const Duration(hours: 1));

  final title = _titleCtrl.text.trim();
  final note = _subtitleCtrl.text.trim();
  final location = _locationCtrl.text.trim();

  widget.onSave(
    title,
    note,
    location,
    _start,
    safeEnd,
  );

  try {
    await SupabaseCalendarService.saveEvent(
      event: widget.event,
      title: title,
      note: note,
      location: location,
      start: _start,
      end: safeEnd,
    );
  } catch (e) {
    debugPrint('Supabase calendar save failed: $e');
  }
}

  String _goalLabel(EventGoal goal) {
    switch (goal) {
      case EventGoal.focus:
        return 'Fokus';
      case EventGoal.business:
        return 'Business';
      case EventGoal.learning:
        return 'Lernen';
      case EventGoal.fitness:
        return 'Fitness';
      case EventGoal.recovery:
        return 'Recovery';
      case EventGoal.social:
        return 'Social';
    }
  }

  IconData _goalIcon(EventGoal goal) {
    switch (goal) {
      case EventGoal.focus:
        return Icons.center_focus_strong_rounded;
      case EventGoal.business:
        return Icons.work_rounded;
      case EventGoal.learning:
        return Icons.school_rounded;
      case EventGoal.fitness:
        return Icons.fitness_center_rounded;
      case EventGoal.recovery:
        return Icons.self_improvement_rounded;
      case EventGoal.social:
        return Icons.people_alt_rounded;
    }
  }

  void _applySuggestion(String value) {
    HapticFeedback.selectionClick();

    setState(() {
      _titleCtrl.text = value;
      _titleCtrl.selection = TextSelection.collapsed(offset: value.length);
      _goal = EventIntelligenceService.inferGoal(value);

      if (_subtitleCtrl.text.trim().isEmpty) {
        _subtitleCtrl.text = _smartNoteFor(value);
      }
    });
  }

  String _smartNoteFor(String title) {
    final goal = EventIntelligenceService.inferGoal(title);

    switch (goal) {
      case EventGoal.focus:
        return 'Ein klares Ziel, keine Ablenkung, sichtbarer Fortschritt.';
      case EventGoal.business:
        return 'Agenda klären, Entscheidungen treffen, nächste Schritte notieren.';
      case EventGoal.learning:
        return 'Konzentrierte Lernsession mit messbarem Fortschritt.';
      case EventGoal.fitness:
        return 'Energie aufbauen und Körper stark halten.';
      case EventGoal.recovery:
        return 'Bewusst runterfahren, damit der nächste Block besser wird.';
      case EventGoal.social:
        return 'Bewusst Zeit für Menschen einplanen, die wichtig sind.';
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();

    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.pri,
              surface: const Color(0xFF141420),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      final oldStart = _start;
      final oldEnd = _end;

      _start = DateTime(
        picked.year,
        picked.month,
        picked.day,
        oldStart.hour,
        oldStart.minute,
      );

      _end = DateTime(
        picked.year,
        picked.month,
        picked.day,
        oldEnd.hour,
        oldEnd.minute,
      );

      if (!_end.isAfter(_start)) {
        _end = _start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickStartTime() async {
    HapticFeedback.lightImpact();

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.pri,
              surface: const Color(0xFF141420),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _start = DateTime(
        _start.year,
        _start.month,
        _start.day,
        picked.hour,
        picked.minute,
      );

      if (!_end.isAfter(_start)) {
        _end = _start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndTime() async {
    HapticFeedback.lightImpact();

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.pri,
              surface: const Color(0xFF141420),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _end = DateTime(
        _start.year,
        _start.month,
        _start.day,
        picked.hour,
        picked.minute,
      );

      if (!_end.isAfter(_start)) {
        _end = _start.add(const Duration(hours: 1));
      }
    });
  }

  String _dateLabel(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final intelligence = EventIntelligenceService.analyze(
      title: _titleCtrl.text,
      note: _subtitleCtrl.text,
      location: _locationCtrl.text,
      start: _start,
      end: _end,
    );

    final score = intelligence.lockedInScore;
    final sH = MediaQuery.of(context).size.height;

    final cMax = (760.0 / sH).clamp(0.76, 0.96).toDouble();
    final baseInit = (710.0 / sH).clamp(0.72, 0.92).toDouble();
    final cInit = baseInit > cMax - 0.02 ? cMax - 0.02 : baseInit;

    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black.withOpacity(0.14),
          child: DraggableScrollableSheet(
            initialChildSize: cInit,
            minChildSize: 0.58,
            maxChildSize: cMax,
            snap: true,
            snapSizes: [cInit, cMax],
            builder: (ctx, sc) {
              return GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(36),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.14),
                            widget.pri.withOpacity(0.14),
                            widget.priLight.withOpacity(0.07),
                            Colors.white.withOpacity(0.028),
                          ],
                          stops: const [0.0, 0.24, 0.62, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            blurRadius: 58,
                            offset: const Offset(0, -12),
                            spreadRadius: -16,
                          ),
                          BoxShadow(
                            color: widget.pri.withOpacity(0.18),
                            blurRadius: 52,
                            offset: const Offset(0, -8),
                            spreadRadius: -14,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 18,
                            right: 18,
                            height: 1.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.20),
                                    Colors.white.withOpacity(0.70),
                                    widget.priLight.withOpacity(0.34),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.18, 0.46, 0.76, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -92,
                            right: -58,
                            child: IgnorePointer(
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      widget.pri.withOpacity(0.30),
                                      widget.priLight.withOpacity(0.12),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CustomScrollView(
                            controller: sc,
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    18,
                                    12,
                                    18,
                                    widget.botPad + 120,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 44,
                                          height: 4.5,
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.12),
                                                Colors.white.withOpacity(0.48),
                                                Colors.white.withOpacity(0.12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      _SheetHeader(
                                        color: widget.priLight,
                                        onClose: _close,
                                      ),
                                      const SizedBox(height: 14),
                                      _GoalSelector(
                                        selected: _goal,
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        labelFor: _goalLabel,
                                        iconFor: _goalIcon,
                                        onChanged: (goal) {
                                          HapticFeedback.selectionClick();
                                          setState(() => _goal = goal);
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      _EventGlassInput(
                                        controller: _titleCtrl,
                                        idleHint: 'Titel',
                                        smartPrompts: const [
                                          'Welcher Termin steht an?',
                                          'Was wird sein?',
                                          'Treffen, Fokus oder Aufgabe?',
                                          'Was möchtest du einplanen?',
                                        ],
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        isHero: true,
                                      ),
                                      const SizedBox(height: 10),
                                      _SuggestionStrip(
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        items: intelligence.suggestions,
                                        onTap: _applySuggestion,
                                      ),
                                      const SizedBox(height: 12),
                                      _EventGlassInput(
                                        controller: _locationCtrl,
                                        idleHint: 'Ort',
                                        smartPrompts: const [
                                          'Wo findet es statt?',
                                          'Ort, Link oder Kontext?',
                                          'Wo soll Nexiia es merken?',
                                        ],
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        icon: Icons.location_on_outlined,
                                      ),
                                      const SizedBox(height: 12),
                                      _EventGlassInput(
                                        controller: _subtitleCtrl,
                                        idleHint: 'Notiz',
                                        smartPrompts: const [
                                          'Was ist das Ziel?',
                                          'Was soll Nexiia beachten?',
                                          'Welcher Output soll entstehen?',
                                        ],
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        icon: Icons.notes_rounded,
                                      ),
                                      const SizedBox(height: 14),
                                      TimeEditRow(
                                        icon: Icons.calendar_today_rounded,
                                        label: 'Datum',
                                        value: _dateLabel(_start),
                                        color: widget.priLight,
                                        onTap: _pickDate,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TimeEditRow(
                                              icon: Icons.schedule_rounded,
                                              label: 'Start',
                                              value: fmtTime(_start),
                                              color: widget.priLight,
                                              onTap: _pickStartTime,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TimeEditRow(
                                              icon: Icons.schedule_rounded,
                                              label: 'Ende',
                                              value: fmtTime(_end),
                                              color: widget.priLight,
                                              onTap: _pickEndTime,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      _LockedInCard(
                                        pri: widget.pri,
                                        priLight: widget.priLight,
                                        score: score,
                                        label: intelligence.label,
                                        hint: intelligence.hint,
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _ActionGlassButton(
                                              label: 'Abbrechen',
                                              icon: Icons.close_rounded,
                                              color: Colors.white,
                                              isPrimary: false,
                                              onTap: _close,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _ActionGlassButton(
                                              label: 'Speichern',
                                              icon: Icons.arrow_upward_rounded,
                                              color: widget.pri,
                                              isPrimary: true,
                                              onTap: _save,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _SheetAction(
                                            icon: Icons.copy_rounded,
                                            label: 'Duplizieren',
                                            color: widget.priLight,
                                            onTap: widget.onDuplicate,
                                          ),
                                          const SizedBox(width: 10),
                                          _SheetAction(
                                            icon: Icons.delete_outline_rounded,
                                            label: 'Löschen',
                                            color: const Color(0xFFFF5C7A),
                                            onTap: widget.onDelete,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

class _SheetHeader extends StatelessWidget {
  final Color color;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.62),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Smart Event',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Colors.white.withOpacity(0.68),
          ),
        ),
        const Spacer(),
        _CircleGlassButton(
          icon: Icons.close_rounded,
          onTap: onClose,
        ),
      ],
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final EventGoal selected;
  final Color pri;
  final Color priLight;
  final String Function(EventGoal) labelFor;
  final IconData Function(EventGoal) iconFor;
  final ValueChanged<EventGoal> onChanged;

  const _GoalSelector({
    required this.selected,
    required this.pri,
    required this.priLight,
    required this.labelFor,
    required this.iconFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: EventGoal.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final goal = EventGoal.values[i];
          final active = goal == selected;

          return _PressableScale(
            onTap: () => onChanged(goal),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: active
                      ? [
                          pri.withOpacity(0.30),
                          priLight.withOpacity(0.14),
                          Colors.white.withOpacity(0.035),
                        ]
                      : [
                          pri.withOpacity(0.10),
                          priLight.withOpacity(0.035),
                          Colors.white.withOpacity(0.025),
                        ],
                ),
                border: Border.all(
                  color: active
                      ? priLight.withOpacity(0.32)
                      : Colors.white.withOpacity(0.10),
                  width: 0.7,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: pri.withOpacity(0.16),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                          spreadRadius: -8,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    iconFor(goal),
                    size: 14,
                    color: active
                        ? Colors.white.withOpacity(0.92)
                        : Colors.white.withOpacity(0.42),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    labelFor(goal),
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? Colors.white.withOpacity(0.92)
                          : Colors.white.withOpacity(0.48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventGlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String idleHint;
  final List<String> smartPrompts;
  final Color pri;
  final Color priLight;
  final IconData? icon;
  final bool isHero;

  const _EventGlassInput({
    required this.controller,
    required this.idleHint,
    required this.smartPrompts,
    required this.pri,
    required this.priLight,
    this.icon,
    this.isHero = false,
  });

  @override
  State<_EventGlassInput> createState() => _EventGlassInputState();
}

class _EventGlassInputState extends State<_EventGlassInput> {
  final FocusNode _focus = FocusNode();

  Timer? _typingTimer;
  int _promptIndex = 0;
  int _charIndex = 0;
  String _typedPrompt = '';

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _focus.addListener(_handleFocusChanged);
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _focus.removeListener(_handleFocusChanged);
    widget.controller.removeListener(_handleTextChanged);
    _focus.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_focus.hasFocus && !_hasText) {
      _startTypingPrompt();
    } else {
      _stopTypingPrompt(clear: !_focus.hasFocus);
    }

    if (mounted) setState(() {});
  }

  void _handleTextChanged() {
    if (_hasText) {
      _stopTypingPrompt(clear: true);
    } else if (_focus.hasFocus) {
      _startTypingPrompt();
    }

    if (mounted) setState(() {});
  }

  void _startTypingPrompt() {
    if (_typingTimer != null) return;
    if (widget.smartPrompts.isEmpty) return;

    final phrase =
        widget.smartPrompts[_promptIndex % widget.smartPrompts.length];

    _charIndex = 0;
    _typedPrompt = '';

    final firstBurst = phrase.length.clamp(0, 5);

    setState(() {
      _charIndex = firstBurst;
      _typedPrompt = phrase.substring(0, firstBurst);
    });

    _typingTimer = Timer.periodic(const Duration(milliseconds: 9), (timer) {
      if (!mounted || !_focus.hasFocus || _hasText) {
        _stopTypingPrompt(clear: true);
        return;
      }

      setState(() {
        if (_charIndex < phrase.length) {
          _charIndex = (_charIndex + 2).clamp(0, phrase.length);
          _typedPrompt = phrase.substring(0, _charIndex);
        } else {
          timer.cancel();
          _typingTimer = null;

          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted || !_focus.hasFocus || _hasText) return;

            setState(() {
              _promptIndex = (_promptIndex + 1) % widget.smartPrompts.length;
              _typedPrompt = '';
              _charIndex = 0;
            });

            _startTypingPrompt();
          });
        }
      });
    });
  }

  void _stopTypingPrompt({required bool clear}) {
    _typingTimer?.cancel();
    _typingTimer = null;

    if (clear && mounted) {
      setState(() {
        _typedPrompt = '';
        _charIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final radius = widget.isHero ? 24.0 : 22.0;

    final visibleHint = focused && !_hasText && _typedPrompt.isNotEmpty
        ? _typedPrompt
        : (!focused && !_hasText ? widget.idleHint : '');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(
        minHeight: widget.isHero ? 60 : 54,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: focused
                ? widget.pri.withOpacity(0.18)
                : widget.pri.withOpacity(0.055),
            blurRadius: focused ? 22 : 12,
            offset: const Offset(0, 6),
            spreadRadius: -14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: focused
                          ? [
                              widget.pri.withOpacity(0.16),
                              widget.priLight.withOpacity(0.055),
                              Colors.white.withOpacity(0.010),
                              Colors.transparent,
                            ]
                          : [
                              widget.pri.withOpacity(0.075),
                              widget.priLight.withOpacity(0.025),
                              Colors.white.withOpacity(0.006),
                              Colors.transparent,
                            ],
                      stops: const [0.0, 0.30, 0.68, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                top: 0,
                height: focused ? 1.6 : 1.25,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(focused ? 0.34 : 0.22),
                          widget.priLight.withOpacity(focused ? 0.82 : 0.55),
                          Colors.white.withOpacity(focused ? 0.34 : 0.22),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: focused ? 20 : 16,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(focused ? 0.095 : 0.060),
                          widget.priLight.withOpacity(focused ? 0.026 : 0.010),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  widget.icon == null ? 18 : 12,
                  5,
                  14,
                  5,
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.priLight.withOpacity(
                                focused ? 0.18 : 0.09,
                              ),
                              widget.pri.withOpacity(
                                focused ? 0.08 : 0.035,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 17,
                          color: widget.priLight.withOpacity(
                            focused ? 0.92 : 0.56,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: widget.isHero ? 50 : 44,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            TextField(
                              controller: widget.controller,
                              focusNode: _focus,
                              maxLines: widget.isHero ? 1 : 2,
                              minLines: 1,
                              textAlignVertical: TextAlignVertical.center,
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: widget.isHero ? 18 : 14,
                                fontWeight: widget.isHero
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: Colors.white.withOpacity(0.94),
                                height: 1.15,
                              ),
                              cursorColor: widget.priLight,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '',
                                filled: false,
                                fillColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: widget.isHero ? 16 : 13,
                                ),
                              ),
                            ),
                            if (!_hasText && visibleHint.isNotEmpty)
                              IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 80),
                                  opacity: focused ? 0.68 : 0.42,
                                  child: Transform.translate(
                                    offset: const Offset(0, -1),
                                    child: Text(
                                      visibleHint,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: widget.isHero ? 18 : 14,
                                        fontWeight: widget.isHero
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (focused && !_hasText && _typedPrompt.isNotEmpty)
                              Positioned(
                                left: _cursorApproxOffset(
                                  _typedPrompt,
                                  widget.isHero ? 18 : 14,
                                  widget.isHero
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                                child: IgnorePointer(
                                  child: AnimatedOpacity(
                                    opacity: 0.78,
                                    duration: const Duration(milliseconds: 70),
                                    child: Container(
                                      width: 1.6,
                                      height: widget.isHero ? 20 : 16,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.priLight.withOpacity(0.88),
                                        borderRadius:
                                            BorderRadius.circular(99),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.priLight
                                                .withOpacity(0.65),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _cursorApproxOffset(String text, double fontSize, FontWeight weight) {
    final multiplier = weight == FontWeight.w800 ? 0.57 : 0.54;
    final raw = text.length * fontSize * multiplier;
    return raw.clamp(0.0, 260.0);
  }
}

class _SuggestionStrip extends StatelessWidget {
  final Color pri;
  final Color priLight;
  final List<String> items;
  final ValueChanged<String> onTap;

  const _SuggestionStrip({
    required this.pri,
    required this.priLight,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];

          return _PressableScale(
            onTap: () => onTap(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    pri.withOpacity(0.14),
                    priLight.withOpacity(0.045),
                    Colors.white.withOpacity(0.020),
                  ],
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.74),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimeEditRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const TimeEditRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.13),
              color.withOpacity(0.045),
              Colors.white.withOpacity(0.004),
              Colors.transparent,
            ],
            stops: const [0.0, 0.34, 0.76, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: -12,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              right: 10,
              top: -11,
              height: 1.35,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.18),
                      color.withOpacity(0.60),
                      Colors.white.withOpacity(0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.24, 0.50, 0.76, 1.0],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.18),
                        color.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: color.withOpacity(0.95),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white.withOpacity(0.38),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.91),
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
    );
  }
}

class _LockedInCard extends StatelessWidget {
  final Color pri;
  final Color priLight;
  final int score;
  final String label;
  final String hint;

  const _LockedInCard({
    required this.pri,
    required this.priLight,
    required this.score,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final progress = score / 100;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pri.withOpacity(0.16),
            priLight.withOpacity(0.06),
            Colors.white.withOpacity(0.022),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: pri.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -14,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.sensors_rounded, size: 17, color: priLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Locked-in Signal',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                  ),
                  Text(
                    '$score/100',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.94),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor:
                      AlwaysStoppedAnimation(priLight.withOpacity(0.95)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: priLight.withOpacity(0.95),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Smart Bewertung',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                hint,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.52),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionGlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionGlassButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.98),
                    color.withOpacity(0.84),
                    color.withOpacity(0.70),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.09),
                    Colors.white.withOpacity(0.035),
                    Colors.white.withOpacity(0.016),
                  ],
                ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? color.withOpacity(0.30)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isPrimary ? 28 : 16,
              offset: const Offset(0, 8),
              spreadRadius: isPrimary ? -10 : -12,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              top: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(isPrimary ? 0.34 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: isPrimary
                        ? Colors.white
                        : Colors.white.withOpacity(0.80),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isPrimary
                          ? Colors.white
                          : Colors.white.withOpacity(0.82),
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

class _CircleGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleGlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.10),
              Colors.white.withOpacity(0.04),
              Colors.white.withOpacity(0.018),
            ],
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.64),
        ),
      ),
    );
  }
}

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
      child: _PressableScale(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.11),
                color.withOpacity(0.045),
                Colors.white.withOpacity(0.016),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.90)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color.withOpacity(0.90),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 150),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.976).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}