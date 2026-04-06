import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/user_preferences.dart';
import '../../shared/models/atmosphere_model.dart';
import '../chat/models/chat_screen.dart';
import '../solve/solve_screen.dart';
import '../calender/calender_screen.dart';

// ═══════════════════════════════════════════════════════════
//  NEXIIA HOME SCREEN — Crystal Glass Edition
// ═══════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── State ──
  int _currentTabIndex = 0;
  String _userName = '';
  bool _voiceActive = false;
  bool _sheetOpen = false;
  late AtmosphereModel _atmo;
  late Color _pri;
  late Color _sec;
  late Color _glo;
  bool get _isCrystal => _atmo.isCrystalGlass;

  // ── Controllers ──
  late AnimationController _bgCtrl;
  late AnimationController _breathCtrl;
  late AnimationController _nebulaCtrl;
  late AnimationController _heartbeatCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _sonarCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _tabCtrl;
  late AnimationController _greetCtrl;
  late AnimationController _staggerCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _logoBreathCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _refractionCtrl; // Crystal refraction
  late AnimationController _prismaCtrl; // Crystal prisma rainbow

  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _userName = UserPreferences.getUserName();
    _atmo = UserPreferences.getAtmosphere();
    _pri = _atmo.colors.primary;
    _sec = _atmo.colors.secondary;
    _glo = _atmo.colors.glow;

    _pageCtrl = PageController();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _nebulaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _heartbeatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _sonarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _logoBreathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Crystal-exclusive controllers
    _refractionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _prismaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _greetCtrl.forward();
        _staggerCtrl.forward();
        _tabCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    for (final c in [
      _bgCtrl,
      _breathCtrl,
      _nebulaCtrl,
      _heartbeatCtrl,
      _floatCtrl,
      _sonarCtrl,
      _waveCtrl,
      _glowCtrl,
      _tabCtrl,
      _greetCtrl,
      _staggerCtrl,
      _shimmerCtrl,
      _logoBreathCtrl,
      _pulseCtrl,
      _refractionCtrl,
      _prismaCtrl,
    ]) {
      c.dispose();
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Tab switching ──
  void _onTabTap(int index) {
    if (index == _currentTabIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentTabIndex = index);
    _tabCtrl.reset();
    _tabCtrl.forward();
    if (index == 0) {
      _staggerCtrl.reset();
      _staggerCtrl.forward();
    }
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Voice ──
  void _toggleVoice() {
    HapticFeedback.mediumImpact();
    setState(() => _voiceActive = !_voiceActive);
    if (_voiceActive) {
      _sonarCtrl.repeat();
      _waveCtrl.repeat();
      _glowCtrl.repeat(reverse: true);
    } else {
      for (final c in [_sonarCtrl, _waveCtrl, _glowCtrl]) {
        c.stop();
        c.reset();
      }
    }
  }

  bool get _showVoice => _currentTabIndex != 1 && !_sheetOpen;

  String _greet() {
    final int h = DateTime.now().hour;
    if (h < 5) return 'Gute Nacht';
    if (h < 12) return 'Guten Morgen';
    if (h < 18) return 'Guten Nachmittag';
    return 'Guten Abend';
  }

  String _greetEmoji() {
    final int h = DateTime.now().hour;
    if (h < 5) return '🌙';
    if (h < 12) return '☀️';
    if (h < 18) return '🌤️';
    return '🌙';
  }

  String _dateString() {
    final DateTime n = DateTime.now();
    const List<String> d = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const List<String> m = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    return '${d[n.weekday - 1]}, ${n.day}. ${m[n.month - 1]}';
  }

  // ════════════════════════════════════════════════════
  //  CRYSTAL GLASS CARD — No blur, pure transparency
  // ════════════════════════════════════════════════════

  /// Builds a glass card. When Crystal atmosphere is active,
  /// uses zero blur + rainbow edge refraction + specular shine.
  /// Otherwise uses the standard frosted glass.
  Widget _crystalCard({
    required Widget child,
    required double radius,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final Widget card = AnimatedBuilder(
      animation: _refractionCtrl,
      builder: (BuildContext context, Widget? _) {
        final double refraction = _refractionCtrl.value;

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // Crystal: ultra-thin transparent, Normal: frosted
            color: _isCrystal
                ? const Color(0x06FFFFFF)
                : const Color(0x0CFFFFFF),
            boxShadow: [
              if (_isCrystal) ...[
                // Subtle outer shadow
                BoxShadow(
                  color: const Color(0x08000000),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
                // Crystal inner light
                BoxShadow(
                  color: Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.03 + math.sin(refraction * math.pi * 2) * 0.015,
                  ),
                  blurRadius: 1,
                  spreadRadius: 0,
                ),
              ] else ...[
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 40,
                  offset: Offset(0, 10),
                ),
              ],
            ],
          ),
          child: CustomPaint(
            painter: _isCrystal
                ? _CrystalBorderPainter(
                    radius: radius,
                    refraction: refraction,
                    breathVal: _breathCtrl.value,
                  )
                : _GlassBorderPainter(
                    radius: radius,
                    color: const Color(0x10FFFFFF),
                  ),
            child: child,
          ),
        );
      },
    );

    if (_isCrystal) {
      // No blur for crystal — pure transparent glass
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: onTap != null ? _GlassTap(onTap: onTap, child: card) : card,
      );
    } else {
      // Standard frosted glass
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: onTap != null ? _GlassTap(onTap: onTap, child: card) : card,
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════
  //  PROFILE SHEET
  // ════════════════════════════════════════════════════

  void _openProfileSheet() {
    HapticFeedback.mediumImpact();
    setState(() => _sheetOpen = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) => _buildProfileSheet(ctx),
    ).then((_) {
      if (mounted) setState(() => _sheetOpen = false);
    });
  }

  Widget _buildProfileSheet(BuildContext ctx) {
    final double bp = MediaQuery.of(ctx).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _isCrystal
            // Crystal: no blur, pure glass
            ? _buildProfileContent(ctx, bp)
            // Normal: frosted
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: _buildProfileContent(ctx, bp),
              ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext ctx, double bp) {
    return AnimatedBuilder(
      animation: _refractionCtrl,
      builder: (BuildContext context, Widget? _) {
        return Container(
          decoration: BoxDecoration(
            color: _isCrystal
                ? const Color(0x0A0C0C14) // Nearly invisible
                : const Color(0xCC0C0C14),
            borderRadius: BorderRadius.circular(32),
          ),
          child: CustomPaint(
            painter: _isCrystal
                ? _CrystalBorderPainter(
                    radius: 32,
                    refraction: _refractionCtrl.value,
                    breathVal: _breathCtrl.value,
                  )
                : _GlassBorderPainter(
                    radius: 32,
                    color: const Color(0x14FFFFFF),
                  ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _isCrystal
                          ? const Color(0x20FFFFFF)
                          : const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Avatar
                  _buildSheetAvatar(),
                  const SizedBox(height: 16),
                  Text(
                    _userName.isNotEmpty ? _userName : 'User',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: _isCrystal ? AppColors.white95 : AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isCrystal
                          ? const Color(0x08FFFFFF)
                          : const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: _isCrystal
                          ? Border.all(
                              color: const Color(0x0CFFFFFF),
                              width: 0.5,
                            )
                          : null,
                    ),
                    child: const Text(
                      'Free Plan',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sheetRow(
                    Icons.person_outline_rounded,
                    'Profil bearbeiten',
                    false,
                    ctx,
                  ),
                  _sheetRow(
                    Icons.palette_outlined,
                    'Atmosphäre wählen',
                    false,
                    ctx,
                  ),
                  _sheetRow(Icons.diamond_outlined, 'Companion', false, ctx),
                  _sheetRow(
                    Icons.bookmark_border_rounded,
                    'Gespeichert',
                    false,
                    ctx,
                  ),
                  _sheetRow(Icons.tune_rounded, 'Einstellungen', false, ctx),
                  const SizedBox(height: 12),
                  Container(
                    height: 0.5,
                    decoration: BoxDecoration(
                      gradient: _isCrystal ? _rainbowLineGradient(0.06) : null,
                      color: _isCrystal ? null : const Color(0x0CFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sheetRow(Icons.logout_rounded, 'Abmelden', true, ctx),
                  SizedBox(height: bp + 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetAvatar() {
    return AnimatedBuilder(
      animation: _prismaCtrl,
      builder: (BuildContext context, Widget? _) {
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _isCrystal
                ? SweepGradient(
                    startAngle: _prismaCtrl.value * math.pi * 2,
                    colors: const [
                      Color(0xFFFF6B6B),
                      Color(0xFFFFE66D),
                      Color(0xFF4ECDC4),
                      Color(0xFF45B7D1),
                      Color(0xFFA78BFA),
                      Color(0xFFF472B6),
                      Color(0xFFFF6B6B),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_pri, _sec, const Color(0xFF06B6D4)],
                  ),
            boxShadow: [
              BoxShadow(
                color: _isCrystal
                    ? const Color(0x25FFFFFF)
                    : Color.fromRGBO(_pri.red, _pri.green, _pri.blue, 0.45),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetRow(IconData icon, String label, bool danger, BuildContext ctx) {
    return _GlassTap(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(ctx);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0x1AFF453A)
                    : _isCrystal
                    ? const Color(0x06FFFFFF)
                    : const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: _isCrystal
                    ? Border.all(color: const Color(0x08FFFFFF), width: 0.5)
                    : null,
              ),
              child: Icon(
                icon,
                size: 18,
                color: danger ? const Color(0xFFFF453A) : AppColors.white50,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: danger ? const Color(0xFFFF453A) : AppColors.white80,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: danger ? const Color(0x55FF453A) : const Color(0x22FFFFFF),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final double bp = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (BuildContext c, Widget? ch) => CustomPaint(
                  size: Size.infinite,
                  painter: _AuroraBgPainter(
                    t: _bgCtrl.value,
                    pri: _pri,
                    sec: _sec,
                    glo: _glo,
                    isCrystal: _isCrystal,
                  ),
                ),
              ),
            ),

            // Crystal: Animated refraction overlay
            if (_isCrystal)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _prismaCtrl,
                  builder: (BuildContext context, Widget? _) => CustomPaint(
                    painter: _CrystalRefractionOverlay(
                      t: _prismaCtrl.value,
                      breath: _breathCtrl.value,
                    ),
                  ),
                ),
              ),

            // Pages
            PageView(
              controller: _pageCtrl,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (int i) {
                if (i != _currentTabIndex) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentTabIndex = i);
                  _tabCtrl.reset();
                  _tabCtrl.forward();
                  if (i == 0) {
                    _staggerCtrl.reset();
                    _staggerCtrl.forward();
                  }
                }
              },
              children: [
                _buildHomeTab(),
                const NexiiaChatScreen(),
                const SolveScreen(),
                const NexiiaHorizonCalendar(),
                _buildFokusTab(),
              ],
            ),

            // Entity
            if (_showVoice)
              Positioned(left: 18, bottom: bp + 92, child: _buildEntity()),

            // Nav
            Positioned(
              left: 14,
              right: 14,
              bottom: bp + 8,
              child: _buildNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  HOME TAB
  // ════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    final double tp = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _greetCtrl,
        _staggerCtrl,
        _shimmerCtrl,
        _logoBreathCtrl,
      ]),
      builder: (BuildContext context, Widget? _) {
        final double greet = Curves.easeOutCubic.transform(_greetCtrl.value);
        final double stagger = _staggerCtrl.value;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(20, tp + 16, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Opacity(
                opacity: greet,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - greet)),
                  child: Row(
                    children: [
                      Expanded(child: _buildLogoHeader()),
                      const SizedBox(width: 12),
                      _buildProfileAvatar(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Greeting
              Opacity(
                opacity: greet,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - greet)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greet(),
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.white30,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$_userName ',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              color: AppColors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            _greetEmoji(),
                            style: const TextStyle(fontSize: 26),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              _staggerChild(stagger, 0, _buildQuickActions()),
              const SizedBox(height: 24),

              // Day Card
              _staggerChild(stagger, 1, _buildDayCard()),
              const SizedBox(height: 14),

              // Insight
              _staggerChild(stagger, 2, _buildInsightCard()),
              const SizedBox(height: 14),

              // Status
              _staggerChild(stagger, 3, _buildStatusCard()),
            ],
          ),
        );
      },
    );
  }

  // ── Logo ──
  Widget _buildLogoHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerCtrl, _logoBreathCtrl]),
      builder: (BuildContext context, Widget? child) {
        final double shimmerPos = _shimmerCtrl.value * 3.0 - 1.0;
        final double breathScale = 0.98 + _logoBreathCtrl.value * 0.02;

        return Transform.scale(
          scale: breathScale,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              if (_isCrystal) {
                // Rainbow prisma shimmer for crystal
                return LinearGradient(
                  begin: Alignment(-1.0 + shimmerPos, -0.3),
                  end: Alignment(1.0 + shimmerPos, 0.3),
                  colors: const [
                    Color(0xFFFF6B6B),
                    Color(0xFFFFE66D),
                    Color(0xFF4ECDC4),
                    Color(0xFF45B7D1),
                    Color(0xFFA78BFA),
                    Color(0xFFF472B6),
                    Color(0xFFFF6B6B),
                  ],
                ).createShader(bounds);
              }
              return LinearGradient(
                begin: Alignment(-1.0 + shimmerPos, -0.3),
                end: Alignment(1.0 + shimmerPos, 0.3),
                colors: [_pri, _sec, const Color(0xFF06B6D4), _pri, _sec],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: const Text(
              'nexiia',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Profile Avatar ──
  Widget _buildProfileAvatar() {
    return _GlassTap(
      onTap: _openProfileSheet,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseCtrl, _prismaCtrl]),
        builder: (BuildContext context, Widget? _) {
          final double pulse = _pulseCtrl.value;

          return SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring
                Opacity(
                  opacity: (1.0 - pulse) * 0.3,
                  child: Container(
                    width: 48 + pulse * 12,
                    height: 48 + pulse * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isCrystal
                            ? Color.fromRGBO(255, 255, 255, 0.3 * (1 - pulse))
                            : Color.fromRGBO(
                                _pri.red,
                                _pri.green,
                                _pri.blue,
                                0.4,
                              ),
                        width: 1.0 * (1.0 - pulse),
                      ),
                    ),
                  ),
                ),
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isCrystal
                        ? SweepGradient(
                            startAngle: _prismaCtrl.value * math.pi * 2,
                            colors: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFFFE66D),
                              Color(0xFF4ECDC4),
                              Color(0xFF45B7D1),
                              Color(0xFFA78BFA),
                              Color(0xFFF472B6),
                              Color(0xFFFF6B6B),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_pri, _sec, const Color(0xFF06B6D4)],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: _isCrystal
                            ? const Color(0x20FFFFFF)
                            : Color.fromRGBO(
                                _pri.red,
                                _pri.green,
                                _pri.blue,
                                0.35,
                              ),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Online dot
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF30D158),
                      border: Border.all(color: AppColors.background, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x6030D158), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 14),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _breathCtrl,
                builder: (BuildContext context, Widget? _) {
                  return Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: _isCrystal
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.6 + _breathCtrl.value * 0.2,
                                ),
                                Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.2 + _breathCtrl.value * 0.1,
                                ),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_pri, _sec],
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'SCHNELLZUGRIFF',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 105,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            children: [
              _quickAction(
                Icons.bolt_rounded,
                'Chat',
                _isCrystal ? const Color(0xFFE8ECF4) : _pri,
                () => _onTabTap(1),
              ),
              const SizedBox(width: 10),
              _quickAction(
                Icons.auto_awesome_rounded,
                'Lösen',
                _isCrystal ? const Color(0xFFC4D0E0) : _sec,
                () => _onTabTap(2),
              ),
              const SizedBox(width: 10),
              _quickAction(
                Icons.event_note_rounded,
                'Kalender',
                _isCrystal ? const Color(0xFFB0C4DE) : const Color(0xFF06B6D4),
                () => _onTabTap(3),
              ),
              const SizedBox(width: 10),
              _quickAction(
                Icons.hexagon_rounded,
                'Fokus',
                _isCrystal ? const Color(0xFFD4BEE0) : const Color(0xFFF472B6),
                () => _onTabTap(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return _GlassTap(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _refractionCtrl,
        builder: (BuildContext context, Widget? _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _isCrystal
                ? _buildCrystalQuickAction(icon, label, color)
                : BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: _buildQuickActionInner(icon, label, color),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCrystalQuickAction(IconData icon, String label, Color color) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x04FFFFFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: CustomPaint(
        painter: _CrystalBorderPainter(
          radius: 22,
          refraction: _refractionCtrl.value,
          breathVal: _breathCtrl.value,
        ),
        child: _buildQuickActionContent(icon, label, color),
      ),
    );
  }

  Widget _buildQuickActionInner(IconData icon, String label, Color color) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color.fromRGBO(color.red, color.green, color.blue, 0.12),
          width: 0.5,
        ),
      ),
      child: _buildQuickActionContent(icon, label, color),
    );
  }

  Widget _buildQuickActionContent(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  _isCrystal ? 0.1 : 0.2,
                ),
                Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  _isCrystal ? 0.04 : 0.08,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  _isCrystal ? 0.1 : 0.25,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            color: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Day Card ──
  Widget _buildDayCard() {
    return _crystalCard(
      radius: 26,
      padding: const EdgeInsets.all(22),
      onTap: () => _onTabTap(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                Icons.wb_sunny_rounded,
                _isCrystal ? const Color(0xFFE8ECF4) : _pri,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dein Tag',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dateString(),
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _statusPill(),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniStat(
                'Aufgaben',
                '0',
                _isCrystal ? const Color(0xFFE8ECF4) : _pri,
              ),
              const SizedBox(width: 12),
              _miniStat('Erledigt', '0', const Color(0xFF30D158)),
              const SizedBox(width: 12),
              _miniStat(
                'Fokus',
                '—',
                _isCrystal ? const Color(0xFFD4BEE0) : const Color(0xFFF472B6),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Starte einen Chat um deinen Tag zu planen und Aufgaben zu organisieren.',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white40,
              fontSize: 14,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 20),
          _buildCTAButton(),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _breathCtrl,
      builder: (BuildContext context, Widget? _) {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  0.15 + _breathCtrl.value * 0.05,
                ),
                Color.fromRGBO(color.red, color.green, color.blue, 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: _isCrystal
                ? Border.all(color: const Color(0x08FFFFFF), width: 0.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.12),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        );
      },
    );
  }

  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x2030D158), Color(0x1030D158)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3030D158), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF30D158),
              boxShadow: [BoxShadow(color: Color(0x6030D158), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Bereit',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: Color(0xFF30D158),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(
            color.red,
            color.green,
            color.blue,
            _isCrystal ? 0.03 : 0.06,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color.fromRGBO(
              color.red,
              color.green,
              color.blue,
              _isCrystal ? 0.06 : 0.1,
            ),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                color: AppColors.white30,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return _GlassTap(
      onTap: () => _onTabTap(1),
      child: AnimatedBuilder(
        animation: _prismaCtrl,
        builder: (BuildContext context, Widget? _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            decoration: BoxDecoration(
              gradient: _isCrystal
                  ? SweepGradient(
                      center: Alignment.center,
                      startAngle: _prismaCtrl.value * math.pi * 2,
                      colors: const [
                        Color(0xCCFF6B6B),
                        Color(0xCCFFE66D),
                        Color(0xCC4ECDC4),
                        Color(0xCC45B7D1),
                        Color(0xCCA78BFA),
                        Color(0xCCF472B6),
                        Color(0xCCFF6B6B),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_pri, _sec],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isCrystal
                      ? const Color(0x20FFFFFF)
                      : Color.fromRGBO(_pri.red, _pri.green, _pri.blue, 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
                SizedBox(width: 8),
                Text(
                  'Chat starten',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Insight Card ──
  Widget _buildInsightCard() {
    return _crystalCard(
      radius: 26,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.auto_graph_rounded, const Color(0xFFF5A623)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Täglicher Impuls',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5A623),
                  boxShadow: [
                    BoxShadow(color: Color(0x60F5A623), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (Rect bounds) => LinearGradient(
              colors: _isCrystal
                  ? const [Color(0xDDFFFFFF), Color(0x77FFFFFF)]
                  : const [Color(0xCCFFFFFF), Color(0x88FFFFFF)],
            ).createShader(bounds),
            child: const Text(
              '„Der beste Zeitpunkt anzufangen war gestern.\nDer zweitbeste ist jetzt."',
              style: TextStyle(
                fontFamily: 'Satoshi',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.6,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Card ──
  Widget _buildStatusCard() {
    return _crystalCard(
      radius: 26,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          _iconBox(
            Icons.memory_rounded,
            _isCrystal ? const Color(0xFFE8ECF4) : _pri,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nexiia Companion',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.white80,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _breathCtrl,
                      builder: (BuildContext context, Widget? _) {
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCrystal
                                ? Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    0.6 + _breathCtrl.value * 0.3,
                                  )
                                : _pri,
                            boxShadow: [
                              BoxShadow(
                                color: _isCrystal
                                    ? Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        0.2 + _breathCtrl.value * 0.1,
                                      )
                                    : Color.fromRGBO(
                                        _pri.red,
                                        _pri.green,
                                        _pri.blue,
                                        0.5,
                                      ),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online • Bereit für dich',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: _isCrystal
                ? const Color(0x30FFFFFF)
                : Color.fromRGBO(_pri.red, _pri.green, _pri.blue, 0.4),
            size: 14,
          ),
        ],
      ),
    );
  }

  // ── Stagger Helper ──
  Widget _staggerChild(double stagger, int index, Widget child) {
    final double delay = index * 0.15;
    final double progress = ((stagger - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final double eased = Curves.easeOutCubic.transform(progress);
    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - eased)),
        child: child,
      ),
    );
  }

  // ── Rainbow gradient helper ──
  LinearGradient _rainbowLineGradient(double opacity) {
    return LinearGradient(
      colors: [
        Color.fromRGBO(255, 107, 107, opacity),
        Color.fromRGBO(255, 230, 109, opacity),
        Color.fromRGBO(78, 205, 196, opacity),
        Color.fromRGBO(69, 183, 209, opacity),
        Color.fromRGBO(167, 139, 250, opacity),
        Color.fromRGBO(244, 114, 182, opacity),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  //  FOKUS TAB
  // ════════════════════════════════════════════════════

  Widget _buildFokusTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _breathCtrl,
            builder: (BuildContext c, Widget? ch) => Transform.scale(
              scale: 0.92 + _breathCtrl.value * 0.08,
              child: ch,
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: _isCrystal
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x14FFFFFF), Color(0x08FFFFFF)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x28F472B6), Color(0x14F472B6)],
                      ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isCrystal
                      ? const Color(0x10FFFFFF)
                      : const Color(0x20F472B6),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isCrystal
                        ? const Color(0x15FFFFFF)
                        : const Color(0x30F472B6),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Icon(
                Icons.hexagon_rounded,
                color: _isCrystal
                    ? const Color(0xCCFFFFFF)
                    : const Color(0xFFF472B6),
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Fokus',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kommt bald…',
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white30,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  ENTITY (Voice Orb)
  // ════════════════════════════════════════════════════

  Widget _buildEntity() {
    final int pr = _pri.red, pg = _pri.green, pb = _pri.blue;
    final int sr = _sec.red, sg = _sec.green, sb = _sec.blue;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathCtrl,
        _nebulaCtrl,
        _heartbeatCtrl,
        _floatCtrl,
        _sonarCtrl,
        _waveCtrl,
        _glowCtrl,
        _prismaCtrl,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double breath = _breathCtrl.value;
        final double nebula = _nebulaCtrl.value;
        final double hb = _heartbeatCtrl.value;
        final double floatY = math.sin(_floatCtrl.value * math.pi * 2) * 1.8;
        final double sonar = _voiceActive ? _sonarCtrl.value : 0.0;
        final double wave = _voiceActive ? _waveCtrl.value : 0.0;
        final double glow = _voiceActive ? _glowCtrl.value : 0.0;
        final double hbP = _heartbeatPulse(hb);
        final double prisma = _prismaCtrl.value;
        final double baseSize = _voiceActive ? 56.0 : 44.0;
        final double scale = 0.96 + breath * 0.04;
        final double canvasSize = baseSize + 60;

        return GestureDetector(
          onTap: _toggleVoice,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: SizedBox(
              width: canvasSize,
              height: canvasSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sonar rings
                  if (_voiceActive)
                    ...List.generate(3, (int i) {
                      final double delay = i * 0.33;
                      final double phase = ((sonar + delay) % 1.0);
                      final double ringSize = baseSize + phase * 40;
                      final double opacity =
                          (1.0 - phase) * 0.15 * (0.5 + glow * 0.5);

                      return CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _isCrystal
                            ? _CrystalSonarPainter(
                                size: ringSize,
                                phase: phase,
                                prisma: prisma,
                                strokeWidth: 0.8 * (1.0 - phase),
                              )
                            : _DiamondRingPainter(
                                size: ringSize,
                                color: Color.fromRGBO(pr, pg, pb, opacity),
                                strokeWidth: 0.8 * (1.0 - phase),
                              ),
                      );
                    }),

                  // Freq lines
                  if (_voiceActive)
                    CustomPaint(
                      size: Size(canvasSize, canvasSize),
                      painter: _EntityFreqPainter(
                        t: wave,
                        glow: glow,
                        entitySize: baseSize,
                        pri: _pri,
                        isCrystal: _isCrystal,
                        prisma: prisma,
                      ),
                    ),

                  // Shadow
                  Container(
                    width: baseSize + 20,
                    height: baseSize + 20,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: _isCrystal
                              ? Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  _voiceActive ? 0.12 + glow * 0.08 : 0.05,
                                )
                              : Color.fromRGBO(
                                  pr,
                                  pg,
                                  pb,
                                  _voiceActive
                                      ? 0.2 + glow * 0.15 + hbP * 0.05
                                      : 0.08 + hbP * 0.04,
                                ),
                          blurRadius: _voiceActive ? 40 : 24,
                          spreadRadius: _voiceActive ? 8 : 2,
                        ),
                        BoxShadow(
                          color: _isCrystal
                              ? Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  _voiceActive ? 0.06 : 0.02,
                                )
                              : Color.fromRGBO(
                                  sr,
                                  sg,
                                  sb,
                                  _voiceActive ? 0.1 + glow * 0.08 : 0.04,
                                ),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),

                  // Glass diamond shell
                  Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _voiceActive ? 14 : 12,
                        ),
                        child: _isCrystal
                            // Crystal: NO blur, pure glass
                            ? _buildEntityShell(
                                baseSize,
                                glow,
                                hbP,
                                breath,
                                pr,
                                pg,
                                pb,
                                prisma,
                              )
                            // Normal: frosted
                            : BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 40,
                                  sigmaY: 40,
                                ),
                                child: _buildEntityShell(
                                  baseSize,
                                  glow,
                                  hbP,
                                  breath,
                                  pr,
                                  pg,
                                  pb,
                                  prisma,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Inner nebula
                  Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _voiceActive ? 12 : 10,
                        ),
                        child: SizedBox(
                          width: baseSize - 6,
                          height: baseSize - 6,
                          child: CustomPaint(
                            painter: _isCrystal
                                ? _CrystalNebulaPainter(
                                    rotation: nebula * math.pi * 2,
                                    intensity: _voiceActive
                                        ? 0.25 + glow * 0.15
                                        : 0.12 + hbP * 0.04,
                                    prisma: prisma,
                                  )
                                : _NebulaPainter(
                                    rotation: nebula * math.pi * 2,
                                    intensity: _voiceActive
                                        ? 0.35 + glow * 0.2
                                        : 0.18 + hbP * 0.06,
                                    pri: _pri,
                                    sec: _sec,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Core spark
                  Container(
                    width: _voiceActive ? 7 + glow * 2 : 5 + hbP * 1.5,
                    height: _voiceActive ? 7 + glow * 2 : 5 + hbP * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(
                        255,
                        255,
                        255,
                        _voiceActive ? 0.8 + glow * 0.2 : 0.55 + hbP * 0.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(
                            255,
                            255,
                            255,
                            _voiceActive ? 0.4 + glow * 0.2 : 0.15 + hbP * 0.1,
                          ),
                          blurRadius: _voiceActive ? 12 : 8,
                          spreadRadius: _voiceActive ? 3 : 1,
                        ),
                        BoxShadow(
                          color: _isCrystal
                              ? Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  _voiceActive ? 0.15 : 0.05,
                                )
                              : Color.fromRGBO(
                                  pr,
                                  pg,
                                  pb,
                                  _voiceActive ? 0.3 : 0.1,
                                ),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),

                  // Specular highlight
                  Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Align(
                        alignment: const Alignment(0, -0.65),
                        child: Container(
                          width: baseSize * 0.5,
                          height: 1.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0x00FFFFFF),
                                Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.18 + breath * 0.08,
                                ),
                                const Color(0x00FFFFFF),
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
          ),
        );
      },
    );
  }

  Widget _buildEntityShell(
    double baseSize,
    double glow,
    double hbP,
    double breath,
    int pr,
    int pg,
    int pb,
    double prisma,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: baseSize,
      height: baseSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_voiceActive ? 14 : 12),
        color: _isCrystal
            ? Color.fromRGBO(
                255,
                255,
                255,
                _voiceActive ? 0.03 + glow * 0.02 : 0.02,
              )
            : Color.fromRGBO(
                255,
                255,
                255,
                _voiceActive ? 0.06 + glow * 0.03 : 0.04,
              ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _isCrystal
            ? _CrystalEntityBorderPainter(
                radius: _voiceActive ? 14.0 : 12.0,
                breath: breath,
                active: _voiceActive,
                prisma: prisma,
                glow: glow,
              )
            : _AccentLinePainter(
                radius: _voiceActive ? 14.0 : 12.0,
                borderColor: _voiceActive
                    ? Color.fromRGBO(255, 255, 255, 0.14 + glow * 0.08)
                    : Color.fromRGBO(255, 255, 255, 0.1 + hbP * 0.03),
                accentColor: Color.fromRGBO(
                  pr,
                  pg,
                  pb,
                  _voiceActive ? 0.3 + glow * 0.2 : 0.15 + hbP * 0.1,
                ),
                breath: breath,
                active: _voiceActive,
              ),
      ),
    );
  }

  double _heartbeatPulse(double t) {
    if (t < 0.15) return math.sin(t / 0.15 * math.pi);
    if (t < 0.25) return 0;
    if (t < 0.4) return math.sin((t - 0.25) / 0.15 * math.pi) * 0.7;
    return 0;
  }

  // ════════════════════════════════════════════════════
  //  NAVIGATION BAR
  // ════════════════════════════════════════════════════

  Widget _buildNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: _isCrystal
          // Crystal: no blur
          ? _buildNavContent()
          // Normal: frosted
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: _buildNavContent(),
            ),
    );
  }

  Widget _buildNavContent() {
    return AnimatedBuilder(
      animation: _refractionCtrl,
      builder: (BuildContext context, Widget? _) {
        return Container(
          height: 72,
          decoration: BoxDecoration(
            color: _isCrystal
                ? const Color(0x080A0A10)
                : const Color(0xCC0A0A10),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _isCrystal
                ? _CrystalBorderPainter(
                    radius: 26,
                    refraction: _refractionCtrl.value,
                    breathVal: _breathCtrl.value,
                  )
                : _GlassBorderPainter(
                    radius: 26,
                    color: const Color(0x12FFFFFF),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.house_rounded, 'Home'),
                _navItem(1, Icons.bolt_rounded, 'Chat'),
                _navItem(2, Icons.auto_awesome_rounded, 'Lösen'),
                _navItem(3, Icons.event_note_rounded, 'Planer'),
                _navItem(4, Icons.hexagon_rounded, 'Fokus'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool active = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: AnimatedBuilder(
          animation: _prismaCtrl,
          builder: (BuildContext context, Widget? _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Active indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: active ? 22 : 0,
                  height: active ? 3 : 0,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    gradient: active
                        ? (_isCrystal
                              ? LinearGradient(
                                  colors: _rainbowColors(_prismaCtrl.value),
                                )
                              : LinearGradient(colors: [_pri, _sec]))
                        : null,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _isCrystal
                                  ? const Color(0x40FFFFFF)
                                  : Color.fromRGBO(
                                      _pri.red,
                                      _pri.green,
                                      _pri.blue,
                                      0.7,
                                    ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
                // Icon
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    if (active) {
                      if (_isCrystal) {
                        return SweepGradient(
                          startAngle: _prismaCtrl.value * math.pi * 2,
                          colors: const [
                            Color(0xFFFF6B6B),
                            Color(0xFFFFE66D),
                            Color(0xFF4ECDC4),
                            Color(0xFFA78BFA),
                            Color(0xFFFF6B6B),
                          ],
                        ).createShader(bounds);
                      }
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_pri, _sec],
                      ).createShader(bounds);
                    }
                    return const LinearGradient(
                      colors: [AppColors.white30, AppColors.white30],
                    ).createShader(bounds);
                  },
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? (_isCrystal ? AppColors.white80 : _pri)
                        : AppColors.white30,
                    letterSpacing: active ? 0.2 : 0,
                  ),
                  child: Text(label),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Color> _rainbowColors(double offset) {
    // Shift rainbow based on animation offset
    final List<Color> base = const [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFFA78BFA),
      Color(0xFFF472B6),
    ];
    final int shift = (offset * base.length).floor() % base.length;
    return [...base.sublist(shift), ...base.sublist(0, shift)];
  }
}

// ═══════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════

// ── Standard Glass Border ──
class _GlassBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  const _GlassBorderPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter old) => old.color != color;
}

// ── Crystal Border — Rainbow refraction edge ──
class _CrystalBorderPainter extends CustomPainter {
  final double radius;
  final double refraction;
  final double breathVal;

  const _CrystalBorderPainter({
    required this.radius,
    required this.refraction,
    required this.breathVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );

    // Outer ultra-thin white line
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.06 + breathVal * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Inner rainbow refraction line
    final double inset = 1.5;
    final RRect inner = RRect.fromLTRBR(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
      Radius.circular(radius - 1),
    );

    final double opacity = 0.08 + breathVal * 0.04;

    final Paint refractionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..shader = SweepGradient(
        startAngle: refraction * math.pi * 2,
        colors: [
          Color.fromRGBO(255, 107, 107, opacity),
          Color.fromRGBO(255, 230, 109, opacity * 1.2),
          Color.fromRGBO(78, 205, 196, opacity),
          Color.fromRGBO(69, 183, 209, opacity * 1.1),
          Color.fromRGBO(167, 139, 250, opacity),
          Color.fromRGBO(244, 114, 182, opacity * 0.9),
          Color.fromRGBO(255, 107, 107, opacity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(inner, refractionPaint);

    // Specular top highlight
    final double specW = size.width * 0.4;
    final double specX =
        (size.width - specW) / 2 + math.sin(refraction * math.pi * 2) * 10;

    canvas.drawLine(
      Offset(specX, 0.5),
      Offset(specX + specW, 0.5),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FFFFFF),
            Color.fromRGBO(255, 255, 255, 0.12 + breathVal * 0.06),
            const Color(0x00FFFFFF),
          ],
        ).createShader(Rect.fromLTWH(specX, 0, specW, 1))
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalBorderPainter old) =>
      old.refraction != refraction || old.breathVal != breathVal;
}

// ── Crystal Refraction Overlay — Full screen light caustics ──
class _CrystalRefractionOverlay extends CustomPainter {
  final double t;
  final double breath;

  const _CrystalRefractionOverlay({required this.t, required this.breath});

  @override
  void paint(Canvas canvas, Size size) {
    final double tau = math.pi * 2;

    // Floating light caustics
    for (int i = 0; i < 5; i++) {
      final double phase = t * tau + i * 1.3;
      final double cx = size.width * (0.2 + i * 0.15) + math.sin(phase) * 30;
      final double cy =
          size.height * (0.15 + i * 0.16) + math.cos(phase * 0.7) * 25;
      final double r = 60 + math.sin(phase * 0.5 + i) * 20;
      final double opacity =
          0.015 + breath * 0.008 + math.sin(phase).abs() * 0.005;

      // Rainbow caustic
      final List<Color> colors = [
        Color.fromRGBO(255, 107, 107, opacity),
        Color.fromRGBO(255, 230, 109, opacity),
        Color.fromRGBO(78, 205, 196, opacity),
        Color.fromRGBO(167, 139, 250, opacity),
      ];

      final Offset center = Offset(cx, cy);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [colors[i % colors.length], const Color(0x00000000)],
          ).createShader(Rect.fromCircle(center: center, radius: r))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
      );
    }

    // Diagonal light streak
    final double streakX = size.width * (0.3 + math.sin(t * tau) * 0.2);
    final double streakOpacity = 0.02 + breath * 0.01;

    canvas.save();
    canvas.translate(streakX, 0);
    canvas.rotate(math.pi / 6);
    canvas.drawRect(
      Rect.fromLTWH(-1, -size.height * 0.2, 2, size.height * 0.8),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0x00FFFFFF),
                Color.fromRGBO(255, 255, 255, streakOpacity),
                Color.fromRGBO(255, 255, 255, streakOpacity * 1.5),
                Color.fromRGBO(255, 255, 255, streakOpacity),
                const Color(0x00FFFFFF),
              ],
            ).createShader(
              Rect.fromLTWH(-1, -size.height * 0.2, 2, size.height * 0.8),
            ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrystalRefractionOverlay old) =>
      old.t != t || old.breath != breath;
}

// ── Crystal Entity Border — Rainbow sweep on diamond ──
class _CrystalEntityBorderPainter extends CustomPainter {
  final double radius;
  final double breath;
  final bool active;
  final double prisma;
  final double glow;

  const _CrystalEntityBorderPainter({
    required this.radius,
    required this.breath,
    required this.active,
    required this.prisma,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );

    // Outer white
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.fromRGBO(
          255,
          255,
          255,
          active ? 0.08 + glow * 0.04 : 0.05 + breath * 0.02,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Inner rainbow sweep
    final double inset = 2.5;
    final RRect inner = RRect.fromLTRBR(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
      Radius.circular(radius - 1.5),
    );

    final double opacity = active
        ? 0.18 + glow * 0.1 + breath * 0.06
        : 0.08 + breath * 0.04;

    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..shader = SweepGradient(
          startAngle: prisma * math.pi * 2,
          colors: [
            Color.fromRGBO(255, 107, 107, opacity),
            Color.fromRGBO(255, 230, 109, opacity * 1.2),
            Color.fromRGBO(78, 205, 196, opacity),
            Color.fromRGBO(69, 183, 209, opacity * 1.1),
            Color.fromRGBO(167, 139, 250, opacity),
            Color.fromRGBO(244, 114, 182, opacity * 0.9),
            Color.fromRGBO(255, 107, 107, opacity),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalEntityBorderPainter old) =>
      old.breath != breath ||
      old.active != active ||
      old.prisma != prisma ||
      old.glow != glow;
}

// ── Crystal Nebula — White prisma swirl inside entity ──
class _CrystalNebulaPainter extends CustomPainter {
  final double rotation;
  final double intensity;
  final double prisma;

  const _CrystalNebulaPainter({
    required this.rotation,
    required this.intensity,
    required this.prisma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: rotation,
          endAngle: rotation + math.pi * 2,
          colors: [
            Color.fromRGBO(255, 255, 255, intensity),
            Color.fromRGBO(200, 220, 255, intensity * 0.7),
            Color.fromRGBO(255, 200, 200, intensity * 0.4),
            Color.fromRGBO(200, 255, 220, intensity * 0.3),
            Color.fromRGBO(220, 200, 255, intensity * 0.5),
            Color.fromRGBO(255, 255, 255, intensity),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalNebulaPainter old) =>
      old.rotation != rotation || old.intensity != intensity;
}

// ── Crystal Sonar — Rainbow diamond rings ──
class _CrystalSonarPainter extends CustomPainter {
  final double size;
  final double phase;
  final double prisma;
  final double strokeWidth;

  const _CrystalSonarPainter({
    required this.size,
    required this.phase,
    required this.prisma,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double cx = canvasSize.width / 2;
    final double cy = canvasSize.height / 2;
    final double half = size / 2;
    final double cornerR = size * 0.22;
    final double opacity = (1.0 - phase) * 0.12;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-cx, -cy);

    canvas.drawRRect(
      RRect.fromLTRBR(
        cx - half,
        cy - half,
        cx + half,
        cy + half,
        Radius.circular(cornerR),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = SweepGradient(
          startAngle: prisma * math.pi * 2,
          colors: [
            Color.fromRGBO(255, 107, 107, opacity),
            Color.fromRGBO(255, 230, 109, opacity),
            Color.fromRGBO(78, 205, 196, opacity),
            Color.fromRGBO(167, 139, 250, opacity),
            Color.fromRGBO(255, 107, 107, opacity),
          ],
        ).createShader(Rect.fromLTWH(cx - half, cy - half, size, size)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrystalSonarPainter old) =>
      old.size != size || old.phase != phase || old.prisma != prisma;
}

// ── Aurora Background ──
class _AuroraBgPainter extends CustomPainter {
  final double t;
  final Color pri;
  final Color sec;
  final Color glo;
  final bool isCrystal;

  const _AuroraBgPainter({
    required this.t,
    required this.pri,
    required this.sec,
    required this.glo,
    required this.isCrystal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.background,
    );

    final double tau = math.pi * 2;

    if (isCrystal) {
      // Crystal: very subtle white/silver aurora blobs
      _blob(
        canvas,
        size.width * 0.15 + math.sin(t * tau) * 35,
        size.height * 0.08 + math.cos(t * tau) * 20,
        180,
        const Color(0x08FFFFFF),
      );
      _blob(
        canvas,
        size.width * 0.85 + math.cos(t * tau + 1.2) * 30,
        size.height * 0.3 + math.sin(t * tau + 1.2) * 25,
        150,
        const Color(0x06C4D0E0),
      );
      _blob(
        canvas,
        size.width * 0.5 + math.sin(t * tau + 2.5) * 20,
        size.height * 0.55 + math.cos(t * tau + 2.5) * 22,
        130,
        const Color(0x06E8ECF4),
      );
      _blob(
        canvas,
        size.width * 0.25 + math.cos(t * tau + 3.8) * 18,
        size.height * 0.8 + math.sin(t * tau + 3.8) * 16,
        100,
        const Color(0x04D4BEE0),
      );
    } else {
      // Normal atmospheres
      _blob(
        canvas,
        size.width * 0.12 + math.sin(t * tau) * 40,
        size.height * 0.06 + math.cos(t * tau) * 25,
        180,
        Color.fromRGBO(pri.red, pri.green, pri.blue, 0.10),
      );
      _blob(
        canvas,
        size.width * 0.88 + math.cos(t * tau + 1.2) * 35,
        size.height * 0.28 + math.sin(t * tau + 1.2) * 30,
        150,
        Color.fromRGBO(sec.red, sec.green, sec.blue, 0.08),
      );
      _blob(
        canvas,
        size.width * 0.5 + math.sin(t * tau + 2.5) * 25,
        size.height * 0.55 + math.cos(t * tau + 2.5) * 25,
        130,
        const Color(0x1206B6D4),
      );
      _blob(
        canvas,
        size.width * 0.25 + math.cos(t * tau + 3.8) * 20,
        size.height * 0.82 + math.sin(t * tau + 3.8) * 18,
        110,
        const Color(0x0CF472B6),
      );
      _blob(
        canvas,
        size.width * 0.7 + math.sin(t * tau + 5.0) * 15,
        size.height * 0.42 + math.cos(t * tau + 5.0) * 20,
        100,
        Color.fromRGBO(glo.red, glo.green, glo.blue, 0.06),
      );
    }
  }

  void _blob(Canvas canvas, double cx, double cy, double r, Color color) {
    final Offset center = Offset(cx, cy);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, const Color(0x00000000)],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraBgPainter old) => old.t != t;
}

// ── Accent Line Painter (for non-crystal entity) ──
class _AccentLinePainter extends CustomPainter {
  final double radius;
  final Color borderColor;
  final Color accentColor;
  final double breath;
  final bool active;

  const _AccentLinePainter({
    required this.radius,
    required this.borderColor,
    required this.accentColor,
    required this.breath,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final double inset = 3.0;
    final RRect inner = RRect.fromLTRBR(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
      Radius.circular(radius - 2),
    );

    final double opacity = active ? 0.3 + breath * 0.15 : 0.12 + breath * 0.08;

    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = SweepGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, opacity),
            Color.fromRGBO(
              accentColor.red,
              accentColor.green,
              accentColor.blue,
              opacity * 1.5,
            ),
            Color.fromRGBO(255, 255, 255, opacity * 0.5),
            Color.fromRGBO(
              accentColor.red,
              accentColor.green,
              accentColor.blue,
              opacity * 0.8,
            ),
            Color.fromRGBO(255, 255, 255, opacity),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _AccentLinePainter old) =>
      old.breath != breath ||
      old.active != active ||
      old.accentColor != accentColor;
}

// ── Nebula (non-crystal) ──
class _NebulaPainter extends CustomPainter {
  final double rotation;
  final double intensity;
  final Color pri;
  final Color sec;

  const _NebulaPainter({
    required this.rotation,
    required this.intensity,
    required this.pri,
    required this.sec,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: rotation,
          endAngle: rotation + math.pi * 2,
          colors: [
            Color.fromRGBO(pri.red, pri.green, pri.blue, intensity),
            Color.fromRGBO(sec.red, sec.green, sec.blue, intensity * 0.8),
            Color.fromRGBO(6, 182, 212, intensity * 0.5),
            Color.fromRGBO(pri.red, pri.green, pri.blue, intensity * 0.4),
            Color.fromRGBO(sec.red, sec.green, sec.blue, intensity * 0.7),
            Color.fromRGBO(pri.red, pri.green, pri.blue, intensity),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter old) =>
      old.rotation != rotation || old.intensity != intensity;
}

// ── Diamond Ring (non-crystal sonar) ──
class _DiamondRingPainter extends CustomPainter {
  final double size;
  final Color color;
  final double strokeWidth;

  const _DiamondRingPainter({
    required this.size,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double cx = canvasSize.width / 2;
    final double cy = canvasSize.height / 2;
    final double half = size / 2;
    final double cornerR = size * 0.22;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-cx, -cy);
    canvas.drawRRect(
      RRect.fromLTRBR(
        cx - half,
        cy - half,
        cx + half,
        cy + half,
        Radius.circular(cornerR),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiamondRingPainter old) =>
      old.size != size || old.color != color;
}

// ── Entity Frequency Lines ──
class _EntityFreqPainter extends CustomPainter {
  final double t;
  final double glow;
  final double entitySize;
  final Color pri;
  final bool isCrystal;
  final double prisma;

  const _EntityFreqPainter({
    required this.t,
    required this.glow,
    required this.entitySize,
    required this.pri,
    required this.isCrystal,
    required this.prisma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double dist = entitySize / 2 + 10;
    const int count = 12;

    for (int i = 0; i < count; i++) {
      final double angle = (i / count) * math.pi * 2 - math.pi / 2;
      final double phase = t * math.pi * 2;
      final double f1 = math.sin(phase * 2.0 + i * 0.7) * 6.0;
      final double f2 = math.cos(phase * 3.0 + i * 1.1) * 3.0;
      final double amp = (f1 + f2).abs() + 2.0;
      final double startX = cx + math.cos(angle) * dist;
      final double startY = cy + math.sin(angle) * dist;
      final double endX = cx + math.cos(angle) * (dist + amp);
      final double endY = cy + math.sin(angle) * (dist + amp);
      final double thickness = 1.2 + math.sin(phase + i * 0.4).abs() * 0.6;
      final double opacity =
          0.3 + glow * 0.3 + math.sin(phase + i * 0.5).abs() * 0.2;

      Color lineColor;
      if (isCrystal) {
        // Rainbow cycle per line
        final double hue = ((prisma + i / count) % 1.0);
        final List<Color> rainbow = const [
          Color(0xFFFF6B6B),
          Color(0xFFFFE66D),
          Color(0xFF4ECDC4),
          Color(0xFF45B7D1),
          Color(0xFFA78BFA),
          Color(0xFFF472B6),
        ];
        final int idx = (hue * rainbow.length).floor() % rainbow.length;
        final Color base = rainbow[idx];
        lineColor = Color.fromRGBO(
          base.red,
          base.green,
          base.blue,
          opacity * 0.7,
        );
      } else {
        final int mixR = ((255 + pri.red) ~/ 2);
        final int mixG = ((255 + pri.green) ~/ 2);
        final int mixB = ((255 + pri.blue) ~/ 2);
        lineColor = Color.fromRGBO(mixR, mixG, mixB, opacity);
      }

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = lineColor
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EntityFreqPainter old) =>
      old.t != t || old.glow != glow || old.prisma != prisma;
}

// ── Glass Tap — Premium haptic press ──
class _GlassTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassTap({required this.child, required this.onTap});
  @override
  State<_GlassTap> createState() => _GlassTapState();
}

class _GlassTapState extends State<_GlassTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (BuildContext c, Widget? ch) => Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _opacity.value, child: ch),
        ),
        child: widget.child,
      ),
    );
  }
}
