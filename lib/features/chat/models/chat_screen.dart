import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/user_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/atmosphere_model.dart';
import '../../ai/services/ai_service.dart';
import 'chat_models.dart';
import 'voice_mode_screen.dart';

// ═══════════════════════════════════════════
// GREETING / PLACEHOLDER DATA
// ═══════════════════════════════════════════

class _GreetingData {
  static List<String> getSubtitles(String name) => [
        'Was steht heute an?',
        'Bereit für den Tag?',
        'Was beschäftigt dich?',
        'Wie kann ich helfen?',
        'Was hast du vor?',
        'Lass uns loslegen',
        'Worauf liegt dein Fokus?',
        'Was brauchst du gerade?',
        'Erzähl mir davon',
        'Neuer Tag, neue Energie',
        'Was möchtest du erreichen?',
        'Ich bin für dich da',
      ];

  static String getTimePrefix() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Gute Nacht';
    if (h < 12) return 'Guten Morgen';
    if (h < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  static String getSubtitle(String name) {
    final subs = getSubtitles(name);
    final seed = DateTime.now().hour * 7 + name.hashCode;
    return subs[seed.abs() % subs.length];
  }
}

class _PlaceholderData {
  static const List<String> _hints = [
    'Frag mich was...',
    'Was beschäftigt dich?',
    'Erzähl mir davon...',
    'Ich höre zu...',
    'Was kann ich tun?',
    'Schreib drauf los...',
    'Dein nächster Schritt?',
    'Lass uns planen...',
  ];

  static String get() {
    final idx = (DateTime.now().minute ~/ 3) % _hints.length;
    return _hints[idx];
  }
}

// ═══════════════════════════════════════════
// MAIN WIDGET
// ═══════════════════════════════════════════

class NexiiaChatScreen extends StatefulWidget {
  final ValueChanged<bool>? onThreadToggled;

  const NexiiaChatScreen({
    super.key,
    this.onThreadToggled,
  });

  @override
  State<NexiiaChatScreen> createState() => _NexiiaChatScreenState();
}

class _NexiiaChatScreenState extends State<NexiiaChatScreen>
    with TickerProviderStateMixin {
  String _userName = '';
  List<ChatThread> _threads = [];
  ChatThread? _activeThread;

  bool _isAiTyping = false;
  bool _companionOn = true;
  bool _plusMenuOpen = false;
  bool _headerMenuOpen = false;
  bool _dotsMenuOpen = false;

  String _placeholder = '';
  String _subtitle = '';

  late AtmosphereModel _atmo;
  late Color _pri;
  late Color _sec;

  bool get _isCrystal => _atmo.isCrystalGlass;

  final TextEditingController _msgController = TextEditingController();
  final NexiiaAI _nexiiaAI = NexiiaAI();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  late AnimationController _ambientCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _breathCtrl;
  late AnimationController _placeholderCtrl;
  late AnimationController _greetCtrl;
  late AnimationController _plusCtrl;
  late AnimationController _headerCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _companionCtrl;
  late AnimationController _dotsCtrl;

  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  String get _uid => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  @override
  void initState() {
    super.initState();

    _userName = UserPreferences.getUserName();
    _atmo = UserPreferences.getAtmosphere();
    _pri = _atmo.colors.primary;
    _sec = _atmo.colors.secondary;
    _placeholder = _PlaceholderData.get();
    _subtitle = _GreetingData.getSubtitle(_userName);

    _ambientCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _entryFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _placeholderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _plusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _companionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _initMockData();
    _entryCtrl.forward();
    _greetCtrl.forward();
    _placeholderCtrl.forward();
    _startPlaceholderLoop();

    _msgController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _startPlaceholderLoop() {
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      _placeholderCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _placeholder = _PlaceholderData.get());
        _placeholderCtrl.forward();
      });
      _startPlaceholderLoop();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _ambientCtrl,
      _breathCtrl,
      _entryCtrl,
      _placeholderCtrl,
      _greetCtrl,
      _plusCtrl,
      _headerCtrl,
      _glowCtrl,
      _companionCtrl,
      _dotsCtrl,
    ]) {
      c.dispose();
    }

    _msgController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _initMockData() {
    final now = DateTime.now();

    _threads = [
      ChatThread(
        id: 'mock1',
        title: 'Tagesplan für Montag',
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Erstelle mir einen produktiven Tagesplan für heute.',
            isUser: true,
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'm2',
            text:
                'Hier ist dein Plan:\n\n☀️ 07:00 – Morgenroutine\n🎯 08:00 – Deep Work Block\n☕ 10:00 – Kurze Pause\n💻 10:15 – Meetings & Mails\n🍽️ 12:00 – Mittagspause\n🧠 13:00 – Kreativarbeit\n📋 15:00 – Admin & Planung\n🏃 17:00 – Bewegung\n📖 19:00 – Abendgestaltung',
            isUser: false,
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ChatThread(
        id: 'mock2',
        title: 'Motivation am Morgen',
        messages: [
          ChatMessage(
            id: 'm3',
            text: 'Gib mir einen motivierenden Impuls für den Tag.',
            isUser: true,
            timestamp: now.subtract(const Duration(days: 1)),
          ),
          ChatMessage(
            id: 'm4',
            text:
                'Jeder Tag ist ein neues Kapitel. Du musst es nicht perfekt schreiben – nur ehrlich. Fang mit dem ersten Satz an. ✨',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // ═══════════════════════════════════════════
  // CHAT LOGIC
  // ═══════════════════════════════════════════

  void _createNewChat({String? initialPrompt}) {
    HapticFeedback.lightImpact();

    final now = DateTime.now();
    final trimmed = initialPrompt?.trim();

    final title = (trimmed != null && trimmed.isNotEmpty)
        ? (trimmed.length > 30 ? '${trimmed.substring(0, 30)}…' : trimmed)
        : 'Neuer Chat';

    final thread = ChatThread(
      id: _uid,
      title: title,
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _threads.insert(0, thread);
      _activeThread = thread;
    });

    widget.onThreadToggled?.call(true);

    if (trimmed != null && trimmed.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        _sendMessageToExistingThread(trimmed);
      });
    }
  }

  void _openThread(ChatThread thread) {
    HapticFeedback.selectionClick();
    setState(() => _activeThread = thread);
    widget.onThreadToggled?.call(true);
    _scrollToBottom();
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    _inputFocus.unfocus();
    _closeAllMenus();
    setState(() => _activeThread = null);
    widget.onThreadToggled?.call(false);
  }

  void _handleSend() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    if (_activeThread == null) {
      _createNewChat(initialPrompt: text);
      _msgController.clear();
      return;
    }

    _sendMessageToExistingThread(text);
  }

  void _sendMessageToExistingThread(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _activeThread == null) return;

    HapticFeedback.lightImpact();
    final now = DateTime.now();

    final userMsg = ChatMessage(
      id: _uid,
      text: trimmed,
      isUser: true,
      timestamp: now,
    );

    widget.onThreadToggled?.call(true);

    final threadId = _activeThread!.id;

    setState(() {
      final idx = _threads.indexWhere((t) => t.id == threadId);
      if (idx == -1) return;

      String newTitle = _threads[idx].title;
      if (_threads[idx].messages.isEmpty) {
        newTitle =
            trimmed.length > 30 ? '${trimmed.substring(0, 30)}…' : trimmed;
      }

      final updated = ChatThread(
        id: _threads[idx].id,
        title: newTitle,
        messages: [..._threads[idx].messages, userMsg],
        createdAt: _threads[idx].createdAt,
        updatedAt: now,
      );

      _threads[idx] = updated;
      _activeThread = updated;
      _isAiTyping = true;
    });

    _msgController.clear();
    _scrollToBottom();

    _nexiiaAI.sendMessage(trimmed).then((aiResponse) {
      if (!mounted) return;

      final intent = _nexiiaAI.extractIntent(aiResponse);
      if (intent != null) {
        _handleIntent(intent);
      }

      final clean = NexiiaAI.sanitizeForUI(
        _nexiiaAI.cleanMessage(aiResponse),
      );

      final aiMsg = ChatMessage(
        id: _uid,
        text: clean,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        final idx = _threads.indexWhere((t) => t.id == threadId);
        if (idx == -1) {
          _isAiTyping = false;
          return;
        }

        final latestThread = _threads[idx];

        final updated = ChatThread(
          id: latestThread.id,
          title: latestThread.title,
          messages: [...latestThread.messages, aiMsg],
          createdAt: latestThread.createdAt,
          updatedAt: DateTime.now(),
        );

        _threads[idx] = updated;
        if (_activeThread?.id == updated.id) {
          _activeThread = updated;
        }

        _isAiTyping = false;
      });

      _scrollToBottom();
    }).catchError((e) {
      debugPrint('❌ AI Fehler: $e');
      if (!mounted) return;
      setState(() => _isAiTyping = false);
    });
  }

  void _handleIntent(Map<String, dynamic> intent) {
    final type = intent['intent'] ?? '';

    switch (type) {
      case 'create_appointment':
        _createAppointmentFromIntent(intent);
        break;
      case 'create_reminder':
        _createReminderFromIntent(intent);
        break;
      case 'open_solve':
        debugPrint('🧠 Lösen: ${intent['problem']}');
        break;
      case 'create_dayplan':
        debugPrint('📋 Tagesplan erstellt');
        break;
      case 'start_focus':
        debugPrint('🎯 Fokus: ${intent['title']}');
        break;
      case 'navigate':
        _handleNavigation(intent['target'] ?? '');
        break;
    }
  }

  Future<void> _createAppointmentFromIntent(Map<String, dynamic> intent) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('appointments').insert({
        'user_id': user.id,
        'title': intent['title'] ?? 'Termin',
        'date':
            intent['date'] ?? DateTime.now().toIso8601String().split('T')[0],
        'start_time': intent['start_time'] ?? '09:00',
        'end_time': intent['end_time'] ?? '10:00',
        'category': intent['category'] ?? 'Puffer',
        'created_by': 'ai',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('📅 Termin erfolgreich eingetragen: ${intent['title']}');
    } catch (e) {
      debugPrint('❌ Termin-Fehler: $e');
    }
  }

  Future<void> _createReminderFromIntent(Map<String, dynamic> intent) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('reminders').insert({
        'user_id': user.id,
        'title': intent['title'] ?? 'Erinnerung',
        'datetime': intent['datetime'] ?? DateTime.now().toIso8601String(),
        'is_done': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('🔔 Erinnerung erfolgreich eingetragen: ${intent['title']}');
    } catch (e) {
      debugPrint('❌ Erinnerung-Fehler: $e');
    }
  }

  void _handleNavigation(String target) {
    debugPrint('🧭 Navigation zu: $target');
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Kopiert',
          style: TextStyle(
            fontFamily: 'Satoshi',
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openVoiceMode() {
    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NexiiaVoiceModeScreen(
          userName: _userName,
          onClose: () => Navigator.pop(context),
        ),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _closeAllMenus() {
    if (_plusMenuOpen) _plusCtrl.reverse();
    if (_headerMenuOpen) _headerCtrl.reverse();
    if (_dotsMenuOpen) _dotsCtrl.reverse();

    setState(() {
      _plusMenuOpen = false;
      _headerMenuOpen = false;
      _dotsMenuOpen = false;
    });
  }

  void _togglePlus() {
    HapticFeedback.mediumImpact();

    if (_headerMenuOpen) _headerCtrl.reverse();
    if (_dotsMenuOpen) _dotsCtrl.reverse();

    setState(() {
      _headerMenuOpen = false;
      _dotsMenuOpen = false;
      _plusMenuOpen = !_plusMenuOpen;
    });

    _plusMenuOpen ? _plusCtrl.forward() : _plusCtrl.reverse();
  }

  void _toggleHeader() {
    HapticFeedback.mediumImpact();

    if (_plusMenuOpen) _plusCtrl.reverse();
    if (_dotsMenuOpen) _dotsCtrl.reverse();

    setState(() {
      _plusMenuOpen = false;
      _dotsMenuOpen = false;
      _headerMenuOpen = !_headerMenuOpen;
    });

    _headerMenuOpen ? _headerCtrl.forward() : _headerCtrl.reverse();
  }

  void _toggleDots() {
    HapticFeedback.mediumImpact();

    if (_plusMenuOpen) _plusCtrl.reverse();
    if (_headerMenuOpen) _headerCtrl.reverse();

    setState(() {
      _plusMenuOpen = false;
      _headerMenuOpen = false;
      _dotsMenuOpen = !_dotsMenuOpen;
    });

    _dotsMenuOpen ? _dotsCtrl.forward() : _dotsCtrl.reverse();
  }

  void _toggleCompanion() {
    HapticFeedback.lightImpact();
    _companionCtrl.forward().then((_) => _companionCtrl.reverse());
    setState(() => _companionOn = !_companionOn);
  }

  void _deleteThread(ChatThread thread) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(ctx).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.08),
                  Colors.black.withOpacity(0.10),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.26),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0x33FF6B6B),
                        const Color(0x16FF4D4D),
                        Colors.black.withOpacity(0.05),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 0.6,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chat löschen?',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dieser Chat wird unwiderruflich gelöscht.',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white40,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.14),
                                Colors.white.withOpacity(0.06),
                                Colors.black.withOpacity(0.06),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.14),
                              width: 0.6,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Abbrechen',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                color: AppColors.white60,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _threads.removeWhere((t) => t.id == thread.id);
                            if (_activeThread?.id == thread.id) {
                              _activeThread = null;
                              widget.onThreadToggled?.call(false);
                            }
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x44E5484D),
                                Color(0x22E5484D),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0x55E5484D),
                              width: 0.6,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Löschen',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                color: AppColors.error,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Jetzt';
    if (diff.inHours < 1) return 'Vor ${diff.inMinutes} Min';
    if (diff.inHours < 24) return 'Vor ${diff.inHours} Std';
    if (diff.inDays == 1) return 'Gestern';
    return '${dt.day}.${dt.month}.';
  }

  Color _priOp(double opacity) =>
      Color.fromRGBO(_pri.red, _pri.green, _pri.blue, opacity);

  Color _secOp(double opacity) =>
      Color.fromRGBO(_sec.red, _sec.green, _sec.blue, opacity);

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    final anyMenuOpen = _plusMenuOpen || _headerMenuOpen || _dotsMenuOpen;
    final threadOpen = _activeThread != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _BgPainter(
                  t: _ambientCtrl.value,
                  pri: _pri,
                  sec: _sec,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.025),
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,
              child: Column(
                children: [
                  SizedBox(height: topPad),
                  _buildHeader(),
                  Expanded(
                    child: threadOpen
                        ? _buildChat(keyboardH)
                        : (_threads.isEmpty ? _buildWelcome() : _buildList()),
                  ),
                  _buildInput(
                    keyboardH > 0
                        ? keyboardH
                        : bottomPad + (threadOpen ? 12 : 98),
                  ),
                ],
              ),
            ),
          ),
          if (anyMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeAllMenus,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 200),
                  builder: (_, val, __) => BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 6 * val,
                      sigmaY: 6 * val,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.22 * val),
                    ),
                  ),
                ),
              ),
            ),
          if (_plusMenuOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardH > 0
                  ? keyboardH + 76
                  : bottomPad + (threadOpen ? 76 : 162),
              child: _buildPlusMenu(),
            ),
          if (_headerMenuOpen)
            Positioned(
              top: topPad + 56,
              right: 16,
              child: _buildHeaderMenu(),
            ),
          if (_dotsMenuOpen)
            Positioned(
              top: topPad + 56,
              right: 16,
              child: _buildDotsMenu(),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HEADER / MENUS
  // ═══════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (_activeThread != null) ...[
            GestureDetector(
              onTap: _goBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.white80,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _activeThread!.title,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildMetalIconButton(
              onTap: _toggleDots,
              size: 38,
              isActive: _dotsMenuOpen,
              icon: Icons.more_horiz_rounded,
            ),
          ] else ...[
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (_, __) => Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _isCrystal
                      ? Color.fromRGBO(
                          255,
                          255,
                          255,
                          0.65 + _breathCtrl.value * 0.22,
                        )
                      : _pri,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _priOp(0.42),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Nexiia',
              style: TextStyle(
                fontFamily: 'Satoshi',
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleCompanion,
              child: AnimatedBuilder(
                animation: Listenable.merge([_companionCtrl, _breathCtrl]),
                builder: (_, __) {
                  final bounce =
                      math.sin(_companionCtrl.value * math.pi) * 0.06;
                  final glow = _breathCtrl.value * 0.12;

                  return Transform.scale(
                    scale: 1.0 + bounce,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: _companionOn
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _priOp(0.24 + glow),
                                  _secOp(0.10 + glow),
                                  Colors.black.withOpacity(0.05),
                                ],
                                stops: const [0.0, 0.58, 1.0],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.14),
                                  Colors.white.withOpacity(0.06),
                                  Colors.black.withOpacity(0.06),
                                ],
                                stops: const [0.0, 0.58, 1.0],
                              ),
                        border: Border.all(
                          color: _companionOn
                              ? _priOp(0.24 + glow)
                              : Colors.white.withOpacity(0.14),
                          width: 0.6,
                        ),
                        boxShadow: _companionOn
                            ? [
                                BoxShadow(
                                  color: _priOp(0.12 + glow),
                                  blurRadius: 16,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _companionOn ? _pri : AppColors.white30,
                              shape: BoxShape.circle,
                              boxShadow: _companionOn
                                  ? [
                                      BoxShadow(
                                        color: _priOp(
                                          0.44 + _breathCtrl.value * 0.20,
                                        ),
                                        blurRadius: 5 + _breathCtrl.value * 2,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Companion',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              color: _companionOn
                                  ? (_isCrystal
                                      ? AppColors.white80
                                      : _priOp(0.92))
                                  : AppColors.white40,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildMetalIconButton(
              onTap: _toggleHeader,
              size: 44,
              isActive: _headerMenuOpen,
              icon: Icons.add_rounded,
              rotateByController: _headerCtrl,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetalIconButton({
    required VoidCallback onTap,
    required double size,
    required bool isActive,
    required IconData icon,
    AnimationController? rotateByController,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: rotateByController ?? kAlwaysDismissedAnimation,
        builder: (_, __) {
          final rot = rotateByController != null
              ? Curves.easeOutBack.transform(rotateByController.value) * 0.75
              : 0.0;

          return Transform.scale(
            scale: isActive ? 0.92 : 1.0,
            child: Transform.rotate(
              angle: rot,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActive
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _priOp(0.28),
                            _secOp(0.12),
                            Colors.black.withOpacity(0.05),
                          ],
                          stops: const [0.0, 0.58, 1.0],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.16),
                            Colors.white.withOpacity(0.07),
                            Colors.black.withOpacity(0.06),
                          ],
                          stops: const [0.0, 0.58, 1.0],
                        ),
                  border: Border.all(
                    color: isActive
                        ? _priOp(0.26)
                        : Colors.white.withOpacity(0.14),
                    width: 0.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    if (isActive)
                      BoxShadow(
                        color: _priOp(0.12),
                        blurRadius: 16,
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isActive ? _pri : AppColors.white80,
                  size: 22,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _glassMenu({
    required AnimationController ctrl,
    required double width,
    required List<Widget> children,
  }) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final p = Curves.easeOutBack.transform(ctrl.value);

        return Transform.scale(
          scale: 0.90 + p * 0.10,
          alignment: Alignment.topRight,
          child: Opacity(
            opacity: Curves.easeOut.transform(ctrl.value),
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.34),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: _priOp(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.07),
                              Colors.black.withOpacity(0.09),
                            ],
                            stops: const [0.0, 0.52, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                            width: 0.7,
                          ),
                        ),
                      ),

                      // sehr schmale saubere Kante
                      Positioned(
                        left: 14,
                        right: 14,
                        top: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 0.9,
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                      ),

                      // leichte kontrollierte Reflection, nicht zu breit
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.09),
                                  Colors.white.withOpacity(0.025),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    String? sub,
    VoidCallback onTap, {
    bool danger = false,
    bool safe = false,
  }) {
    final color = danger
        ? AppColors.error
        : safe
            ? const Color(0xFFFF6B9D)
            : (_isCrystal ? AppColors.white80 : _pri);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(color.red, color.green, color.blue, 0.24),
                    Color.fromRGBO(color.red, color.green, color.blue, 0.10),
                    Colors.black.withOpacity(0.04),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: danger
                          ? AppColors.error
                          : safe
                              ? const Color(0xFFFF6B9D)
                              : AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white30,
                        fontSize: 11,
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

  Widget _menuDivider() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        height: 0.5,
        color: Colors.white.withOpacity(0.08),
      );

  Widget _buildHeaderMenu() => _glassMenu(
        ctrl: _headerCtrl,
        width: 238,
        children: [
          _menuItem(Icons.add_rounded, 'Neuer Chat', null, () {
            _closeAllMenus();
            _createNewChat();
          }),
          _menuItem(
            Icons.event_note_rounded,
            'Termin hinzufügen',
            'Im Planer eintragen',
            () {
              _closeAllMenus();
              _createNewChat(
                initialPrompt: 'Ich möchte einen Termin eintragen.',
              );
            },
          ),
          _menuItem(
            Icons.account_tree_rounded,
            'Struktur planen',
            'Problem zerlegen',
            () {
              _closeAllMenus();
              _createNewChat(
                initialPrompt: 'Hilf mir eine Struktur zu planen.',
              );
            },
          ),
          _menuItem(
            Icons.psychology_rounded,
            'Therapie',
            'Geführtes Gespräch',
            () {
              _closeAllMenus();
              _createNewChat(
                initialPrompt:
                    'Ich möchte ein therapeutisches Gespräch führen.',
              );
            },
          ),
          _menuDivider(),
          _menuItem(
            Icons.favorite_rounded,
            'SafeSpace',
            'Sicherer Raum für dich',
            () {
              _closeAllMenus();
              _createNewChat(
                initialPrompt: 'Ich brauche einen sicheren Raum zum Reden.',
              );
            },
            safe: true,
          ),
        ],
      );

  Widget _buildDotsMenu() => _glassMenu(
        ctrl: _dotsCtrl,
        width: 224,
        children: [
          _menuItem(Icons.copy_rounded, 'Chat kopieren', 'Gesamten Verlauf',
              () {
            _closeAllMenus();
            if (_activeThread != null) {
              final all = _activeThread!.messages
                  .map((m) => '${m.isUser ? "Du" : "Nexiia"}: ${m.text}')
                  .join('\n\n');
              _copyText(all);
            }
          }),
          _menuItem(
            Icons.text_snippet_rounded,
            'Letzte Antwort',
            'Kopieren',
            () {
              _closeAllMenus();
              if (_activeThread != null && _activeThread!.messages.isNotEmpty) {
                ChatMessage? lastAi;
                for (final m in _activeThread!.messages.reversed) {
                  if (!m.isUser) {
                    lastAi = m;
                    break;
                  }
                }
                _copyText(lastAi?.text ?? _activeThread!.messages.last.text);
              }
            },
          ),
          _menuItem(Icons.share_rounded, 'Teilen', null, () {
            _closeAllMenus();
          }),
          _menuDivider(),
          _menuItem(Icons.delete_outline_rounded, 'Chat löschen', null, () {
            _closeAllMenus();
            if (_activeThread != null) {
              _deleteThread(_activeThread!);
            }
          }, danger: true),
        ],
      );
  // ═══════════════════════════════════════════
  // LIST / WELCOME
  // ═══════════════════════════════════════════

  Widget _buildList() {
    return Column(
      children: [
        _buildStickyHeader(),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            itemCount: _threads.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: Row(
                    children: [
                      const Text(
                        'CHATS',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _createNewChat,
                        child: Text(
                          '+ Neu',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: _pri,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildThreadTile(_threads[i - 1]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStickyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _greetCtrl,
            builder: (_, __) {
              final p = Curves.easeOutCubic.transform(_greetCtrl.value);
              return Opacity(
                opacity: p,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - p)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _GreetingData.getTimePrefix(),
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: _isCrystal ? AppColors.white40 : _priOp(0.52),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _subtitle,
                          key: ValueKey(_subtitle),
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color:
                                _isCrystal ? AppColors.white30 : _priOp(0.46),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(right: 20),
              itemCount: kDefaultSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = kDefaultSuggestions[i];
                return GestureDetector(
                  onTap: () => _createNewChat(initialPrompt: s.prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _priOp(0.18),
                          _secOp(0.08),
                          Colors.black.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.60, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: _priOp(0.06),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, color: _priOp(0.70), size: 15),
                        const SizedBox(width: 8),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color:
                                _isCrystal ? AppColors.white80 : _priOp(0.88),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadTile(ChatThread thread) {
    return GestureDetector(
      onTap: () => _openThread(thread),
      onLongPress: () => _deleteThread(thread),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.10),
              Colors.white.withOpacity(0.045),
              Colors.black.withOpacity(0.06),
            ],
            stops: const [0.0, 0.54, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // nur eine feine obere Kante, nicht breit
            Positioned(
              left: 14,
              right: 14,
              top: 0,
              child: IgnorePointer(
                child: Container(
                  height: 0.8,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _priOp(0.22),
                        _secOp(0.08),
                        Colors.black.withOpacity(0.03),
                      ],
                      stops: const [0.0, 0.58, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    thread.lastWasAi
                        ? Icons.auto_awesome_rounded
                        : Icons.chat_bubble_outline_rounded,
                    color: _isCrystal ? AppColors.white80 : _priOp(0.84),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        thread.lastMessagePreview,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white30,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _fmtDate(thread.updatedAt),
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white20,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.white15,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_ambientCtrl, _breathCtrl]),
              builder: (_, __) {
                final pulse =
                    0.86 + 0.14 * math.sin(_ambientCtrl.value * math.pi * 2);
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _priOp(0.36),
                          _secOp(0.16),
                          const Color(0x00000000),
                        ],
                        stops: const [0.0, 0.60, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _priOp(0.88),
                          boxShadow: [
                            BoxShadow(
                              color: _priOp(0.38),
                              blurRadius: 26,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _greetCtrl,
              builder: (_, __) {
                final p = Curves.easeOutCubic.transform(_greetCtrl.value);
                return Opacity(
                  opacity: p,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - p)),
                    child: Column(
                      children: [
                        Text(
                          '${_GreetingData.getTimePrefix()}, $_userName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color:
                                _isCrystal ? AppColors.white30 : _priOp(0.45),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < 4 && i < kDefaultSuggestions.length; i++)
                  GestureDetector(
                    onTap: () => _createNewChat(
                      initialPrompt: kDefaultSuggestions[i].prompt,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _priOp(0.18),
                            _secOp(0.08),
                            Colors.black.withOpacity(0.05),
                          ],
                          stops: const [0.0, 0.60, 1.0],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            kDefaultSuggestions[i].icon,
                            color: _priOp(0.56),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            kDefaultSuggestions[i].label,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              color:
                                  _isCrystal ? AppColors.white80 : _priOp(0.82),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }

  // ═══════════════════════════════════════════
  // CHAT
  // ═══════════════════════════════════════════

  Widget _buildChat(double kbH) {
    final msgs = _activeThread!.messages;

    return GestureDetector(
      onTap: () {
        _inputFocus.unfocus();
        _closeAllMenus();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 8, 16, kbH > 0 ? 20 : 100),
        itemCount: msgs.length + (_isAiTyping ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == msgs.length && _isAiTyping) {
            return _buildTyping();
          }
          return _buildBubble(msgs[i]);
        },
      ),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAiOrb(28),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomRight: Radius.circular(22),
              bottomLeft: Radius.circular(8),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.08),
                          Colors.black.withOpacity(0.08),
                        ],
                        stops: const [0.0, 0.56, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                        width: 0.6,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: AnimatedBuilder(
                      animation: _ambientCtrl,
                      builder: (_, __) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (j) {
                          final v = math.sin(
                            (_ambientCtrl.value * math.pi * 2) + (j * 0.8),
                          );
                          final op = 0.34 + 0.42 * ((v + 1) / 2);

                          return Container(
                            margin: EdgeInsets.only(right: j < 2 ? 4.0 : 0.0),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _isCrystal
                                  ? Color.fromRGBO(255, 255, 255, op)
                                  : _priOp(op),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiOrb(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _priOp(0.28),
            _secOp(0.12),
            Colors.black.withOpacity(0.05),
          ],
          stops: const [0.0, 0.58, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _priOp(0.14),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: _isCrystal ? AppColors.white80 : _pri,
        size: size * 0.46,
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - val)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _buildAiOrb(28),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(isUser ? 22 : 8),
                      bottomRight: Radius.circular(isUser ? 8 : 22),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Stack(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isUser
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _priOp(0.30),
                                        _secOp(0.12),
                                        Colors.black.withOpacity(0.05),
                                      ],
                                      stops: const [0.0, 0.58, 1.0],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.18),
                                        Colors.white.withOpacity(0.08),
                                        Colors.black.withOpacity(0.08),
                                      ],
                                      stops: const [0.0, 0.56, 1.0],
                                    ),
                              border: Border.all(
                                color: isUser
                                    ? _priOp(0.18)
                                    : Colors.white.withOpacity(0.16),
                                width: 0.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                                if (isUser)
                                  BoxShadow(
                                    color: _priOp(0.10),
                                    blurRadius: 18,
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            top: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: const Alignment(-1.0, -0.9),
                                    end: const Alignment(0.8, 1.0),
                                    colors: [
                                      Colors.white.withOpacity(0.12),
                                      Colors.white.withOpacity(0.03),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.18, 0.40],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                color: isUser
                                    ? AppColors.white
                                    : AppColors.white80,
                                fontSize: 15,
                                height: 1.5,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmtTime(msg.timestamp),
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white15,
                          fontSize: 11,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _copyText(msg.text),
                          child: const Text(
                            'Kopieren',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              color: AppColors.white20,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PLUS MENU / INPUT
  // ═══════════════════════════════════════════

  Widget _buildPlusMenu() {
    return AnimatedBuilder(
      animation: _plusCtrl,
      builder: (_, __) {
        final p = Curves.easeOutBack.transform(_plusCtrl.value);
        if (p < 0.01) return const SizedBox.shrink();

        return Opacity(
          opacity: Curves.easeOut.transform(_plusCtrl.value),
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - p)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.14),
                              Colors.white.withOpacity(0.06),
                              Colors.black.withOpacity(0.09),
                            ],
                            stops: const [0.0, 0.52, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                            width: 0.7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.26),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        top: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 0.9,
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: 22,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.02),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _plusChip(Icons.account_tree_rounded, 'Struktur',
                                () {
                              _closeAllMenus();
                              _createNewChat(
                                initialPrompt:
                                    'Hilf mir eine Struktur zu planen.',
                              );
                            }),
                            _plusChip(
                              Icons.record_voice_over_rounded,
                              'Live Talk',
                              () {
                                _closeAllMenus();
                                _openVoiceMode();
                              },
                            ),
                            _plusChip(Icons.camera_alt_rounded, 'Kamera', () {
                              _closeAllMenus();
                            }),
                            _plusChip(Icons.event_rounded, 'Termine', () {
                              _closeAllMenus();
                              _createNewChat(
                                initialPrompt:
                                    'Ich möchte einen Termin eintragen.',
                              );
                            }),
                            _plusChip(Icons.favorite_rounded, 'SafeSpace', () {
                              _closeAllMenus();
                              _createNewChat(
                                initialPrompt:
                                    'Ich brauche einen sicheren Raum zum Reden.',
                              );
                            }, safe: true),
                            _plusChip(Icons.auto_fix_high_rounded, 'Fokus', () {
                              _closeAllMenus();
                              _createNewChat(
                                initialPrompt:
                                    'Hilf mir jetzt in einen klaren Fokus zu kommen.',
                              );
                            }),
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
      },
    );
  }

  Widget _plusChip(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool safe = false,
  }) {
    final color = safe
        ? const Color(0xFFFF6B9D)
        : (_isCrystal ? AppColors.white80 : _pri);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(color.red, color.green, color.blue, 0.22),
              Color.fromRGBO(color.red, color.green, color.blue, 0.09),
              Colors.black.withOpacity(0.04),
            ],
            stops: const [0.0, 0.58, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                color: Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  0.92,
                ),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(double bottomPad) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutExpo,
      padding: EdgeInsets.fromLTRB(14, 6, 14, bottomPad + 6),
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathCtrl, _glowCtrl]),
        builder: (_, __) {
          final glow = 0.04 + _glowCtrl.value * 0.05;
          final borderGlow = 0.10 + _breathCtrl.value * 0.05;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _priOp(glow),
                  blurRadius: 18,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.14),
                            Colors.white.withOpacity(0.07),
                            Colors.black.withOpacity(0.09),
                          ],
                          stops: const [0.0, 0.50, 1.0],
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(
                            _pri.red,
                            _pri.green,
                            _pri.blue,
                            borderGlow,
                          ),
                          width: 0.75,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      top: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 0.9,
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 18,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _togglePlus,
                            child: AnimatedBuilder(
                              animation: _plusCtrl,
                              builder: (_, __) {
                                final rot = Curves.easeOutBack
                                        .transform(_plusCtrl.value) *
                                    0.75;
                                final isOpen = _plusMenuOpen;

                                return Transform.scale(
                                  scale: isOpen ? 0.92 : 1.0,
                                  child: Transform.rotate(
                                    angle: rot,
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isOpen
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  _priOp(0.28),
                                                  _secOp(0.12),
                                                ],
                                              )
                                            : LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white
                                                      .withOpacity(0.16),
                                                  Colors.white
                                                      .withOpacity(0.07),
                                                  Colors.black
                                                      .withOpacity(0.05),
                                                ],
                                                stops: const [0.0, 0.55, 1.0],
                                              ),
                                        border: Border.all(
                                          color: isOpen
                                              ? _priOp(0.24)
                                              : Colors.white.withOpacity(0.14),
                                          width: 0.6,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.16),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        color:
                                            isOpen ? _pri : AppColors.white80,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  TextField(
                                    controller: _msgController,
                                    focusNode: _inputFocus,
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      color: AppColors.white,
                                      fontSize: 15,
                                      height: 1.15,
                                    ),
                                    maxLines: 4,
                                    minLines: 1,
                                    textAlignVertical: TextAlignVertical.center,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: '',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        top: 11,
                                        bottom: 11,
                                      ),
                                      fillColor: Colors.transparent,
                                      filled: false,
                                    ),
                                    cursorColor: AppColors.white,
                                    onTap: _closeAllMenus,
                                    onSubmitted: (_) => _handleSend(),
                                  ),
                                  if (_msgController.text.isEmpty)
                                    IgnorePointer(
                                      child: AnimatedBuilder(
                                        animation: _placeholderCtrl,
                                        builder: (_, __) {
                                          final op = Curves.easeInOut.transform(
                                            _placeholderCtrl.value,
                                          );
                                          return Opacity(
                                            opacity: op * 0.52,
                                            child: Transform.translate(
                                              offset: const Offset(0, -1.5),
                                              child: Text(
                                                _placeholder,
                                                style: const TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  color: AppColors.white,
                                                  fontSize: 15,
                                                  height: 1.1,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _openVoiceMode,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.14),
                                    Colors.white.withOpacity(0.06),
                                    Colors.black.withOpacity(0.05),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 0.6,
                                ),
                              ),
                              child: const Icon(
                                Icons.mic_none_rounded,
                                color: AppColors.white60,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _handleSend,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isCrystal
                                      ? [
                                          Colors.white.withOpacity(0.95),
                                          Colors.white.withOpacity(0.72),
                                          Colors.white.withOpacity(0.42),
                                        ]
                                      : [
                                          _pri,
                                          Color.lerp(_pri, _sec, 0.55) ?? _pri,
                                          _sec,
                                        ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.20),
                                  width: 0.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _priOp(0.30),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: AppColors.white,
                                size: 18,
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
        },
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  final Color pri;
  final Color sec;

  const _BgPainter({
    required this.t,
    required this.pri,
    required this.sec,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.background,
    );

    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(pri.red, pri.green, pri.blue, 0.040),
          const Color(0x00000000),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.36),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.36),
      topGlow,
    );

    _blob(
      canvas,
      size.width * 0.20 + math.sin(t * math.pi * 2) * 30,
      size.height * 0.15 + math.cos(t * math.pi * 2) * 20,
      140,
      Color.fromRGBO(pri.red, pri.green, pri.blue, 0.12),
    );

    _blob(
      canvas,
      size.width * 0.85 + math.cos(t * math.pi * 2 + 1.2) * 26,
      size.height * 0.38 + math.sin(t * math.pi * 2 + 1.2) * 30,
      118,
      Color.fromRGBO(sec.red, sec.green, sec.blue, 0.09),
    );

    _blob(
      canvas,
      size.width * 0.42 + math.sin(t * math.pi * 2 + 2.5) * 20,
      size.height * 0.76 + math.cos(t * math.pi * 2 + 2.5) * 26,
      108,
      const Color(0x1406B6D4),
    );

    _blob(
      canvas,
      size.width * 0.76 + math.cos(t * math.pi * 2 + 3.8) * 15,
      size.height * 0.60 + math.sin(t * math.pi * 2 + 3.8) * 20,
      96,
      Color.fromRGBO(pri.red, pri.green, pri.blue, 0.06),
    );

    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -0.7),
        end: const Alignment(1.0, 0.8),
        colors: [
          Colors.white.withOpacity(0.035),
          Colors.white.withOpacity(0.010),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.6],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      sheenPaint,
    );
  }

  void _blob(Canvas c, double cx, double cy, double r, Color color) {
    final center = Offset(cx, cy);
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, const Color(0x00000000)],
        ).createShader(
          Rect.fromCircle(center: center, radius: r),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 62),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) {
    return old.t != t || old.pri != pri || old.sec != sec;
  }
}
