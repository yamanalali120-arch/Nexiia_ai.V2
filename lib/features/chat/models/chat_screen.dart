import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_preferences.dart';
import 'chat_models.dart';
import 'voice_mode_screen.dart';

class NexiiaChatScreen extends StatefulWidget {
  const NexiiaChatScreen({super.key});
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

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  late AnimationController _ambientCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  String get _uid => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  @override
  void initState() {
    super.initState();
    _userName = UserPreferences.getUserName();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _initMockData();
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _entryCtrl.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _initMockData() {
    final DateTime now = DateTime.now();
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
            text: 'Hier ist dein Plan:\n\n'
                '☀️ 07:00 – Morgenroutine\n'
                '🎯 08:00 – Deep Work Block\n'
                '☕ 10:00 – Kurze Pause\n'
                '💻 10:15 – Meetings & Mails\n'
                '🍽️ 12:00 – Mittagspause\n'
                '🧠 13:00 – Kreativarbeit\n'
                '📋 15:00 – Admin & Planung\n'
                '🏃 17:00 – Bewegung\n'
                '📖 19:00 – Abendgestaltung',
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
            text: 'Jeder Tag ist ein neues Kapitel. Du musst es nicht '
                'perfekt schreiben – nur ehrlich. Fang mit dem ersten '
                'Satz an. ✨',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _createNewChat({String? initialPrompt}) {
    HapticFeedback.lightImpact();
    final DateTime now = DateTime.now();
    String title;
    if (initialPrompt != null && initialPrompt.length > 30) {
      title = '${initialPrompt.substring(0, 30)}…';
    } else {
      title = initialPrompt ?? 'Neuer Chat';
    }
    final ChatThread thread = ChatThread(
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
    if (initialPrompt != null && initialPrompt.trim().isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _sendMessage(initialPrompt);
      });
    }
  }

  void _openThread(ChatThread thread) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeThread = thread;
    });
    _scrollToBottom();
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    _inputFocus.unfocus();
    setState(() {
      _activeThread = null;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final DateTime now = DateTime.now();
    final ChatMessage userMsg = ChatMessage(
      id: _uid,
      text: text.trim(),
      isUser: true,
      timestamp: now,
    );
    setState(() {
      final int idx = _threads.indexWhere((ChatThread t) => t.id == _activeThread!.id);
      if (idx == -1) return;
      String newTitle = _activeThread!.title;
      if (_activeThread!.messages.isEmpty) {
        newTitle = text.length > 30 ? '${text.substring(0, 30)}…' : text;
      }
      final ChatThread updated = ChatThread(
        id: _activeThread!.id,
        title: newTitle,
        messages: [..._activeThread!.messages, userMsg],
        createdAt: _activeThread!.createdAt,
        updatedAt: now,
      );
      _threads[idx] = updated;
      _activeThread = updated;
      _isAiTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final ChatMessage aiMsg = ChatMessage(
        id: _uid,
        text: _mockAiReply(text),
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        final int idx = _threads.indexWhere((ChatThread t) => t.id == _activeThread!.id);
        if (idx == -1) return;
        final ChatThread updated = ChatThread(
          id: _activeThread!.id,
          title: _activeThread!.title,
          messages: [..._activeThread!.messages, aiMsg],
          createdAt: _activeThread!.createdAt,
          updatedAt: DateTime.now(),
        );
        _threads[idx] = updated;
        _activeThread = updated;
        _isAiTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _mockAiReply(String input) {
    final String l = input.toLowerCase();
    if (l.contains('plan') || l.contains('tag')) {
      return 'Hier ein Vorschlag für deinen Tag:\n\n'
          '🌅 Morgens: Deep-Work-Session\n'
          '☀️ Mittags: Bewegung & frische Luft\n'
          '🌙 Abends: Reflexion & Planung\n\n'
          'Soll ich das genauer aufschlüsseln?';
    }
    if (l.contains('motiv')) {
      return 'Denk daran: Du bist weiter als gestern. Jeder kleine Schritt zählt. 🚀';
    }
    if (l.contains('mail') || l.contains('schreib')) {
      return 'Gerne! An wen geht die Mail und was ist die Kernbotschaft?';
    }
    if (l.contains('zusammenfass')) {
      return 'Klar, füge den Text ein den du zusammengefasst haben möchtest.';
    }
    if (l.contains('fokus') || l.contains('konzentration')) {
      return 'Drei Methoden:\n\n'
          '1. Pomodoro: 25 Min Fokus → 5 Min Pause\n'
          '2. Handy in anderen Raum\n'
          '3. Aufschreiben: „Jetzt arbeite ich an X"';
    }
    return 'Guter Gedanke! Was genau möchtest du als nächstes?';
  }

  void _deleteThread(ChatThread thread) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: const Color(0x88000000),
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Chat löschen?',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Dieser Chat wird unwiderruflich gelöscht.',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white60,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Abbrechen',
                style: TextStyle(fontFamily: 'Satoshi', color: AppColors.white50),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _threads.removeWhere((ChatThread t) => t.id == thread.id);
                  if (_activeThread?.id == thread.id) {
                    _activeThread = null;
                  }
                });
              },
              child: const Text(
                'Löschen',
                style: TextStyle(fontFamily: 'Satoshi', color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Kopiert',
          style: TextStyle(fontFamily: 'Satoshi', color: AppColors.white),
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openVoiceMode() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2) {
          return NexiiaVoiceModeScreen(
            userName: _userName,
            onClose: () => Navigator.pop(context),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (BuildContext context, Animation<double> anim,
            Animation<double> secondAnim, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _handleSend() {
    final String text = _msgController.text;
    if (text.trim().isEmpty) return;
    if (_activeThread == null) {
      _createNewChat(initialPrompt: text);
    } else {
      _sendMessage(text);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String _fmtTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Jetzt';
    if (diff.inHours < 1) return 'Vor ${diff.inMinutes} Min';
    if (diff.inHours < 24) return 'Vor ${diff.inHours} Std';
    if (diff.inDays == 1) return 'Gestern';
    return '${dt.day}.${dt.month}.';
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad = MediaQuery.of(context).padding.bottom;
    final double topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _BgPainter(t: _ambientCtrl.value),
                );
              },
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
                    child: _activeThread != null
                        ? _buildChat()
                        : (_threads.isEmpty ? _buildWelcome() : _buildList()),
                  ),
                  _buildInput(bottomPad),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                child: Icon(Icons.arrow_back_ios_rounded, color: AppColors.white80, size: 20),
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
            GestureDetector(
              onTap: () => _deleteThread(_activeThread!),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_horiz_rounded, color: AppColors.white40, size: 20),
              ),
            ),
          ] else ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.electricBlue,
                shape: BoxShape.circle,
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
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _companionOn = !_companionOn;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _companionOn
                      ? const Color(0x1F3478F6)
                      : const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _companionOn
                        ? const Color(0x333478F6)
                        : const Color(0x14FFFFFF),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _companionOn ? AppColors.electricBlue : AppColors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Companion',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: _companionOn ? AppColors.electricBlueLight : AppColors.white40,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _createNewChat(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.white60, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 16),
        Text(
          'Hey $_userName 👋',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Wobei kann ich dir helfen?',
          style: TextStyle(fontFamily: 'Satoshi', color: AppColors.white40, fontSize: 15),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: kDefaultSuggestions.length,
            separatorBuilder: (BuildContext ctx, int idx) => const SizedBox(width: 8),
            itemBuilder: (BuildContext ctx, int i) {
              final SuggestionChip s = kDefaultSuggestions[i];
              return GestureDetector(
                onTap: () => _createNewChat(initialPrompt: s.prompt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x0AFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, color: AppColors.white40, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        s.label,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white60,
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
        const SizedBox(height: 28),
        Row(
          children: [
            const Text(
              'CHATS',
              style: TextStyle(
                fontFamily: 'Satoshi',
                color: AppColors.white50,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _createNewChat(),
              child: const Text(
                '+ Neu',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.electricBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _threads.length; i++)
          _buildThreadTile(_threads[i]),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildThreadTile(ChatThread thread) {
    return GestureDetector(
      onTap: () => _openThread(thread),
      onLongPress: () => _deleteThread(thread),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0FFFFFFF), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x143478F6),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                thread.lastWasAi
                    ? Icons.auto_awesome_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: const Color(0x993478F6),
                size: 16,
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
            const Icon(Icons.chevron_right_rounded, color: AppColors.white15, size: 16),
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
              animation: _ambientCtrl,
              builder: (BuildContext context, Widget? child) {
                final double pulse =
                    0.85 + 0.15 * math.sin(_ambientCtrl.value * math.pi * 2);
                return Transform.scale(
                  scale: pulse,
                  child: child,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0x4D3478F6),
                      Color(0x0D3478F6),
                      Color(0x00000000),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xB33478F6),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D3478F6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hey $_userName',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wobei kann ich dir helfen?',
              style: TextStyle(fontFamily: 'Satoshi', color: AppColors.white40, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < 4 && i < kDefaultSuggestions.length; i++)
                  GestureDetector(
                    onTap: () => _createNewChat(initialPrompt: kDefaultSuggestions[i].prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x0AFFFFFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(kDefaultSuggestions[i].icon, color: AppColors.white30, size: 15),
                          const SizedBox(width: 8),
                          Text(
                            kDefaultSuggestions[i].label,
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              color: AppColors.white60,
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

  Widget _buildChat() {
    final List<ChatMessage> msgs = _activeThread!.messages;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: msgs.length + (_isAiTyping ? 1 : 0),
      itemBuilder: (BuildContext context, int i) {
        if (i == msgs.length && _isAiTyping) {
          return _buildTypingIndicator();
        }
        return _buildBubble(msgs[i]);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1F3478F6),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.electricBlueLight, size: 13),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
              border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
            ),
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (BuildContext context, Widget? child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (int j) {
                    final double v =
                        math.sin((_ambientCtrl.value * math.pi * 2) + (j * 0.8));
                    final double op = 0.3 + 0.4 * ((v + 1) / 2);
                    return Container(
                      margin: EdgeInsets.only(right: j < 2 ? 4.0 : 0.0),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, op),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final bool isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1F3478F6),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.electricBlueLight, size: 13),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0x243478F6) : const Color(0x0AFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 6),
                      bottomRight: Radius.circular(isUser ? 6 : 20),
                    ),
                    border: Border.all(
                      color: isUser ? const Color(0x1A3478F6) : const Color(0x0FFFFFFF),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: isUser ? AppColors.white : AppColors.white80,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmtTime(message.timestamp),
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white15,
                        fontSize: 11,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _copyText(message.text),
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
    );
  }

  Widget _buildInput(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPad + 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x14FFFFFF), width: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0x0DFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.white40, size: 19),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _msgController,
                focusNode: _inputFocus,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.white,
                  fontSize: 15,
                ),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Nachricht…',
                  hintStyle: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white30,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (String val) => _handleSend(),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _openVoiceMode,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Icon(Icons.mic_none_rounded, color: AppColors.white40, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.electricBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  const _BgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.background,
    );
    _blob(canvas, size.width * 0.2 + math.sin(t * math.pi * 2) * 30,
        size.height * 0.15 + math.cos(t * math.pi * 2) * 20, 130,
        const Color(0x143478F6));
    _blob(canvas, size.width * 0.85 + math.cos(t * math.pi * 2 + 1.2) * 25,
        size.height * 0.38 + math.sin(t * math.pi * 2 + 1.2) * 30, 110,
        const Color(0x0F8B5CF6));
    _blob(canvas, size.width * 0.4 + math.sin(t * math.pi * 2 + 2.5) * 20,
        size.height * 0.75 + math.cos(t * math.pi * 2 + 2.5) * 25, 100,
        const Color(0x0D06B6D4));
    _blob(canvas, size.width * 0.75 + math.cos(t * math.pi * 2 + 3.8) * 15,
        size.height * 0.6 + math.sin(t * math.pi * 2 + 3.8) * 20, 90,
        const Color(0x0AE879A8));
  }

  void _blob(Canvas canvas, double cx, double cy, double r, Color color) {
    final Offset center = Offset(cx, cy);
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [color, const Color(0x00000000)],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant _BgPainter oldDelegate) => oldDelegate.t != t;
}