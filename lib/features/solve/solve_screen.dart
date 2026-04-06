// ═══════════════════════════════════════════════════════════════════════════
//  NEXIIA ORBITAL SOLVER — solve_screen.dart
//  Lösche alles in der Datei und ersetze mit diesem Code
//  TEIL 1 von 2
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

// ─── Haptics Helper ──────────────────────────────────────────────────────
class _Haptics {
  static void selection() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
}

// ─── Enums ───────────────────────────────────────────────────────────────
enum NodeCategory {
  core, problem, cause, effect, solution, action,
  note, reminder, focus, journal, resource, positive,
}

enum ConnType { causal, effect, solution, action, relation }

// ─── Category Config ─────────────────────────────────────────────────────
class _CatCfg {
  final String label;
  final String sub;
  final Color color;
  final IconData icon;
  final int layer;
  const _CatCfg(this.label, this.sub, this.color, this.icon, this.layer);
}

final Map<NodeCategory, _CatCfg> _cfg = {
  NodeCategory.core: const _CatCfg(
    'Kern', 'Dein Mittelpunkt',
    Color(0xFF0A84FF), Icons.person_rounded, 0,
  ),
  NodeCategory.problem: const _CatCfg(
    'Problem', 'Herausforderung hinzufügen',
    Color(0xFFFF453A), Icons.warning_amber_rounded, 1,
  ),
  NodeCategory.cause: const _CatCfg(
    'Ursache', 'Woher kommt es?',
    Color(0xFFBF5AF2), Icons.psychology_rounded, 1,
  ),
  NodeCategory.effect: const _CatCfg(
    'Auswirkung', 'Was bewirkt es?',
    Color(0xFFFF6482), Icons.show_chart_rounded, 1,
  ),
  NodeCategory.solution: const _CatCfg(
    'Lösung', 'Lösungsansatz beschreiben',
    Color(0xFF30D158), Icons.lightbulb_rounded, 2,
  ),
  NodeCategory.action: const _CatCfg(
    'Maßnahme', 'Konkreter nächster Schritt',
    Color(0xFFFFD60A), Icons.rocket_launch_rounded, 2,
  ),
  NodeCategory.note: const _CatCfg(
    'Notiz', 'Gedanken festhalten',
    Color(0xFF64D2FF), Icons.sticky_note_2_rounded, 2,
  ),
  NodeCategory.reminder: const _CatCfg(
    'Erinnerung', 'Datum & Uhrzeit wählen',
    Color(0xFFFF9F0A), Icons.alarm_rounded, 2,
  ),
  NodeCategory.focus: const _CatCfg(
    'Fokus', 'Worauf konzentrierst du dich?',
    Color(0xFFAC8E68), Icons.center_focus_strong_rounded, 1,
  ),
  NodeCategory.journal: const _CatCfg(
    'Tagebuch', 'Tageseintrag schreiben',
    Color(0xFF5E5CE6), Icons.auto_stories_rounded, 2,
  ),
  NodeCategory.resource: const _CatCfg(
    'Ressource', 'Was steht dir zur Verfügung?',
    Color(0xFF06C7BE), Icons.inventory_2_rounded, 2,
  ),
  NodeCategory.positive: const _CatCfg(
    'Positives', 'Was funktioniert bereits?',
    Color(0xFF30D158), Icons.thumb_up_alt_rounded, 2,
  ),
};

// ─── Data Models ─────────────────────────────────────────────────────────
class ONode {
  String id;
  String label;
  String description;
  NodeCategory category;
  int layer;
  double angle;
  double elevation;
  double radius;
  double nodeSize;
  double importance;
  Color color;
  IconData icon;
  DateTime? reminderDate;
  TimeOfDay? reminderTime;
  String? journal;
  DateTime created;

  ONode({
    required this.id,
    required this.label,
    this.description = '',
    required this.category,
    required this.layer,
    required this.angle,
    this.elevation = 0,
    required this.radius,
    this.nodeSize = 12,
    required this.color,
    this.importance = 0.7,
    required this.icon,
    this.reminderDate,
    this.reminderTime,
    this.journal,
  }) : created = DateTime.now();
}

class Conn {
  final String from;
  final String to;
  double strength;
  ConnType type;
  Conn(this.from, this.to, this.strength, this.type);
}

class _Proj {
  final Offset pos;
  final double depth;
  final double scale;
  const _Proj(this.pos, this.depth, this.scale);
}

class _PNode {
  final ONode node;
  final _Proj p;
  const _PNode(this.node, this.p);
}

class _Part {
  final double x;
  final double y;
  final double sz;
  final double spd;
  final double op;
  final double ph;
  const _Part(this.x, this.y, this.sz, this.spd, this.op, this.ph);
}

// ═════════════════════════════════════════════════════════════════════════
//  MAIN WIDGET
// ═════════════════════════════════════════════════════════════════════════
class SolveScreen extends StatefulWidget {
  const SolveScreen({super.key});

  @override
  State<SolveScreen> createState() => _SolveScreenState();
}

class _SolveScreenState extends State<SolveScreen>
    with TickerProviderStateMixin {
  // ── 3D Transform ──
  double _rotY = 0.4;
  double _rotX = 0.15;
  double _zoom = 1.0;
  double _tZoom = 1.0;
  double _bZoom = 1.0;
  bool _dragging = false;
  double _vx = 0;
  double _vy = 0;

  // ── State ──
  String? _selId;
  final Set<int> _visLayers = {0, 1, 2};
  bool _showConn = true;
  bool _showLbl = true;
  bool _autoRot = true;

  // ── Animation Controllers ──
  late AnimationController _pulseC;
  late AnimationController _rotC;
  late AnimationController _entryC;
  late AnimationController _flowC;
  late AnimationController _partC;

  // ── Data ──
  final List<ONode> _nodes = [];
  final List<Conn> _conns = [];
  final List<_Part> _parts = [];
  String _userName = 'Mein Name';
  int _idC = 0;
  Timer? _lpTimer;
  String? _lpId;

  @override
  void initState() {
    super.initState();
    _initAnim();
    _buildCore();
    _genParts();
  }

  void _initAnim() {
    _pulseC = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotC = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _entryC = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..forward();

    _flowC = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _partC = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotC.addListener(_frame);
  }

  void _frame() {
    if (!mounted) return;
    setState(() {
      if (!_dragging) {
        if (_autoRot && _vx.abs() < 0.001 && _vy.abs() < 0.001) {
          _rotY += 0.0008;
        }
        _rotY += _vx;
        _rotX = (_rotX + _vy).clamp(-0.8, 0.8);
        _vx *= 0.96;
        _vy *= 0.96;
      }
      _zoom += (_tZoom - _zoom) * 0.1;
    });
  }

  void _genParts() {
    final r = math.Random(42);
    for (int i = 0; i < 50; i++) {
      _parts.add(_Part(
        r.nextDouble(),
        r.nextDouble(),
        r.nextDouble() * 1.8 + 0.5,
        r.nextDouble() * 0.25 + 0.1,
        r.nextDouble() * 0.35 + 0.08,
        r.nextDouble() * math.pi * 2,
      ));
    }
  }

  void _buildCore() {
    _nodes.add(ONode(
      id: 'core',
      label: _userName,
      description: 'Dein persönlicher Mittelpunkt',
      category: NodeCategory.core,
      layer: 0,
      angle: 0,
      radius: 0,
      nodeSize: 22,
      color: _cfg[NodeCategory.core]!.color,
      importance: 1.0,
      icon: Icons.person_rounded,
    ));
  }

  // ═══════════════════ NODE MANAGEMENT ════════════════════════════════
  String _nid() => 'n_${_idC++}';

  ONode _addNode(NodeCategory cat, {String? parent}) {
    final c = _cfg[cat]!;
    final ln = _nodes.where((n) => n.layer == c.layer).toList();
    final cnt = ln.length;
    final ang = cnt * (math.pi * 2 / math.max(cnt + 1, 6)) +
        math.Random().nextDouble() * 0.3;
    final elev = math.sin(ang * 2) * 0.28;

    double rad;
    double sz;
    switch (c.layer) {
      case 0:
        rad = 0;
        sz = 22;
        break;
      case 1:
        rad = 0.38;
        sz = 14;
        break;
      default:
        rad = 0.68;
        sz = 11;
        break;
    }

    final node = ONode(
      id: _nid(),
      label: c.label,
      description: c.sub,
      category: cat,
      layer: c.layer,
      angle: ang,
      elevation: elev,
      radius: rad,
      nodeSize: sz,
      color: c.color,
      importance: 0.7,
      icon: c.icon,
    );

    setState(() {
      _nodes.add(node);
      _visLayers.add(c.layer);

      if (parent != null) {
        final ct = switch (cat) {
          NodeCategory.solution || NodeCategory.positive => ConnType.solution,
          NodeCategory.action => ConnType.action,
          NodeCategory.effect => ConnType.effect,
          _ => ConnType.causal,
        };
        _conns.add(Conn(parent, node.id, 0.7, ct));
      } else {
        _conns.add(Conn('core', node.id, 0.6, ConnType.relation));
      }
      _redistLayer(c.layer);
    });
    return node;
  }

  void _redistLayer(int l) {
    final ln = _nodes.where((n) => n.layer == l && n.id != 'core').toList();
    for (int i = 0; i < ln.length; i++) {
      ln[i].angle = (i / ln.length) * math.pi * 2;
      ln[i].elevation = math.sin(ln[i].angle * 2) * 0.28;
    }
  }

  void _removeNode(String id) {
    if (id == 'core') return;
    setState(() {
      _nodes.removeWhere((n) => n.id == id);
      _conns.removeWhere((c) => c.from == id || c.to == id);
      if (_selId == id) _selId = null;
      for (int l = 1; l <= 2; l++) {
        _redistLayer(l);
      }
    });
  }

  // ═══════════════════ GESTURES ══════════════════════════════════════
  void _onSS(ScaleStartDetails d) {
    _dragging = true;
    _bZoom = _tZoom;
    _vx = 0;
    _vy = 0;
  }

  void _onSU(ScaleUpdateDetails d) {
    setState(() {
      _rotY += d.focalPointDelta.dx * 0.008;
      _rotX = (_rotX + d.focalPointDelta.dy * 0.008).clamp(-0.8, 0.8);
      _vx = d.focalPointDelta.dx * 0.0015;
      _vy = d.focalPointDelta.dy * 0.0015;
      if (d.pointerCount >= 2) {
        _tZoom = (_bZoom * d.horizontalScale).clamp(0.4, 3.0);
      }
    });
  }

  void _onSE(ScaleEndDetails d) => _dragging = false;

  String? _hit(Offset pos) {
    final sz = MediaQuery.of(context).size;
    final ctr = Offset(sz.width / 2, sz.height * 0.42);
    final br = sz.width * 0.38;
    String? hid;
    double md = 48;
    for (final n in _nodes) {
      if (!_visLayers.contains(n.layer)) continue;
      final p = _proj(n, ctr, br);
      if (p == null) continue;
      final d = (pos - p.pos).distance;
      if (d < md) {
        md = d;
        hid = n.id;
      }
    }
    return hid;
  }

  void _onTap(TapUpDetails d) {
    _lpTimer?.cancel();
    final hid = _hit(d.localPosition);
    if (hid != null && _selId == hid) {
      final node = _nodes.firstWhere((n) => n.id == hid);
      _showNodeOptions(node);
    } else if (hid != null) {
      _Haptics.selection();
      setState(() => _selId = hid);
    } else {
      setState(() => _selId = null);
    }
  }

  void _onLPS(LongPressStartDetails d) {
    final hid = _hit(d.localPosition);
    if (hid == null) return;
    _lpId = hid;
    _lpTimer?.cancel();
    _lpTimer = Timer(const Duration(milliseconds: 1670), () {
      if (_lpId != null) {
        _Haptics.heavy();
        _showRename(_lpId!);
      }
    });
  }

  void _onLPE(LongPressEndDetails d) {
    _lpTimer?.cancel();
    _lpId = null;
  }

  void _reset() {
    _Haptics.light();
    setState(() {
      _tZoom = 1.0;
      _rotY = 0.4;
      _rotX = 0.15;
      _vx = 0;
      _vy = 0;
      _selId = null;
      _visLayers.addAll({0, 1, 2});
    });
  }

  // ═══════════════════ 3D PROJECTION ═════════════════════════════════
  _Proj? _proj(ONode node, Offset ctr, double br) {
    final e = _entryC.value;
    final ld = (node.layer * 0.2).clamp(0.0, 0.6);
    final le = Curves.easeOutBack
        .transform(((e - ld) / (1.0 - ld)).clamp(0.0, 1.0));
    final r = node.radius * le +
        math.sin(_pulseC.value * math.pi * 2 + node.angle) * 0.012;

    double x = r * math.cos(node.angle);
    double y = node.elevation * 0.5 * le;
    double z = r * math.sin(node.angle);

    final cy = math.cos(_rotY);
    final sy = math.sin(_rotY);
    final nx = x * cy - z * sy;
    final nz = x * sy + z * cy;

    final cx = math.cos(_rotX);
    final sx = math.sin(_rotX);
    final ny = y * cx - nz * sx;
    final fz = y * sx + nz * cx;

    const fl = 1.8;
    final sc = fl / (fl + fz);
    if (fz > fl - 0.1) return null;

    return _Proj(
      Offset(
        ctr.dx + nx * br * _zoom * sc,
        ctr.dy - ny * br * _zoom * sc,
      ),
      fz,
      sc,
    );
  }

  // ═══════════════════ HELPER WIDGETS ════════════════════════════════
  Widget _glass({
    required Widget child,
    double blur = 30,
    Color bg = const Color(0x12FFFFFF),
    Color bdr = const Color(0x18FFFFFF),
    double rad = 20,
    EdgeInsets? pad,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rad),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: pad ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(rad),
              border: Border.all(color: bdr, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Future<T?> _sheet<T>({required Widget Function(BuildContext) b}) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (c) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: b(c),
      ),
    );
  }

  Widget _handle() => Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _btn(String t, Color bg, Color fg, VoidCallback f) => GestureDetector(
        onTap: () {
          _Haptics.light();
          f();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: bg,
            border: Border.all(color: fg.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              t,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      );

  String _fmtD(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  // ═══════════════════ ADD MENU ══════════════════════════════════════
  void _showAddMenu() {
    _Haptics.medium();
    final cats = [
      NodeCategory.problem,
      NodeCategory.cause,
      NodeCategory.effect,
      NodeCategory.solution,
      NodeCategory.action,
      NodeCategory.note,
      NodeCategory.reminder,
      NodeCategory.focus,
      NodeCategory.journal,
      NodeCategory.resource,
      NodeCategory.positive,
    ];

    _sheet(
      b: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              Text(
                'Hinzufügen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Was möchtest du hinzufügen?',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...cats.map((cat) {
                final c = _cfg[cat]!;
                return GestureDetector(
                  onTap: () {
                    _Haptics.selection();
                    Navigator.pop(ctx);
                    if (cat == NodeCategory.reminder) {
                      _addReminderFlow();
                    } else if (cat == NodeCategory.journal) {
                      _addJournalFlow();
                    } else {
                      final n = _addNode(cat, parent: _selId);
                      setState(() => _selId = n.id);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: c.color.withValues(alpha: 0.07),
                      border: Border.all(
                        color: c.color.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(c.icon, size: 18, color: c.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              Text(
                                c.sub,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: c.color.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ RENAME (long press 1.67s) ═════════════════════
  void _showRename(String nid) {
    final node = _nodes.firstWhere((n) => n.id == nid);
    final ctrl = TextEditingController(text: node.label);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: _glass(
          blur: 50,
          bg: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
          bdr: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          pad: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Umbenennen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Name eingeben…',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: node.color.withValues(alpha: 0.5),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _btn(
                        'Abbrechen',
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.5),
                        () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _btn(
                        'Speichern',
                        node.color.withValues(alpha: 0.2),
                        node.color,
                        () {
                          setState(() {
                            node.label = ctrl.text.trim().isEmpty
                                ? node.label
                                : ctrl.text.trim();
                            if (nid == 'core') _userName = node.label;
                          });
                          Navigator.pop(ctx);
                        },
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

  // ═══════════════════ NODE OPTIONS ══════════════════════════════════
  void _showNodeOptions(ONode node) {
    _Haptics.medium();
    final isCore = node.id == 'core';

    _sheet(
      b: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: node.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(node.icon, size: 22, color: node.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (node.description.isNotEmpty)
                          Text(
                            node.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _optTile(ctx, 'Beschreiben', 'Beschreibung bearbeiten',
                  Icons.edit_rounded, const Color(0xFF0A84FF),
                  () => _editDesc(node)),
              _optTile(ctx, 'KI fragen', 'nexiia um Hilfe bitten',
                  Icons.auto_awesome_rounded, const Color(0xFFBF5AF2),
                  () => _askAI(node)),
              if (!isCore) ...[
                _optTile(ctx, 'Verbinden', 'Mit anderem Knoten verknüpfen',
                    Icons.link_rounded, const Color(0xFF64D2FF),
                    () => _connectNode(node)),
                _optTile(ctx, 'Relevanz', 'Wichtigkeit anpassen',
                    Icons.tune_rounded, const Color(0xFFFFD60A),
                    () => _changeImp(node)),
                _optTile(ctx, 'Erinnerung', 'Erinnerung setzen',
                    Icons.alarm_add_rounded, const Color(0xFFFF9F0A),
                    () => _setReminder(node)),
                _optTile(ctx, 'Entfernen', 'Löschen',
                    Icons.delete_outline_rounded, const Color(0xFFFF453A),
                    () => _confirmDel(node)),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optTile(BuildContext ctx, String t, String s, IconData i, Color c,
      VoidCallback f) {
    return GestureDetector(
      onTap: () {
        _Haptics.selection();
        Navigator.pop(ctx);
        Future.delayed(const Duration(milliseconds: 200), f);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: c.withValues(alpha: 0.06),
        ),
        child: Row(
          children: [
            Icon(i, size: 19, color: c),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    s,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════ EDIT DESCRIPTION ══════════════════════════════
  void _editDesc(ONode node) {
    final ctrl = TextEditingController(text: node.description);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: _glass(
          blur: 50,
          bg: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
          bdr: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          pad: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beschreibung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Beschreibe „${node.label}"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Was genau meinst du damit?',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: node.color.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _btn(
                        'Abbrechen',
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.5),
                        () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _btn(
                        'Speichern',
                        node.color.withValues(alpha: 0.2),
                        node.color,
                        () {
                          setState(
                              () => node.description = ctrl.text.trim());
                          Navigator.pop(ctx);
                        },
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

  // ═══════════════════ ASK AI ════════════════════════════════════════
  void _askAI(ONode node) {
    _sheet(
      b: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    const Color(0xFFBF5AF2).withValues(alpha: 0.15),
                    const Color(0xFF0A84FF).withValues(alpha: 0.1),
                  ]),
                  border: Border.all(
                    color: const Color(0xFFBF5AF2).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBF5AF2), Color(0xFF0A84FF)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'nexiia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          Text(
                            'KI-Assistent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse: „${node.label}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'nexiia analysiert dein Problem und schlägt '
                      'personalisierte Lösungen vor. Diese Funktion '
                      'wird mit Sprachsteuerung verfügbar.\n\n'
                      '🎙️ Sprachsteuerung kommt bald…',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            const Color(0xFFBF5AF2).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFFBF5AF2)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic_rounded,
                              size: 16,
                              color: const Color(0xFFBF5AF2)
                                  .withValues(alpha: 0.6)),
                          const SizedBox(width: 8),
                          Text(
                            'Bald: „Hey nexiia, hilf mir…"',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFBF5AF2)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _btn(
                'Schließen',
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.5),
                () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ CONNECT NODE ══════════════════════════════════
  void _connectNode(ONode node) {
    final others =
        _nodes.where((n) => n.id != node.id && n.id != 'core').toList();
    if (others.isEmpty) return;

    _sheet(
      b: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              Text(
                'Verbinden mit…',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 14),
              ...others.map((o) => GestureDetector(
                    onTap: () {
                      _Haptics.selection();
                      final exists = _conns.any((c) =>
                          (c.from == node.id && c.to == o.id) ||
                          (c.from == o.id && c.to == node.id));
                      if (!exists) {
                        setState(() => _conns.add(
                            Conn(node.id, o.id, 0.6, ConnType.relation)));
                      }
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: o.color.withValues(alpha: 0.06),
                      ),
                      child: Row(
                        children: [
                          Icon(o.icon, size: 18, color: o.color),
                          const SizedBox(width: 12),
                          Text(
                            o.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ IMPORTANCE ════════════════════════════════════
  void _changeImp(ONode node) {
    double v = node.importance;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: _glass(
          blur: 50,
          bg: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
          bdr: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          pad: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (_, setL) => Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Relevanz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(v * 100).round()}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: node.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: node.color,
                      inactiveTrackColor:
                          Colors.white.withValues(alpha: 0.06),
                      thumbColor: node.color,
                      overlayColor: node.color.withValues(alpha: 0.1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: v,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (nv) => setL(() => v = nv),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _btn(
                    'Übernehmen',
                    node.color.withValues(alpha: 0.2),
                    node.color,
                    () {
                      setState(() {
                        node.importance = v;
                        node.nodeSize = 8 + v * 14;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════ REMINDER ══════════════════════════════════════
  void _setReminder(ONode node) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, ch) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFFF9F0A),
            surface: const Color(0xFF1C1C1E),
            onSurface: Colors.white.withValues(alpha: 0.9),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
        ),
        child: ch!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (c, ch) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFFF9F0A),
            surface: const Color(0xFF1C1C1E),
            onSurface: Colors.white.withValues(alpha: 0.9),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
        ),
        child: ch!,
      ),
    );
    if (time == null || !mounted) return;

    _Haptics.medium();
    setState(() {
      node.reminderDate = date;
      node.reminderTime = time;
      node.description =
          '⏰ ${_fmtD(date)} um ${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    });
  }

  void _addReminderFlow() async {
    final n = _addNode(NodeCategory.reminder, parent: _selId);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _setReminder(n);
  }

  // ═══════════════════ JOURNAL ═══════════════════════════════════════
  void _addJournalFlow() {
    final node = _addNode(NodeCategory.journal, parent: _selId);
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: _glass(
          blur: 50,
          bg: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
          bdr: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          pad: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        size: 22, color: Color(0xFF5E5CE6)),
                    const SizedBox(width: 10),
                    Text(
                      'Tagebuch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _fmtD(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLines: 6,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Wie geht es dir heute?',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _btn(
                        'Abbrechen',
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.5),
                        () {
                          if (ctrl.text.trim().isEmpty) {
                            _removeNode(node.id);
                          }
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _btn(
                        'Speichern',
                        const Color(0xFF5E5CE6).withValues(alpha: 0.2),
                        const Color(0xFF5E5CE6),
                        () {
                          setState(() {
                            node.journal = ctrl.text.trim();
                            node.description =
                                ctrl.text.trim().length > 40
                                    ? '${ctrl.text.trim().substring(0, 40)}…'
                                    : ctrl.text.trim();
                            node.label =
                                'Eintrag ${_fmtD(DateTime.now())}';
                          });
                          Navigator.pop(ctx);
                        },
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

  // ═══════════════════ DELETE CONFIRM ════════════════════════════════
  void _confirmDel(ONode node) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: _glass(
          blur: 50,
          bg: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
          bdr: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          pad: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFF453A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 26, color: Color(0xFFFF453A)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Entfernen?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '„${node.label}" wird gelöscht.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _btn(
                        'Abbrechen',
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.5),
                        () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _btn(
                        'Entfernen',
                        const Color(0xFFFF453A).withValues(alpha: 0.2),
                        const Color(0xFFFF453A),
                        () {
                          _removeNode(node.id);
                          Navigator.pop(ctx);
                        },
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

// HIER ENDET TEIL 1 — TEIL 2 DIREKT DARUNTER EINFÜGEN (KEIN ENTER DAZWISCHEN)// ═══════════════════════════════════════════════════════════════════════════
// TEIL 2 — ALLES AB HIER BIS DATEIENDE
// ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Listener(
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) {
              setState(() {
                _tZoom =
                    (_tZoom + e.scrollDelta.dy * -0.001).clamp(0.4, 3.0);
              });
            }
          },
          child: GestureDetector(
            onScaleStart: _onSS,
            onScaleUpdate: _onSU,
            onScaleEnd: _onSE,
            onTapUp: _onTap,
            onLongPressStart: _onLPS,
            onLongPressEnd: _onLPE,
            onDoubleTap: _reset,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.3),
                      radius: 1.2,
                      colors: [
                        Color(0xFF151520),
                        Color(0xFF0A0A0F),
                        Color(0xFF050508),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: Listenable.merge(
                      [_pulseC, _rotC, _entryC, _flowC, _partC],
                    ),
                    builder: (context, _) => CustomPaint(
                      painter: _OPainter(
                        nodes: _nodes,
                        conns: _conns,
                        parts: _parts,
                        rotY: _rotY,
                        rotX: _rotX,
                        zoom: _zoom,
                        selId: _selId,
                        visLayers: _visLayers,
                        showConn: _showConn,
                        showLbl: _showLbl,
                        pulse: _pulseC.value,
                        entry: _entryC.value,
                        flow: _flowC.value,
                        partT: _partC.value,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
                Positioned(
                  top: pad.top + 12,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mein Universum',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color:
                                    Colors.white.withValues(alpha: 0.95),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_nodes.length} Elemente · ${_conns.length} Verbindungen',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _iconBtn(Icons.refresh_rounded, _reset),
                    ],
                  ),
                ),
                Positioned(
                  top: pad.top + 68,
                  left: 20,
                  right: 20,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _layerChip(0, 'Kern', const Color(0xFF0A84FF)),
                        _layerChip(1, 'Probleme', const Color(0xFFFF453A)),
                        _layerChip(2, 'Lösungen', const Color(0xFF30D158)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: pad.bottom + 120,
                  child: Column(
                    children: [
                      _iconBtn(
                        _autoRot
                            ? Icons.motion_photos_on_rounded
                            : Icons.motion_photos_paused_rounded,
                        () => setState(() => _autoRot = !_autoRot),
                        active: _autoRot,
                      ),
                      const SizedBox(height: 8),
                      _iconBtn(
                        _showConn
                            ? Icons.share_rounded
                            : Icons.share_outlined,
                        () => setState(() => _showConn = !_showConn),
                        active: _showConn,
                      ),
                      const SizedBox(height: 8),
                      _iconBtn(
                        _showLbl
                            ? Icons.label_rounded
                            : Icons.label_off_rounded,
                        () => setState(() => _showLbl = !_showLbl),
                        active: _showLbl,
                      ),
                      const SizedBox(height: 16),
                      _iconBtn(
                        Icons.add_rounded,
                        () => setState(() {
                          _tZoom = (_tZoom + 0.2).clamp(0.4, 3.0);
                        }),
                      ),
                      const SizedBox(height: 4),
                      _iconBtn(
                        Icons.remove_rounded,
                        () => setState(() {
                          _tZoom = (_tZoom - 0.2).clamp(0.4, 3.0);
                        }),
                      ),
                    ],
                  ),
                ),
                if (_selId != null) _buildDetail(),
                Positioned(
                  bottom: pad.bottom + 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _showAddMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xFF0A84FF)
                              .withValues(alpha: 0.12),
                          border: Border.all(
                            color: const Color(0xFF0A84FF)
                                .withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A84FF)
                                  .withValues(alpha: 0.12),
                              blurRadius: 30,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Color(0xFF0A84FF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hinzufügen',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A84FF)
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: pad.bottom + 68,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zoom: ${(_zoom * 100).round()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.2),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 10,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Text(
                        '1.67s halten = umbenennen',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.2),
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildDetail() {
    final node = _nodes.firstWhere((n) => n.id == _selId!);
    final rc =
        _conns.where((c) => c.from == node.id || c.to == node.id).length;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 110,
      left: 20,
      right: 75,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (_, v, ch) => Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: Opacity(opacity: v, child: ch),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withValues(alpha: 0.06),
                border:
                    Border.all(color: node.color.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: node.color.withValues(alpha: 0.08),
                    blurRadius: 25,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: node.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child:
                            Icon(node.icon, size: 18, color: node.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              node.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (node.description.isNotEmpty)
                              Text(
                                node.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white
                                      .withValues(alpha: 0.45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selId = null),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _chip('Ebene ${node.layer}', node.color),
                      const SizedBox(width: 6),
                      _chip('$rc Verb.', Colors.white),
                      const SizedBox(width: 6),
                      _chip(
                          '${(node.importance * 100).round()}%',
                          Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: node.importance,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation(
                        node.color.withValues(alpha: 0.6),
                      ),
                      minHeight: 3,
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

  Widget _chip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: c.withValues(alpha: 0.08),
        ),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 11,
            color: c.withValues(alpha: 0.55),
          ),
        ),
      );

  Widget _layerChip(int i, String l, Color c) {
    final on = _visLayers.contains(i);
    final cnt = _nodes.where((n) => n.layer == i).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _Haptics.selection();
          setState(() {
            if (on && _visLayers.length > 1) {
              _visLayers.remove(i);
            } else {
              _visLayers.add(i);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: on
                ? c.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: on
                  ? c.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: on
                      ? c
                      : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: on
                      ? c
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$cnt',
                style: TextStyle(
                  fontSize: 11,
                  color: on
                      ? c.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData ic, VoidCallback f, {bool active = false}) {
    return GestureDetector(
      onTap: () {
        _Haptics.selection();
        f();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: active
                  ? const Color(0xFF0A84FF).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: active
                    ? const Color(0xFF0A84FF).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              ic,
              size: 18,
              color: active
                  ? const Color(0xFF0A84FF)
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lpTimer?.cancel();
    _pulseC.dispose();
    _rotC.dispose();
    _entryC.dispose();
    _flowC.dispose();
    _partC.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _OPainter extends CustomPainter {
  final List<ONode> nodes;
  final List<Conn> conns;
  final List<_Part> parts;
  final double rotY;
  final double rotX;
  final double zoom;
  final String? selId;
  final Set<int> visLayers;
  final bool showConn;
  final bool showLbl;
  final double pulse;
  final double entry;
  final double flow;
  final double partT;

  const _OPainter({
    required this.nodes,
    required this.conns,
    required this.parts,
    required this.rotY,
    required this.rotX,
    required this.zoom,
    required this.selId,
    required this.visLayers,
    required this.showConn,
    required this.showLbl,
    required this.pulse,
    required this.entry,
    required this.flow,
    required this.partT,
  });

  Color _c(Color base, double a) =>
      base.withValues(alpha: a.clamp(0.0, 1.0));

  Color _w(double a) =>
      Colors.white.withValues(alpha: a.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final baseR = size.width * 0.38;

    _drawParticles(canvas, size);
    _drawGuides(canvas, center, baseR);

    final projected = <String, _PNode>{};
    for (final n in nodes) {
      if (!visLayers.contains(n.layer)) continue;
      final p = _projNode(n, center, baseR);
      if (p != null) {
        projected[n.id] = _PNode(n, p);
      }
    }

    final sorted = projected.values.toList()
      ..sort((a, b) => b.p.depth.compareTo(a.p.depth));

    if (showConn) {
      _drawConns(canvas, projected);
    }

    for (final pn in sorted) {
      _drawNode(canvas, pn);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in parts) {
      final t = (partT + p.ph) % 1.0;
      final x =
          (p.x + math.sin(t * math.pi * 2 + p.ph) * 0.03) * size.width;
      final y = (p.y + t * p.spd * 0.5) % 1.0 * size.height;
      final alpha = p.op * (0.5 + 0.5 * math.sin(t * math.pi * 2));
      paint.color = _w(alpha);
      canvas.drawCircle(Offset(x, y), p.sz, paint);
    }
  }

  void _drawGuides(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int layer = 1; layer <= 2; layer++) {
      if (!visLayers.contains(layer)) continue;
      paint.color = _c(const Color(0xFF0A84FF), 0.06);
      final lr = radius * (layer == 1 ? 0.38 : 0.68) * zoom;

      final path = Path();
      const segs = 80;
      for (int i = 0; i < segs; i++) {
        final a = (i / segs) * math.pi * 2;
        final x = center.dx + math.cos(a) * lr;
        final y = center.dy + math.sin(a) * lr * 0.3;
        if (i == 0) {
          path.moveTo(x, y);
        } else if (i % 2 == 0) {
          path.lineTo(x, y);
        } else {
          path.moveTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawConns(Canvas canvas, Map<String, _PNode> projected) {
    for (final c in conns) {
      final from = projected[c.from];
      final to = projected[c.to];
      if (from == null || to == null) continue;

      final hl = c.from == selId || c.to == selId;
      final avgD = (from.p.depth + to.p.depth) / 2;
      final dAlpha = (1.0 - ((avgD + 1) / 2)).clamp(0.0, 1.0);

      final cc = switch (c.type) {
        ConnType.causal => const Color(0xFFFF453A),
        ConnType.effect => const Color(0xFFFF6482),
        ConnType.solution => const Color(0xFF30D158),
        ConnType.action => const Color(0xFFFFD60A),
        ConnType.relation => Colors.white,
      };

      final alpha = hl
          ? 0.45 * dAlpha
          : 0.08 * dAlpha * c.strength;

      final lp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hl ? 1.8 : 0.8
        ..color = _c(cc, alpha);

      final p1 = from.p.pos;
      final p2 = to.p.pos;
      final mid =
          Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 - 15);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
      canvas.drawPath(path, lp);

      if (hl) {
        final dp = Paint()..color = _c(cc, 0.7 * dAlpha);
        final d1 =
            _quadPt(p1, mid, p2, (flow + c.strength * 0.5) % 1.0);
        canvas.drawCircle(d1, 2.5, dp);
        final d2 = _quadPt(
            p1, mid, p2, (flow + 0.5 + c.strength * 0.5) % 1.0);
        canvas.drawCircle(d2, 2, dp);
      }
    }
  }

  Offset _quadPt(Offset p0, Offset p1, Offset p2, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
      mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
    );
  }

  void _drawNode(Canvas canvas, _PNode pn) {
    final node = pn.node;
    final pos = pn.p.pos;
    final scale = pn.p.scale;
    final depth = pn.p.depth;

    final isSel = node.id == selId;
    final isConn = selId != null &&
        conns.any((cn) =>
            (cn.from == selId && cn.to == node.id) ||
            (cn.to == selId && cn.from == node.id));
    final faded = selId != null && !isSel && !isConn;

    final dAlpha = (1.0 - ((depth + 1) / 2)).clamp(0.0, 1.0);
    final fAlpha = faded ? 0.25 : 1.0;
    final fa = dAlpha * fAlpha;

    final nr = node.nodeSize * scale * zoom;
    if (nr < 2) return;

    // Outer glow
    final gs = nr * (isSel ? 5 : 3) * (0.8 + pulse * 0.2);
    final gp = Paint()
      ..color = _c(node.color, 0.12 * fa)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, gs * 0.6);
    canvas.drawCircle(pos, gs, gp);

    // Ring glow
    if (isSel || node.layer == 0) {
      final rg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _c(node.color, 0.25 * fa * (0.5 + pulse * 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, nr + 6, rg);
    }

    // Body
    final bp = Paint()..color = _c(node.color, 0.85 * fa);
    canvas.drawCircle(pos, nr, bp);

    // Inner highlight
    final ip = Paint()..color = _w(0.45 * fa);
    canvas.drawCircle(
      Offset(pos.dx - nr * 0.2, pos.dy - nr * 0.2),
      nr * 0.3,
      ip,
    );

    // Ring
    final rp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSel ? 2.5 : 1.0
      ..color = isSel ? node.color : _c(node.color, 0.25 * fa);
    canvas.drawCircle(pos, nr + (isSel ? 10 : 3), rp);

    // Selection pulse
    if (isSel) {
      final sp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _c(node.color, 0.35 * (1 - pulse));
      canvas.drawCircle(pos, nr + 10 + pulse * 20, sp);
    }

    // Label
    if (showLbl && depth < 0.6 && nr > 4) {
      final fontSize = (12.0 * scale).clamp(8.0, 14.0);

      final ts = TextStyle(
        fontSize: fontSize,
        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        color: _w(0.85 * fa),
        letterSpacing: -0.2,
      );

      final tp = TextPainter(
        text: TextSpan(text: node.label, style: ts),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 120);

      final tbr = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + nr + 14),
          width: tp.width + 12,
          height: tp.height + 6,
        ),
        const Radius.circular(6),
      );
      final tbp = Paint()
        ..color = _c(const Color(0xFF0A0A0F), 0.7 * fa);
      canvas.drawRRect(tbr, tbp);

      tp.paint(
        canvas,
        Offset(
          pos.dx - tp.width / 2,
          pos.dy + nr + 14 - tp.height / 2,
        ),
      );
    }
  }

  _Proj? _projNode(ONode node, Offset ctr, double br) {
    final ld = (node.layer * 0.2).clamp(0.0, 0.6);
    final le = Curves.easeOutBack
        .transform(((entry - ld) / (1.0 - ld)).clamp(0.0, 1.0));
    final r = node.radius * le +
        math.sin(pulse * math.pi * 2 + node.angle) * 0.012;

    double x = r * math.cos(node.angle);
    double y = node.elevation * 0.5 * le;
    double z = r * math.sin(node.angle);

    final cy = math.cos(rotY);
    final sy = math.sin(rotY);
    final nx = x * cy - z * sy;
    final nz = x * sy + z * cy;

    final cx = math.cos(rotX);
    final sx = math.sin(rotX);
    final ny = y * cx - nz * sx;
    final fz = y * sx + nz * cx;

    const fl = 1.8;
    final sc = fl / (fl + fz);
    if (fz > fl - 0.1) return null;

    return _Proj(
      Offset(
        ctr.dx + nx * br * zoom * sc,
        ctr.dy - ny * br * zoom * sc,
      ),
      fz,
      sc,
    );
  }

  @override
  bool shouldRepaint(covariant _OPainter old) => true;
}